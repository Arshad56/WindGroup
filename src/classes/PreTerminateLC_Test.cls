@isTest(seeAllData=false)
public with sharing class PreTerminateLC_Test {
	static Property__c prop;
	static Account acc;
	static Lease_Unit__c lu;
	static Lease__c ls;
	static Lease_Charges__c lc;
	static Lease_Charges__c lcChild;
    static void init(){
        prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        Units__c unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.NLA_SQF__c = 200;
        unt.Active__c = true;
        unt.Start_Date__c = system.today().addDays(-10);
        unt.End_Date__c = system.today().addYears(2);
        unt.Charge_Method__c = 'Monthly Rate - L';
        insert unt;
        
        acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;
        
        
        ls = new Lease__c(); 
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        ls.Lease_Start_Date__c =  System.today().addDays(-10);
        ls.Lease_Tenure_Days__c = ''+31;
        insert ls;
        
        lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.Lease_End_Date__c =  System.today().addDays(30);
        insert lu;
        
        lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = system.today();
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Type__c='By Area';
        lc.Commercial_Tax_Apply__c = true;
		lc.Pre_Termination__c = false;
        insert lc;
        
        lcChild = new Lease_Charges__c();
		lcChild.Name = 'TestCharge11';
        lcChild.Active__c = true;
        lcChild.Start_Date__c = system.today();
        lcChild.End_Date__c = system.today().addYears(1);
        lcChild.Lease_Unit__c = lu.Id;
        lcChild.Billing_Frequency__c='Monthly';
        lcChild.Type__c='By Area';
        lcChild.Commercial_Tax_Apply__c = true;
        lcChild.Parent_Lease_Charge__c= lc.Id;
        
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;                
        rentRoll.Total_Amount__c = 100;
        insert rentRoll;
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        //rs.Name = unt.Name;
        rs.Lease_Unit__c = lu.Id;
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        rs.Rent_Roll__c = rentRoll.Id;
        rs.Approved__c = true;
        insert rs;
        
        rs = new Rent_Schedules__c();
        //rs.Name = unt.Name;
        rs.Lease_Unit__c = lu.Id;
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = lc.End_Date__c.addMonths(1);
        rs.End_Date__c = rs.Start_Date__c.addMonths(1);
        rs.Rent_Roll__c = rentRoll.Id;
        rs.Approved__c = true;
        insert rs;
    }  
    static TestMethod void Test1(){
    	PreTerminateLC_Test.init();
    	Test.startTest();
		try{
			//lc.Pre_Termination__c = false;
			//update lc;
			
			lc.Pre_Termination__c = true;
			lc.End_Date__c = lc.Start_Date__c.addDays(-1);
			update lc;
		}catch(Exception e){
			String message = e.getMessage();
			system.assert(message.contains('Terminat'), 'message=' + message);
		}	
		
		Test.stopTest();    	
    }
    static TestMethod void Test2(){
    	PreTerminateLC_Test.init();
    	Test.startTest();
    	try {
    		//lc.Pre_Termination__c = false;
			// lc;
			
			lc.Pre_Termination__c = true;
			lc.End_Date__c = Null;
			update lc;
		}catch(Exception e){
			 String message = e.getMessage();
	         system.assert(message.contains('Terminat'), 'message=' + message);
		}
		Test.stopTest();    
    }
    static TestMethod void Test3(){
    	PreTerminateLC_Test.init();
    	Test.startTest();
		try{
			//lc.Pre_Termination__c = false;
			//update lc;
			
			lc.Pre_Termination__c = true;
			lc.End_Date__c = system.today().addYears(1);
			update lc;
		}catch(Exception e){
			String message = e.getMessage();
			system.assert(message.contains('Terminat'), 'message=' + message);
		}
		Test.stopTest(); 
    }
    
    static TestMethod void Test4(){
    	PreTerminateLC_Test.init();
    	lcChild.Pre_Termination__c = false;
		insert lcChild;
		
    	Test.startTest();
    	try{
    		//lc.Pre_Termination__c = false;
			//update lc;
			
			lc.Pre_Termination__c = true;
			lc.End_Date__c = system.today().addDays(10);
			update lc;
		}catch(Exception e){
			String message = e.getMessage();
			system.assert(message.contains('Terminat'), 'message=' + message);
		}
		Test.stopTest();
    } 
}