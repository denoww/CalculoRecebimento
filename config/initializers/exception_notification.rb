require 'exception_notification/rails'

ExceptionNotification.configure do |config|

  # Email notifier sends notifications by email.
  app_name = Rails.application.class.parent_name
  config.add_notifier :email, {
    :email_prefix => "[Erro no App: #{app_name}]",
    :sender_address => %{"Erro Prototipo" <erros.prototipos@seucondominio.com.br>},
    :exception_recipients => [ENV['EMAIL_SYS_ADMIN']]
    # :exception_recipients => ["denoww@gmail.com"]
  }
end

