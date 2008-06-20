require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require File.dirname(__FILE__) + '/lib/redcloth'

PKG_VERSION = RedCloth::VERSION
PKG_NAME = "RedCloth"
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
RUBY_FORGE_PROJECT = "redcloth"
RUBY_FORGE_USER = "why"
RELEASE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_FILES = FileList[
    '*.rb',
    'bin/**/*', 
    'doc/**/*', 
    'lib/**/redcloth.rb', 
    'tests/**/*',
    'images/*'
]

CLEAN.include "**/.*.sw*"

spec = Gem::Specification.new do |s|
    s.name = PKG_NAME
    s.version = PKG_VERSION
    s.summary = <<-TXT
      RedCloth is a module for using Textile and Markdown in Ruby. Textile and Markdown are text formats. 
      A very simple text format. Another stab at making readable text that can be converted to HTML.
    TXT
    s.description = <<-TXT
      No need to use verbose HTML to build your docs, your blogs, your pages.  Textile gives you readable text while you're writing and beautiful text for your readers.  And if you need to break out into HTML, Textile will allow you to do so.

      Textile also handles some subtleties of formatting which will enhance your document's readability:

      * Single- and double-quotes around words or phrases are converted to curly quotations, much easier on
        the eye.  "Observe!"

      * Double hyphens are replaced with an em-dash.  Observe -- very nice!

      * Single hyphens are replaced with en-dashes. Observe - so cute!

      * Triplets of periods become an ellipsis.  Observe...

      * The letter 'x' becomes a dimension sign when used alone.  Observe: 2 x 2.

      * Conversion of ==(TM)== to (TM), ==(R)== to (R), ==(C)== to (C).

      For more on Textile's language, hop over to "A Textile Reference":http://hobix.com/textile/.  For more
      on Markdown, see "Daring Fireball's page":http://daringfireball.net/projects/markdown/.
    TXT

    ## Include tests, libs, docs

    s.files = PKG_FILES.to_a

    ## Load-time details

    s.require_path = 'lib'
    s.autorequire = 'redcloth'
    s.bindir = 'bin'
    s.executables = ["redcloth"]
    s.default_executable = "redcloth"

    ## Author and project details

    s.author = "why the lucky stiff"
    s.email = "why@ruby-lang.org"
    s.rubyforge_project = "redcloth"
    s.homepage = "http://www.whytheluckystiff.net/ruby/redcloth/"
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar_gz = true
    pkg.need_zip = true
end

desc "Publish the release files to RubyForge."
task :tag_cvs do
    system("cvs tag RELEASE_#{PKG_VERSION.gsub(/\./,'_')} -m 'tag release #{PKG_VERSION}'")
end

desc "Publish the release files to RubyForge."
task :rubyforge_upload => [:package] do
    files = ["exe", "tar.gz", "zip"].map { |ext| "pkg/#{PKG_FILE_NAME}.#{ext}" }

    if RUBY_FORGE_PROJECT then
        require 'net/http'
        require 'open-uri'

        project_uri = "http://rubyforge.org/projects/#{RUBY_FORGE_PROJECT}/"
        project_data = open(project_uri) { |data| data.read }
        group_id = project_data[/[?&]group_id=(\d+)/, 1]
        raise "Couldn't get group id" unless group_id

        # This echos password to shell which is a bit sucky
        if ENV["RUBY_FORGE_PASSWORD"]
            password = ENV["RUBY_FORGE_PASSWORD"]
        else
            print "#{RUBY_FORGE_USER}@rubyforge.org's password: "
            password = STDIN.gets.chomp
        end

        login_response = Net::HTTP.start("rubyforge.org", 80) do |http|
            data = [
                "login=1",
                "form_loginname=#{RUBY_FORGE_USER}",
                "form_pw=#{password}"
            ].join("&")
            http.post("/account/login.php", data)
        end

        cookie = login_response["set-cookie"]
        raise "Login failed" unless cookie
        headers = { "Cookie" => cookie }

        release_uri = "http://rubyforge.org/frs/admin/?group_id=#{group_id}"
        release_data = open(release_uri, headers) { |data| data.read }
        package_id = release_data[/[?&]package_id=(\d+)/, 1]
        raise "Couldn't get package id" unless package_id

        first_file = true
        release_id = ""

        files.each do |filename|
            basename  = File.basename(filename)
            file_ext  = File.extname(filename)
            file_data = File.open(filename, "rb") { |file| file.read }

            puts "Releasing #{basename}..."

            release_response = Net::HTTP.start("rubyforge.org", 80) do |http|
                release_date = Time.now.strftime("%Y-%m-%d %H:%M")
                type_map = {
                    ".zip"    => "3000",
                    ".tgz"    => "3110",
                    ".gz"     => "3110",
                    ".gem"    => "1400"
                }; type_map.default = "9999"
                type = type_map[file_ext]
                boundary = "rubyqMY6QN9bp6e4kS21H4y0zxcvoor"

                query_hash = if first_file then
                  {
                    "group_id" => group_id,
                    "package_id" => package_id,
                    "release_name" => RELEASE_NAME,
                    "release_date" => release_date,
                    "type_id" => type,
                    "processor_id" => "8000", # Any
                    "release_notes" => "",
                    "release_changes" => "",
                    "preformatted" => "1",
                    "submit" => "1"
                  }
                else
                  {
                    "group_id" => group_id,
                    "release_id" => release_id,
                    "package_id" => package_id,
                    "step2" => "1",
                    "type_id" => type,
                    "processor_id" => "8000", # Any
                    "submit" => "Add This File"
                  }
                end

                query = "?" + query_hash.map do |(name, value)|
                    [name, URI.encode(value)].join("=")
                end.join("&")

                data = [
                    "--" + boundary,
                    "Content-Disposition: form-data; name=\"userfile\"; filename=\"#{basename}\"",
                    "Content-Type: application/octet-stream",
                    "Content-Transfer-Encoding: binary",
                    "", file_data, ""
                    ].join("\x0D\x0A")

                release_headers = headers.merge(
                    "Content-Type" => "multipart/form-data; boundary=#{boundary}"
                )

                target = first_file ? "/frs/admin/qrs.php" : "/frs/admin/editrelease.php"
                http.post(target + query, data, release_headers)
            end

            if first_file then
                release_id = release_response.body[/release_id=(\d+)/, 1]
                raise("Couldn't get release id") unless release_id
            end

            first_file = false
        end
    end
end
