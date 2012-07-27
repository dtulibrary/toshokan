# RVM bootstrap
# $:.unshift(File.expand_path('./lib', ENV['rvm_path']))

require 'rvm/capistrano'

set :rvm_ruby_string, '1.9.3-p194'
set :rvm_type, :system

# bundler bootstrap
require 'bundler/capistrano'

set :stages, %w(unstable staging production)
set :default_stage, "unstable"
require 'capistrano/ext/multistage'

def configure_stage(conf = {})
  set :conf, conf
  set :application, "#{conf[:host]}"
  set :env, conf[:env]
  set :rails_env, "#{conf[:env]}"
  set :deploy_to, "/var/www/#{conf[:host]}"

  role :web, "#{conf[:host]}"
  role :app, "#{conf[:host]}"
  role :db, "#{conf[:host]}", :primary => true
end

# server details
default_run_options[:pty] = true
ssh_options[:forward_agent] = false
set :deploy_via, :remote_cache
set :user, "passenger"
set :use_sudo, false

# repo details
set :scm, :git
set :scm_username, ENV['CAP_USER']
set :repository, ENV['SCM']
if variables.include?(:branch_name)
  set :branch, "#{branch_name}"
else
  set :branch, "master"
end  
set :git_enable_submodules, 1

# tasks

before "deploy:assets:precompile", "config:update", "config:symlink"

# install configuration files not included in main scm
namespace :config do
        
  desc "update configuration from separate repository"
  task :update do
    run "mkdir -p #{deploy_to}/shared/config"
    run "cd ~/toshokan-config-#{env} && git pull && cp database.yml solr.yml application.local.rb #{deploy_to}/shared/config"
  end
  
  desc "linking configuration to current release"
  task :symlink do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/shared/config/solr.yml #{release_path}/config/solr.yml"
    run "ln -nfs #{deploy_to}/shared/config/application.local.rb #{release_path}/config/application.local.rb"
  end
end

# load deploy:seed task
load 'lib/deploy/seed' 

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end


