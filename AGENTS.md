# Radiant CMS

Radiant is a no-fluff, open source content management system designed for small
teams. It is built with Ruby on Rails and uses a custom tag language called
Radius for templating.

## Project Overview

- **Type:** Rails engine / CMS gem
- **Ruby version:** See `.ruby-version` or Gemfile
- **Rails version:** Upgrading to Rails 8 (from legacy Rails 2.3)
- **Database:** SQLite (dev/test), PostgreSQL and MySQL also supported
- **Test frameworks:** RSpec, Cucumber

## Project Structure

```
app/          - Controllers, models, views, helpers
config/       - Rails configuration
db/           - Migrations and seeds
lib/          - Radiant core library and extensions framework
spec/         - RSpec tests
features/     - Cucumber features
public/       - Static assets
vendor/       - Vendored plugins and extensions
```

## Key Concepts

- **Pages:** Content is organized in a page hierarchy (tree structure via
  `acts_as_tree`)
- **Layouts:** Define the overall HTML structure for pages
- **Snippets:** Reusable content fragments
- **Page Parts:** Named content regions within a page (body, sidebar, etc.)
- **Radius Tags:** Custom template tags for dynamic content
- **Extensions:** Plugin system for adding functionality

## Development Guidelines

### Code Style

- Follow standard Ruby and Rails conventions
- Use 2-space indentation for Ruby files
- Use `snake_case` for methods and variables, `CamelCase` for classes/modules
- Keep controllers thin, models fat

### Testing

- Run RSpec tests: `bundle exec rspec`
- Run Cucumber features: `bundle exec cucumber`
- Run all tests: `bundle exec rake`
- Write specs for all new functionality
- Maintain existing test coverage when refactoring

### Database

- Use migrations for all schema changes
- Keep migrations reversible when possible
- Test with SQLite for speed, but verify against PostgreSQL

### Rails 8 Upgrade Notes

This branch (`rails8`) is for upgrading Radiant from Rails 2.3 to Rails 8.
This is a major modernization effort. Key areas of change:

- Update Gemfile and gemspec for Rails 8 dependencies
- Migrate from Rails 2.3 routing to modern Rails routing DSL
- Update controllers to inherit from `ApplicationController` (ActionController::Base)
- Replace deprecated ActiveRecord patterns
- Update views and helpers for modern Rails conventions
- Modernize the asset pipeline (Propshaft or import maps)
- Update the extension/plugin system for Rails 8 engines
- Replace vendored plugins with modern gem equivalents

### Commands to Avoid

- Do not run `rails db:reset` or `rails db:drop` without confirmation
- Do not run `bundle exec rake radiant:freeze` (legacy command)
- Do not modify `vendor/` contents without discussion
