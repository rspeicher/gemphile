# Gemphile

A Gemfile and gemspec indexer

## Purpose

For some developers, the best way to learn how to use a gem is to see how other
projects use it in the real world. But what if you can't easily find a project
that uses the gem you're trying to learn about? Gemphile was created to index
the Gemfiles and gemspecs of Ruby projects on GitHub and then to provide a
simple search interface to find those projects.

Gemphile makes use of GitHub's post-receive hooks to discover new projects and
to know when an existing project's Gemfile or gemspec has been modified.

## Contributing

Contributions would be very appreciated; just send a pull request.

If you're thinking of adding some major functionality like voting, or
something, send me a message on GitHub first so we can discuss it, as I'd like
to keep the site simple for now.

### Requirements

* Ruby 1.9
* MongoDB 1.8+

### Organization

Gemphile consists of two major parts:

* Sinatra app: Serves the site and receives GitHub post-receive hooks. Lives in
  `app/`.
* Gemfile reader: Reads downloaded Gemfiles in an isolated, elevated-security
  environment to prevent exploits. Lives in `vendor/gemfile_reader/`.

### Developer Quickstart

First, you'll need Ruby 1.9. Working with [RVM](https://rvm.beginrescueend.com/)
is probably easiest.

    rvm install 1.9.2
    rvm --create 1.9.2@gemphile

Next, you'll need MongoDB. If you're on Mac OSX, this is super easy with
[Homebrew](https://github.com/mxcl/homebrew):

    brew install mongodb

Ubuntu/Debian users, see the official
[packages](http://www.mongodb.org/display/DOCS/Ubuntu+and+Debian+packages).

Then use [Bundler](http://gembundler.com/) to install the dependencies.

    gem install bundler
    bundle install

Then run the specs.

    rake spec

If everything passes, you're good to go.

Sass stylesheets are not automatically converted to CSS at runtime. You'll need
to compile them as needed with `sass` or just leave `compass watch` running.

### TODO

* I'd love some HTML/CSS improvements. I am not a designer.

## Copyright

Copyright (c) 2011 Robert Speicher. Released under the MIT License. See
`LICENSE` for details.
