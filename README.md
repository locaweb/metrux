# Metrux

An instrumentation library which persists the metrics on InfluxDB.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'metrux'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install metrux

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bin/rake install`. To release a new version, update the version number in `version.rb`, and then run `bin/rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Git tags

Don't forget to tag your work! After a merge request being accepted, run:

1. (git tag -a "x.x.x" -m "") to create the new tag.
2. (git push origin "x.x.x") to push the new tag to remote.

Follow the RubyGems conventions at http://docs.rubygems.org/read/chapter/7 to know how to increment the version number. Covered in more detail in http://semver.org/

## Pull requests acceptance

Don't forget to write tests for your changes. It's very important to maintain the codebase's sanity. Any pull request that doesn't have enough test coverage will be asked a revision.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
