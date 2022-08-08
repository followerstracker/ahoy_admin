# frozen_string_literal: true

# original source https://github.com/ankane/ahoy/blob/f05719b2a69c4a392381daa73ef746923f2d1d83/test/internal/db/schema.rb

ActiveRecord::Schema.define do
  create_table :ahoy_visits do |t|
    t.string :visit_token
    t.string :visitor_token

    # the rest are recommended but optional
    # simply remove any you don't want

    # user
    t.references :user

    # standard
    t.string :ip
    t.text :user_agent
    t.text :referrer
    t.string :referring_domain
    t.text :landing_page

    # technology
    t.string :browser
    t.string :os
    t.string :device_type

    # location
    t.string :country
    t.string :region
    t.string :city
    t.float :latitude
    t.float :longitude

    # utm parameters
    t.string :utm_source
    t.string :utm_medium
    t.string :utm_term
    t.string :utm_content
    t.string :utm_campaign

    # native apps
    t.string :app_version
    t.string :os_version
    t.string :platform

    t.datetime :started_at
  end

  add_index :ahoy_visits, [:visit_token], unique: true

  create_table :ahoy_events do |t|
    t.references :visit
    t.references :user

    t.string :name
    t.jsonb :properties
    t.datetime :time
  end

  add_index :ahoy_events, %i[name time]

  create_table :products do |t|
    t.string :name
    t.references :ahoy_visit
  end

  create_table :users do |t|
    t.string :name
  end

  add_column :ahoy_visits, :bot, :string, index: true # addition by ahoy_admin gem
end
