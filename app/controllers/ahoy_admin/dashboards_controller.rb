class AhoyAdmin::DashboardsController < AhoyAdmin::ApplicationController

  before_action(:verify_widget, only: :widget)
  before_action(:verify_period)
  around_action(:set_time_zone)

  PERIODS = [
    %i[today last-24-hours yesterday],
    %i[this-week last-7-days],
    %i[this-month last-30-days last-90-days this-year],
  ].freeze

  def overview
    @presenter = AhoyAdmin::OverviewPresenter.new(current_period: current_period)
  end

  def widget
    send(current_widget)
  end

  AhoyAdmin::Engine.config.widgets.each do |widget|
    define_method(widget) do
      @presenter = "AhoyAdmin::#{widget.classify}Presenter".constantize.new(
        current_period: current_period,
        ref: params[:ref],
        page: params[:page],
      )
      render(:presenter)
    end
  end

  protected

  attr_reader(:presenter)

  helper_method(:presenter)

  def set_time_zone(&block)
    Time.use_zone(AhoyAdmin::Engine.config.time_zone, &block)
  end

  def verify_widget
    return true if current_widget.in?(AhoyAdmin::Engine.config.widgets)

    render(plain: "Not Found", status: :not_found) && false
  end

  def verify_period
    return true if params[:period].blank?
    return true if PERIODS.flatten.include?(params[:period].to_sym)

    redirect_to(root_path)

    false
  end

  def current_widget
    @current_widget ||= params[:widget].to_s.underscore
  end

  def current_period
    params[:period]&.gsub("-", "_")&.to_sym || :last_7_days
  end
end
