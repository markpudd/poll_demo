task :sync_polls => :environment do |t, args|
  
  crypt = ActiveSupport::MessageEncryptor.new(ENV['DB_TOKEN'])

  access_token =  crypt.decrypt_and_verify(GameCore::EnvConfig.where(name: 'SF_ACCESS_TOKEN').first.value)
  instance_url = crypt.decrypt_and_verify(GameCore::EnvConfig.where(name: 'SF_INSTANCE_URL').first.value)
  
  qs = {'q' =>'SELECT Id,Name, Poll_Text__c,(SELECT Id, Answer_Text__c, Sequence__c FROM moroku__Answers__r)'}

  request = HTTParty.get('https://ap1.salesforce.com/services/data/v20.0/query', :query => qs,
             :headers => {'Content-type' => 'application/json',
                          'Authorization' => 'Bearer '+ access_token} )


  data = JSON.parse(r2.body)
  
  if data[0] && data[0]['errorCode'] == 'INVALID_SESSION_ID'
    puts "refreshing token"
    uri = URI.parse("https://login.salesforce.com")
	  http = Net::HTTP.new(uri.host, uri.port)
	  http.use_ssl = true
	  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	  request = Net::HTTP::Post.new('/services/oauth2/token')
	  request.add_field('Content-Type', 'application/x-www-form-urlencoded')
	
	  request.body = "grant_type=refresh_token&client_id=#{crypt.decrypt_and_verify(GameCore::EnvConfig.where(name: 'SF_CLIENT_ID').first.value)}&
				  client_secret=#{crypt.decrypt_and_verify(GameCore::EnvConfig.where(name: 'SF_CLIENT_SECRET').first.value)}&
				  refresh_token=#{crypt.decrypt_and_verify(GameCore::EnvConfig.where(name: 'SF_REFRESH_TOKEN').first.value)}"

	  response = http.request(request)
	  response_data = JSON.parse(response.body)
	
	 
	  access_token = response_data['access_token']
    
    if access_token
      r2 = HTTParty.get('https://ap1.salesforce.com/services/data/v20.0/query', :query => qs,
           :headers => {'Content-type' => 'application/json',
                        'Authorization' => 'Bearer '+ access_token} )
    end
  end
  
  r2['records'].each do | record |
    poll_h = record['Poll__r']
    
    poll = Poll.find_by_sfid(poll_h['Id'])
    poll = Poll.new if !poll
    poll.sfid = poll_h['Id']
    poll.poll_text = record['Poll_Text__c']
    poll.save

    if record['Answers__r']
      record['Answers__r']['records'].each do | answer_h |
        a = Answer.find_by_sfid(answer_h['Id'])
        a = Answer.new if !a
      
        a.sfid = answer_h['Id']
      #  a.order = answer_h['moroku__Sequence__c']
        a.answer =answer_h['moroku__Answer_Text__c'];
        a.save
      end
    end

  end
  
  Rails.cache.write('poll_list_cache', Poll.all.to_json)
  
end