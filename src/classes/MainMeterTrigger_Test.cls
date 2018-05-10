@isTest(seeAllData=false)
public with sharing class MainMeterTrigger_Test {
	static Property__c prop;
	static Level__c lvl;
	static Units__c unt;
    static void init(){
		prop = new Property__c();
        prop.Name = 'TestProperty';
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
        unt.Active__c = true;
        insert unt;
    }
    static testMethod void runInserRS1() {
		init();
		Test.startTest();
			Electric_Meter__c emc1= new Electric_Meter__c();
			emc1.Status__c = 'Inactive';
			emc1.Meter_No__c = 'Meter1';
			emc1.Unit__c = unt.Id;
			emc1.Start_Date__c = System.today();
			emc1.End_Date__c = System.today();
			insert emc1;
			
			
			Electric_Meter__c emc= new Electric_Meter__c();
			emc.Status__c = 'Active';
			emc.Meter_No__c = 'Meter1';
			emc.Unit__c = unt.Id;
			emc.Start_Date__c = System.today();
			emc.End_Date__c = System.today();
			insert emc;
			
			update emc;
			
			try{
				emc.Meter_No__c = 'Meter11';
				update emc;
			}catch(Exception e){
				
			}
			 emc1= new Electric_Meter__c();
			emc1.Status__c = 'Active';
			emc1.Meter_No__c = 'Meter1';
			emc1.Unit__c = unt.Id;
			emc1.Start_Date__c = System.today();
			emc1.End_Date__c = System.today();
			try{
				insert emc1;
			}catch(Exception e){
				
			}
		Test.stopTest();
	}		
}