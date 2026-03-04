# Project Summary

## Overview

Radiant CMS is a no-fluff, open source content management system designed for
small teams. It is similar to Textpattern or MovableType, but is a general
purpose CMS — not merely a blogging engine. It features hierarchical pages,
flexible templating with layouts, snippets, and a custom tag language (Radius),
a simple user management system, and an advanced plugin/extension system.

## Tech Stack

- **Language:** Ruby
- **Framework:** Ruby on Rails (upgrading from 2.3 to Rails 8 on the `rails8` branch)
- **Package manager:** Bundler
- **Database:** SQLite (dev/test), PostgreSQL and MySQL also supported
- **Templating:** Radius (custom tag language), Haml, ERB
- **Test frameworks:** RSpec, Cucumber
- **Repository:** github.com/radiant/radiant

## Project Structure

| Directory    | Purpose                                          |
|--------------|--------------------------------------------------|
| `app/`       | Controllers, models, views, helpers              |
| `bin/`       | Executable (`radiant` CLI)                       |
| `config/`    | Rails configuration and routes                   |
| `db/`        | Migrations and seeds                             |
| `features/`  | Cucumber acceptance tests (9 feature files)      |
| `lib/`       | Radiant core library, extensions framework, tasks|
| `log/`       | Application logs                                 |
| `public/`    | Static assets (CSS, JS, images)                  |
| `rails/`     | Rails application templates                      |
| `script/`    | Legacy script directory                          |
| `spec/`      | RSpec tests (controllers, models, helpers, lib)  |
| `test/`      | Additional test directory                        |
| `vendor/`    | Vendored plugins and extensions                  |

## Key Files

| File                 | Purpose                                        |
|----------------------|------------------------------------------------|
| `README.md`          | Project overview and setup instructions         |
| `CLAUDE.md`          | AI agent configuration and project guidelines   |
| `AGENTS.md`          | AI agent configuration (same as CLAUDE.md)      |
| `INSTALL.md`         | Installation instructions                       |
| `CHANGELOG.md`       | Release history                                 |
| `CONTRIBUTORS.md`    | List of contributors                            |
| `LICENSE.md`         | MIT license                                     |
| `Gemfile`            | Bundle dependencies                             |
| `radiant.gemspec`    | Gem specification with all dependencies         |
| `Rakefile`           | Rake task definitions                           |

## Key Concepts

- **Pages:** Content organized in a tree hierarchy (`acts_as_tree`)
- **Layouts:** Define overall HTML structure for pages
- **Snippets:** Reusable content fragments
- **Page Parts:** Named content regions within a page (body, sidebar, etc.)
- **Radius Tags:** Custom template tags for dynamic content
- **Extensions:** Plugin system for adding functionality (located in `vendor/extensions/`)

## Configuration

- No linter or formatter configuration files present
- 2-space indentation for Ruby files (per CLAUDE.md conventions)
- `snake_case` for methods/variables, `CamelCase` for classes/modules

## CI/CD

- Previously used Travis CI (badge in README references travis-ci.org)
- No current CI configuration files present (.github/workflows, etc.)

## Conventions

- Controllers are namespaced under `Admin::` for the admin interface
- `SiteController` handles front-end page rendering
- Models use the Dataset pattern for test fixtures (`spec/datasets/`)
- The gem is distributed as `radiant` on RubyGems
- The active development branch is `rails8` (major upgrade from Rails 2.3 to Rails 8)
- Main branch is `master`
