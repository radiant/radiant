source "https://rubygems.org"

gemspec
# gem "compass-rails", "~> 1.0.3"

if ENV['TRAVIS']
  gemspec :development_group => :test
  gem "mysql"
  gem "pg"
end

group :development, :test, :cucumber do
  gem "rspec-rails"
  gem "pry-debugger"
  gem "dataset", :git => "https://github.com/radiant/dataset.git"
end

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