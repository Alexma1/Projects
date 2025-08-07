"""
Lambda Function Manager
This Lambda function scans for and deletes outdated Lambda functions based on configurable criteria.
"""

import boto3
import json
import logging
import os
from datetime import datetime, timezone, timedelta
from typing import Dict, List, Any
import re

# Configure logging
logger = logging.getLogger()
logger.setLevel(getattr(logging, os.environ.get('LOG_LEVEL', 'INFO')))

# Initialize AWS clients
lambda_client = boto3.client('lambda')
cloudwatch_client = boto3.client('cloudwatch')


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main Lambda handler function.
    
    Args:
        event: Lambda event data
        context: Lambda context object
        
    Returns:
        Dict containing execution results
    """
    try:
        logger.info("Starting Lambda function cleanup process")
        
        # Get configuration from environment variables
        retention_days = int(os.environ.get('RETENTION_DAYS', 30))
        environment = os.environ.get('ENVIRONMENT', 'dev')
        
        logger.info(f"Configuration: retention_days={retention_days}, environment={environment}")
        
        # Get all Lambda functions
        functions = get_all_lambda_functions()
        logger.info(f"Found {len(functions)} Lambda functions to analyze")
        
        # Filter functions for deletion
        functions_to_delete = identify_outdated_functions(functions, retention_days)
        logger.info(f"Identified {len(functions_to_delete)} functions for deletion")
        
        # Delete outdated functions
        deletion_results = delete_outdated_functions(functions_to_delete)
        
        # Send metrics to CloudWatch
        send_metrics(len(functions), len(functions_to_delete), len(deletion_results['successful']))
        
        # Prepare response
        response = {
            'statusCode': 200,
            'body': {
                'message': 'Lambda cleanup completed successfully',
                'total_functions': len(functions),
                'functions_analyzed': len(functions_to_delete),
                'functions_deleted': len(deletion_results['successful']),
                'deletion_errors': len(deletion_results['failed']),
                'deleted_functions': deletion_results['successful'],
                'failed_deletions': deletion_results['failed']
            }
        }
        
        logger.info(f"Cleanup completed: {response['body']}")
        return response
        
    except Exception as e:
        logger.error(f"Error in lambda_handler: {str(e)}")
        return {
            'statusCode': 500,
            'body': {
                'message': 'Error during Lambda cleanup',
                'error': str(e)
            }
        }


def get_all_lambda_functions() -> List[Dict[str, Any]]:
    """
    Retrieve all Lambda functions in the current AWS account and region.
    
    Returns:
        List of Lambda function metadata
    """
    functions = []
    paginator = lambda_client.get_paginator('list_functions')
    
    try:
        for page in paginator.paginate():
            for function in page['Functions']:
                # Get additional function details
                function_details = get_function_details(function['FunctionName'])
                if function_details:
                    functions.append(function_details)
                    
    except Exception as e:
        logger.error(f"Error retrieving Lambda functions: {str(e)}")
        
    return functions


def get_function_details(function_name: str) -> Dict[str, Any]:
    """
    Get detailed information about a specific Lambda function.
    
    Args:
        function_name: Name of the Lambda function
        
    Returns:
        Dictionary containing function details
    """
    try:
        response = lambda_client.get_function(FunctionName=function_name)
        function_config = response['Configuration']
        
        # Get function tags
        try:
            tags_response = lambda_client.list_tags(Resource=function_config['FunctionArn'])
            tags = tags_response.get('Tags', {})
        except Exception:
            tags = {}
        
        return {
            'FunctionName': function_config['FunctionName'],
            'FunctionArn': function_config['FunctionArn'],
            'LastModified': function_config['LastModified'],
            'Runtime': function_config.get('Runtime', 'unknown'),
            'Tags': tags,
            'Description': function_config.get('Description', ''),
            'State': function_config.get('State', 'Active'),
            'PackageType': function_config.get('PackageType', 'Zip')
        }
        
    except Exception as e:
        logger.warning(f"Could not get details for function {function_name}: {str(e)}")
        return None


def identify_outdated_functions(functions: List[Dict[str, Any]], retention_days: int) -> List[Dict[str, Any]]:
    """
    Identify Lambda functions that should be deleted based on age and other criteria.
    
    Args:
        functions: List of Lambda function metadata
        retention_days: Number of days to retain functions
        
    Returns:
        List of functions to delete
    """
    outdated_functions = []
    cutoff_date = datetime.now(timezone.utc) - timedelta(days=retention_days)
    
    # Functions to exclude from deletion (modify as needed)
    protected_patterns = [
        r'.*-prod-.*',  # Production functions
        r'lambda-function-manager.*',  # This function itself
        r'.*-critical-.*',  # Critical functions
    ]
    
    protected_tags = ['Protected', 'Critical', 'DoNotDelete']
    
    for function in functions:
        try:
            # Parse last modified date
            last_modified_str = function['LastModified']
            last_modified = datetime.fromisoformat(last_modified_str.replace('Z', '+00:00'))
            
            # Check if function is old enough for deletion
            if last_modified < cutoff_date:
                # Check if function is protected by name pattern
                if is_function_protected_by_name(function['FunctionName'], protected_patterns):
                    logger.info(f"Skipping protected function: {function['FunctionName']}")
                    continue
                
                # Check if function is protected by tags
                if is_function_protected_by_tags(function['Tags'], protected_tags):
                    logger.info(f"Skipping function with protection tags: {function['FunctionName']}")
                    continue
                
                # Check if function is in active state
                if function['State'] == 'Active':
                    outdated_functions.append(function)
                    logger.info(f"Marked for deletion: {function['FunctionName']} (last modified: {last_modified_str})")
                
        except Exception as e:
            logger.warning(f"Error processing function {function.get('FunctionName', 'unknown')}: {str(e)}")
            
    return outdated_functions


def is_function_protected_by_name(function_name: str, protected_patterns: List[str]) -> bool:
    """
    Check if a function is protected by name pattern.
    
    Args:
        function_name: Name of the function
        protected_patterns: List of regex patterns for protected functions
        
    Returns:
        True if function is protected, False otherwise
    """
    for pattern in protected_patterns:
        if re.match(pattern, function_name, re.IGNORECASE):
            return True
    return False


def is_function_protected_by_tags(tags: Dict[str, str], protected_tags: List[str]) -> bool:
    """
    Check if a function is protected by tags.
    
    Args:
        tags: Function tags
        protected_tags: List of tag keys that indicate protection
        
    Returns:
        True if function is protected, False otherwise
    """
    for tag_key in protected_tags:
        if tag_key in tags:
            return True
    return False


def delete_outdated_functions(functions_to_delete: List[Dict[str, Any]]) -> Dict[str, List[str]]:
    """
    Delete the identified outdated Lambda functions.
    
    Args:
        functions_to_delete: List of functions to delete
        
    Returns:
        Dictionary with successful and failed deletions
    """
    results = {
        'successful': [],
        'failed': []
    }
    
    for function in functions_to_delete:
        function_name = function['FunctionName']
        try:
            logger.info(f"Deleting function: {function_name}")
            lambda_client.delete_function(FunctionName=function_name)
            results['successful'].append(function_name)
            logger.info(f"Successfully deleted function: {function_name}")
            
        except Exception as e:
            logger.error(f"Failed to delete function {function_name}: {str(e)}")
            results['failed'].append(f"{function_name}: {str(e)}")
    
    return results


def send_metrics(total_functions: int, analyzed_functions: int, deleted_functions: int) -> None:
    """
    Send custom metrics to CloudWatch.
    
    Args:
        total_functions: Total number of functions found
        analyzed_functions: Number of functions analyzed for deletion
        deleted_functions: Number of functions actually deleted
    """
    try:
        namespace = 'Lambda/Management'
        
        cloudwatch_client.put_metric_data(
            Namespace=namespace,
            MetricData=[
                {
                    'MetricName': 'TotalFunctions',
                    'Value': total_functions,
                    'Unit': 'Count'
                },
                {
                    'MetricName': 'AnalyzedFunctions',
                    'Value': analyzed_functions,
                    'Unit': 'Count'
                },
                {
                    'MetricName': 'DeletedFunctions',
                    'Value': deleted_functions,
                    'Unit': 'Count'
                }
            ]
        )
        
        logger.info("Metrics sent to CloudWatch successfully")
        
    except Exception as e:
        logger.warning(f"Failed to send metrics to CloudWatch: {str(e)}")


if __name__ == "__main__":
    # For local testing
    test_event = {}
    test_context = type('Context', (), {'aws_request_id': 'test-request-id'})()
    
    result = lambda_handler(test_event, test_context)
    print(json.dumps(result, indent=2))
