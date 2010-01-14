if yes?("Do you want to use RSpec for testing?")
  plugin "rspec", :git => "git://github.com/dchelimsky/rspec.git"
  plugin "rspec-rails", :git => "git://github.com/dchelimsky/rspec-rails.git"
  generate :rspec
end

run "gem install nifty-generators", :sudo => true
generate :nifty_layout

run "echo 'TODO add readme content' > README"
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"

file ".gitignore", <<-END
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END

git :init

plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git', :submodule => true
rake 'asset:packager:create_yml'

git :submodule => "init"
git :add => ".", :commit => "-m 'Initial commit.'"