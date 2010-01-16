load_template "~/Sites/rails-templates/base.rb"

gem 'paperclip'

rake "gems:install", :sudo => true


rake 'db:migrate'

git :add => ".", :commit => "-m 'Added paperclip.'"