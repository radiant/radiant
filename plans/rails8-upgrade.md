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

## Status: COMPLETE

All 7 phases are done. 405 tests, 704 assertions, 0 failures, 0 errors.

| Phase | Description | PR(s) | Status |
|-------|-------------|-------|--------|
| 1 | GitHub Actions CI | #436 | ✅ Done |
| 2 | Rails 8 Core Upgrade | #437, #438, #439, #440, #441, #442, #443 | ✅ Done |
| 3 | HAML → ERB | #444 | ✅ Done |
| 4 | Asset Pipeline | #445, #458, #459, #460 | ✅ Done |
| 5 | Authentication | #446, #461 | ✅ Done |
| 6 | RSpec/Cucumber → Minitest | #447 | ✅ Done |
| 7 | Extensions → Rails Engines | #448, #462 | ✅ Done |

---

## Phase 1: Setup GitHub Actions ✅

**Goal:** Establish CI so all subsequent phases have automated verification.

### Tasks

1. ✅ **Create `.github/workflows/ci.yml`**

   - Single Ruby version matching `.ruby-version` (Ruby 3.3)
   - SQLite only — it's the Rails default and Radiant's primary database
   - Steps: checkout, setup Ruby, `bundle install`, `bin/rails test`
   - Minimal — one job, no matrix, no deploy

2. ✅ **Add branch protection rules**
   - Require CI to pass before merging to `master`
   - Require 1 approval

---

## Phase 2: Upgrade to Rails 8 ✅

**Goal:** Get Radiant booting and running on Rails 8 with core functionality
working. Follow the structure of a freshly generated `rails new` app as the
target.

### Sub-phase 2a: Update dependencies ✅

1. ✅ **Rewrote the Gemfile from scratch** — Rails 8 defaults plus only
   `radius`, `acts_as_tree`, `RedCloth`. Removed 17 legacy gems.

2. ✅ **Updated the gemspec** to match
3. ✅ **Resolved all bundle conflicts**

### Sub-phase 2b: Rebuild configuration from scratch ✅

1. ✅ **`config/application.rb`** — `Radiant::Application < Rails::Application`
   with `config.load_defaults 8.0`
2. ✅ **`config/environment.rb`** — Standard Rails boot
3. ✅ **`config/boot.rb`** — Standard Bundler + bootsnap boot
4. ✅ **`config/environments/`** — Modern Rails 8 configs for all environments
5. ✅ **`config/initializers/`** — Only what's needed
6. ✅ **`bin/`** — Standard Rails 8 scripts
7. ✅ **`config/database.yml`** — Standard SQLite config
8. ✅ **Credentials** — Modern Rails credentials

### Sub-phase 2c: Rewrite routing ✅

1. ✅ **`config/routes.rb`** uses modern DSL with RESTful resources

### Sub-phase 2d: Update controllers ✅

1. ✅ **Replaced all deprecated callbacks** — `before_action` everywhere
2. ✅ **Simplified `ApplicationController`** — `rescue_from`, standard CSRF
3. ✅ **Updated `LoginSystem`** temporarily (replaced in Phase 5)
4. ✅ **Kept `Admin::ResourceController`** — provides real shared CRUD behavior

### Sub-phase 2e: Update models ✅

1. ✅ **Replaced all deprecated ActiveRecord patterns** — modern scopes,
   `update`, `class_attribute`, lambda `default_scope`
2. ✅ **Simplified models** where appropriate

### Sub-phase 2f: Database ✅

1. ✅ **Consolidated 30 migrations** into single `db/schema.rb`
   (`ActiveRecord::Schema[8.1]`)
2. ✅ **Schema loads cleanly** with `rails db:schema:load`

### Sub-phase 2g: Smoke test ✅

1. ✅ Application boots and serves pages
2. ✅ Admin login and CRUD work
3. ✅ Front-end Radius template rendering works

---

## Phase 3: HAML → ERB ✅

**Goal:** Convert all 34 HAML view files to ERB.

### Tasks

1. ✅ **Converted all HAML files to ERB** — 33 ERB view files in app/views/
2. ✅ **Reviewed each converted file**
3. ✅ **Removed HAML entirely** — no `haml` in Gemfile, no `.haml` files remain
4. ✅ **All pages render correctly**

---

## Phase 4: Modernize the asset pipeline ✅

**Goal:** Use the Rails 8 defaults — Propshaft for assets, import maps for
JavaScript.

### Tasks

1. ✅ **Set up Propshaft** — `app/assets/stylesheets/`, `app/assets/images/`
2. ✅ **Set up import maps** — `config/importmap.rb` with Turbo and Stimulus pins
3. ✅ **Migrated assets from `public/`** — removed Prototype.js, Compass
4. ✅ **Embraced Hotwire** — Turbo Drive for navigation, 9 Stimulus controllers
   replacing all inline JavaScript (`onclick`, `onsubmit`, `link_to_function`,
   `content_for :page_scripts` — all eliminated)
