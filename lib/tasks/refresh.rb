
def refresh_token
  puts "refreshing token"
  crypt = ActiveSupport::MessageEncryptor.new(ENV['DB_TOKEN'])
  
  client_id =  crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_CLIENT_ID').first.value)
  client_secret = crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_CLIENT_SECRET').first.value)
  refresh_token =  crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_REFRESH_TOKEN').first.value)
  

  qs = { 'grant_type' => 'refresh_token',
         'client_id' =>client_id,
         'client_secret' => client_secret,
         'refresh_token' => refresh_token}
  
  response_data = HTTParty.post("https://login.salesforce.com/services/oauth2/token", :query => qs,
             :headers => {'Content-type' => 'application/x-www-form-urlencoded'})
  
  
  access_token = response_data['access_token']
  if access_token
    config = EnvConfig.where(name: "SF_ACCESS_TOKEN").first
    if !config
      config = EnvConfig.new
      config.name = "SF_ACCESS_TOKEN"
    end
    config.value = crypt.encrypt_and_sign(access_token)
    config.save
  end
  
  access_token
end
