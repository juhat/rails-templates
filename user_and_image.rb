load_template "http://github.com/juhat/rails-templates/raw/master/base.rb"

gem 'authlogic'
rake "gems:install", :sudo => true

#USER model

generate :model, 'user'

run 'rm -rf db/migrate/*'

file 'db/migrate/20100101000000_create_users.rb', <<-END
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      #t.string    :login,               :null => false                # optional, you can use email instead, or both
      t.string    :email,               :null => false                # optional, you can use login instead, or both
      t.string    :crypted_password,    :null => false                # optional, see below
      t.string    :password_salt,       :null => false                # optional, but highly recommended
      t.string    :persistence_token,   :null => false                # required
      t.string    :single_access_token, :null => false                # optional, see Authlogic::Session::Params
      t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability

      # Magic columns, just like ActiveRecord's created_at and updated_at. These are automatically maintained by Authlogic if they are present.
      t.integer   :login_count,         :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      t.integer   :failed_login_count,  :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      t.datetime  :last_request_at                                    # optional, see Authlogic::Session::MagicColumns
      t.datetime  :current_login_at                                   # optional, see Authlogic::Session::MagicColumns
      t.datetime  :last_login_at                                      # optional, see Authlogic::Session::MagicColumns
      t.string    :current_login_ip                                   # optional, see Authlogic::Session::MagicColumns
      t.string    :last_login_ip                                      # optional, see Authlogic::Session::MagicColumns
    end
  end
  
  def self.down
    drop_table :users
  end
end
END

file 'app/models/user.rb', <<-END
class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = 'email'
  end
end
END

#SESSION and login

generate :session, 'user_session'
generate :controller, 'user_sessions'

route 'map.resource :user_session'
route 'map.root :controller => "user_sessions", :action => "new"'

file 'app/controllers/user_sessions_controller.rb', <<-END
class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end
end
END

file 'app/views/user_sessions/new.html.erb', <<-END
<h1>Login</h1>

<% form_for @user_session, :url => user_session_path do |f| %>
  <%= f.error_messages %>
  <%= f.label :email %><br />
  <%= f.text_field :email %><br />
  <br />
  <%= f.label :password %><br />
  <%= f.password_field :password %><br />
  <br />
  <%= f.check_box :remember_me %><%= f.label :remember_me %><br />
  <br />
  <%= f.submit "Login" %>
<% end %>
END

#SESSION PERSIST

file 'app/controllers/application_controller.rb', <<-END
# app/controllers/application.rb
class ApplicationController < ActionController::Base
  helper :all
 filter_parameter_logging :password, :password_confirmation
 helper_method :current_user_session, :current_user

 #require_user and require_no_user can be used in before filters.

 private
   def current_user_session
     return @current_user_session if defined?(@current_user_session)
     @current_user_session = UserSession.find
   end

   def current_user
     return @current_user if defined?(@current_user)
     @current_user = current_user_session && current_user_session.user
   end
   
   def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end
    
    def redirect_back_or_default(default)
        redirect_to(session[:return_to] || default)
        session[:return_to] = nil
    end
end
END

#USER REG

generate :controller, 'users'

route 'map.resource :account, :controller => "users"'
route 'map.resources :users'

file 'app/controllers/users_controller.rb', <<-END
class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end
  
  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
END

file 'app/views/users/_form.erb', <<-END
<%= form.label :email %><br />
<%= form.text_field :email %><br />
<br />
<%= form.label :password, form.object.new_record? ? nil : "Change password" %><br />
<%= form.password_field :password %><br />
<br />
<%= form.label :password_confirmation %><br />
<%= form.password_field :password_confirmation %><br />
END

file 'app/views/users/edit.html.erb', <<-END
<h1>Edit My Account</h1>

<% form_for @user, :url => account_path do |f| %>
  <%= f.error_messages %>
  <%= render :partial => "form", :object => f %>
  <%= f.submit "Update" %>
<% end %>

<br /><%= link_to "My Profile", account_path %>
END

file 'app/views/users/new.html.erb', <<-END
<h1>Register</h1>

<% form_for @user, :url => account_path do |f| %>
  <%= f.error_messages %>
  <%= render :partial => "form", :object => f %>
  <%= f.submit "Register" %>
<% end %>
END

file 'app/views/users/show.html.erb', <<-END
<p>
  <b>Email:</b>
  <%=h @user.Email %>
</p>
<p>
  <b>Login count:</b>
  <%=h @user.login_count %>
</p>
<p>
  <b>Last request at:</b>
  <%=h @user.last_request_at %>
</p>
<p>
  <b>Last login at:</b>
  <%=h @user.last_login_at %>
</p>
<p>
  <b>Current login at:</b>
  <%=h @user.current_login_at %>
</p>
<p>
  <b>Last login ip:</b>
  <%=h @user.last_login_ip %>
</p>
<p>
  <b>Current login ip:</b>
  <%=h @user.current_login_ip %>
</p>

<%= link_to 'Edit', edit_account_path %>
END

rake 'db:migrate'

#rake 'db:create:all'

git :add => ".", :commit => "-m 'Added authlogic.'"