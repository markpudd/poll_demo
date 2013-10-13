require 'salesforce_bulk_api'

def refresh_token
  puts "refreshing token"
  crypt = ActiveSupport::MessageEncryptor.new(ENV['DB_TOKEN'])
  uri = URI.parse("https://login.salesforce.com")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Post.new('/services/oauth2/token')
  request.add_field('Content-Type', 'application/x-www-form-urlencoded')

  request.body = "grant_type=refresh_token&client_id=#{crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_CLIENT_ID').first.value)}&client_secret=#{crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_CLIENT_SECRET').first.value)}&refresh_token=#{crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_REFRESH_TOKEN').first.value)}"

  response = http.request(request)
  response_data = JSON.parse(response.body)

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



desc "Sync Poll results"
task :sync_results => :environment do
  

  crypt = ActiveSupport::MessageEncryptor.new(ENV['DB_TOKEN'])
  client = Databasedotcom::Client.new :client_id =>  crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_CLIENT_ID').first.value), :client_secret => crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_CLIENT_SECRET').first.value) #client_id and client_secret respectively
  client.authenticate :token => crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_ACCESS_TOKEN').first.value), :instance_url => crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_INSTANCE_URL').first.value)
  salesforce = SalesforceBulkApi::Api.new(client)
  
  records_to_upsert = Array.new
  
  Answer.all.each do |answer|
    
    sf_data = {
      "Source__Id_c" => answer.id,
      "Answer__r" => {"Source__Id_c" => answer.id.to_s},
      "Votes__c" => answer.votes.count
    }

      records_to_upsert.push(sf_data)
  end
  puts "Syncing "+records_to_upsert.count.to_s+" records"

  begin
    job = salesforce.upsert("Poll_Result__c", records_to_upsert, "Source_Id__c") # Note that upsert accepts an extra parameter for the external field name
  rescue
    access_token = refresh_token
    if access_token
      client.authenticate :token => access_token, :instance_url => crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_INSTANCE_URL').first.value)
      salesforce = SalesforceBulkApi::Api.new(client)
      job = salesforce.upsert("Poll_Result__c", records_to_upsert, "Source_Id__c") 
    end
  end
end