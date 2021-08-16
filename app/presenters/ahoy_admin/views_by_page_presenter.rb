class AhoyAdmin::ViewsByPagePresenter < AhoyAdmin::BasePresenter

  def set_object
    self.object = base_scope
      .where("properties ->> 'url' = ?", ref_clause)
      .send(group_by_method, :time, range: current_period_range)
      .count
  end

  def set_collection
    views_by_page = base_scope
      .group("properties ->> 'url'")
      .order("1 desc")
      .select("count(*) AS metric, properties ->> 'url' as dimension")

    self.pagy, self.collection = pagy_arel(views_by_page)

    self.collection_total = Ahoy::Event
      .with(views_by_page: views_by_page.to_sql)
      .from("views_by_page")
      .pick("sum(metric)::integer")
  end

  def dimension_human(dimension)
    url_strip(dimension)
  end

  def show_dimension_link?
    true
  end

  private

  def base_scope
    scope = Ahoy::Event
      .where(time: current_period_range)
      .where(name: "$view")

    scope = scope.joins(:visit).where(ahoy_visits: { bot: nil }) if bots_column?
    scope
  end

end
