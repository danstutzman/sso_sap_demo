#!/usr/bin/env ruby
require 'bundler'
require 'sinatra'
require 'haml'
require 'base64'
require 'open3'
require 'sinatra/flash'
require 'sso_sap'

KEYSTORE_PATH = 'java/keystore'
CERT_PATH = 'java/verify.der'

set :port, 4567

class AppError < RuntimeError
end

get '/' do
  logged_in = false
  if request.cookies['MYSAPSSO2']
    begin
      @user = SsoSap.extract_user_from_ticket(
        request, Base64.encode64(File.read(CERT_PATH)))
      logged_in = true
    rescue SsoSap::TicketError => e
      response.delete_cookie 'MYSAPSSO2'
      flash.now[:error] = e.to_s
    end
  end
  haml logged_in ? :fake_sap_portal_logged_in : :fake_sap_portal_logged_out
end

post '/' do
  if request.params['login']
    user_id = params['user_id'] || ''
    if !user_id.match(/^[0-9A-Za-z_-]+$/)
      raise AppError, 'Bad user_id'
    end
    timeout_minutes = params['minutes_before_expiration'] || ''
    if !timeout_minutes.match(/^[0-9]+$/)
      raise AppError, 'Bad minutes_before_expiration'
    end
  
    if !File.exists?(KEYSTORE_PATH)
      raise AppError, 'You must first create the keystore'
    end
  
    command = [
      'java/issue_logon_ticket.sh', KEYSTORE_PATH, user_id, timeout_minutes
    ].join(' ')
    stdin, stdout, stderr = Open3.popen3(command)
    error = stderr.gets
    if error
      raise AppError, "Error running #{command}: #{error}"
    end
    logon_ticket = stdout.gets
  
    response.set_cookie 'MYSAPSSO2', logon_ticket
  elsif request.params['logout']
    session[:user_id] = nil
    response.delete_cookie 'MYSAPSSO2'
  end
  redirect '/'
end
