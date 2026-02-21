# 🚀 Zsh Configuration Quick Start Guide

## 📋 Table of Contents

- [Installation](#installation)
- [First Time Setup](#first-time-setup)
- [Available Functions](#available-functions)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Performance Tips](#performance-tips)

---

## 🔧 Installation

### Prerequisites

```bash
# Required
sudo apt-get install zsh fzf

# Optional (for AWS functions)
sudo apt-get install awscli
```

### Basic Setup

```bash
# 1. Clone or symlink the configuration
ln -sf ~/dots/zsh/zshrc ~/.zshrc

# 2. Install Zinit (plugin manager)
# Will auto-install on first run

# 3. Restart your shell
exec zsh
```

---

## 🎯 First Time Setup

### 1. Configure AWS CLI (if using AWS functions)

```bash
aws configure --profile default
# AWS Access Key ID: <your-key>
# AWS Secret Access Key: <your-secret>
# Default region name: ap-northeast-1
# Default output format: json
```

### 2. Set Default Profile

```bash
export AWS_PROFILE=default
echo 'export AWS_PROFILE=default' >> ~/.zshrc
```

### 3. Verify Installation

```bash
# Check AWS functions
aws-help

# Test function loading
type ec2-ssm
```

---

## 📚 Available Functions

### AWS EC2 Functions

#### `ec2-list`
List all EC2 instances in your account

```bash
ec2-list
```

#### `ec2-ssm`
Connect to EC2 instance via SSM (no SSH key needed)

```bash
ec2-ssm
# 1. Select AWS profile (interactive)
# 2. Select EC2 instance (interactive)
# 3. Automatically connects
```

**Requirements:**
- SSM Agent running on EC2
- IAM permissions for SSM
- Session Manager Plugin installed

### AWS RDS Functions

#### `rds-ssm`
Connect to RDS via EC2 bastion using SSM port forwarding

```bash
# Basic usage
rds-ssm

# Show all RDS instances (including unreachable)
rds-ssm --show-all

# Search all regions
rds-ssm --all-regions

# Help
rds-ssm --help
```

**Features:**
- Automatic security group connectivity check
- Smart secret detection from AWS Secrets Manager
- Automatic port forwarding via SSM
- Supports PostgreSQL and MySQL

### CloudWatch Logs

#### `awslogs`
Stream CloudWatch Logs in real-time

```bash
# Simple view (timestamp + message)
awslogs

# Verbose view (full log details)
awslogs -v
awslogs --verbose
```

### ECS Functions

#### `ecs-list`
List all ECS clusters

```bash
ecs-list
```

### Help

#### `aws-help`
Display comprehensive help for all AWS functions

```bash
aws-help
```

---

## ⚙️ Configuration

### Custom Configuration

```bash
# Copy example configuration
cp ~/dots/zsh/config.example.zsh ~/dots/zsh/config.zsh

# Edit configuration
nvim ~/dots/zsh/config.zsh
```

### Common Settings

```bash
# Enable debug mode
export ZSH_FUNCTIONS_DEBUG=true

# Set default AWS profile
export AWS_PROFILE=production

# Set default AWS region
export AWS_DEFAULT_REGION=us-east-1

# Disable Claude Code history
export DISABLE_CLAUDE_CODE_HISTORY=1
```

### Custom DOTFILES_DIR

If your dotfiles are in a non-standard location:

```bash
# In config.zsh
DOTFILES_DIR="/path/to/your/dotfiles"
```

---

## 🔍 Troubleshooting

### Functions Not Loading

```bash
# Enable debug mode
export ZSH_FUNCTIONS_DEBUG=true
source ~/.zshrc

# Check DOTFILES_DIR detection
echo $DOTFILES_DIR

# Manually set DOTFILES_DIR
export DOTFILES_DIR=/path/to/dots
source ~/.zshrc
```

### AWS CLI Errors

```bash
# Verify AWS CLI installation
aws --version  # Should be v2.x

# Check credentials
aws sts get-caller-identity

# Test specific profile
aws sts get-caller-identity --profile myprofile
```

### fzf Not Found

```bash
# Ubuntu/Debian
sudo apt-get install fzf

# macOS
brew install fzf

# Verify installation
fzf --version
```

### SSM Connection Fails

```bash
# Check SSM plugin
session-manager-plugin

# If not found, install:
# https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

# Verify IAM permissions
aws iam get-user
```

### Slow Shell Startup

```bash
# Measure startup time
time zsh -i -c exit

# Disable Powerlevel10k instant prompt temporarily
# Comment out in ~/.zshrc:
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Check which functions are loading
export ZSH_FUNCTIONS_DEBUG=true
source ~/.zshrc
```

---

## ⚡ Performance Tips

### 1. Optimize Function Loading

Functions are now loaded efficiently using zsh arrays and glob qualifiers.

**Current performance:** ~50-100ms for 2-3 function files

### 2. Use Powerlevel10k Instant Prompt

Already configured! Ensures fast prompt rendering.

### 3. Lazy Load Heavy Functions

For functions you rarely use:

```bash
# Instead of loading immediately, define wrapper
aws-heavy-function() {
    unfunction aws-heavy-function
    source ~/dots/zsh/functions/heavy.zsh
    aws-heavy-function "$@"
}
```

### 4. Cache AWS Calls

```bash
# Cache region lookup (in your profile)
export AWS_REGION_CACHE=$(aws configure get region)
```

### 5. Disable Unused Plugins

Edit `~/.zshrc` and comment out unused Zinit plugins.

---

## 📝 Best Practices

### 1. Use Named Profiles

```bash
# Create separate profiles for different accounts
aws configure --profile personal
aws configure --profile work
aws configure --profile dev

# Switch profiles easily
export AWS_PROFILE=work
```

### 2. Enable MFA

```bash
# Add MFA to your AWS profiles
aws configure set mfa_serial arn:aws:iam::ACCOUNT:mfa/USER --profile work
```

### 3. Use SSM Instead of SSH

Benefits:
- No SSH key management
- No open ports (uses HTTPS)
- Full audit trail in CloudTrail
- Session recording capability

### 4. Regular Updates

```bash
# Update Zinit plugins
zinit update

# Update AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
```

---

## 🆘 Getting Help

### Built-in Help

```bash
# AWS functions help
aws-help

# RDS-SSM specific help
rds-ssm --help
```

### Debug Mode

```bash
# Enable verbose output
export ZSH_FUNCTIONS_DEBUG=true

# Re-source configuration
source ~/.zshrc
```

### Common Issues

1. **"command not found: ec2-ssm"**
   - Check DOTFILES_DIR detection
   - Verify functions directory exists
   - Enable debug mode

2. **"AWS CLI not found"**
   - Install AWS CLI v2
   - Verify `aws --version`

3. **"fzf not found"**
   - Install fzf: `sudo apt-get install fzf`

4. **SSM connection fails**
   - Install Session Manager Plugin
   - Check IAM permissions
   - Verify EC2 has SSM agent

---

## 📚 Additional Resources

- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [fzf Documentation](https://github.com/junegunn/fzf)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Zinit](https://github.com/zdharma-continuum/zinit)

---

**Version:** 2.0
**Last Updated:** 2025-01-03
**Maintainer:** dots/zsh configuration
