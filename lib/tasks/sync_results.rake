require 'salesforce_bulk_api'

desc "Sync Poll results"
task :sync_results => :environment do
  

  crypt = ActiveSupport::MessageEncryptor.new(ENV['DB_TOKEN'])
  client = Databasedotcom::Client.new :client_id =>  crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_CLIENT_ID').first.value), :client_secret => crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_CLIENT_SECRET').first.value) #client_id and client_secret respectively
  client.authenticate :token => crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_ACCESS_TOKEN').first.value), :instance_url => crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_INSTANCE_URL').first.value)
  salesforce = SalesforceBulkApi::Api.new(client)
  
  records_to_upsert = Array.new
  
  Answer.all.each do |answer|
    
    sf_data = {
      "Answer__r" => {"Id__c" => answer.sfid.to_s},
      "Votes__c" => answer.votes.count,
      "Source__Id_c" => answer.id.to_s
    }

      records_to_upsert.push(sf_data)
  end

    job = salesforce.upsert("Poll_Result__c", records_to_upsert, "Source_Id__c") # Note that upsert accepts an extra parameter for the external field name
end