require_relative "lib/ahoy_admin/version"

Gem::Specification.new do |spec|
  spec.name        = "ahoy_admin"
  spec.version     = AhoyAdmin::VERSION
  spec.authors     = ["Followers Tracker"]
  spec.email       = ["support@followerstracker.net"]
  spec.homepage    = "https://followerstracker.net"
  spec.summary     = "Ahoy Admin"
  spec.description = "Ahoy Admin Panel"
  spec.license     = "MIT"
  spec.required_ruby_version = "~> 2.7"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "http://mygemserver.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/followerstracker/ahoy_admin"
  spec.metadata["changelog_uri"] = "https://github.com/followerstracker/ahoy_admin/Changelog"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency("active_record_extended")
  spec.add_dependency("ahoy_matey", "~> 3.2.0")
  spec.add_dependency("bootstrap", "~> 5.0.1")
  spec.add_dependency("pagy", "~> 4.8.0")
  spec.add_dependency("rails", "~> 6.1.1")
  spec.add_dependency("slim", "~> 4.1.0")
end
