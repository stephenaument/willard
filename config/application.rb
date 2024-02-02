require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module Willard
  class Application < Rails::Application
    config.assets.quiet = true

    config.generators do |generate|
      generate.helper false
      generate.javascripts false
      generate.controller_specs false
      generate.request_specs true
      generate.routing_specs false
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
    end

    config.action_controller.action_on_unpermitted_parameters = :raise
    config.load_defaults 7.0

    config.generators.system_tests = nil
    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = nil
    config.action_mailbox.queues.routing = nil
    config.active_storage.queues.analysis = nil
    config.active_storage.queues.purge = nil
    config.active_storage.queues.mirror = nil
  end
end
