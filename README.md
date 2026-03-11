# Radiant CMS

Radiant is a no-fluff, open source content management system designed for
small teams. It is built with Ruby on Rails and uses a custom tag language
called [Radius](https://github.com/jlong/radius) for templating.

[![CI](https://github.com/radiant/radiant/actions/workflows/ci.yml/badge.svg)](https://github.com/radiant/radiant/actions/workflows/ci.yml)

## Features

* An elegant admin interface built with Turbo and Stimulus
* Pages arranged in a hierarchy with flexible URL mapping
* Layouts, page parts, and Radius tags for flexible templating
* Support for Markdown, Textile, and HTML content filters
* A simple role-based user management system (admin, designer, editor)
* An extension system built on standard Rails Engines
* Built with Ruby on Rails 8

## Requirements

* Ruby 3.3+
* SQLite3 (default), PostgreSQL, or MySQL
* Bundler

## Getting Started

Clone the repository and install dependencies:

```bash
git clone https://github.com/radiant/radiant.git
cd radiant
bundle install
```

Set up the database and seed data:

```bash
bin/rails db:setup
```

Start the server:

```bash
bin/rails server
```

Visit `http://localhost:3000/admin` and log in with:

* **Username:** `admin`
* **Password:** `radiant`

## Running Tests

```bash
bin/rails test
```

## Extensions

Radiant extensions are standard Rails Engines that inherit from
`Radiant::Extension`. They are packaged as gems and installed via the
Gemfile.

Generate a new extension:

```bash
bin/rails generate radiant:extension my_feature
```

See [docs/extensions.md](docs/extensions.md) for the full extension API.

## Key Concepts

| Concept     | Description                                           |
|-------------|-------------------------------------------------------|
| Pages       | Content organized in a tree hierarchy                 |
| Layouts     | Define the overall HTML structure for pages            |
| Page Parts  | Named content regions within a page (body, sidebar)   |
| Radius Tags | Custom template tags for dynamic content              |
| Extensions  | Rails Engine plugins for adding functionality         |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b my-feature`)
3. Write tests for your changes
4. Make your changes
5. Run `bin/rails test` to verify
6. Commit with a [conventional commit](https://www.conventionalcommits.org/)
   message (`feat:`, `fix:`, `chore:`, etc.)
7. Open a pull request

## License

Radiant is released under the MIT license. Copyright (c) 2006-2026
John W. Long and Sean Cribbs. See [LICENSE.md](LICENSE.md) for details.
