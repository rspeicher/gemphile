# Gemphile

Gemfile indexing

## Purpose

Ever wanted a real-world usage example for a particular Ruby gem, but couldn't
find any projects that use it? Well, now you can search for it on Gemphile and
get a list of projects that require that gem in their Gemfile.

Gemphile makes use of GitHub's post-receive hooks to discover new projects and
to know when an existing project's Gemfile has been modified.

## Caveats

* Processes Gemfile `gem` directives only. Nothing in a `gemspec` file will
  currently be processed.

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

* **Front-end!**
* `gemspec` reading.

## Copyright

Copyright (c) 2011 Robert Speicher. License TBD.
