@isTest
public class FSMSvcTriggerHelper_Test {
    
    @isTest
    private static void testScheduledRequest(){
        Count_Index__c setting = new Count_Index__c();
        setting.Name = 'Request_ST_Index';
        setting.Count__c = null;
        insert setting;

        Id rtId = [Select Id from RecordType where RecordType.Name = 'Staff'].Id;
        
        Property__c prop = new Property__c(Name = 'testSCProperty', Short_Code__c='TT');
        insert prop;
        
        Account acct = new Account(Name = 'TestAccount');
        insert acct;
        
        Contact con = new Contact(AccountId = acct.Id, LastName = 'Operation', email = 'asteststrequest@gmail.com', Status__c = 'Employed', RecordTypeId = rtId);
        insert con;
   
        Permission_Set__c ps = new Permission_Set__c(Status__c = 'Active');
        insert ps;
        
        Permission_Assignment__c pa = new Permission_Assignment__c(Operations_User__c = con.Id, Permission_Set__c = ps.Id, Status__c ='Active');
        insert pa;
        
        FM_Service_Contract__c sc1 = new FM_Service_Contract__c(Contact__c = con.Id, Property__c= prop.Id, Account__c = acct.Id, Service_Contract_Start_Date__c = System.today(), Term__c = 1);
        insert sc1;
        
        FM_Service_Contract__c sc2 = new FM_Service_Contract__c( Contact__c = con.Id, Property__c= prop.Id, Account__c = acct.Id, Service_Contract_Start_Date__c = System.today(), Term__c = 1);
        insert sc2;
        
        FM_Service_Contract__c sc3 = new FM_Service_Contract__c(Contact__c = con.Id, Property__c= prop.Id, Account__c = acct.Id, Service_Contract_Start_Date__c = System.today(), Term__c = 12);
        insert sc3;
        
        FM_Service_Contract__c sc4 = new FM_Service_Contract__c(Contact__c = con.Id, Property__c= prop.Id, Account__c = acct.Id, Service_Contract_Start_Date__c = System.today(), Term__c = 12);
        insert sc4;
        
        FM_Service_Contract__c sc5 = new FM_Service_Contract__c(Contact__c = con.Id, Property__c= prop.Id, Account__c = acct.Id, Service_Contract_Start_Date__c = System.today(), Term__c = 12);
        insert sc5;
        
        FM_Service_Contract__c sc6 = new FM_Service_Contract__c(Contact__c = con.Id, Property__c= prop.Id, Account__c = acct.Id, Service_Contract_Start_Date__c = System.today(), Term__c = 12);
        insert sc6;
        
        FM_Service_Contract__c sc7 = new FM_Service_Contract__c(Contact__c = con.Id, Property__c= prop.Id, Account__c = acct.Id, Service_Contract_Start_Date__c = System.today(), Term__c = 14);
        insert sc7;
        
        Action_Taker__c team = new Action_Taker__c(Job_Request__c = 'Request', Status__c ='Active', Property__c= prop.Id, Department__c ='Operations', Job_Type__c = 'Ops - M & E');
        insert team;

        Equipment__c equip = new Equipment__c(Name = '20170901-TESTEQ-0001', Property__c = prop.Id);
        insert equip;
        
        Equipment_Service_Contract__c esc2 = new Equipment_Service_Contract__c(Equipment__c = equip.Id, FM_Service_Contract__c= sc1.Id, Request_Start_Date__c = System.today(), Frequency__c = 'Daily');
        insert esc2;
        
        Equipment_Service_Contract__c esc3 = new Equipment_Service_Contract__c(Equipment__c = equip.Id, FM_Service_Contract__c= sc2.Id, Request_Start_Date__c = System.today(), Frequency__c = 'Weekly');
        insert esc3;
        
        Equipment_Service_Contract__c esc4 = new Equipment_Service_Contract__c(Equipment__c = equip.Id, FM_Service_Contract__c= sc3.Id, Request_Start_Date__c = System.today(), Frequency__c = 'Fortnightly');
        insert esc4;
        
        Equipment_Service_Contract__c esc5 = new Equipment_Service_Contract__c(Equipment__c = equip.Id, FM_Service_Contract__c= sc4.Id, Request_Start_Date__c = System.today(), Frequency__c = 'Monthly');
        insert esc5;
        
        Equipment_Service_Contract__c esc6 = new Equipment_Service_Contract__c(Equipment__c = equip.Id, FM_Service_Contract__c= sc5.Id, Request_Start_Date__c = System.today(), Frequency__c = 'Quarterly');
        insert esc6;
        
        Equipment_Service_Contract__c esc7 = new Equipment_Service_Contract__c(Equipment__c = equip.Id, FM_Service_Contract__c= sc6.Id, Request_Start_Date__c = System.today(), Frequency__c = 'Semiannually');
        insert esc7;
        
        Equipment_Service_Contract__c esc8 = new Equipment_Service_Contract__c(Equipment__c = equip.Id, FM_Service_Contract__c= sc7.Id, Request_Start_Date__c = System.today(), Frequency__c = 'Annually');
        insert esc8;

        Test.startTest();  
        	
        	esc2.create_Request__c = true;
        	update esc2;
        
            esc3.Create_Request__c = true;
            update esc3;
            
            esc4.Create_Request__c = true;
            update esc4;
            
            esc5.Create_Request__c = true;
            update esc5;
            
            esc6.Create_Request__c = true;
            update esc6;
            
            esc7.Create_Request__c = true;
            update esc7;
            
            esc8.Create_Request__c = true;
            update esc8;
        
        	esc2.Request_Start_Date__c = System.today().addDays(5);
            update esc2;
        
        	esc8.End_Date__c = System.today().addMonths(20);
            update esc8;

        Test.stopTest();     
     
    }
    
    @isTest
    private static void testSCNameValidation(){
        Count_Index__c setting = new Count_Index__c();
        setting.Name = 'Request_ST_Index';
        setting.Count__c = null;
        insert setting;
        
         Id rtId = [Select Id from RecordType where RecordType.Name = 'Staff'].Id;
        
        Property__c prop = new Property__c(Name = 'testSCProperty', Short_Code__c='TT');
        insert prop;
        
        Account acct = new Account(Name = 'TestAccount');
        insert acct;
        
        Contact con = new Contact(AccountId = acct.Id, LastName = 'Operation', email = 'asteststrequest@gmail.com', Status__c = 'Employed', RecordTypeId = rtId);
        insert con;
   
        Permission_Set__c ps = new Permission_Set__c(Status__c = 'Active');
        insert ps;
        
        Permission_Assignment__c pa = new Permission_Assignment__c(Operations_User__c = con.Id, Permission_Set__c = ps.Id, Status__c ='Active');
        insert pa;
        
        FM_Service_Contract__c sc = new FM_Service_Contract__c(Name = 'TESTSc7', Contact__c = con.Id, Property__c= prop.Id, Account__c = acct.Id, Service_Contract_Start_Date__c = System.today(), Term__c = 12);
        insert sc;
       
    }

}