@isTest(seeAllData=false)
public class MainActionTakerTrigger_Test {
	static testMethod void runCounterOnNULL() {
 		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contact; 
		Map<String,Schema.RecordTypeInfo> ContactRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
		Id rtId = ContactRecordTypeInfo .get('Staff').getRecordTypeId();
		
		Contact co = new Contact();
        co.FirstName='demo';
        co.LastName ='demo';
        co.recordtypeid = rtId;
    	insert co;
    	
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
        
        List<Action_Taker__c> ataker = new List<Action_Taker__c>();
	    Action_Taker__c aa = new Action_Taker__c();
	    aa.Property__c     = prop.Id;
	    aa.Status__c = 'Active';
	    aa.Job_Request__c = 'Request';
	    aa.Job_Type__c = 'Ops - Security; Ops - Cleaning';
	    ataker.add(aa);
	    
	    aa = new Action_Taker__c();
	    aa.Department__c   = 'Operations';
	    aa.Job_Request__c = 'Request';
	    aa.Status__c = 'Active';
	    aa.Job_Type__c = 'Ops - Security; Ops - Cleaning';
	    ataker.add(aa);
	    
	    aa = new Action_Taker__c();
	    aa.Department__c   = 'Operations';
	    aa.Property__c     = prop.Id;
	    aa.Job_Request__c = 'Request';
	    aa.Status__c = 'Active';
	    aa.Job_Type__c = 'Ops - Security; Ops - Cleaning';
	    ataker.add(aa);
	    
	    insert ataker;
    }
}