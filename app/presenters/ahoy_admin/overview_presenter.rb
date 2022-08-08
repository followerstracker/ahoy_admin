# frozen_string_literal: true

module AhoyAdmin
  class OverviewPresenter < AhoyAdmin::BasePresenter
    AhoyAdmin::Engine.config.widgets.each do |widget|
      define_method(widget) do
        "AhoyAdmin::#{widget.classify}Presenter".constantize.new(
          current_time: current_time,
          current_period: current_period
        )
      end
    end

    def initialize(*args, **kw)
      super

      # pre-fetching data
      chart_views
      chart_visits
      chart_avg_session_durations
      chart_bounce_rates
      total_views
      total_visits
    end

    def set_data
      # do nothing
    end

    memoize def data_views
      views = Ahoy::Event
        .where(time: current_period_range)
        .where(name: "$view")
        .group_by_period(group_by_period, :time, range: current_period_range)
        .order("2")

      views = views.joins(:visit).where(ahoy_visits: {bot: nil}) if bots_column?
      views.count
    end

    memoize def chart_views
      chart_adjustment(data_views)
    end

    memoize def data_visits
      visits = Ahoy::Visit
        .where(started_at: current_period_range)
        .group_by_period(group_by_period, :started_at, range: current_period_range)
        .order("2")
      visits = visits.where(bot: nil) if bots_column?
      visits.count
    end

    memoize def chart_visits
      chart_adjustment(data_visits)
    end

    memoize def data_bounce_rates
      data_views_single_page.map.with_index do |data, idx|
        [data[0], (data[1].zero? ? 0 : data[1].to_f / data_views_all[idx].last).round(2) * 100]
      end
    end

    memoize def chart_bounce_rates
      chart_adjustment(data_bounce_rates)
    end

    memoize def data_avg_session_durations
      durations = Ahoy::Visit
        .where(started_at: current_period_range)
        .joins(:events)
        .group("ahoy_visits.id")
        .select("started_at, max(time) - min(time) as duration")

      durations = durations.where(bot: nil) if bots_column?

      Ahoy::Visit
        .from("(#{durations.to_sql}) ahoy_visits")
        .group_by_period(group_by_period, :started_at, range: current_period_range)
        .average(:duration)
    end

    memoize def chart_avg_session_durations
      chart_adjustment(data_avg_session_durations)
    end

    def pages_data
    end

    memoize def total_views
      data_views.values.reduce(:+)
    end

    memoize def total_visits
      data_visits.values.reduce(:+)
    end

    memoize def total_bounce_rates
      (data_views_single_page.sum(&:last).to_f / data_views_all.sum(&:last) * 100).round(2)
    end

    memoize def total_avg_session_durations
      durations = data_avg_session_durations.map(&:last).map(&:to_i)
      sum = durations.reduce(:+)
      (sum / durations.size).to_i
    end

    private

    memoize def data_views_single_page
      views = Ahoy::Event
        .group_by_period(group_by_period, :time, range: current_period_range)
        .where(name: "$view")
        .group(:visit_id)
        .having("count(*) = 1")

      views = views.joins(:visit).where(ahoy_visits: {bot: nil}) if bots_column?

      subq = views.select("#{views.group_values[0]} as period", "count(*) as count_all").to_sql
      Ahoy::Event.from("(#{subq}) subq")
        .group(:period)
        .pluck(:period, Arel.sql("sum(count_all)"))
    end

    memoize def data_views_all
      views = Ahoy::Event
        .where(name: "$view")
        .group_by_period(group_by_period, :time, range: current_period_range)

      views = views.joins(:visit).where(ahoy_visits: {bot: nil}) if bots_column?
      views = views.count

      views.group_by(&:first)
        .transform_values { |values| values.map(&:last).sum }
        .sort_by(&:first)
    end
  end
end
