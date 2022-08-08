# frozen_string_literal: true

require "spec_helper"

describe AhoyAdmin::ViewsByPagePresenter do
  include GenerateHelpers

  subject { described_class.new(current_period: current_period) }

  let(:tnow) { ActiveSupport::TimeZone["UTC"].parse("2022-01-01 2pm") }

  before do
    Timecop.freeze(tnow)
  end

  let(:url1) { "https://followerstracker.com" }
  let(:url2) { "https://followerstracker.com/twitter/dhh" }

  context "current period - today" do
    let(:current_period) { :today }
    let(:beginning_at) { Time.current.beginning_of_day }
    let(:interval) { 10.minutes }

    it "works" do
      generate_visits(count: 3, url1: url1, url2: url2, beginning_at: beginning_at, interval: interval)

      expect(subject.collection.first).to have_attributes(metric: 3, dimension: url1)
      expect(subject.collection.last).to have_attributes(metric: 3, dimension: url2)
      expect(subject.collection_total).to eq(6)
    end

    it "works with pagination" do
      generate_visits(count: 3, url1: url1, url2: url2, beginning_at: beginning_at, interval: interval)

      charli = "https://followerstracker.com/tiktok/charlidamelio"
      khaby = "https://followerstracker.com/tiktok/khaby.lame"
      generate_visits(count: 2, url1: charli, url2: khaby, beginning_at: beginning_at, interval: interval)

      10.times do |x|
        u1 = "#{url1}/path-#{x}"
        u2 = "#{url2}/path-#{x}"
        generate_visits(count: 1, url1: u1, url2: u2, beginning_at: beginning_at, interval: interval)
      end

      expect(subject.collection.first).to have_attributes(metric: 3, dimension: url1)
      expect(subject.collection.second).to have_attributes(metric: 3, dimension: url2)
      expect(subject.collection.third).to have_attributes(metric: 2, dimension: charli)
      expect(subject.collection.to_a.size).to eq(20)
      expect(subject.collection_total).to eq(30)
    end
  end

  context "current period - last_24_hours" do
    let(:current_period) { :last_24_hours }
    let(:beginning_at) { 30.hours.ago.beginning_of_hour }
    let(:interval) { 1.hour }

    it "works" do
      generate_visits(count: 30, url1: url1, url2: url2, beginning_at: beginning_at, interval: interval)

      expect(subject.collection.first).to have_attributes(metric: 24, dimension: url1)
      expect(subject.collection.last).to have_attributes(metric: 24, dimension: url2)
      expect(subject.collection_total).to eq(48)
    end
  end

  context "current period - yesterday" do
    let(:current_period) { :yesterday }
    let(:beginning_at) { Time.current.yesterday.midday }
    let(:interval) { 1.hour }

    it "works" do
      generate_visits(count: 24, url1: url1, url2: url2, beginning_at: beginning_at, interval: interval)

      expect(subject.collection.first).to have_attributes(metric: 12, dimension: url1)
      expect(subject.collection.last).to have_attributes(metric: 12, dimension: url2)
      expect(subject.collection_total).to eq(24)
    end
  end

  context "current period - this_week" do
    let(:current_period) { :this_week }
    let(:beginning_at) { 1.week.ago.beginning_of_day }
    let(:interval) { 1.day }
    let(:wday) { Time.current.wday - 1 }

    it "works" do
      generate_visits(count: 7, url1: url1, url2: url2, beginning_at: beginning_at, interval: interval)

      expect(subject.collection.first).to have_attributes(metric: wday, dimension: url1)
      expect(subject.collection.last).to have_attributes(metric: wday, dimension: url2)
      expect(subject.collection_total).to eq(wday * 2)
    end
  end

  context "current period - last_7_days" do
    let(:current_period) { :last_7_days }
    let(:beginning_at) { 10.days.ago.beginning_of_day }
    let(:interval) { 1.day }

    it "works" do
      generate_visits(count: 10, url1: url1, url2: url2, beginning_at: beginning_at, interval: interval)

      expect(subject.collection.first).to have_attributes(metric: 7, dimension: url1)
      expect(subject.collection.last).to have_attributes(metric: 7, dimension: url2)
      expect(subject.collection_total).to eq(14)
    end
  end

  context "current period - this_month" do
    let(:current_period) { :this_month }
    let(:beginning_at) { Time.current.beginning_of_month - 3.days }
    let(:interval) { 1.day }

    it "works" do
      generate_visits(count: 10, url1: url1, url2: url2, beginning_at: beginning_at, interval: interval)

      expect(subject.collection.first).to have_attributes(metric: 7, dimension: url1)
      expect(subject.collection.last).to have_attributes(metric: 7, dimension: url2)
      expect(subject.collection_total).to eq(14)
    end
  end

  context "current period - last_30_days" do
    let(:current_period) { :last_30_days }
    let(:beginning_at) { 40.days.ago.beginning_of_day }
    let(:interval) { 10.day }

    it "works" do
      generate_visits(count: 4, url1: url1, url2: url2, beginning_at: beginning_at, interval: interval)

      expect(subject.collection.first).to have_attributes(metric: 3, dimension: url1)
      expect(subject.collection.last).to have_attributes(metric: 3, dimension: url2)
      expect(subject.collection_total).to eq(6)
    end
  end

  context "current period - last_90_days" do
    let(:current_period) { :last_90_days }
    let(:beginning_at) { 100.days.ago.beginning_of_day }
    let(:interval) { 10.days }

    it "works" do
      generate_visits(count: 10, url1: url1, url2: url2, beginning_at: beginning_at, interval: interval)

      expect(subject.collection.first).to have_attributes(metric: 9, dimension: url1)
      expect(subject.collection.last).to have_attributes(metric: 9, dimension: url2)
      expect(subject.collection_total).to eq(18)
    end
  end

  context "current period - this_year" do
    let(:current_period) { :this_year }
    let(:beginning_at) { Time.current.beginning_of_year - 1.day }
    let(:interval) { 1.month }

    it "works" do
      generate_visits(count: 2, url1: url1, url2: url2, beginning_at: beginning_at, interval: interval)

      expect(subject.collection.first).to have_attributes(metric: 1, dimension: url1)
      expect(subject.collection.last).to have_attributes(metric: 1, dimension: url2)
      expect(subject.collection_total).to eq(2)
    end
  end
end
