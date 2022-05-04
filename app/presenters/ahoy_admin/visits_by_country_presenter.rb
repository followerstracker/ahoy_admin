class AhoyAdmin::VisitsByCountryPresenter < AhoyAdmin::BasePresenter

  def set_object
    self.object = base_scope
      .where(country: ref_clause)
      .group_by_period(group_by_period, :started_at, range: current_period_range)
      .count
  end

  def set_collection
    visits_by_country = base_scope
      .group(:country)
      .order("1 desc, 2")
      .select("count(*) AS metric, country as dimension")

    self.pagy, self.collection = pagy_custom(visits_by_country)

    self.collection_total = Ahoy::Event
      .with(visits_by_country: visits_by_country.to_sql)
      .from("visits_by_country")
      .pick("sum(metric)::integer")
  end

  private

  def base_scope
    scope = Ahoy::Visit.where(started_at: current_period_range)
    scope = scope.where(bot: nil) if bots_column?
    scope
  end
end
