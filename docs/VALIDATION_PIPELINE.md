# BC Building Code JSON Validation Pipeline

This repository includes an automated validation pipeline that ensures the `BuildingCode.json` file conforms to the defined schema before any changes are merged to the `develop` branch.

## Overview

The validation pipeline automatically:
- Validates `BuildingCode.json` against `schema.json` on every PR to `develop`
- Posts detailed validation results as PR comments
- Prevents merging PRs with validation errors
- Provides clear feedback on what needs to be fixed

## Files Created

### GitHub Actions Workflow
- **`.github/workflows/validate-json.yml`** - Main workflow that runs on PR creation/updates

### Validation Script
- **`.github/scripts/validate_json.py`** - Python script that performs the actual validation

## How It Works

1. **Trigger**: When a PR is created or updated targeting the `develop` branch
2. **Validation**: The workflow runs the Python validation script
3. **Results**: Validation results are posted as PR comments
4. **Protection**: Branch protection rules prevent merging if validation fails

## Validation Features

- **Comprehensive Error Reporting**: Shows exact paths and error messages
- **Large File Support**: Handles the 60MB BuildingCode.json file efficiently  
- **Schema Compliance**: Uses JSON Schema Draft 7 for validation
- **Clear Feedback**: Human-readable error messages in PR comment

## Validation Process

The validation script checks:
- JSON syntax validity
- Schema compliance for all required fields
- Data type validation
- Structure validation for nested objects
- Array item validation

## Error Handling

When validation fails:
- ❌ The GitHub Action fails
- 📝 Detailed errors are written to `validation_errors.txt`
- 💬 A comment is posted on the PR with error details
- 🚫 The PR cannot be merged until errors are fixed

When validation succeeds:
- ✅ The GitHub Action passes
- 💬 A success comment is posted on the PR
- 🎯 The PR is ready for review and merge

## Testing the Pipeline

To test the validation pipeline:

1. Create a test branch from `develop`
2. Modify `BuildingCode.json` to introduce a schema violation
3. Create a PR to `develop`
4. Observe the validation workflow run and report errors
5. Fix the errors and push again
6. Verify the workflow passes

## Maintenance

- The validation script uses Python 3.11 and the `jsonschema` library
- No additional dependencies or setup required
- The workflow runs on Ubuntu latest in GitHub Actions
- All validation logic is contained in the Python script
