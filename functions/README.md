# 📚 Zsh Functions Documentation

Comprehensive reference for custom zsh functions in this dotfiles repository.

---

## 📋 Table of Contents

- [Overview](#overview)
- [AWS Functions](#aws-functions)
  - [aws-help](#aws-help)
  - [ec2-list](#ec2-list)
  - [ec2-ssm](#ec2-ssm)
  - [rds-ssm](#rds-ssm)
  - [awslogs](#awslogs)
  - [ecs-list](#ecs-list)
- [Cursor Functions](#cursor-functions)
  - [cursor](#cursor)
- [Internal Helper Functions](#internal-helper-functions)
- [Development Guide](#development-guide)
- [Testing](#testing)

---

## 🎯 Overview

This directory contains modular function files that extend zsh functionality. Functions are automatically loaded at shell startup through the main zshrc configuration.

**Loading Mechanism**: Array-based glob processing with optimized performance (~60-70ms startup)

**File Patterns**:
- `*.zsh` - Function files to load
- `*.disabled` - Disabled functions (skipped)
- `*.broken` - Broken functions (skipped)
- `*.tmp` - Temporary files (skipped)

---

## ☁️ AWS Functions

Comprehensive AWS helper functions with interactive selection using fzf.

**Module Structure**: Organized into specialized files for maintainability
- `aws/core.zsh` (116 lines) - Core utilities and profile selection
- `aws/ec2.zsh` (68 lines) - EC2 instance management
- `aws/ecs.zsh` (28 lines) - ECS cluster operations
- `aws/logs.zsh` (61 lines) - CloudWatch Logs streaming
- `aws/rds.zsh` (165 lines) - RDS connection via SSM
- `aws/rds-helpers.zsh` (2,992 lines) - RDS internal helper functions

**Total**: 3,430 lines across 6 modules

**Prerequisites**:
- AWS CLI v2.x
- fzf (fuzzy finder)
- Session Manager Plugin (for SSM functions)
- jq (JSON processor)

**Common Features**:
- Interactive AWS profile selection
- fzf-powered resource selection
- Error handling with cleanup traps
- Comprehensive validation

**Module Loading**: All AWS modules are automatically sourced at shell startup via the main zshrc configuration

---

### `aws-help`

**Purpose**: Display comprehensive help for all AWS functions.

**Usage**:
```bash
aws-help
```

**Output**: Shows detailed usage information for all AWS functions including:
- Function descriptions
- Prerequisites
- Usage examples
- Common workflows

**Example**:
```bash
$ aws-help
🔧 AWS Helper Functions
=====================

Available Functions:
  aws-help    - Show this help message
  ec2-list    - List all EC2 instances
  ec2-ssm     - Connect to EC2 via SSM
  ...
```

---

### `ec2-list`

**Purpose**: List all EC2 instances with details.

**Usage**:
```bash
ec2-list
```

**Output Format**:
```text
InstanceID | State | Type | Name | PrivateIP | PublicIP
```

**Example**:
```bash
$ ec2-list
i-1234567890abcdef0 | running | t3.micro | web-server | 10.0.1.100 | 54.123.45.67
i-0987654321fedcba0 | stopped | t3.small | db-server  | 10.0.1.200 | -
```

**Features**:
- Color-coded instance states
- Handles missing public IPs gracefully
- Sorted by instance state

---

### `ec2-ssm`

**Purpose**: Connect to EC2 instance via SSM (no SSH key needed).

**Usage**:
```bash
ec2-ssm
```

**Interactive Workflow**:
1. Select AWS profile (fzf)
2. Select EC2 instance (fzf with instance details)
3. Automatically connects via SSM

**Prerequisites**:
- SSM Agent running on target EC2
- Session Manager Plugin installed
- IAM permissions: `ssm:StartSession`

**Example Session**:
```bash
$ ec2-ssm
🔍 Available AWS Profiles:
▶ default
  production
  staging

# After selection
🖥️ Available EC2 Instances:
▶ i-1234567890abcdef0 (web-server) - running
  i-0987654321fedcba0 (db-server)  - running

# Auto-connects
Starting session with SessionId: user-0a1b2c3d4e5f6g7h8
sh-4.2$
```

**Security Benefits**:
- No SSH key management
- No open ports (uses HTTPS)
- Full CloudTrail audit trail
- Session recording capability

**Troubleshooting**:
```bash
# Verify SSM plugin
session-manager-plugin

# Check IAM permissions
aws iam get-user

# Test SSM connectivity
aws ssm start-session --target i-1234567890abcdef0
```

---

### `rds-ssm`

**Purpose**: Connect to RDS via EC2 bastion using SSM port forwarding.

**Usage**:
```bash
# Basic usage (connectable instances only)
rds-ssm

# Show all instances
rds-ssm --show-all

# Search all regions
rds-ssm --all-regions

# Help
rds-ssm --help
```

**Interactive Workflow**:
1. Select AWS profile
2. Select EC2 bastion instance
3. Select RDS instance (with connectivity validation)
4. Auto-detect credentials from Secrets Manager
5. Start SSM port forwarding
6. Launch database client (psql/mysql)

**Features**:
- ✅ Security group connectivity validation
- ✅ AWS Secrets Manager integration
- ✅ Automatic port forwarding
- ✅ PostgreSQL and MySQL support
- ✅ Smart secret detection

**Example Session**:
```bash
$ rds-ssm
🔍 AWS Profile: production

🖥️ Select Bastion:
▶ i-bastion01 (bastion-server) - running

📊 RDS Instances:
▶ my-postgres-db (aurora-postgresql) - available ✅
  my-mysql-db    (aurora-mysql)      - available ✅

🔐 Detected Secret: rds/production/postgres/admin

🔄 Starting SSM port forwarding...
Port forwarding session started successfully.

Local port: 5432 → RDS endpoint
Connection: localhost:5432

🚀 Launching psql...
psql (14.5)
Type "help" for help.

postgres=>
```

**Security Group Validation**:
- Checks if bastion security group allows outbound to RDS
- Checks if RDS security group allows inbound from bastion
- Shows warning if connectivity not verified

**Secrets Manager Integration**:
- Auto-detects secrets matching pattern: `rds/{env}/{engine}/{user}`
- Extracts username/password/database automatically
- Falls back to manual input if no secret found

**Supported Engines**:
- PostgreSQL (aurora-postgresql, postgres)
- MySQL (aurora-mysql, mysql)

**Options**:
- `--show-all`: Show all RDS instances (including unreachable)
- `--all-regions`: Search all AWS regions
- `--help`: Display detailed help

**Cleanup**:
- Automatic trap handlers for temporary files
- Cleans up on EXIT, INT, TERM signals

---

### `awslogs`

**Purpose**: Stream CloudWatch Logs in real-time.

**Usage**:
```bash
# Simple view (timestamp + message)
awslogs

# Verbose view (full details)
awslogs -v
awslogs --verbose
```

**Interactive Workflow**:
1. Select AWS profile
2. Select log group (fzf)
3. Stream logs in real-time

**Output Formats**:

**Simple Mode** (default):
```text
2025-01-03T10:15:30Z [INFO] Application started
2025-01-03T10:15:31Z [INFO] Connected to database
2025-01-03T10:15:32Z [ERROR] Failed to load config
```

**Verbose Mode** (`-v`):
```text
====================================
Timestamp: 2025-01-03T10:15:30Z
Log Stream: app-server-001
Message: [INFO] Application started
====================================
```

**Features**:
- Real-time log streaming
- Interactive log group selection
- Customizable output format
- Color-coded log levels

**Example**:
```bash
$ awslogs
🔍 AWS Profile: production

📋 Select Log Group:
▶ /aws/lambda/api-handler
  /aws/ecs/web-service
  /aws/rds/postgres/error

# Streaming logs...
2025-01-03T10:15:30Z START RequestId: abc-123
2025-01-03T10:15:31Z [INFO] Processing request
2025-01-03T10:15:32Z END RequestId: abc-123
```

---

### `ecs-list`

**Purpose**: List all ECS clusters.

**Usage**:
```bash
ecs-list
```

**Output**:
```text
Cluster ARN                                     | Status  | Services | Tasks
arn:aws:ecs:us-east-1:123456789:cluster/prod  | ACTIVE  | 5        | 12
arn:aws:ecs:us-east-1:123456789:cluster/dev   | ACTIVE  | 3        | 6
```

**Features**:
- Lists all clusters in current region
- Shows cluster status
- Displays service and task counts
- Color-coded status indicators

---

## 🖥️ Cursor Functions

**File**: `cursor.zsh` (38 lines)

---

### `cursor`

**Purpose**: Launch Cursor IDE from command line with optional directory.

**Usage**:
```bash
# Open current directory
cursor

# Open specific directory
cursor ~/projects/myapp

# Open specific file
cursor package.json
```

**Features**:
- Smart path resolution
- Opens Cursor IDE in background
- Handles relative and absolute paths

**Example**:
```bash
$ cursor ~/dots/vim
# Launches Cursor IDE with ~/dots/vim open

$ cd ~/projects && cursor
# Launches Cursor IDE with ~/projects open
```

---

## 🔧 Internal Helper Functions

These functions are used internally by AWS functions and are not meant to be called directly.

### `_aws_select_profile`

**Purpose**: Interactive AWS profile selection with validation.

**Features**:
- Dependency validation (AWS CLI, fzf)
- Helpful installation instructions on error
- Returns selected profile to caller

**Validation Checks**:
```bash
# AWS CLI installation
if ! command -v aws >/dev/null 2>&1; then
    echo "❌ AWS CLIが見つかりません" >&2
    echo "   https://docs.aws.amazon.com/cli/..." >&2
    return 1
fi

# fzf installation
if ! command -v fzf >/dev/null 2>&1; then
    echo "❌ fzfが見つかりません" >&2
    echo "   Ubuntu/Debian: sudo apt-get install fzf" >&2
    return 1
fi
```

### `_aws_select_ec2_instance`

**Purpose**: Interactive EC2 instance selection with formatted display.

**Parameters**:
- `$1`: AWS profile name

**Output Format**:
- Instance ID, Name, State, Type, IPs
- Color-coded states (running=green, stopped=red)
- Handles missing values gracefully

**Returns**: Selected instance ID

---

## 👨‍💻 Development Guide

### Creating New Functions

#### Single-File Functions

1. **Create Function File**:
```bash
cat > ~/dots/zsh/functions/my-function.zsh << 'EOF'
#!/usr/bin/env zsh

my-custom-function() {
    echo "Hello from custom function"
}
EOF
```

2. **Reload Shell**:
```bash
exec zsh
```

3. **Test Function**:
```bash
my-custom-function
```

#### Modular Functions (AWS-style)

For complex function suites, use a modular structure:

1. **Create Module Directory**:
```bash
mkdir -p ~/dots/zsh/functions/mymodule
```

2. **Create Module Files**:
```bash
# Core module with shared utilities
cat > ~/dots/zsh/functions/mymodule/core.zsh << 'EOF'
#!/usr/bin/env zsh
# Shared helper functions
_mymodule_helper() {
    echo "Helper function"
}
EOF

# Feature-specific module
cat > ~/dots/zsh/functions/mymodule/feature.zsh << 'EOF'
#!/usr/bin/env zsh
mymodule-feature() {
    _mymodule_helper
    echo "Feature function"
}
EOF
```

3. **Module Loading**: Modules are auto-loaded by pattern matching in zshrc
   - All `*.zsh` files in subdirectories are sourced automatically
   - Load order is alphabetical by filename

4. **Example Module Structure**:
```text
functions/
├── aws/
│   ├── core.zsh       # Core utilities, profile selection
│   ├── ec2.zsh        # EC2-specific functions
│   ├── ecs.zsh        # ECS-specific functions
│   ├── logs.zsh       # CloudWatch Logs
│   ├── rds.zsh        # RDS functions
│   └── rds-helpers.zsh # RDS internal helpers
└── cursor.zsh         # Standalone function
```

### Best Practices

**Function Structure**:
```bash
#!/usr/bin/env zsh
# ===================================================================
# Function Name and Purpose
# ===================================================================
#
# Usage: function-name [options]
#
# Prerequisites:
#   - Dependency 1
#   - Dependency 2
#
# Examples:
#   function-name              # Example 1
#   function-name --verbose    # Example 2
# ===================================================================

function-name() {
    # Dependency validation
    if ! command -v required-tool >/dev/null 2>&1; then
        echo "❌ Error message" >&2
        return 1
    fi

    # Temporary file with cleanup trap
    local temp_file=$(mktemp)
    trap "rm -f '$temp_file'" EXIT INT TERM

    # Function logic
    # ...

    # Success
    return 0
}
```

**Security Guidelines**:
- ✅ Never use `eval` for command execution
- ✅ Always add trap handlers for temporary files
- ✅ Validate all dependencies at start
- ✅ Quote all variables
- ✅ Use `local` for function-scoped variables

**Performance Guidelines**:
- ✅ Use parameter expansion over subprocesses
- ✅ Use arrays for bulk operations
- ✅ Minimize external command calls
- ✅ Cache expensive operations

**Examples**:
```bash
# ❌ BAD: Subprocess spawning
basename "$file"

# ✅ GOOD: Parameter expansion
"${file:t}"

# ❌ BAD: Multiple subprocesses
for item in $(command); do
    process "$item"
done

# ✅ GOOD: Array-based processing
items=(${(f)"$(command)"})
for item in "${items[@]}"; do
    process "$item"
done
```

### Error Handling Patterns

**Dependency Validation**:
```bash
_validate_dependencies() {
    local -a missing_deps=()

    for dep in aws fzf jq; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "❌ Missing dependencies: ${missing_deps[*]}" >&2
        return 1
    fi
}
```

**Cleanup Traps**:
```bash
my-function() {
    local temp_file=$(mktemp)
    local temp_dir=$(mktemp -d)

    # Register cleanup
    trap "rm -f '$temp_file'; rm -rf '$temp_dir'" EXIT INT TERM

    # Function logic
    # ...
}
```

**Error Messages**:
```bash
# Actionable error messages
echo "❌ AWS CLI not found" >&2
echo "   Install: https://docs.aws.amazon.com/cli/..." >&2
echo "   Ubuntu: sudo apt-get install awscli" >&2
return 1
```

---

## 🧪 Testing

### Manual Testing

**Test Function Loading**:
```bash
# Enable debug mode
export ZSH_FUNCTIONS_DEBUG=true
source ~/.zshrc

# Verify function available
type my-function

# Test execution
my-function --help
```

**Test Error Handling**:
```bash
# Missing dependency
PATH=/usr/bin my-function  # Should show error

# Invalid input
my-function --invalid-flag  # Should show usage

# Cleanup verification
lsof | grep "$USER.*tmp"  # Check for leaked files
```

### Automated Testing

**Create Test Script**:
```bash
#!/usr/bin/env zsh

source ~/dots/zsh/functions/my-function.zsh

test_basic_usage() {
    local result=$(my-function)
    [[ -n "$result" ]] && echo "✅ Basic usage test passed"
}

test_error_handling() {
    my-function --invalid 2>/dev/null
    [[ $? -ne 0 ]] && echo "✅ Error handling test passed"
}

test_basic_usage
test_error_handling
```

---

## 📊 Function Statistics

### AWS Functions (Modular)

| Module | Lines | Functions | Description |
|--------|-------|-----------|-------------|
| `aws/core.zsh` | 116 | aws-help, profile selection | Core utilities |
| `aws/ec2.zsh` | 68 | ec2-list, ec2-ssm | EC2 management |
| `aws/ecs.zsh` | 28 | ecs-list | ECS operations |
| `aws/logs.zsh` | 61 | awslogs | CloudWatch Logs |
| `aws/rds.zsh` | 165 | rds-ssm | RDS connections |
| `aws/rds-helpers.zsh` | 2,992 | Internal helpers | RDS utilities |
| **AWS Subtotal** | **3,430** | **6 modules** | - |

### Other Functions

| Function | Lines | Dependencies | Features |
|----------|-------|--------------|----------|
| `cursor` | 38 | cursor | IDE launcher |
| **Total** | **3,468** | - | **6 AWS modules + 1 function** |

---

## 🔗 Related Documentation

- [Main README](../README.md) - Overall zsh configuration
- [QUICKSTART](../QUICKSTART.md) - Quick start guide
- [config.example.zsh](../config.example.zsh) - Configuration template

---

## 🆘 Support

For issues or questions:
1. Check function-specific help: `aws-help`, `rds-ssm --help`
2. Enable debug mode: `export ZSH_FUNCTIONS_DEBUG=true`
3. Review inline documentation in function files
4. Check main troubleshooting guide in [README.md](../README.md)

---

**Last Updated**: 2025-10-13
**Total Functions**: 7 public functions across 6 AWS modules + 1 cursor function
**Total Lines**: 3,468
