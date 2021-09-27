class AhoyAdmin::VisitsByBotPresenter < AhoyAdmin::BasePresenter

  def set_object
    self.object = base_scope
      .where(bot: ref_clause)
      .send(group_by_method, :started_at, range: current_period_range)
      .count
  end

  def set_collection
    visits_by_bot = base_scope
      .group(:bot)
      .order("1 desc, 2")
      .select("count(*) AS metric, bot as dimension")

    self.pagy, self.collection = pagy_custom(visits_by_bot)

    self.collection_total = Ahoy::Event
      .with(visits_by_bot: visits_by_bot.to_sql)
      .from("visits_by_bot")
      .pick("sum(metric)::integer")
  end

  private

  def base_scope
    Ahoy::Visit
      .where(started_at: current_period_range)
      .where.not(bot: nil)
  end
end
