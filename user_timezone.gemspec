# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'user_timezone/version'

Gem::Specification.new do |spec|
  spec.name          = "user_timezone"
  spec.version       = UserTimezone::VERSION
  spec.authors       = ["Jay El-Kaake"]
  spec.email         = ["najibkaake@gmail.com"]

  spec.summary       = %q{Detects a user's timezone based on their country/state/city/etc}
  spec.description   = %q{This gem lets you add a 'has_timezone' to a User, Contact or Account that has a city, state, country or zip and it will add the #timezone attribute that will automatically populate the timezone attribute.}
  spec.homepage      = "https://www.github.com/jayelkaake/user_timezone"
  spec.license       = "MIT"

  # # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'httparty', '~> 0.13'

  spec.add_development_dependency 'rails', '~> 4.2'
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", '~> 10.0'

  spec.add_development_dependency "rspec", '~> 3.4'
end
