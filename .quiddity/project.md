# Project Summary

## Overview

Radiant CMS is a no-fluff, open source content management system designed for
small teams. It features hierarchical pages, flexible templating with layouts
and a custom tag language (Radius), a role-based user management system, and
an extension system built on Rails Engines.

## Tech Stack

- **Language:** Ruby 3.3
- **Framework:** Ruby on Rails 8
- **Package manager:** Bundler
- **Database:** SQLite (dev/test), PostgreSQL and MySQL also supported
- **Templating:** Radius (custom tag language), ERB
- **Asset pipeline:** Propshaft, import maps, Turbo, Stimulus
- **Authentication:** `has_secure_password` (bcrypt) with custom `Authentication` concern
- **Test framework:** Minitest with fixtures
- **CI:** GitHub Actions
- **Repository:** github.com/radiant/radiant

## Project Structure

| Directory    | Purpose                                          |
|--------------|--------------------------------------------------|
| `app/`       | Controllers, models, views, helpers, assets, JS  |
| `bin/`       | Rails scripts                                    |
| `config/`    | Rails configuration and routes                   |
| `db/`        | Schema, migrations, seeds                        |
| `docs/`      | Extension API documentation                      |
| `lib/`       | Radiant core library, extensions framework       |
| `plans/`     | Upgrade plans and technical docs                 |
| `test/`      | Minitest tests and fixtures                      |
| `vendor/`    | Legacy vendored plugins                          |

## Key Files

| File                 | Purpose                                        |
|----------------------|------------------------------------------------|
| `README.md`          | Project overview and setup instructions         |
| `CLAUDE.md`          | AI agent configuration and project guidelines   |
| `Gemfile`            | Bundle dependencies                             |
| `radiant.gemspec`    | Gem specification                               |
| `Rakefile`           | Rake task definitions                           |

## Key Concepts

- **Pages:** Content organized in a tree hierarchy (`acts_as_tree`)
- **Layouts:** Define overall HTML structure for pages
- **Page Parts:** Named content regions within a page (body, sidebar, etc.)
- **Radius Tags:** Custom template tags for dynamic content (defined in `standard_tags.rb`)
- **Extensions:** Rails Engine plugins inheriting from `Radiant::Extension`

## Configuration

- 2-space indentation for Ruby files
- `snake_case` for methods/variables, `CamelCase` for classes/modules
- Conventional commits for PRs and commit messages

## CI/CD

- GitHub Actions (`.github/workflows/ci.yml`)
- Runs `bin/rails test` on push and PR

## Conventions

- Controllers are namespaced under `Admin::` for the admin interface
- `SiteController` handles front-end page rendering
- `Admin::ResourceController` provides shared CRUD behavior
- The extension system uses `Radiant::Extension < Rails::Engine`
- The gem is distributed as `radiant` on RubyGems
- Main branch is `master`, active upgrade branch is `rails8`
