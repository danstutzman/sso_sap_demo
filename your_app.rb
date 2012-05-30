#!/usr/bin/env ruby
require 'bundler'
require 'sinatra'
require 'haml'
require 'base64'
require 'sinatra/flash'
require 'sso_sap'

CERT_PATH = 'java/verify.der'

set :port, 4568

get '/' do
  begin
    @user = SsoSap.extract_user_from_ticket(
      request, Base64.encode64(File.read(CERT_PATH)))
    haml :your_app_logged_in
  rescue SsoSap::TicketError => e
    flash.now[:error] = e.to_s
    haml :your_app_logged_out
  end
end