5. ✅ **Updated view helpers** — Propshaft-compatible asset references
6. ✅ **Cleaned up `public/`** — only static files remain

---

## Phase 5: Rails 8 built-in authentication ✅

**Goal:** Replace the custom `LoginSystem` with Rails 8's native auth.

### Tasks

1. ✅ **Created `Authentication` concern** — session + HTTP Basic auth,
   `has_secure_password` (bcrypt)
2. ✅ **Migrated the User model** — `password_digest` column, removed `salt`
   and legacy SHA1 hashing
3. ✅ **Wired up authentication** — included in `ApplicationController`,
   `current_user` from session
4. ✅ **Simplified authorization** — `require_role` DSL with `before_action`,
   role-based access control
5. ✅ **Updated login/logout views** (already ERB from Phase 3)
6. ✅ **Deleted legacy auth code** — `lib/login_system.rb` removed
7. ✅ **Wrote Minitest tests** for auth flows

---

## Phase 6: RSpec/Cucumber → Minitest ✅

**Goal:** Use the Rails default test framework. Minitest with fixtures.

### Tasks

1. ✅ **Set up Minitest** — `test/test_helper.rb`, standard directory structure
   (`test/controllers/`, `test/models/`, `test/helpers/`, `test/lib/`,
   `test/integration/`, `test/system/`, `test/fixtures/`)
2. ✅ **Created fixtures** — users, pages, layouts, page_parts, page_fields,
   configs, snippets
3. ✅ **Migrated all tests** — RSpec → Minitest syntax
4. ✅ **Removed all legacy test dependencies** — no `rspec`, `cucumber`,
   `webrat`, `database_cleaner`, `dataset`. No `spec/` or `features/`
   directories remain.
5. ✅ **Updated CI** to run `bin/rails test`

---

## Phase 7: Modernize the extension system → Rails Engines ✅

**Goal:** Replace the custom Radiant extension system with standard Rails
Engines.

### Tasks

1. ✅ **Designed the new extension architecture** — each extension is a
   standard Rails Engine gem declared in the Gemfile
2. ✅ **Created `Radiant::Extension` base class** — wraps `Rails::Engine`
   with DSL for metadata (`extension_name`, `description`, `version`, `url`)
   and admin nav registration (`nav`)
3. ✅ **Removed custom extension infrastructure** — deleted `ExtensionLoader`,
   `ExtensionPath`, `ExtensionMigrator`, `Extension::Script`
4. ✅ **Created extension generator** —
   `rails generate radiant:extension my_extension` produces a proper Rails
   Engine gem with standard structure
5. **Migrate core extensions** — deferred to post-upgrade. No core extensions
   were actively in use on the `rails8` branch. The generator and base class
   are ready for when extensions are created/ported.
6. ✅ **Simplified admin extensions page** — discovers installed extensions
   via `Radiant::Extension.descendants`, shows metadata
7. ✅ **Documented the extension API** — `docs/extensions.md`

---

## Sequencing (as executed)

```
Phase 1: GitHub Actions (CI foundation)                    #436
    ↓
Phase 2: Rails 8 Core Upgrade (the big one)                #437–#443
    ↓
Phase 3: HAML → ERB ──────┐                                #444
    ↓                     │
Phase 4: Asset Pipeline ──┘                                #445, #458–#460
    ↓
Phase 5: Rails 8 Built-in Auth                             #446, #461
    ↓
Phase 6: RSpec/Cucumber → Minitest                         #447
    ↓
Phase 7: Extensions → Rails Engines                        #448, #462
```

---

## Gems to keep vs. remove

### Keep (Radiant needs these, Rails doesn't provide them)

| Gem            | Reason                                                   |
| -------------- | -------------------------------------------------------- |
| `radius`       | Radiant's custom template language — core to the product |
| `acts_as_tree` | Page hierarchy data model                                |
| `RedCloth`     | Textile filter (evaluate if still needed)                |

### Remove (Rails 8 provides these or they're no longer needed)

| Gem                            | Replacement                                          |
| ------------------------------ | ---------------------------------------------------- |
| `haml`                         | ERB (Rails default)                                  |
| `compass` / `compass-rails`    | Plain CSS + Propshaft                                |
| `will_paginate`                | Rails built-in pagination or simple `limit`/`offset` |
| `delocalize`                   | Rails I18n                                           |
| `highline`                     | Not needed (or use Ruby stdlib)                      |
| `rack` / `rack-cache`          | Rails manages these                                  |
| `tzinfo`                       | Rails bundles this                                   |
| `stringex`                     | ActiveSupport provides most of what this does        |
| `rdoc`                         | Not a runtime dependency                             |
| `rspec` / `rspec-rails`        | Minitest (Rails default)                             |
| `cucumber-rails` / `webrat`    | System tests (Rails default)                         |
| `database_cleaner` / `dataset` | Fixtures + transactional tests                       |

### The test: before adding any gem, ask

> "Does Rails already do this?" If yes, don't add the gem.
