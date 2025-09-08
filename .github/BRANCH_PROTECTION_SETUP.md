# Branch Protection Rules Setup

To complete the validation pipeline setup, you need to configure branch protection rules in GitHub to prevent merging PRs with validation errors.

## Steps to Configure Branch Protection:

1. **Navigate to Repository Settings**
   - Go to your GitHub repository
   - Click on "Settings" tab
   - Select "Branches" from the left sidebar

2. **Add Branch Protection Rule**
   - Click "Add rule" button
   - Enter `develop` as the branch name pattern

3. **Configure Protection Settings**
   - ✅ **Require status checks to pass before merging**
   - ✅ **Require branches to be up to date before merging**
   - Under "Status checks that are required":
     - Search for and select: `validate / Validate Building Code JSON`
   
4. **Additional Recommended Settings**
   - ✅ **Require pull request reviews before merging** (at least 1 review)
   - ✅ **Dismiss stale pull request approvals when new commits are pushed**
   - ✅ **Require review from code owners** (if you have CODEOWNERS file)
   - ✅ **Restrict pushes that create files that exceed 100 MB**

5. **Save the Rule**
   - Click "Create" to save the branch protection rule

## What This Achieves:

- **Automatic Validation**: Every PR to `develop` will trigger JSON schema validation
- **Merge Prevention**: PRs with validation errors cannot be merged
- **Clear Feedback**: Validation results are posted as PR comments
- **Status Checks**: GitHub shows validation status in the PR interface

## Testing the Pipeline:

1. Create a test branch from `develop`
2. Make a small change to `BuildingCode.json` that violates the schema
3. Create a PR to `develop`
4. Observe the validation workflow run and fail
5. Check that the merge button is disabled
6. Fix the validation error and push again
7. Verify the workflow passes and merge is allowed

## Troubleshooting:

- If the status check doesn't appear, ensure the workflow has run at least once
- The status check name should match exactly: `validate`
- Make sure the workflow file is on the `develop` branch
