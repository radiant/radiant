# Installation and Setup

Once you have extracted the files into the directory where you would like to
install Radiant:

1. Change to the new application directory and run:

    % bundle install

to create a gem bundle containing all of the radiant app's dependencies.
Whenever you edit the Gemfile to add new extensions, run `bundle install`
again.

2. Decide what database you want to use. Radiant ships with a SQLite
configuration that will let you try it out. For serious use you will probably
want to use on of the other supported databases: MySQL, PostgreSQL, SQL Server
or DB2. This is the time to set up the database, grant permissions and edit
config/database.yml to match.

3. Run the database bootstrap rake task:

    % rake production db:bootstrap

(If you would like bootstrap a development database run `rake db:bootstrap`.)

4. Radiant is a normal Rails application and you can run it in all the usual
ways. To test your installation, try running:

    % script/server production

And type this address into a web browser:

    http://localhost:3000

The administrative interface is available at /admin/. If your site is empty,
you will be directed there automatically to create a home page. By default the
bootstrap rake task creates a user called "admin" with a password of
"radiant".

When using Radiant on a production system you may also need to set permissions
on the public and cache directories so that your Web server can access those
directories with the user that it runs under.
