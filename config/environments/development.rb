require 'simple_worker'

SimpleWorker.configure do |config|
  config.token = 'tSNJz33ZkkKdBWvUhvYBNIEmhbQ'
  config.project_id = '4ed7ace3b786c80144000060'
end
Consonrisas::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  
ActionMailer::Base.smtp_settings = {
  :address        => "smtp.sendgrid.net",
  :port           => "25",
  :authentication => :plain,
  :user_name      => ENV['app366774@heroku.com'],
  :password       => ENV['94418ccb8c1b86975f'],
  :domain         => 'heroku.com'
}

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
#  config.load_paths += %W( #{RAILS_ROOT}/app/workers )

  config.autoload_paths += %W( #{::Rails.root.to_s}/app/workers )
end

