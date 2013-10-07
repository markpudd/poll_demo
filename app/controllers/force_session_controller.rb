require 'net/http'

class ForceSessionController < ApplicationController
 
  def authorize


    
    
    uri = URI.parse("https://login.salesforce.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new('/services/oauth2/token')
    request.add_field('Content-Type', 'application/x-www-form-urlencoded')

    crypt = ActiveSupport::MessageEncryptor.new(ENV['DB_TOKEN'])

    code = CGI::escape(params['code'])
    client_id = crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_CLIENT_ID').first.value)
    client_secret = crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_CLIENT_SECRET').first.value)
    request.body = "code=#{code}&grant_type=authorization_code&client_id=#{client_id}&client_secret=#{client_secret}&redirect_uri=#{ENV['REDIRECT_URL']}"

    response = http.request(request)

    data = JSON.parse(response.body)

    id = data['id']
    refresh_token = data['refresh_token']
    instance_url = data['instance_url']
    signature = data['signature']
    access_token = data['access_token']


    if id
      save_config(crypt, 'SF_ID', id)
    end

    if refresh_token
      save_config(crypt, 'SF_REFRESH_TOKEN', refresh_token)
    end

    if instance_url
      save_config(crypt, 'SF_INSTANCE_URL', instance_url)
    end

    if signature
      save_config(crypt, 'SF_SIGNATURE', signature)
    end

    if access_token
      save_config(crypt, 'SF_ACCESS_TOKEN', access_token)
    end

    render text: "Done"
  end

  def save_config(crypt, name, value)
    config = EnvConfig.where(name: name).first
    if !config
      config = EnvConfig.new
      config.name = name
    end
    config.value = crypt.encrypt_and_sign(value)
    config.save
  end
  
  
  def create
  
    crypt = ActiveSupport::MessageEncryptor.new(ENV['DB_TOKEN'])
    
    config = EnvConfig.where(name: 'SF_TOKEN').first
    if !config
      config = EnvConfig.new
      config.name = 'SF_TOKEN'
    end
    config.value = crypt.encrypt_and_sign(request.env['omniauth.auth']['credentials']['token'])
    config.save
  
    config = EnvConfig.where(name: 'SF_INSTANCE_URL').first
    if !config
      config = EnvConfig.new
      config.name = 'SF_INSTANCE_URL'
    end
    config.value = crypt.encrypt_and_sign(request.env['omniauth.auth']['instance_url'])
    config.save
    
    render :text => request.env['omniauth.auth'].inspect
  end
end
