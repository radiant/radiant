# Radiant Extension API

Radiant extensions are standard Rails Engines that inherit from
`Radiant::Extension`. They are packaged as gems and installed via
the Gemfile.

## Creating an Extension

Generate the scaffolding:

```bash
bin/rails generate radiant:extension my_feature
```

This creates a `radiant-my_feature/` directory with the standard
Rails Engine structure.

## Extension Structure

```
radiant-my_feature/
  app/
    controllers/
    models/
    views/
  config/
    routes.rb
  db/
    migrate/
  lib/
    my_feature.rb
    my_feature_extension.rb   # Engine class
  test/
  radiant-my_feature.gemspec
  Gemfile
  README.md
```

## Defining an Extension

The main engine class inherits from `Radiant::Extension`:

```ruby
# lib/my_feature_extension.rb
require "my_feature"

class MyFeatureExtension < Radiant::Extension
  extension_name "My Feature"
  description    "Adds a useful feature to Radiant"
  version        "1.0.0"
  url            "https://github.com/example/radiant-my_feature"

  # Add admin navigation
  nav "Content" do |tab|
    tab.add_item "My Feature", "/admin/my_feature"
  end
end
```

## Metadata Methods

| Method           | Description                          |
|------------------|--------------------------------------|
| `extension_name` | Display name (defaults to class name)|
| `description`    | Short description of the extension   |
| `version`        | Version string                       |
| `url`            | URL for more information             |

## Admin Navigation

Register navigation items using the `nav` class method:

```ruby
# Add to an existing tab
nav "Content" do |tab|
  tab.add_item "Archives", "/admin/archives"
end

# Add a new tab
nav "Reports" do |tab|
  tab.add_item "Page Views", "/admin/reports/page_views"
end

# Control tab position
nav "Reports", before: "Settings" do |tab|
  tab.add_item "Analytics", "/admin/analytics"
end
```

## Routes

Define routes in `config/routes.rb` — they are loaded automatically
by Rails Engine conventions:

```ruby
Rails.application.routes.draw do
  namespace :admin do
    resources :archives
  end
end
```

## Migrations

Place migrations in `db/migrate/`. Install them in the host app:

```bash
bin/rails my_feature_extension:install:migrations
bin/rails db:migrate
```

## Radius Tags

Add Radius tags by including `Radiant::Taggable` in your models
or by reopening the `Page` class:

```ruby
# In an initializer or the engine's config
Page.class_eval do
  tag "archive:list" do |tag|
    # tag implementation
  end
end
```

## Page Types

Define custom page types as models that inherit from `Page`:

```ruby
# app/models/archive_page.rb
class ArchivePage < Page
  def find_by_url(url, live = true, clean = false)
    # Custom URL handling
  end
end
```

Page types are automatically discovered via Rails autoloading.

## Installing an Extension

Add the gem to your Gemfile:

```ruby
gem "radiant-my_feature"
```

Run `bundle install`, copy migrations, and migrate:

```bash
bundle install
bin/rails my_feature_extension:install:migrations
bin/rails db:migrate
```

The extension's admin navigation, routes, models, and views are
all loaded automatically by Rails Engine conventions.

## Listing Installed Extensions

Visit `/admin/extensions` in the admin UI, or programmatically:

```ruby
Radiant::Extension.descendants
```
