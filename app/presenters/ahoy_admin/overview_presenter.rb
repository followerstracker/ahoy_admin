class AhoyAdmin::OverviewPresenter < AhoyAdmin::BasePresenter

  AhoyAdmin::Engine.config.widgets.each do |widget|
    define_method(widget) do
      "AhoyAdmin::#{widget.classify}Presenter".constantize.new(
        current_time: current_time,
        current_period: current_period,
        current_period_range: current_period_range,
      )
    end
  end

  def set_data
    # do nothing
  end

  def views_data
    return @views_data if @views_data
    views = Ahoy::Event
      .where(time: current_period_range)
      .where(name: "$view")
      .send(group_by_method, :time, range: current_period_range)
      .order("2")

    views = views.joins(:visit).where(ahoy_visits: { bot: nil }) if bots_column?
    @views_data = views.count
  end

  def views_chart
    chart_adjustment(views_data)
  end

  def visits_data
    return @visits_data if @visits_data
    visits = Ahoy::Visit
      .where(started_at: current_period_range)
      .send(group_by_method, :started_at, range: current_period_range)
      .order("2")
    visits = visits.where(bot: nil) if bots_column?
    @visits_data = visits.count
  end

  def visits_chart
    chart_adjustment(visits_data)
  end

  def bounce_rates
    views_single_page.map.with_index do |data, idx|
      [data[0], (data[1].zero? ? 0 : data[1].to_f / views_all[idx].last).round(2) * 100]
    end
  end

  def bounce_rates_chart
    chart_adjustment(bounce_rates)
  end

  def avg_session_durations
    return @avg_session_durations if @avg_session_durations

    durations = Ahoy::Visit
      .where(started_at: current_period_range)
      .joins(:events)
      .group("ahoy_visits.id")
      .select("started_at, max(time) - min(time) as duration")

    durations = durations.where(bot: nil) if bots_column?

    durations_avg = Ahoy::Visit
      .from("(#{durations.to_sql}) ahoy_visits")
      .send(group_by_method, :started_at, range: current_period_range)
      .average(:duration)

    @avg_session_durations = durations_avg
  end

  def avg_session_durations_chart
    chart_adjustment(avg_session_durations)
  end

  def pages_data
  end

  def total_views
    views_data.values.reduce(:+)
  end

  def total_visits
    visits_data.values.reduce(:+)
  end

  def total_bounce_rates
    (views_single_page.sum(&:last).to_f / views_all.sum(&:last) * 100).round(2)
  end

  def total_avg_session_durations
    durations = avg_session_durations.map(&:last).map(&:to_i)
    sum = durations.reduce(:+)
    (sum / durations.size).to_i
  end

  private

  def views_single_page
    return @views_single_page if @views_single_page

    views = Ahoy::Event
      .send(group_by_method, :time, range: current_period_range)
      .group(:visit_id)
      .having("count(*) = 1")

    views = views.joins(:visit).where(ahoy_visits: { bot: nil }) if bots_column?

    views = views.count

    views = views.group_by { |i| i[0][0] }
      .transform_values { |values| values.map(&:last).sum }
      .sort_by(&:first)

    @views_single_page = views
  end

  def views_all
    return @views_all if @views_all

    views = Ahoy::Event
      .where(name: "$view")
      .send(group_by_method, :time, range: current_period_range)

    views = views.joins(:visit).where(ahoy_visits: { bot: nil }) if bots_column?
    views = views.count

    views = views.group_by(&:first)
      .transform_values { |values| values.map(&:last).sum }
      .sort_by(&:first)


    @views_all = views
  end

end
