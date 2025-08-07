# Ansible Playbook Execution Control Guide


# REMEMBER SEQUENTIAL ORDER, BREAK UP PLAYBOOKS IF NEED

# ansible-playbook yamlfile.yml --start-at-task 'task name'
# ansible-playbook http.yml --start-at-task 'install telnet '

## Overview
This guide covers various methods to selectively run tasks and steps in Ansible playbooks, giving you fine-grained control over execution.

## 1. Using Tags


### Adding Tags to Tasks
```yaml
- name: Install packages
  yum:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - mysql
  tags:
    - packages
    - install

- name: Start services
  service:
    name: "{{ item }}"
    state: started
  loop:
    - nginx
    - mysql
  tags:
    - services
    - start
```

### Running Specific Tags
```bash
# Run only tasks tagged with 'packages'
ansible-playbook playbook.yml --tags packages

# Run multiple tags
ansible-playbook playbook.yml --tags "packages,services"

# Skip specific tags
ansible-playbook playbook.yml --skip-tags install
```

## 2. Using Conditionals (when)

### Basic Conditionals
```yaml
- name: Install Apache on Red Hat systems
  yum:
    name: httpd
    state: present
  when: ansible_os_family == "RedHat"

- name: Install Apache on Debian systems
  apt:
    name: apache2
    state: present
  when: ansible_os_family == "Debian"
```

### Variable-based Conditions
```yaml
- name: Deploy application
  copy:
    src: app.jar
    dest: /opt/app/
  when: deploy_app | default(false) | bool
```

### Running with Variables
```bash
# Enable specific tasks
ansible-playbook playbook.yml -e "deploy_app=true"
```

## 3. Using Blocks for Grouping

### Conditional Blocks
```yaml
- block:
    - name: Install database
      yum:
        name: mysql-server
        state: present
    
    - name: Start database
      service:
        name: mysqld
        state: started
  when: install_database | default(false) | bool
  tags: database
```

## 4. Step-by-Step Execution

### Interactive Mode
```bash
# Run playbook step by step (confirm each task)
ansible-playbook playbook.yml --step
```

### Start at Specific Task
```bash
# Start execution from a specific task
ansible-playbook playbook.yml --start-at-task "Install packages"
```

## 5. Limiting Hosts

### Target Specific Hosts
```bash
# Run on specific hosts
ansible-playbook playbook.yml --limit web_servers

# Run on specific host
ansible-playbook playbook.yml --limit server1.example.com

# Exclude hosts
ansible-playbook playbook.yml --limit 'all:!database_servers'
```

## 6. Using Extra Variables

### Control Task Execution
```yaml
- name: Optional backup task
  shell: /usr/local/bin/backup.sh
  when: run_backup | default(false) | bool

- name: Debug mode output
  debug:
    msg: "Debug information here"
  when: debug_mode | default(false) | bool
```

### Runtime Control
```bash
# Enable specific features
ansible-playbook playbook.yml -e "run_backup=true debug_mode=true"
```

## 7. Check Mode (Dry Run)

### Test Without Changes
```bash
# See what would happen without making changes
ansible-playbook playbook.yml --check

# Check with diff output
ansible-playbook playbook.yml --check --diff
```

## 8. Advanced Tag Strategies

### Multiple Tag Combinations
```yaml
- name: Install web server
  yum:
    name: nginx
    state: present
  tags:
    - web
    - install
    - always  # Always runs unless explicitly skipped

- name: Configure web server
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  tags:
    - web
    - config
    - never   # Never runs unless explicitly called
```

### Tag Usage Examples
```bash
# Run tasks tagged 'always' and 'web'
ansible-playbook playbook.yml --tags web

# Force run 'never' tagged tasks
ansible-playbook playbook.yml --tags never

# Skip 'always' tagged tasks
ansible-playbook playbook.yml --skip-tags always
```

## 9. Practical Examples

### Environment-Specific Execution
```bash
# Development environment
ansible-playbook site.yml --tags "install,config" --limit dev_servers

# Production environment (skip debug tasks)
ansible-playbook site.yml --skip-tags debug --limit prod_servers

# Quick fix (specific task only)
ansible-playbook site.yml --tags hotfix --start-at-task "Apply security patch"
```

### Maintenance Mode
```bash
# Maintenance tasks only
ansible-playbook maintenance.yml --tags "backup,cleanup,update"

# Emergency response
ansible-playbook emergency.yml --tags critical --limit affected_servers
```

## Best Practices

1. **Use Descriptive Tags**: Make tags meaningful (`web-install`, `db-config`)
2. **Group Related Tasks**: Use blocks for logical grouping
3. **Test First**: Always use `--check` mode for important changes
4. **Document Variables**: Comment variable-controlled behavior
5. **Layer Controls**: Combine tags, limits, and variables for precision
6. **Default to Safe**: Use `default(false)` for destructive operations

## Quick Reference Commands

```bash
# Most common selective execution patterns
ansible-playbook playbook.yml --tags install          # Run install tasks
ansible-playbook playbook.yml --skip-tags config      # Skip config tasks
ansible-playbook playbook.yml --limit web_servers     # Target specific group
ansible-playbook playbook.yml --check                 # Dry run
ansible-playbook playbook.yml --step                  # Interactive mode
ansible-playbook playbook.yml -e "var=value"          # Override variables
```