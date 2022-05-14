Rails.application.routes.draw do
  match '/ping' => 'status#ping', via: %i(get post)

  post '/africastalking_ussd/:provider_key/:business_account/:api_key/' => 'africastalking_ussd#notify'
  get '/ussd/bj_moov/:instance_name/' => 'moov_ussd#notify'
  get '/ussd/eea/:instance_name/' => 'eea_ussd#notify'

  get '/comviva_ussd/:provider_key/:short_code/notify' => 'comviva_ussd#notify'
  post '/comviva_ussd_xml/:provider_key/:short_code/notify' => 'comviva_xml_ussd#notify'
  # keep fenixdb url until VPN is moved over
  post '/support/ussd/mtn/mtn_ug' => 'comviva_xml_ussd#notify', defaults: { provider_key: 'ug_mtn', short_code: '165*62' }
end
