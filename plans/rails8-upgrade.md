# Rails 8 Upgrade Plan

Radiant CMS is currently on Rails 2.3.18. This plan covers the full
modernization to Rails 8, with a guiding principle:

> **"What would DHH do?"** — At every decision point, choose the Rails default.
> No extra gems where Rails provides the answer. Convention over configuration.
> Embrace the framework. Radiant should be a textbook Rails 8 application.

This means:
- **ERB** over HAML (Rails default templating)
- **Minitest** over RSpec (Rails default test framework)
- **Fixtures** over FactoryBot (Rails default test data)
- **Propshaft** for assets (Rails 8 default asset pipeline)
- **Import maps** for JavaScript (Rails 8 default, no Node/bundler needed)
- **Rails 8 built-in auth** over Devise (native, zero dependencies)
- **Rails Engines** over custom plugin systems (standard extension mechanism)
- **Solid Cache / Solid Queue / Solid Cable** if needed (Rails 8 defaults)
- **SQLite** as the primary database (Rails 8 default, good enough for most)
- **No extra gems** unless absolutely necessary — if Rails does it, use Rails

---

## Phase 1: Setup GitHub Actions

**Goal:** Establish CI so all subsequent phases have automated verification.

### Tasks

1. **Create `.github/workflows/ci.yml`**
   - Single Ruby version matching `.ruby-version` (Ruby 3.2+)
   - SQLite only — it's the Rails default and Radiant's primary database
   - Steps: checkout, setup Ruby, `bundle install`, `bin/rails test`
   - Keep it minimal — one job, no matrix, no deploy

2. **Add branch protection rules**
   - Require CI to pass before merging to `master`
   - Require 1 approval

### Notes
- CI will initially run the legacy test suite (RSpec/Cucumber); it will be
  updated when tests are migrated to Minitest in Phase 6
- No caching, no artifacts, no fancy stuff — just run the tests

---

## Phase 2: Upgrade to Rails 8

**Goal:** Get Radiant booting and running on Rails 8 with core functionality
working. Follow the structure of a freshly generated `rails new` app as the
target.

### Guiding principle

Generate a fresh Rails 8 app (`rails new radiant_reference`) and use it as the
reference for how every config file, directory, and convention should look.
When in doubt, match what `rails new` produces.

### Sub-phase 2a: Update dependencies

1. **Rewrite the Gemfile from scratch**
   - Start with what `rails new` gives you, then add only what Radiant needs
   - `rails` ~> 8.0
   - `propshaft` (Rails 8 default asset pipeline)
   - `sqlite3` (Rails 8 default database)
   - `puma` (Rails 8 default web server)
   - Ruby 3.2+ (update `.ruby-version`)
   - Only add gems Radiant truly needs:
     | Gem | Reason |
     |---|---|
     | `radius` | Core to Radiant — custom template language |
     | `acts_as_tree` (latest) | Page hierarchy — core data model |
     | `RedCloth` | Textile filter support (evaluate if still needed) |
   - **Remove everything else** — Rails 8 provides: caching, Rack, tzinfo,
     asset pipeline, testing, session management

2. **Update the gemspec** to match
3. **Run `bundle install`** and resolve conflicts

### Sub-phase 2b: Rebuild configuration from scratch

Rather than patching old config files, recreate them to match Rails 8
conventions:

1. **`config/application.rb`** — create `Radiant::Application < Rails::Application`
   using the standard Rails 8 template
2. **`config/environment.rb`** — remove `Radiant::Initializer.run`, use standard
   Rails boot
3. **`config/boot.rb`** — standard Bundler boot
4. **`config/environments/`** — copy from `rails new` and customize minimally
5. **`config/initializers/`** — delete everything custom, only add what's needed
6. **`bin/`** — regenerate with `rails app:update:bin`
7. **`config/database.yml`** — standard SQLite config from `rails new`
8. **Credentials** — use `rails credentials:edit` for secrets (no hardcoded keys)

### Sub-phase 2c: Rewrite routing

