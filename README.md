# Hubbado::UpsertVersion

Provides an ActiveRecord based upsert with a per row version column

Upsert means that if an attempted INSERT results in a conflict then an UPDATE is done instead. This is atomic, but it requires that a duplicate entry is detected. Duplicate rows are detected based on the column values for the row or rows passed to `target`. A unique constraint for these columns must exist in the database.

A version is provided along with the row data. If an existing row has a version number greater than this version then no changes are made.

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

As a standalone class:

```ruby
upsert_version = Hubbado::UpsertVersion.new(SomeModel, target: :id)

attributes = {
  id: some_model_id,
  version: some_version,
  some_model_attribute: :some_value
}

upsert_version.(attributes)
```

As a dependency:

```ruby
class SomeClass
  dependency :upsert_version

  def self.build
    Hubbado::UpsertVersion.configure(self, SomeModel, target: :id)
  end

  def call
    upsert_version.(attributes)
  end
end
```

## Testing

This gem is using `standalone_migrations` to use Rails style migrations with rake commands without using rails.

Run `RACK_ENV=test rake db:create` to prepare test database.
Run `RACK_ENV=test rake db:migrate` to run migrations.
Run `rspec` to test all scenarios.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hubbado/hubbado-upsert_version.
