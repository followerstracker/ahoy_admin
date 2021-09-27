class AhoyAdmin::VisitsByDevicePresenter < AhoyAdmin::BasePresenter

  def set_object
    self.object = base_scope
      .where(device_type: ref_clause)
      .send(group_by_method, :started_at, range: current_period_range)
      .count
  end

  def set_collection
    visits_by_device = base_scope
      .group(:device_type)
      .order("1 desc, 2")
      .select("count(*) AS metric, device_type as dimension")

    self.pagy, self.collection = pagy_custom(visits_by_device)

    self.collection_total = Ahoy::Event
      .with(visits_by_device: visits_by_device.to_sql)
      .from("visits_by_device")
      .pick("sum(metric)::integer")
  end

  private

  def base_scope
    scope = Ahoy::Visit.where(started_at: current_period_range)
    scope = scope.where(bot: nil) if bots_column?
    scope
  end
end
