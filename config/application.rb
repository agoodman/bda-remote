require_relative 'boot'

require 'rails/all'
#require 'rails'
#require 'active_record/railtie'
#require 'active_controller/railtie'
#require 'active_storage/railtie'
#require 'action_view/railtie'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bdascores
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.eager_load_paths += %W(#{config.root}/lib)
  end
end
