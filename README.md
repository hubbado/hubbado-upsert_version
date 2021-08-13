# Hubbado::UpsertVersion

Provides an ActiveRecord based upsert with a per row version column

Upsert means that if an attempted INSERT results in a conflict then an UPDATE is done instead. This is atomic, but it requires that a duplicate entry is detected.

A version is provided along with the row data, that is the version of the given data. If an existing row has a version number greater than this version then no changes are made. This is designed to allow idempotent reply of SQL updates commands.

This gem is using `pg_tester` to start a local temporary postgres server, but for some reason this doesn't work correctly on Codeship.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hubbado-upsert_version'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hubbado-upsert_version

## Usage

`ActiveRecord::UpsertVersion.(**attributes, version: <version>)`

## Testing

Run `RACK_ENV=test rake db:create` to prepare test database.
Run `RACK_ENV=test rake db:migrate` to run migrations.
Run `rspec` to test all scenarios.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hubbado/hubbado-upsert_version.
