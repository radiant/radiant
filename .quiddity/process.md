# Development Process

## Branching strategy

You use GitHub flow. Short-lived feature branches are created off `master`
(the main branch) and merged back via pull requests. The `rails8` branch is a
long-lived branch for the Rails 8 upgrade effort.

Branch names follow the convention `<issue-number>-<slug>` (e.g.,
`448-modernize-extension-system`).

## Code review

Pull requests are required for all changes. PRs are squash-merged to keep a
clean commit history on `master`. At least one reviewer should approve before
merging. The team is small (2-5 contributors), so any team member can review.

## Issue workflow

You use GitHub Issues for tracking work. The workflow is informal — issues are
created as needed, prioritized through discussion, and assigned to whoever picks
them up. There are no formal sprints or cycles. Bugs, features, and chores are
distinguished by labels.

## Commit and PR conventions

You follow conventional commits format:
- `feat:` for new features
- `fix:` for bug fixes
- `chore:` for maintenance tasks
- `refactor:` for code restructuring
- `docs:` for documentation changes
- `test:` for test-only changes

PR titles should also follow this convention. PR descriptions should explain
the "why" behind the change and include any relevant context.

## Testing

Tests are required for all new code. You use Minitest for unit and integration
tests with YAML fixtures. Existing test coverage should be maintained when
refactoring. The change author is responsible for writing tests.

- Run tests: `bin/rails test`
- Run all tests: `bundle exec rake`

## Release and deployment

You use semantic versioning (semver) with manual gem releases to RubyGems.
The version is defined in `lib/radiant.rb`. No formal release schedule — releases
happen when ready. No continuous deployment pipeline is in place.

## Team structure

Small team of 2-5 contributors. Work is divided informally. The current focus
is the Rails 8 upgrade on the `rails8` branch.
