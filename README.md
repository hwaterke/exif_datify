# ExifDatify

[![Build Status](https://img.shields.io/travis/hwaterke/exif_datify/master.svg?style=flat-square)](https://travis-ci.org/hwaterke/exif_datify)

Prepend files with date and time from exif information

## Prerequisites

This gem requires `exiftool` to be installed.
On a Mac, this can be done with `brew install exiftool`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'exif_datify'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install exif_datify

## Usage

```
datify photo.jpg
```

or

```
datify photo_directory
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hwaterke/exif_datify.
