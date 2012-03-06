## Welcome to Radiant

Radiant is a no-fluff, open source content management system designed for
small teams. It is similar to Textpattern or MovableType, but is a general
purpose content management system (not just a blogging engine).

[![Build Status](https://secure.travis-ci.org/radiant/radiant.png?branch=2.0)](http://travis-ci.org/radiant/radiant)

Radiant features:

* An elegant user interface
* The ability to arrange pages in a hierarchy
* Flexible templating with layouts, snippets, page parts, and a custom tagging
  language (Radius: http://radius.rubyforge.org)
* Add a simple user management/permissions system, or bring your own
* Support for multiple filtering syntax languages including Markdown and Textile as 
  well as traditional HTML (it's easy to create other filters)
* An advanced extension system
* Preview content before going live
* A flexible caching system (which by default expires pages every 5 minutes)
* Built using Ruby on Rails
* And much more...

## License

Radiant is released under the MIT license and is copyright (c) 2006-2009
John W. Long and Sean Cribbs. A copy of the MIT license can be found in the
LICENSE file.

## Installation and Setup

Radiant is a traditional Ruby on Rails application, meaning that you can
configure and run it the way you would a normal Rails application.

See the INSTALL file for more details.

### Installation of a Prerelease

As Radiant nears newer releases, you can experiment with any prerelease version.

Install the prerelease gem with the following command:

    $ gem install radiant --prerelease

## Development Requirements

To run tests you will need to uncomment the "gemspec" line in the Gemfile
and run "bundle install". Then run "bundle install rake spec".

## Support

The best place to get support is on the mailing list:

http://radiantcms.org/mailing-list/

Most of the development for Radiant happens on Github:

http://github.com/radiant/radiant/

The project wiki is here:

http://wiki.github.com/radiant/radiant/


Enjoy!

--
The Radiant Dev Team
http://radiantcms.org
