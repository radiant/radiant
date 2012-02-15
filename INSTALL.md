# Installation and Setup

From within the directory containing your Radiant instance:

1. Decide which database you want to use. SQLite is configured by default and
   the easiest way to get started. If you want to use another database:
   - Enable your preferred database adapter in the Gemfile
   - Run `bundle update`

2. Run `bundle exec rake production db:bootstrap` to initialize the database
