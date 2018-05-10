@isTest(seeAllData=false)
public with sharing class MainUnitTrigger_Test {
    static Property__c prop;
    static Level__c lvl;
    static Units__c unt;
    static void init(){
        prop = new Property__c();
        prop.Name = 'TestProperty';
        prop.End_Year__c = '2018';
        insert prop;
        
        lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addYears(2);
        unt.Charge_Method__c = 'Monthly Rate - L';
        unt.Gas_Meter_No__c = 'Gas10';
        unt.Phone_Extension_No__c = 'Phone10';
        unt.Water_Meter_No__c = 'Water10';
        insert unt;
        
        Account acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;        
        insert ls;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.Lease_Start_Date__c = unt.Start_Date__c;
        lu.Lease_End_Date__c = unt.Start_Date__c+1;
        insert lu;
        
        LOI__c li = new LOI__c();
        li.Tenant__c = acc.Id;
        li.Property__c = prop.Id;        
        insert li;
        
        LOI_Unit__c loi = new LOI_Unit__c();
        loi.LOI_Agreement_No__c = li.Id;
        loi.Unit__c = unt.Id;
        loi.LOI_Start_Date__c = unt.Start_Date__c+2;
        loi.LOI_End_Date__c = loi.LOI_Start_Date__c+3;
        loi.Update_LOI_Plans__c = true;
        insert loi;
        
        Electric_Meter__c em =new Electric_Meter__c();
        em.Meter_No__c = 'ele10';
        em.Unit__c =  unt.Id;
        em.Status__c = 'Active';
        insert em;
    }
    static testMethod void splitTest() {
    	init();
        Test.startTest();
            List<Lease_Plan__c > listExistingLp =[select Id from Lease_Plan__c];
            if(listExistingLp.size() > 1)
            listExistingLp.remove(1);
            delete listExistingLp;
            Units__c splitUnt = new Units__c();
            splitUnt = unt.clone(false, true);
            splitUnt.Name = unt.name+'A';
            
            splitUnt.Active__c = true;
            splitUnt.Generate_Lease_Plans__c = false;
            splitUnt.Gas_Meter_No__c = null;
	        splitUnt.Phone_Extension_No__c = null;
	        splitUnt.Water_Meter_No__c = null;
	        splitUnt.Start_Date__c = system.today()+10;
	        splitUnt.Main_Unit__c = unt.Id;
	        splitUnt.Generate_Lease_Plans__c = true;
	       
	        insert splitUnt;
	        MainUnitTrigger_Helper.createLeasePlansForSplit(new List<Units__c>{splitUnt});
	        try{
	        	splitUnt.Start_Date__c = system.today();
	        	splitUnt.Generate_Lease_Plans__c = true;
	        	update splitUnt;
	        }catch(Exception e){}
	       // MainUnitTrigger_Helper.createLeasePlansForSplit(new List<Units__c>{splitUnt});
	        /*try{
		        splitUnt.Main_Unit__c = unt.Id;
	        	splitUnt.Generate_Lease_Plans__c = true;
	        	update splitUnt;
	        }catch (Exception e){}*/
	        
        Test.stopTest();   
    }
    static testMethod void runInserRS1() {
        init();
        Test.startTest();
            Units__c unt = new Units__c();
            unt.Property__c = prop.Id;
            unt.Level__c = lvl.Id;
            unt.Name = 'TestUnit';
            unt.Active__c = true;
            unt.Generate_Lease_Plans__c = true;
            unt.Start_Date__c = system.today().addYears(3);
            unt.End_Date__c = system.today().addYears(4);
            unt.Charge_Method__c = 'Monthly Rate - L';
            unt.Gas_Meter_No__c = 'Gas20';
            unt.Phone_Extension_No__c = 'Phone20';
            unt.Water_Meter_No__c = 'Water20';
            insert unt;
            
            Electric_Meter__c em =new Electric_Meter__c();
            em.Meter_No__c = 'ele10';
            em.Unit__c =  unt.Id;
            em.Status__c = 'Active';
            insert em;
            
            unt.Generate_Lease_Plans__c = false;
            update unt;
            
            unt.Generate_Lease_Plans__c = true;
            update unt;
            
        Test.stopTest();
    }       
}