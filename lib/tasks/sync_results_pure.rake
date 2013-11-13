require 'builder'

desc "This task syncs polls"
task :sync_results_pure => :environment do


  crypt = ActiveSupport::MessageEncryptor.new(ENV['DB_TOKEN'])

  access_token =  crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_ACCESS_TOKEN').first.value)
  instance_url = crypt.decrypt_and_verify(EnvConfig.where(name: 'SF_INSTANCE_URL').first.value)
  
  
  # Create job
  
  xml = Builder::XmlMarkup.new
  xml.instruct!
  xml.job_info('xmlns'=>'http://www.force.com/2009/06/asyncapi/dataload') do |x|
    x.operation 'upsert'
    x.object 'Poll_Result__c'
    x.externalIdFieldName 'Source_Id__c'
    x.contentType 'XML'
  end

  response = HTTParty.post('https://ap1.salesforce.com/services/async/29.0/job', :body => xml.target!,
             :headers => {'Content-type' => 'application/xml',
                          'X-SFDC-Session:' =>  access_token} )

  jobId = response['jobInfo']['id']
  puts jobId
  


  xml = Builder::XmlMarkup.new
  xml.instruct!
  xml.sObjects('xmlns'=>'http://www.force.com/2009/06/asyncapi/dataload') do |x|

  Answer.all.each do |answer|
      x.sObject do |sObject|
        sObject.Source_Id__c answer.id.to_s
        sObject.Answer__r do |aa| 
          aa.sObject do |aa_sObject|
            aa_sObject.Answer_Ext_Id__c answer.sfid
          end
        end
        sObject.Votes__c  answer.votes.count.to_s
      end
    end
  end
  
  
  response = HTTParty.post('https://ap1.salesforce.com/services/async/29.0/job/'+jobId+'/batch', :body => xml.target!,
              :headers => {'Content-type' => 'application/xml',
                           'X-SFDC-Session:' =>  access_token} )
   puts response

   id = response['batchInfo']['id']



    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.job_info('xmlns'=>'http://www.force.com/2009/06/asyncapi/dataload') do |x|
      x.state 'Closed'
    end

    response = HTTParty.post('https://ap1.salesforce.com/services/async/29.0/job/'+jobId, :body => xml.target!,
                :headers => {'Content-type' => 'application/xml',
                             'X-SFDC-Session:' =>  access_token} )

    puts response


end