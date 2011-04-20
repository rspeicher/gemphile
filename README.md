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

Also, I needed an excuse to work with Sinatra, MongoDB, Mustache, Ruby 1.9 and
the GitHub API.

## Contributing

There's still plenty of work to be done, particularly on the front-end.
Contributions would be very much appreciated. Just send a pull request.

### Requirements

* Ruby 1.9.2
* MongoDB 1.8+

### Organization

Gemphile consists of two major parts:

* Sinatra app: Serves the site and receives GitHub post-receive hooks. Lives in
  `app/`.
* Gemfile reader: Reads downloaded Gemfiles in an isolated, elevated-security
  environment to prevent exploits. Lives in `vendor/gemfile_reader/`.

### Developer Quickstart

Basically:

    rvm --create 1.9.2@gemphile
    bundle install
    rake spec

[Guard](https://github.com/guard/guard) is used to facilitate automatic testing.

    guard

### TODO

* I'd love some HTML/CSS improvements. I am not a designer.

## Copyright

Copyright (c) 2011 Robert Speicher. License TBD.
