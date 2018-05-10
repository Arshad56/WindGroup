@isTest(seeAllData=false)
public with sharing class NotifyBillingExecutive_Test {
    static Property__c prop;
    static Rent_Roll__c rentRoll;
   
    static testMethod void runBatchClass() {
        
	    UserRole financeRole = [select Id,DeveloperName from UserRole where Name = 'Finance' limit 1];
	    UserRole billingRole = [select Id,DeveloperName from UserRole where Name = 'Billing' limit 1];
        Profile pBilling = [SELECT Id FROM Profile WHERE Name='Billing']; 
        Profile profFinance = [Select Name, Id From Profile where name = 'Finance' limit 1 ];
        Profile profCenterS = [Select Name, Id From Profile where name = 'Centre Supervision' limit 1 ];
        
        List<User> listUnser = new List<User>();
        User uBilling = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pBilling.Id, UserRoleId = billingRole.Id ,
            TimeZoneSidKey='America/Los_Angeles', UserName='standardBillingTestuser@tmc.com');
        listUnser.add(uBilling);
        
        User uFinance = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profFinance.Id, UserRoleId = financeRole.Id ,
            TimeZoneSidKey='America/Los_Angeles', UserName='standardFinanceTestuser@tmc.com');
        listUnser.add(uFinance);
        
        User uCentrSup = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profCenterS.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardCenterSupTestuser@tmc.com');
        listUnser.add(uCentrSup);
        
        User uAdminSup = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = userinfo.getProfileId(), 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardAdminTestuser@tmc.com');
        listUnser.add(uAdminSup);
        
        User uAdminSup11 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = userinfo.getProfileId(), 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardAdmin11Testuser@tmc.com');
        listUnser.add(uAdminSup11);
        
		User uAdminSup121 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = userinfo.getProfileId(), 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardAdmin121Testuser@tmc.com');
        listUnser.add(uAdminSup121);        
        insert  listUnser;
        
        System.RunAs(uAdminSup121) { 
        	Contact con = new Contact();
	        con.email = 'Test@gmail.com';
	        con.lastName = 'Test';
	        con.Region__c = 'Asia';
	        insert con;
	         
	        prop = new Property__c();
	        prop.Name = 'TestProperty';
	        insert prop;
	        
        }
        
        System.RunAs(uAdminSup) {
	        Group testGrp = new Group();
			testGrp.Name = 'TestProperty share';
			insert testGrp;
			
			List<GroupMember> grpMmbrList = new List<GroupMember>();
			GroupMember GrpMmbr = new GroupMember();
			grpMmbr.UserOrGroupId = uBilling.Id;
			grpMmbr.GroupId = testGrp.Id;
			grpMmbrList.add(grpMmbr);
			
			GrpMmbr = new GroupMember();
			grpMmbr.UserOrGroupId = uFinance.Id;
			grpMmbr.GroupId = testGrp.Id;
			grpMmbrList.add(grpMmbr);
			
			GrpMmbr = new GroupMember();
			grpMmbr.UserOrGroupId = uCentrSup.Id;
			grpMmbr.GroupId = testGrp.Id;
			grpMmbrList.add(grpMmbr);
		
			insert grpMmbrList;
		}
		System.RunAs(uAdminSup11) {
			Count_Index__c setting = new Count_Index__c();
	        setting.Name = 'Request_ST_Index';
	        setting.Count__c = null;
	        insert setting;
	    
	        Count_Index__c setting1 = new Count_Index__c();
	        setting1.Name = 'Task_ST_Index';
	        setting1.Count__c = null;
	        insert setting1;
	        
	        cc_Email_Address__c ccMail = new cc_Email_Address__c();
	        ccMail.Name = 'Test mail';
	        ccMail.Email__c = 'test@gmail.com';
	        insert ccMail;
	        
	        rentRoll = new Rent_Roll__c();
	        rentRoll.Property__c = prop.Id;
	        rentRoll.Approved__c  = false;             
	        rentRoll.Total_Amount__c = 100;
	        
	        insert rentRoll;
	        
			List<Rent_Roll__Share> listRRshr= new List<Rent_Roll__Share>();
	        Rent_Roll__Share rr = new Rent_Roll__Share();
	        rr.ParentId = rentRoll.Id;
	        rr.UserOrGroupId = uBilling.Id;
	        rr.RowCause = 'Manual';
	        rr.AccessLevel = 'Edit';
	        listRRshr.add(rr);
	        
	        Group testGrp =[select Id, Name from Group where Name = 'TestProperty share']; 
	        rr = new Rent_Roll__Share();
	        rr.ParentId = rentRoll.Id;
	        rr.UserOrGroupId = testGrp.Id;
	        rr.RowCause = 'Manual';
	        rr.AccessLevel = 'Edit';
	        listRRshr.add(rr);
	        
	        rr = new Rent_Roll__Share();
	        rr.ParentId = rentRoll.Id;
	        rr.UserOrGroupId = uCentrSup.Id;
	        rr.RowCause = 'Manual';
	        rr.AccessLevel = 'Edit';
	        listRRshr.add(rr);
	        
	        insert listRRshr;
	        
	        Test.startTest();
        	Utility.NfyBillExeRun = true;
	         NotifyFinance_Helper.NotifyFinanceUsers(new Set<Id>{rentRoll.Id});
	         
	        rentRoll.Approved__c  = true; 
	        update rentRoll;
	        Utility.NfyBillExeRun = true; 
	        
	        NotifyBilling_Helper.NotifyBillingUsers(new Set<Id>{rentRoll.Id});
	        Utility.NfyBillExeRun = true;
	        rentRoll = new Rent_Roll__c();
	        rentRoll.Property__c = prop.Id;
	        rentRoll.Approved__c  = true;             
	        rentRoll.Total_Amount__c = 100;
	        
	        insert rentRoll;
	        Test.stopTest();
		}
    }
}