source 'https://rubygems.org'

ruby "2.0.0"
gem 'rails'

gem 'jquery-rails'
gem 'sass-rails'
gem 'uglifier'

gem 'coffee-rails'
gem 'bower-rails'
gem 'jbuilder'

gem 'exception_notification'
group :production do
  gem 'pg'
end

group :development, :test do
  gem 'sdoc', group: :doc
  # Call 'debugger' anywhere in the code to stop execution and get a debugger console
  gem 'sqlite3'

  gem 'byebug'
  #gem 'pry-byebug' #home
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'webrick', '~> 1.3.1'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

