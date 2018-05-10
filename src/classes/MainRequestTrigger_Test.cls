@isTest(seeAllData=false)
public with sharing class MainRequestTrigger_Test {
	static Contact co;
	static void init(){
	
	}
 	static testMethod void runCounterOnNULL() {
 		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contact; 
		Map<String,Schema.RecordTypeInfo> ContactRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
		Id rtId = ContactRecordTypeInfo.get('Staff').getRecordTypeId();
		
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testClass.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduse11r@testClass.com');
		
        System.runAs(u) {
        	Notify_Schedule_Request_Creation__c notify = new Notify_Schedule_Request_Creation__c();
	        notify.Name = 'Scheduled';
	        notify.Notify_ON_OFF__c = true;
	        insert notify;
	        
        	Contact userCon = new Contact();
	        userCon.FirstName='demo';
	        userCon.LastName ='demo';
	        userCon.recordtypeid = rtId;
	        userCon.Region__c = 'Asia';
	        userCon.Email = 'test@gmail.com';
	        userCon.SF_User__c = u.Id;
	    	insert userCon;
	    	
			co = new Contact();
	        co.FirstName='demo';
	        co.LastName ='demo';
	        co.recordtypeid = rtId;
	        co.Region__c = 'Asia';
	        co.Email = 'test211@gmail.com';
	    	insert co;
	    	
	    	Property__c prop = new Property__c();
	        prop.Name = 'TestProperty';
	        prop.Deposit_Refund_Index__c = null;
	        insert prop;
	        
	        Property__c prop1 = new Property__c();
	        prop1.Name = 'TestProperty1';
	        prop1.Deposit_Refund_Index__c = null;
	        insert prop1;
	        
	    	Mobile_Module__c mm = new Mobile_Module__c();
	    	mm.Name = 'iRequest';
	    	mm.Status__c = 'Active';
	    	mm.Process_Type__c = 'iRequest';
	    	mm.Type__c = 'iRequest';
	    	mm.App__c = 'iRequest';
	    	insert mm;
	    	
	    	Permission_Set__c ps= new Permission_Set__c();
	    	ps.Status__c ='Active';
	    	ps.Property__c = prop.Id;
	    	ps.Mobile_Module__c = mm.Id;
	    	insert ps;
	    	
	    	Permission_Assignment__c pas =new Permission_Assignment__c();
	    	pas.Operations_User__c = co.Id;
	    	pas.Permission_Set__c = ps.Id;
	    	pas.Status__c ='Active';
	    	pas.Notify__c =true;
	    	insert pas;
	    	
	    	pas =new Permission_Assignment__c();
	    	pas.Operations_User__c = userCon.Id;
	    	pas.Permission_Set__c = ps.Id;
	    	pas.Status__c ='Active';
	    	pas.Notify__c =true;
	    	insert pas;
	    	
	    	Permission_Set__c ps1= new Permission_Set__c();
	    	ps1.Status__c ='Active';
	    	ps1.Property__c = prop1.Id;
	    	ps1.Mobile_Module__c = mm.Id;
	    	insert ps1;
	    	
	        pas =new Permission_Assignment__c();
	    	pas.Operations_User__c = co.Id;
	    	pas.Permission_Set__c = ps1.Id;
	    	pas.Status__c ='Active';
	    	pas.Notify__c =true;
	    	insert pas;
	    	
	    	pas =new Permission_Assignment__c();
	    	pas.Operations_User__c = userCon.Id;
	    	pas.Permission_Set__c = ps1.Id;
	    	pas.Status__c ='Active';
	    	pas.Notify__c =true;
	    	insert pas;
	    	
	    	
	    	Count_Index__c setting = new Count_Index__c();
			setting.Name = 'Request_ST_Index';
			setting.Count__c = null;
			insert setting;
		
			Count_Index__c setting1 = new Count_Index__c();
			setting1.Name = 'Task_ST_Index';
			setting1.Count__c = null;
			insert setting1;
			
		    Test.startTest();
		    
		    Action_Taker__c aa1 = new Action_Taker__c();
		    aa1.Status__c = 'Active';
		    insert aa1;
		    
		    Team_Member__c tm1 = new Team_Member__c();
		    tm1.In_Charge__c = true;
		    tm1.Member__c = co.Id;
		    tm1.Status__c = 'Active';
		    tm1.Team__c = aa1.Id;
		    insert tm1;
		    
		    /*Action_Taker__c aa2 = new Action_Taker__c();
		    aa2.Action_Taker__c = co.Id;
		    aa2.Staus__c = 'Active';
		    aa2.Department__c   = 'Operations';
		    aa2.Job_Request__c = 'Request';
		    aa2.Job_Type__c = 'Ops - Security; Ops - Cleaning';
		    insert aa2;
		    
		    
		    Team_Member__c tm2 = new Team_Member__c();
		    tm2.In_Charge__c = true;
		    tm2.Member__c = co.Id;
		    tm2.Status__c = 'Active';
		    tm2.Team__c = aa2.Id;
		    insert tm2;*/
		    Action_Taker__c aa11 = new Action_Taker__c();
		    aa11.Department__c   = 'Finance';
		    aa11.Property__c     = prop.Id;
		    aa11.Status__c = 'Active';
		    aa11.Job_Request__c = 'Request';
		    aa11.Job_Type__c = 'Ops - Security; Ops - Cleaning';
		    insert aa11;
		    
		    Team_Member__c tmAA1 = new Team_Member__c();
		    tmAA1.In_Charge__c = true;
		    tmAA1.Member__c = co.Id;
		    tmAA1.Status__c = 'Active';
		    tmAA1.Team__c = aa11.Id;
		    insert tmAA1;
		    
		    Action_Taker__c aa = new Action_Taker__c();
		    aa.Department__c   = 'Operations';
		    aa.Property__c     = prop.Id;
		    aa.Status__c = 'Active';
		    aa.Job_Request__c = 'Request';
		    aa.Job_Type__c = 'Ops - Security; Ops - Cleaning';
		    insert aa;
		    
		    Team_Member__c tm3 = new Team_Member__c();
		    tm3.In_Charge__c = true;
		    tm3.Member__c = co.Id;
		    tm3.Status__c = 'Active';
		    tm3.Team__c = aa.Id;
		    insert tm3;
		    
		     Team_Member__c tm4 = new Team_Member__c();
		    tm4.In_Charge__c = false;
		    tm4.Member__c = co.Id;
		    tm4.Status__c = 'Active';
		    tm4.Team__c = aa.Id;
		    insert tm4;
		    
		    try{
			    Team_Member__c tm5 = new Team_Member__c();
			    tm5.In_Charge__c = true;
			    tm5.Member__c = co.Id;
			    tm5.Status__c = 'Active';
			    tm5.Team__c = aa.Id;
			    insert tm5;
		    }catch(Exception e){
				String message = e.getMessage();
				system.assert(message.contains('Incharge'), 'message=' + message);
			}
			
		    List<Request__c> reList= new List<Request__c>();
	        Request__c rr = new Request__c();
		    rr.name = 'TestRec'; 
		    rr.Property__c = prop.Id;
		    rr.Dept_in_Charge__c = 'Operations';
		    rr.Request_Type__c = ' Ops - Cleaning';
		    reList.add(rr);
		    rr = new Request__c();
		    rr.name = 'TestRec'; 
		    rr.Property__c = prop.Id;
		    //rr.Request_Type__c = 'Ops - Security';
		    reList.add(rr);
		    
		    rr = new Request__c();
		    rr.name = 'TestRec'; 
		    rr.Dept_in_Charge__c = 'Operations';
		    rr.Request_Type__c = 'Ops - Security';
		    reList.add(rr);
		    
		    rr = new Request__c();
		    rr.name = 'TestRec'; 
		    rr.Dept_in_Charge__c = 'Operations';
		    rr.Request_Type__c = 'Ops - Security';
		    reList.add(rr);
		    
		    rr = new Request__c();
		    rr.name = 'TestRec'; 
		    rr.Dept_in_Charge__c = 'Operations';
		    rr.Request_Type__c = 'Ops - Security';
		    rr.Team__c = aa.Id;
		    rr.Person_In_Charge__c = userCon.Id;
		    reList.add(rr);
		    
		    rr = new Request__c();  
		    rr.name = 'TestRec'; 
		    reList.add(rr);
		    insert relIst;
	        checkRecursive.makeRunTrue();
	        for(Request__c rq:relIst){
	        	rq.Status__c = 'In Progress';
	        	rr.Person_In_Charge__c = co.Id;
	        }
	        update relIst;
	        checkRecursive.makeRunTrue();
	        for(Request__c rq:relIst){
	        	rq.Status__c = 'In Progress';
	        	rr.Team__c = aa11.Id;
	        }
	        update relIst;
	        checkRecursive.makeRunTrue();
	        for(Request__c rq:relIst){
	        	rq.Status__c = 'In Progress';
	        	rq.Requested_By__c = null;
	        	rr.Person_In_Charge__c = userCon.Id;
	        }
	        update relIst;
            Test.stopTest();
        }
 	}
}