# SidekiqThreadDumpParser

A utility for heping to parse and analyze Sidekiq thread dumps created with:
```
kill -TTIN [sidekiq_worker_pid]
```

Running the above command will dump stack traces of each thread spawned by the
given Sidekiq worker process ID.

From there, you can feed these lines into `SidekiqThreadDumpParser`, which will
separate them into different objects for each thread, and provide a few
convenience methods for parsing the stack traces and analyzing them.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq_thread_dump_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq_thread_dump_parser

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sidekiq_thread_dump_parser.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
