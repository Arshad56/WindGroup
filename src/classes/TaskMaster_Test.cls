@isTest(seeAllData=false)
public with sharing class TaskMaster_Test {
    static testMethod void runTaskMaster_Test() {
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
        
	    Request__c rr = new Request__c();
	    rr.name = 'TestRec'; 
	    rr.Property__c = prop.Id;
	    insert rr;
	    
	    Tasklist_Master__c tm = new Tasklist_Master__c();
	    tm.Name = 'test Master';
	    insert tm;
	    
	    Tasklist_Items__c ti = new Tasklist_Items__c();
	    ti.Instructions__c = '';
	    ti.Priority__c = 'Normal';
	    ti.Requested_Completion_Days__c = 10;
	    ti.Tasklist_Master__c = tm.Id;
	    ti.Subject__c = 'Call';
	    ti.Status__c = 'Open';
	    
	    insert ti;
	    
	    Test.startTest();
	    
	    PageReference pageRef = Page.TaskMaster;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('request_Id', rr.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(rr);
		
		TaskMaster_Controller testAccPlan = new TaskMaster_Controller();
		testAccPlan.ti.Tasklist_Master__c = tm.Id;
		testAccPlan.Save();
		testAccPlan.ti.Tasklist_Master__c = null;
		testAccPlan.Save();
		ti.Requested_Completion_Days__c = null;
		update ti;
		testAccPlan.ti.Tasklist_Master__c = tm.Id;
		testAccPlan.Save();
	    Test.stopTest();
    }
}