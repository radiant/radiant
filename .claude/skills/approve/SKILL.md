---
name: approve
description: Verify checks and merge an approved PR.
argument-hint: "[pr-number]"
---

# /approve

You are verifying and merging an approved pull request for the Radiant CMS
project.

## Input

The user may provide a PR number via `$ARGUMENTS` (e.g., `/approve 42`).
If no PR number is provided, detect the PR for the current branch:
```
gh pr view --json number,title,url
```

## Process

1. **Read context.** Load `.quiddity/tools.json` for PR and source control
   configuration.

2. **Get PR details.** Fetch the PR information:
   ```
   gh pr view <number> --json number,title,url,state,reviewDecision,statusCheckRollup,body,comments,reviews
   ```

3. **Verify the PR is ready to merge.** Check all of the following:

   ### a. PR is open
   If the PR is already merged or closed, report that and stop.

   ### b. Required approvals
   Verify the PR has at least 1 approval (`reviewDecision` is `APPROVED`).
   If not, report who needs to review and stop.

   ### c. Unresolved review comments
   Check for unresolved review threads:
   ```
   gh api repos/radiant/radiant/pulls/<number>/reviews
   ```
   If there are unresolved comments or requested changes, list them and stop.

   ### d. CI checks
   Verify all GitHub status checks and check runs have passed:
   ```
   gh pr checks <number>
   ```
   If any checks are still pending, wait and poll every 30 seconds (up to 10
   minutes) until they complete. If any checks fail, list the failing checks
   with their details and stop. Do NOT merge with failing or pending checks.

4. **Report status.** Show the user a summary:
   - PR title and number
   - Approval status
   - Review comments status
   - CI checks status (pass/fail/pending for each check)
   - Whether the PR is ready to merge

   If anything blocks the merge, report clearly and stop. Do NOT proceed
   with the merge.

5. **Confirm with the user.** Ask for explicit confirmation before merging.

6. **Merge the PR.** Use squash merge:
   ```
   gh pr merge <number> --squash --delete-branch
   ```

7. **Post-merge cleanup.**
   - Switch to master and pull latest:
     ```
     git checkout master && git pull
     ```
   - Delete the local branch if it still exists:
     ```
     git branch -d <branch-name>
     ```
   - Close the linked issue if one is referenced in the PR body
     (look for `Closes #<number>` or `Fixes #<number>`):
     ```
     gh issue close <issue-number> --comment "Closed via PR #<pr-number>"
     ```

8. **Report back.** Show the user:
   - Confirmation that the PR was merged
   - The linked issue that was closed (if any)
   - That the local branch was cleaned up
   - Current branch is now `master` with latest changes

## When blocked

If the PR cannot be merged, clearly report:
- Which checks failed (approvals, comments, CI)
- What needs to happen before it can be merged
- Do NOT force-merge or bypass any checks
