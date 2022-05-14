# config valid only for current version of Capistrano
lock "3.16.0"

set :application, "mese"
set :repo_url, "git@git.plugintheworld.com:db-dev/mese.git"

# Default branch is :master
ask :branch, :master

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/mese"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :linked_files is []
append :linked_files, "config/database.yml", "config/secrets.yml.key", ".env"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp" # /pids", "tmp/cache", "tmp/sockets", "publc/system""

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 3

# no sidekiq tasks yet
#before 'deploy:started', 'systemd:sidekiq_stop_processing'

# no sidekiq tasks yet
#after 'deploy:published', 'systemd:sidekiq:restart'
after 'deploy:published', 'systemd:puma:restart'
