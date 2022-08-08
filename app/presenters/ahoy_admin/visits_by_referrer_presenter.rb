# frozen_string_literal: true

module AhoyAdmin
  class VisitsByReferrerPresenter < AhoyAdmin::BasePresenter
    def set_object
      self.object = base_scope
        .where(referring_domain: ref_clause)
        .group_by_period(group_by_period, :started_at, range: current_period_range)
        .count
    end

    def set_collection
      visits_by_referrer = base_scope
        .group(:referring_domain)
        .order("1 desc, 2")
        .select("count(*) AS metric, referring_domain as dimension")

      self.pagy, self.collection = pagy_custom(visits_by_referrer)

      self.collection_total = Ahoy::Event
        .with(visits_by_referrer: visits_by_referrer.to_sql)
        .from("visits_by_referrer")
        .pick("sum(metric)::integer")
    end

    private

    def base_scope
      scope = Ahoy::Visit
        .where(started_at: current_period_range)
        .where.not(referring_domain: AhoyAdmin::Engine.config.domains)

      scope = scope.where(bot: nil) if bots_column?
      scope
    end
  end
end