1. **Rewrite `config/routes.rb`** to modern DSL:
   ```ruby
   Rails.application.routes.draw do
     namespace :admin do
       resources :pages do
         resources :children, controller: "pages"  # nested page hierarchy
         member { get :remove }
       end
       resources :layouts
       resources :users
       resource :preferences, only: [:show, :update]
       resource :configuration, only: [:show]
       get "reference/:type", to: "references#show", as: :reference
     end

     # Login/logout
     get  "admin/login",  to: "admin/welcome#login"
     post "admin/login",  to: "admin/welcome#login"
     get  "admin/logout", to: "admin/welcome#logout"

     # Front-end page serving (catch-all, must be last)
     get "*url", to: "site#show_page"
     root to: "site#show_page"
   end
   ```

### Sub-phase 2d: Update controllers

1. **Replace deprecated callbacks everywhere**
   - `before_filter` → `before_action`
   - `prepend_before_filter` → `prepend_before_action`
   - `skip_before_filter` → `skip_before_action`

2. **Simplify `ApplicationController`**
   - Remove `rescue_action_in_public` → use `rescue_from`
   - Remove `filter_parameter_logging` → use `config.filter_parameters`
   - Standard `protect_from_forgery with: :exception`

3. **Update `LoginSystem`** temporarily for Rails 8 compatibility
   (will be replaced entirely in Phase 5)

4. **Simplify `Admin::ResourceController`**
   - Question: does this abstraction earn its keep, or should controllers
     just be straightforward? DHH would say: just write the controllers.
     If there's real shared behavior, extract a concern — not an
     inheritance hierarchy.

### Sub-phase 2e: Update models

1. **Replace all deprecated ActiveRecord patterns**
   - `named_scope` → `scope`
   - `find(:all, ...)` → `where(...)`
   - `update_attributes` → `update`
   - `before_save :method` stays (this is still Rails convention)

2. **Simplify models** — remove meta-programming where plain Ruby suffices

### Sub-phase 2f: Database

1. **Collapse all 31 migrations** into a single `db/schema.rb`
   - For a fresh Rails 8 app, the schema file is the source of truth
   - Old migrations are historical artifacts — archive them or delete them
2. **Verify schema loads cleanly** with `rails db:schema:load`

### Sub-phase 2g: Smoke test

1. Boot the application — `bin/rails server`
2. Verify admin login and basic page CRUD
3. Verify front-end page rendering
4. Run whatever tests still pass

---

## Phase 3: HAML → ERB

**Goal:** Convert all 34 HAML view files to ERB. ERB is the Rails default.
DHH doesn't use HAML. Neither should we.

### Tasks

1. **Convert all HAML files to ERB**
   - Use `haml2erb` or manual conversion
   - Organize by directory:
     - `app/views/layouts/`
     - `app/views/admin/welcome/` (login)
     - `app/views/admin/pages/`
     - `app/views/admin/layouts/`
     - `app/views/admin/users/`
     - `app/views/admin/preferences/`
     - `app/views/admin/configuration/`
     - `app/views/admin/extensions/`
     - `app/views/admin/references/`
     - All shared partials

2. **Review each converted file** — automated conversion is imperfect

3. **Remove HAML entirely**
   - Delete `haml` from Gemfile
   - Delete `config/initializers/haml.rb`
   - No HAML files should remain

4. **Verify all pages render**

---

## Phase 4: Modernize the asset pipeline

**Goal:** Use the Rails 8 defaults — Propshaft for assets, import maps for
JavaScript. No Webpack, no Node.js, no esbuild. Keep it simple.

### Tasks

1. **Set up Propshaft** (already added to Gemfile in Phase 2)
   - `app/assets/stylesheets/` for CSS
   - `app/assets/images/` for images
   - Standard `application.css` manifest

2. **Set up import maps** for JavaScript
   - `bin/importmap` for managing JS dependencies
   - Pin any needed JS libraries
   - No build step required

3. **Migrate assets from `public/`**
   - `public/stylesheets/` → `app/assets/stylesheets/`
   - `public/images/` → `app/assets/images/`
   - `public/javascripts/` → `app/javascript/`
   - Remove Compass — just write plain CSS
   - Remove Prototype.js — use Hotwire (Turbo + Stimulus) if JS is needed

