---
name: new-issue
description: Create a new issue from a plain-English description.
argument-hint: "[description]"
---

# /new-issue

You are creating a new GitHub issue for the Radiant CMS project.

## Input

The user provides a plain-English description of the issue via `$ARGUMENTS`.
If no arguments are provided, ask the user to describe the issue.

## Process

1. **Read context.** Load `.quiddity/tools.json` for issue tracker configuration.

2. **Classify the issue.** Determine if this is a:
   - **bug** — something is broken or not working as expected
   - **feature** — new functionality to add
   - **chore** — maintenance, refactoring, or infrastructure work

3. **Generate a structured issue.** Based on the classification, create:

   ### For features:

   **Title:** A concise, imperative title (e.g., "Add dark mode support")

   **Body:**
   ```
   ## Description
   [Clear description of the feature and why it's needed]

   ## Wireframes
   [ASCII mockup of any UI changes, or "N/A" if not UI-related]

   ## Technical Notes
   [Implementation considerations, affected files/areas, dependencies]

   ## Acceptance Criteria
   - [ ] [Criterion 1]
   - [ ] [Criterion 2]
   - [ ] [Criterion 3]
   ```

   ### For bugs:

   **Title:** A concise title describing the bug (e.g., "Fix login redirect loop")

   **Body:**
   ```
   ## Description
   [Clear description of the bug]

   ## Steps to Reproduce
   1. [Step 1]
   2. [Step 2]
   3. [Step 3]

   ## Expected Behavior
   [What should happen]

   ## Actual Behavior
   [What happens instead]

   ## Technical Notes
   [Possible root cause, affected files/areas]

   ## Acceptance Criteria
   - [ ] [Criterion 1]
   - [ ] [Criterion 2]
   ```

   ### For chores:

   **Title:** A concise title (e.g., "Update RSpec to latest version")

   **Body:**
   ```
   ## Description
   [Clear description of the work]

   ## Technical Notes
   [Implementation considerations, affected files/areas]

   ## Acceptance Criteria
   - [ ] [Criterion 1]
   - [ ] [Criterion 2]
   ```

4. **Show the issue to the user** before creating it. Ask for confirmation or
   adjustments.

5. **Create the issue** using the `gh` CLI:
   ```
   gh issue create --repo radiant/radiant --title "..." --body "..." --label "..."
   ```

   - Apply the appropriate label: `bug`, `feature`, or `chore`
   - Do NOT assign the issue (leave unassigned for the team)

6. **Return the result.** Show the issue number and URL to the user.
