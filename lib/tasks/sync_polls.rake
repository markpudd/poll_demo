require "#{Rails.root}/lib/tasks/refresh"



desc "This task syncs polls"
task :sync_polls => :environment do
  
  crypt = ActiveSupport::MessageEncryptor.new(ENV['DB_TOKEN'])

  access_token =  crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_ACCESS_TOKEN').first.value)
  instance_url = crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_INSTANCE_URL').first.value)
  
  qs = {'q' =>'SELECT Id,Name, Poll_Text__c,(SELECT Answer_Ext_Id__c, Answer_Text__c, Sequence__c FROM Answers__r)  FROM Poll__c'}

  response = HTTParty.get('https://ap1.salesforce.com/services/data/v20.0/query', :query => qs,
             :headers => {'Content-type' => 'application/json',
                          'Authorization' => 'Bearer '+ access_token} )


  data = JSON.parse(response.body)
  
  if data[0] && data[0]['errorCode'] == 'INVALID_SESSION_ID'
    access_token = refresh_token
    if access_token
      response = HTTParty.get('https://ap1.salesforce.com/services/data/v20.0/query', :query => qs, :headers => {'Content-type' => 'application/json', 'Authorization' => 'Bearer '+ access_token} )
    end
  end
  
  
  puts data

  response['records'].each do | record |
    
    poll = Poll.find_by_sfid(record['Id'])
    poll = Poll.new if !poll
    poll.sfid = record['Id']
    poll.question = record['Poll_Text__c']
    poll.save

    if record['Answers__r']
      record['Answers__r']['records'].each do | answer_h |
        a = Answer.find_by_sfid(answer_h['Answer_Ext_Id__c'])
        a = Answer.new if !a
      
        a.sfid = answer_h['Answer_Ext_Id__c']
      #  a.order = answer_h['moroku__Sequence__c']
        a.answer_text =answer_h['Answer_Text__c'];
        a.poll = poll
        a.save
      end
    end

  end
  
  Rails.cache.write('poll_list_cache', Poll.all.to_json)
  
end