4. **Embrace Hotwire** where appropriate
   - Turbo Drive for page navigation (free with Rails 8)
   - Turbo Frames for partial page updates in the admin
   - Stimulus for small JS behaviors
   - No jQuery, no Prototype.js, no custom JS frameworks

5. **Update view helpers** — ensure `stylesheet_link_tag`, `image_tag`, etc.
   work with Propshaft

6. **Clean up `public/`** — only static files that don't go through the
   pipeline (favicon, robots.txt, etc.)

---

## Phase 5: Rails 8 built-in authentication

**Goal:** Replace the custom `LoginSystem` with Rails 8's native auth.
No Devise. No gems. Just Rails.

### Tasks

1. **Run `rails generate authentication`**
   - Generates: `Session` model, `SessionsController`, `Authentication`
     concern, bcrypt password hashing
   - This is the Rails 8 Way

2. **Migrate the User model**
   - Add `password_digest` column for bcrypt
   - Remove legacy columns: `salt`, `session_token`
   - Keep the role system (`admin`, `designer`, `editor`) — authorization
     is separate from authentication
   - Write a data migration to handle existing users (likely: require
     password resets since SHA1 hashes can't be converted to bcrypt)

3. **Wire up authentication**
   - Include the generated `Authentication` concern in `ApplicationController`
   - Remove `LoginSystem` module entirely
   - `current_user` comes from the generated auth system

4. **Simplify authorization**
   - Replace `only_allow_access_to` DSL with simple `before_action` methods:
     ```ruby
     before_action :require_admin

     def require_admin
       head :forbidden unless current_user&.admin?
     end
     ```
   - DHH would keep this dead simple — a few `before_action` helpers, no
     authorization framework

5. **Update login/logout views** (already ERB from Phase 3)

6. **Delete legacy auth code**
   - `lib/login_system.rb`
   - Related matchers and specs

7. **Write Minitest tests** for the new auth flow (or integration tests
   if Phase 6 hasn't happened yet)

---

## Phase 6: RSpec/Cucumber → Minitest

**Goal:** Use the Rails default test framework. Minitest with fixtures.
No RSpec, no FactoryBot, no Cucumber. DHH writes Minitest tests with
fixtures — so do we.

### Tasks

1. **Set up Minitest** (it's already there — Rails includes it)
   - Create `test/test_helper.rb` from Rails 8 defaults
   - Directory structure:
     ```
     test/
       controllers/
       models/
       helpers/
       lib/
       integration/      # replaces Cucumber features
       system/           # browser tests with Capybara if needed
       fixtures/         # YAML fixtures, the Rails Way
     ```

2. **Create fixtures** to replace Dataset
   - `test/fixtures/users.yml`
   - `test/fixtures/pages.yml`
   - `test/fixtures/layouts.yml`
   - `test/fixtures/page_parts.yml`
   - Keep them minimal and readable — fixtures are underrated

3. **Migrate tests** (convert RSpec → Minitest syntax)
   - `describe`/`it` → `class FooTest < ActiveSupport::TestCase` / `test "..."`
   - `expect(x).to eq(y)` → `assert_equal y, x`
   - `before` → `setup`
   - Model specs → `test/models/`
   - Controller specs → `test/controllers/`
   - Helper specs → `test/helpers/`
   - Lib specs → `test/lib/`

4. **Convert Cucumber features → system tests**
   - Use `ActionDispatch::SystemTestCase` with Capybara (built into Rails)
   - These are browser-level tests — the Rails replacement for Cucumber
   - Convert the 9 feature files to system tests in `test/system/`

5. **Remove all legacy test dependencies**
   - Delete: `rspec`, `rspec-rails`, `cucumber-rails`, `webrat`,
     `database_cleaner`, `dataset`, `test-unit`
   - Delete `spec/` directory entirely
   - Delete `features/` directory entirely

6. **Update CI** to run `bin/rails test` (and `bin/rails test:system` if
   system tests are added)

---

## Phase 7: Modernize the extension system → Rails Engines

**Goal:** Replace the custom Radiant extension system with standard Rails
Engines. If Rails already has a plugin system (it does — Engines), use it.

### Tasks

1. **Design the new extension architecture**
   - Each extension is a standard Rails Engine packaged as a gem
   - No custom loader, no custom path scanning, no custom activation
   - Extensions declare themselves in the host app's Gemfile — that's it
   - Routes mount via `mount` in `config/routes.rb`
   - Migrations install via `rails radiant_archive:install:migrations`

2. **Create `Radiant::Engine` base class**
   - Thin wrapper around `Rails::Engine` providing Radiant-specific hooks:
     - Register admin navigation tabs
     - Register Radius tags
     - Register page types
   - Keep it minimal — don't re-invent what Rails Engines already provide

3. **Remove custom extension infrastructure**
   - Delete `Radiant::ExtensionLoader`
   - Delete `Radiant::ExtensionPath`
   - Simplify or delete `Radiant::ExtensionMigrator` (use Rails migration
     tasks instead)
   - Remove `config.extensions` array — Bundler is the extension manager now

4. **Create an extension generator**
   - `rails generate radiant:extension my_extension`
   - Generates a proper Rails Engine with:
     - `lib/radiant/my_extension/engine.rb`
     - Standard Engine directory structure
     - Minitest test setup
     - Gemspec

5. **Migrate core extensions** to the Engine pattern
   - Each becomes an independent gem:
     - `radiant-archive` (page archiving)
     - `radiant-snippets` (reusable content fragments)
     - `radiant-sheets` (stylesheets/scripts as pages)
     - `radiant-markdown-filter` (Markdown support)
     - `radiant-textile-filter` (Textile/RedCloth support)
   - Drop any extensions that are no longer relevant

6. **Simplify the admin extensions page**
   - List installed engines discovered via `Rails::Engine.subclasses`
   - No activation/deactivation — if it's in the Gemfile, it's active
   - Show version, description from gemspec metadata

7. **Document the extension API**
   - Keep docs in the repo (not a wiki)
   - Cover: creating an extension, adding routes, models, views, Radius
     tags, admin tabs, migrations

---

## Sequencing

```
Phase 1: GitHub Actions (CI foundation)
    ↓
Phase 2: Rails 8 Core Upgrade (the big one)
    ↓
Phase 3: HAML → ERB ──────┐
    ↓                      │ (can run in parallel)
Phase 4: Asset Pipeline ───┘
    ↓
Phase 5: Rails 8 Built-in Auth
    ↓
Phase 6: RSpec/Cucumber → Minitest
    ↓
Phase 7: Extensions → Rails Engines
```

Each phase should result in a working application with passing tests before
moving to the next. Commit frequently. Open a PR per sub-phase when possible.

---

## Gems to keep vs. remove

### Keep (Radiant needs these, Rails doesn't provide them)
| Gem | Reason |
|---|---|
| `radius` | Radiant's custom template language — core to the product |
| `acts_as_tree` | Page hierarchy data model |
| `RedCloth` | Textile filter (evaluate if still needed) |

### Remove (Rails 8 provides these or they're no longer needed)
| Gem | Replacement |
|---|---|
| `haml` | ERB (Rails default) |
| `compass` / `compass-rails` | Plain CSS + Propshaft |
| `will_paginate` | Rails built-in pagination or simple `limit`/`offset` |
| `delocalize` | Rails I18n |
| `highline` | Not needed (or use Ruby stdlib) |
| `rack` / `rack-cache` | Rails manages these |
| `tzinfo` | Rails bundles this |
| `stringex` | ActiveSupport provides most of what this does |
| `rdoc` | Not a runtime dependency |
| `rspec` / `rspec-rails` | Minitest (Rails default) |
| `cucumber-rails` / `webrat` | System tests (Rails default) |
| `database_cleaner` / `dataset` | Fixtures + transactional tests |

### The test: before adding any gem, ask
> "Does Rails already do this?" If yes, don't add the gem.
