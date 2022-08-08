FactoryBot.define do
  factory :visit, class: "Ahoy::Visit" do
    visit_token { SecureRandom.uuid }
    visitor_token { SecureRandom.uuid }
    ip { "1.2.3.4" }
    user_agent { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36" }
    landing_page { "https://followerstracker.com" }
    browser { "Chrome" }
    os { "Windows" }
    device_type { "Desktop" }
    country { "Austria" }
    region { "Vienna" }
    city { "Vienna" }
    latitude { 48.1932 }
    longitude { 16.3747 }
    platform { "Web" }
  end
end
