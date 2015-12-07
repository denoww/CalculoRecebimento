require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module ReceberCobranca
  class Application < Rails::Application

    config.active_record.raise_in_transactional_callbacks = true

    # emails
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              ENV['MAIL_DELIVERY_ADRRESS'],
      port:                 ENV['MAIL_DELIVERY_PORT'],
      domain:               ENV['DOMAIN'],
      user_name:            ENV['MAIL_DELIVERY_USER_NAME'],
      password:             ENV['MAIL_DELIVERY_PASSWORD'],
      authentication:       'plain',
      enable_starttls_auto: true
    }
  end
end
