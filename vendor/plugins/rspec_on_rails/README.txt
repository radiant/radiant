= Spec::Rails

* http://rspec.info
* http://rspec.info/rdoc-rails/
* http://github.com/dchelimsky/rspec-rails/wikis
* mailto:rspec-devel@rubyforge.org

== DESCRIPTION:

Behaviour Driven Development for Ruby on Rails.

Spec::Rails (a.k.a. RSpec on Rails) is a Ruby on Rails plugin that allows you
to drive the development of your RoR application using RSpec, a framework that
aims to enable Example Driven Development in Ruby.

== FEATURES:

* Use RSpec to independently specify Rails Models, Views, Controllers and Helpers
* Integrated fixture loading
* Special generators for Resources, Models, Views and Controllers that generate Specs instead of Tests.

== VISION:

For people for whom TDD is a brand new concept, the testing support built into
Ruby on Rails is a huge leap forward. The fact that it is built right in is
fantastic, and Ruby on Rails apps are generally much easier to maintain than
they might have been without such support.

For those of us coming from a history with TDD, and now BDD, the existing
support presents some problems related to dependencies across examples. To
that end, RSpec on Rails supports 4 types of examples. We’ve also built in
first class mocking and stubbing support in order to break dependencies across
these different concerns.

== MORE INFORMATION:

See Spec::Rails::Runner for information about the different kinds of example
groups you can use to spec the different Rails components

See Spec::Rails::Expectations for information about Rails-specific
expectations you can set on responses and models, etc.

== INSTALL

* Visit http://github.com/dchelimsky/rspec-rails/wikis for installation instructions.

== LICENSE

(The MIT License)

====================================================================
==== RSpec, RSpec-Rails
Copyright (c) 2005-2008 The RSpec Development Team
====================================================================
==== ARTS
Copyright (c) 2006 Kevin Clark, Jake Howerton
====================================================================
==== ZenTest
Copyright (c) 2001-2006 Ryan Davis, Eric Hodel, Zen Spider Software
====================================================================
==== AssertSelect
Copyright (c) 2006 Assaf Arkin
====================================================================

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
