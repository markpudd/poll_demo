Polls Demo
=========

This is the demo application for my Dreamforce 2013 presentation. 

There are the main rake tasks:-

	* sync_polls - Example of using the REST API to load the polls from Force.com
	* sync_results_pure - Example of using the Bulk API directly.   
		This builds the XML to create and close the batch.  
		I'de recommend this technique over the using th GEM
	* sync_results -  Example of using th salesforce_bulk_api gem
	
There is also simple DB encryption of tokens so you'll need the DB_TOKEN environment variable set in order to run.   


Future
------

I may implement a GEM around all of this to manage the OAuth and the REST/Bulk requests......