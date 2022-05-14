# from https://github.com/seuros/capistrano-sidekiq/issues/51#issuecomment-246499540
namespace :systemd do
  namespace :puma do
    %w(start stop restart).each do |action|
      task(action.to_sym) do
        on roles %i(app db web) do
          execute :systemctl, "--user #{action} puma.service"
        end
      end
    end
  end
end
