AhoyAdmin::Engine.routes.draw do
  root("dashboards#overview")

  get("dashboards/*widget" => "dashboards#widget", as: :widget_dashboards)
end
