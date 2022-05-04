class AhoyAdmin::BasePresenter
  include Pagy::Backend
  include Memery

  attr_accessor(
    :collection_total,
    :collection,
    :current_period_range,
    :current_period,
    :current_time,
    :group_by_period,
    :object,
    :page,
    :pagy,
    :ref,
  )

  def initialize(
    current_time: nil,
    current_period: nil,
    current_period_range: nil,
    ref: nil,
    page: nil
  )
    self.current_period = current_period
    self.current_period_range = current_period_range
    self.current_time = current_time || Time.current
    self.page = page
    self.ref = ref

    set_current_period_range
    set_group_by_period
    set_data
  end

  def set_current_period_range
    self.current_period_range = {
      today: current_time.beginning_of_day..current_time.end_of_day,
      last_24_hours: 24.hours.ago.beginning_of_hour..1.hours.ago.end_of_hour,
      yesterday: current_time.yesterday.beginning_of_day..current_time.yesterday.end_of_day,
      this_week: current_time.beginning_of_week..current_time.end_of_week,
      last_7_days: 7.days.ago.beginning_of_day..current_time.end_of_day,
      this_month: current_time.beginning_of_month..current_time.end_of_month,
      last_30_days: 30.days.ago.beginning_of_day..current_time.end_of_day,
      last_90_days: 90.days.ago.beginning_of_day..current_time.end_of_day,
      this_year: current_time.beginning_of_year..current_time.end_of_year,
    }[current_period]
  end

  def set_group_by_period
    self.group_by_period = {
      today: :hour,
      last_24_hours: :hour,
      yesterday: :hour,
      this_week: :day,
      last_7_days: :day,
      this_month: :day,
      last_30_days: :day,
      last_90_days: :day,
      this_year: :month,
    }[current_period]
  end

  def url_strip(url)
    uri = URI.parse(url)
    uri.host = nil
    uri.scheme = nil
    uri.port = nil
    CGI.unescape(uri.to_s)
  end

  def data_chart
    chart_adjustment(object).to_json
  end

  def chart_html_id
    self.class.name.demodulize.tableize
  end

  def unique_name
    @unique_name ||= self.class.name.demodulize.underscore.split("_")[0..-2].join("_")
  end

  def metric_and_dimension
    unique_name.split("_").values_at(0, 2)
  end

  def metric
    metric_and_dimension.first
  end

  def dimension
    metric_and_dimension.last
  end

  def dimension_human(dimension)
    dimension.presence || "(blank)"
  end

  def set_data
    ref ? set_object : set_collection
  end

  def show_dimension_link?
    false
  end

  private

  def pagy_custom(scope)
    pagy_arel(scope, size: [1,2,2,1])
  end

  def ref_clause
    ref == "null" ? nil : ref
  end

  def chart_adjustment(data)
    x = data.map { |i| i.first.to_time.to_i }
    y = data.map { |i| i.last.to_i }

    result = [x, y]

    return result if result.all?(&:blank?)

    result[0].prepend(result[0][0] - 1.send(period_adjustment).seconds.to_i)
    result[0].append(result[0][-1] + 1.send(period_adjustment).seconds.to_i)
    result[1] = [0, *result[1], 0]
    result
  end

  def period_adjustment
    case current_period
    when :today, :last_24_hours, :yesterday
      :hour
    when :this_year
      :month
    else
      :day
    end
  end

  def bots_column?
    Ahoy::Visit.columns_hash["bot"]
  end

  def params
    { page: page }
  end
end
