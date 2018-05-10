@isTest(seeAllData=false)
public with sharing class RequestTaskHistoryTracking_Test {
    static testMethod void runCounterOnNULL() {
    	Count_Index__c setting = new Count_Index__c();
		setting.Name = 'Request_ST_Index';
		setting.Count__c = null;
		insert setting;
	
		Count_Index__c setting1 = new Count_Index__c();
		setting1.Name = 'Task_ST_Index';
		setting1.Count__c = null;
		insert setting1;

		Property__c prop = new Property__c();
        prop.Name = 'TestProperty';
        prop.Deposit_Refund_Index__c = null;
        insert prop;
        
	    Test.startTest();
	    Request__c rr = new Request__c();
	    rr.name = 'TestRec'; 
	    rr.Property__c = prop.Id;
	    insert rr;
	    
        List<Task> ttList= new List<Task>();
	    task t = new task(
				        WhatID = rr.id,
				        Subject='Donni',
				        Status='New',
				        Property__c = prop.Id);
	    ttList.add(t);  
	    t = new task(
				        WhatID = rr.id,
				        Subject='Donni',
				        Status='New',
				        Property__c = prop.Id);
	    ttList.add(t);
	    t = new task(
				        WhatID = rr.id,
				        Subject='Donni',
				        Status='New' );
	    ttList.add(t);
	    insert ttList;
	    ttList[0].Description = 'test Description';
	    ttList[1].Description = 'test Description';
	    ttList[2].Description = 'test Description'; 
	    update ttList;
	     ttList[0].Description = 'test 00';
	    ttList[1].Description = 'test 11';
	    ttList[2].Description = 'test 22'; 
	    update ttList;
	    Test.stopTest();
	}
}