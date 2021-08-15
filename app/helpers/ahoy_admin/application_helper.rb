module AhoyAdmin
  module ApplicationHelper
    include Pagy::Frontend

    def link_to_period(tag)
      active = params[:period]&.to_sym == tag || params[:period].blank? && tag == :"last-7-days" ? "bg-secondary text-white" : "text-muted"
      link_to(tag.to_s.titleize, url_for(period: tag, url: params[:url]), class: "px-4 py-1 d-block #{active}")
    end

    def ahoy_admin_chart_column(chart_id, chart_data)
      result = "".html_safe
      result += content_tag(:div, "", id: chart_id)
      result +=
        nonced_javascript_tag do
          <<-JS.html_safe
        (function(o){
          o.id = "#{chart_id}"
          o.data = #{chart_data.html_safe};
          o.opts = {
            width: 472,
            height: 400,
            series: [
              {},
              {
                show: true,
                spanGaps: false,
                label: "Value",
                stroke: "#198754",
                fill: "#a3cfbb",
                paths: uPlot.paths.bars({}),
                width: 2,
              }
            ],
            scales: {},
            axes: [
              {},
              {}
            ],
          };
          o.uplot = new uPlot(o.opts, o.data, document.getElementById(o.id));
          chartResize(o.uplot, o.id);
          window.addEventListener("resize", window.throttle(() => chartResize(o.uplot, o.id), 200));
        })(namespace("chart.#{chart_id}"));
          JS
        end
      result
    end

    def admin_user?
      AhoyAdmin::Engine.config.current_user_admin.call(ahoy_admin_current_user)
    end

    def ahoy_admin_current_user
      send(AhoyAdmin::Engine.config.current_user_method)
    end
  end
end
