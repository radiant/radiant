%w(rubygems rake rake/clean fileutils newgem rubigen hoe).each { |f| require f }

require 'lib/radius/version'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
Hoe.spec 'radius' do |p|
  p.version = Radius::Version.to_s
  p.url = "http://radius.rubyforge.org"
  p.developer('John W. Long', 'me@johnwlong.com')
  p.author = [
    "John W. Long (me@johnwlong.com)",
    "David Chelimsky (dchelimsky@gmail.com)",
    "Bryce Kerley (bkerley@brycekerley.net)"
  ]
  p.changes              = p.paragraphs_of("CHANGELOG", 1..2).join("\n\n")
  p.rubyforge_name       = p.name
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"]
  ]
  p.readme_file = 'README.rdoc'
  p.extra_rdoc_files |= %w(README.rdoc QUICKSTART.rdoc)
  p.clean_globs |= %w(**/.DS_Store tmp *.log) # Remove these files on "rake clean"
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
  p.test_globs = "test/**/*_test.rb"
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }