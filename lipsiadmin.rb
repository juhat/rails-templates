load_template "/Users/juhat/Sites/rails-templates/base.rb"

gem "lipsiadmin"

rake "gems:install", :sudo => true

run "script/generate backend -f"

appname = ask('app name: ')
email_from = ask 'email from: '
email_from ||= 'test@atti.la'

email_help = ask 'dev help: '
email_help ||= 'test@atti.la'

host = ask 'host: '

file 'config/config.yml', <<-END
common:
  project: #{appname}
  email_from: #{email_from}
  email_help: #{email_help}
  host_addr: #{host}

production:
  host_addr: #{host}

development:
  host_addr: localhost:3000
  
test:
  host_addr: localhost:3000
END

file 'config/inizializers/exception_notifier.rb', <<-END
Lipsiadmin::Mailer::ExceptionNotifier.sender_address       = %("Exception Notifier" <test@atti.la>)
Lipsiadmin::Mailer::ExceptionNotifier.recipients_addresses = %(goraffe@atti.la)
Lipsiadmin::Mailer::ExceptionNotifier.email_prefix         = "[#{appname}]"
Lipsiadmin::Mailer::ExceptionNotifier.send_mail            = true

# Uncomment this if this mail is for redmine handler
# Lipsiadmin::Mailer::ExceptionNotifier.extra_options        = { :project => "lipsiabug", :tracker => "Bug", :priority => "Immediata" }
END

run 'rm -rf db/migrate/*'
file 'db/migrate/20100201180912_create_accounts.rb', <<-END
class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts, :force => true do |t|
      t.string      :name, :surname, :email, :salt, :crypted_password, :role, :modules
      t.timestamps
    end

    # I'll create the first account
    Account.create({:email => "test@atti.la", 
                    :name => "Test", 
                    :surname => "Test",
                    :password => "admin", 
                    :password_confirmation => "admin", 
                    :role => "administrator" })
  end

  def self.down
    drop_table "accounts"
  end
end
END

rake 'db:create'
rake 'db:migrate'
