# if yes?("Do you want to use RSpec for testing?")
#   plugin "rspec", :git => "git://github.com/dchelimsky/rspec.git"
#   plugin "rspec-rails", :git => "git://github.com/dchelimsky/rspec-rails.git"
#   generate :rspec
# end

run "echo 'TODO add readme content' > README"
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"
run "rm public/index.html"
run "rm public/favicon.ico"
#run "rm public/robots.txt"

file ".gitignore", <<-END
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END


git :init


plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git', :submodule => true
rake 'asset:packager:create_yml'

run 'sudo gem install nifty-generators'
generate :nifty_layout

gem 'annotate'

plugin 'action_mailer_optional_tls', :git => 'git://github.com/collectiveidea/action_mailer_optional_tls.git', :submodule => true

file 'config/environments/development.rb', <<-END
# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

ActionMailer::Base.smtp_settings = {
    :tls => true,
    :address => "smtp.gmail.com",
    :port => "587",
    :domain => "YOURDOMAIN",
    :authentication => :plain,
    :user_name => "test@atti.la",
    :password => "testtest" 
}
END

file 'config/environments/production.rb', <<-END
# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

ActionMailer::Base.smtp_settings = {
    :tls => true,
    :address => "smtp.gmail.com",
    :port => "587",
    :domain => "YOURDOMAIN",
    :authentication => :plain,
    :user_name => "GOOGLEUSERNAME",
    :password => "GOOGLEPASSWORD" 
}
END


rake "gems:install", :sudo => true


git :submodule => "init"
git :add => ".", :commit => "-m 'Initial commit.'"