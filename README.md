# ⚠️ Archive notice

SamfundetAuth is archived as its functionality has been merged into the main [Samfundet](https://github.com/samfundet/samfundet) project.

---

# SamfundetAuth

This project rocks and uses MIT-LICENSE.

## Installation

SamfundetAuth depens upon SamfundetDomain. However, neither of these gems has been published on eg.
rubygems.org. Gem does not support fetching gems from Github repositories. This is a feature of the
Bundler. This is why we need to specify both of the gems, as if one did not depend upon the other,
even though it does.

Add the following lines to your Gemfile and run `bundle install` again.

```ruby
# SamfundetDomain is a gem which provides the application with samfundets domain models.
gem 'samfundet_domain', :git => "git://github.com/Samfundet/SamfundetDomain.git"

# SamfundetAuth is a gem which provides the application with methods for authenticating against mdb2.
gem 'samfundet_auth', :git => "git://github.com/Samfundet/SamfundetAuth.git"
```

Copy the migrations to your project with the following commands.

```bash
rake samfundet_domain_engine:install:migrations
rake samfundet_auth:install:migrations
```

Run `rake db:migrate` to execute the newly created migrations.

You may add the following line to your db/seeds.rb to seed group types, groups, areas, member
and roles. (samfundet_domain_engine:db:seed is automatically invoked from samfundet_auth.)

```ruby
Rake::Task['samfundet_auth_engine:db:seed'].invoke
```

## Updating

Run the following commands to update the gem.

```bash
bundle update --source samfundet_domain
bundle update --source samfundet_auth
rake samfundet_domain_engine:install:migrations
rake samfundet_auth:install:migrations
```

Run `rake db:migrate` again to execute any newly created migrations.

## Usage

If installed correctly, you will have access to six new models: Group, GroupType, Area, Role,
MembersRole and Member. They can all be utilized exactly like any other models. They may be
decorated using standards ways of decorating models provided by engines.

## Example

Below is some example code of how authentication can be done using samfundet_auth and
declarative_authorization. The variable @current_user will then be available in your views.

```ruby
class ApplicationController < ActionController::Base
  def current_user
    unless session[:member_id].nil?
      @current_user = Member.find session[:member_id]
    end
  end
end
```

```ruby
class SessionsController < ApplicationController
  def new
  end

  def create
    member = Member.authenticate params[:member][:mail], params[:member][:passord]

    if member.nil?
      flash[:error] = "Du tastet inn feil brukernavn eller passord."
      redirect_to login_path
    else
      flash[:success] = "Du er nå logget inn."
      session[:member_id] = member.id
      redirect_to root_path
    end
  end
end
```

```ruby
= semantic_form_for Member.new, :url => login_path do |f|
  = f.inputs do
    = f.input :mail
    = f.input :passord, :as => :password
  = f.actions do
    = f.action :submit, :label => "Logg inn"
```

```ruby
YourApplication::Application.routes.draw do
  match '/login', :to => 'sessions#new', :via => :get
  match '/login', :to => 'sessions#create', :via => :post
end
```
