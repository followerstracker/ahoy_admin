module GenerateHelpers
  def generate_visits(url1:, url2:, beginning_at:, interval:, count:)
    count.times do |x|
      visit = create :visit, started_at: beginning_at + x * interval

      create :event,
        visit: visit,
        name: "$view",
        properties: {url: url1, page: "/", title: "Title"},
        time: visit.started_at

      create :event,
        visit: visit,
        name: "$click",
        properties: {tag: "a", href: url2, page: "/", text: "@dhh"},
        time: visit.started_at + 5.seconds
      create :event,
        visit: visit,
        name: "$view",
        properties: {url: url2, page: "/twitter/dhh", title: "Title"},
        time: visit.started_at + 6.seconds
    end
  end
end
