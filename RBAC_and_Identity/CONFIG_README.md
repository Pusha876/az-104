# Azure Configuration Setup

This directory uses a configuration system to protect sensitive information like subscription IDs from being committed to the repository.

## Setup Instructions

1. **Copy the template file:**
   ```bash
   cp config.template.sh config.sh
   ```

2. **Edit the config.sh file** with your own values:
   ```bash
   nano config.sh  # or use your preferred editor
   ```

3. **Update the following values in config.sh:**
   - `SUB_ID`: Your Azure subscription ID
   - `TEST_USER_UPN`: Your test user principal name
   - `AZURE_REGION`: Your preferred Azure region
   - Other values as needed

## Security Notes

- The `config.sh` file is automatically ignored by git (see `.gitignore`)
- Never commit sensitive information like subscription IDs to the repository
- Each user should have their own `config.sh` file with their own values
- The `config.template.sh` file serves as a template for new users

## Usage

All scripts in the lab directories will automatically source the configuration file. If the file is missing, scripts will display an error message with setup instructions.

## Files

- `config.template.sh` - Template file (committed to git)
- `config.sh` - Your personal config file (ignored by git)