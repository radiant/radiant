source "https://rubygems.org"

gemspec

gem 'combustion', '~> 0.5.4', :group => :test

if ENV['TRAVIS']
  gemspec :development_group => :test
  gem "mysql"
  gem "pg"
end

group :development do
  gem "autotest-rails"
end
gem 'pry-debugger', :group => [:development, :test] if RUBY_VERSION < "2.0.0"
gem 'pry-byebug', :group => [:development, :test] if RUBY_VERSION >= "2.0.0"

# gem "radiant-archive-extension",             "~> 1.0.7"
# gem "radiant-clipped-extension",             "~> 1.1.0"
# gem "radiant-debug-extension",               "~> 1.0.2"
# gem "radiant-exporter-extension",            "~> 1.1.0"
# gem "radiant-markdown_filter-extension",     "~> 1.0.2"
# gem "radiant-sheets-extension",              "~> 1.1.0.alpha"
# gem "radiant-snippets-extension",            "~> 1.1.0.alpha"
# gem "radiant-site_templates-extension",      "~> 1.0.4"
# gem "radiant-smarty_pants_filter-extension", "~> 1.0.2"
# gem "radiant-textile_filter-extension",      "~> 1.0.4"
