# frozen_string_literal: true

require_relative "lib/ahoy_admin/version"

Gem::Specification.new do |spec|
  spec.name = "ahoy_admin"
  spec.version = AhoyAdmin::VERSION
  spec.authors = ["Followers Tracker"]
  spec.email = ["support@followerstracker.com"]
  spec.homepage = "https://followerstracker.com"
  spec.summary = "Ahoy Admin"
  spec.description = "Ahoy Admin Panel"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/followerstracker/ahoy_admin"
  spec.metadata["changelog_uri"] = "https://github.com/followerstracker/ahoy_admin/Changelog"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency("active_record_extended")
  spec.add_dependency("ahoy_matey", "~> 4.0")
  spec.add_dependency("bootstrap", "~> 5.2")
  spec.add_dependency("groupdate", "~> 6.1")
  spec.add_dependency("memery")
  spec.add_dependency("pagy")
  spec.add_dependency("rails", ">= 6")
  spec.add_dependency("slim")
end
