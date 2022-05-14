class StatusController < ApplicationController
  # lightweight url for alive checking
  def ping
    # trigger a server error, if something is really bad :D
    Mese::Config.providers
    Mese::Config.instances

    render plain: 'pong', status: 200
  end
end
