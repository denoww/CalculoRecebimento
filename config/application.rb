require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module ReceberCobranca
  class Application < Rails::Application

    config.active_record.raise_in_transactional_callbacks = true


    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              'smtp.gmail.com',
      port:                 587,
      domain:               'gmail.com',
      user_name:            ENV['EMAIL_LOGIN_EXCEPTION_NOTIFICATION'],
      password:             ENV['EMAIL_PASS_EXCEPTION_NOTIFICATION'],
      authentication:       'plain',
      enable_starttls_auto: true
    }

  end
end
