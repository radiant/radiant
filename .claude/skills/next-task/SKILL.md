---
name: next-task
description: Pick up the next task, implement it, and open a PR.
---

# /next-task

You are picking up the next task for the Radiant CMS project, implementing it,
and opening a pull request.

## Process

1. **Read context.** Load `.quiddity/tools.json`, `.quiddity/process.md`, and
   `.quiddity/project.md` for project conventions.

2. **Find candidate tasks.** Query GitHub Issues for open issues:
   ```
   gh issue list --repo radiant/radiant --state open --limit 10
   ```
   Present the top candidates to the user and ask which one to work on.

3. **Claim the task.** Once the user selects an issue:
   - Assign it to the current user: `gh issue edit <number> --add-assignee @me`
   - Read the full issue details: `gh issue view <number>`

4. **Create a branch.** Follow the branch naming convention:
   ```
   git checkout master && git pull
   git checkout -b <number>-<slug>
   ```
   Where `<slug>` is a short kebab-case summary derived from the issue title
   (e.g., `42-add-dark-mode-support`).

5. **Plan the implementation.** Before writing code:
   - Understand the issue requirements and acceptance criteria
   - Identify the files and areas of the codebase that need changes
   - Consider the impact on existing tests
   - If anything is unclear or the task seems too large, report back to the
     user instead of plowing ahead

6. **Implement the changes.** Write the code following Radiant's conventions:
   - 2-space indentation for Ruby files
   - `snake_case` for methods/variables, `CamelCase` for classes/modules
   - Keep controllers thin, models fat
   - Write tests for all new functionality (RSpec and/or Cucumber as appropriate)

7. **Run local checks.** Before pushing, run the test suite:
   ```
   bundle exec rspec
   ```
   If tests fail, fix the issues before proceeding. If Cucumber features are
   relevant to the change, also run:
   ```
   bundle exec cucumber
   ```

8. **Commit and push.** Use conventional commit format:
   ```
   git add <files>
   git commit -m "feat: <description>

   Closes #<number>"
   ```
   Use the appropriate prefix (`feat:`, `fix:`, `chore:`, etc.) based on the
   issue type. Then push:
   ```
   git push -u origin <branch-name>
   ```

9. **Open a pull request.** Create a PR linking to the issue:
   ```
   gh pr create --repo radiant/radiant \
     --title "feat: <description>" \
     --body "## Summary
   <bullet points describing the changes>

   ## Test Plan
   - [ ] <how to verify the changes>

   Closes #<number>"
   ```
   - PR title follows conventional commit format
   - Body includes a summary and test plan
   - Reference the issue with `Closes #<number>`

10. **Report back.** Show the user:
    - The PR number and URL
    - A summary of what was implemented
    - Any notes or concerns about the implementation

## When blocked

If you encounter a blocker during implementation:
- Do NOT push through with a guess or hack
- Report the blocker to the user clearly
- Suggest possible approaches or ask for guidance
- Keep the branch and any partial work so the user can continue
