# AhoyAdmin

:bar_chart: Simple Admin Panel for [ahoy](https://github.com/ankane/ahoy) analytics and Rails.

WARNING: Despite the fact that it's been running in production for a while, this is still a beta software.

## Features

- [x] :date: Analytics for different time periods today/last-24hr/yesterday/this-week/last-7-days/this-month etc..
- [x] :chart_with_upwards_trend: Beatiful and lightweight charts with [uPlot](https://github.com/leeoniya/uPlot)
- [ ] :muscle: Caching for heavy DB queries and templates
- [x] :bar_chart: Top pages/bots/devices/countries etc...
- [x] :speedboat: Lightweight, Mobile friendly UI

## Demo

The live demo is located [here](https://followerstracker.com/site-stats)

## Screenshots

<img src="https://user-images.githubusercontent.com/86723496/129568055-846241f2-5932-4db7-bbef-82783ca380cb.png" width="180"> <img src="https://user-images.githubusercontent.com/86723496/129568104-8846e395-c189-48e8-81a0-b8a23ea8035a.png" width="180"> <img src="https://user-images.githubusercontent.com/86723496/129568127-dc06a34d-4eb8-47dd-9eec-22ae4ba6fabe.png" width="180"> <img src="https://user-images.githubusercontent.com/86723496/129568294-df674694-6c25-4d7a-9477-042ba23cabc9.png" width="180">

## Limitations

* PostgreSQL support **only** at this moment

## Installation

```Gemfile
gem "ahoy_admin", git: "https://github.com/followerstracker/ahoy_admin"
```

Add mounting to the routes (config/routes.rb)

```ruby
mount(AhoyAdmin::Engine, at: "/ahoy")
```

## Configuration

Add a configuration to initializers, `config/initializers/ahoy_admin.rb`:

```ruby
AhoyAdmin.configure do |config|
  config.head_title = "Ahoy Admin"
  config.head_meta_description = "Ahoy Admin Panel"
  config.head_meta_keywords = "ahoy, admin, panel, analytics"
  config.head_favicon_url = "/favicon.ico"
  config.brand_name = "Ahoy Admin"
  config.domains = []
  config.time_zone = "UTC"
  config.current_user_method = :current_user
  config.current_user_admin = lambda { |user| user&.admin? || Rails.env.development? }
end
```

## Tracking bots

By default [ahoy](https://github.com/ankane/ahoy) gem doesn't track bots. We think that information could be useful, tracked and analyzed.

In order to enable this functionality, you might want to create a migration and to add the `bot` column to ahoy_visits table:

```ruby
  disable_ddl_transaction!

  def change
    add_column(:ahoy_visits, :bot, :string)
    add_index(:ahoy_visits, :bot, algorithm: :concurrently)
  end
```

Now we need to change the way we populate that column:

```ruby
class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    data[:bot] = DeviceDetector.new(request.user_agent).send(:bot)&.send(:regex_meta).try(:[], :name)
    super(data)
  end
end
```

This should be enough to see reports for bots.

## Tests

Yeah, there are no tests yet. Stay tuned.

## Contributing

TBD

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
