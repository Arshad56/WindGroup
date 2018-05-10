@isTest(seeAllData=false)
public with sharing class MainLOIUnitTrigger_Test {
   static Property__c prop;
   static Units__c unt;
   static LOI_Unit__c lu;
   static LOI_Unit__c lu2;
    static void init(){
         prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addYears(1);
        unt.Charge_Method__c = 'Monthly Rate - CL';
        insert unt;
        
        Account acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;
        
        LOI__c ls = new LOI__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;        
        insert ls;
        
        lu = new LOI_Unit__c();
        lu.LOI_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.LOI_Start_Date__c = unt.Start_Date__c+2;
        lu.LOI_End_Date__c = unt.Start_Date__c+3;
        lu.Update_LOI_Plans__c = true;
        
        lu2 = new LOI_Unit__c();
        lu2.LOI_Agreement_No__c = ls.Id;
        lu2.Unit__c = unt.Id;
        lu2.LOI_Start_Date__c = unt.Start_Date__c;
        lu2.LOI_End_Date__c = unt.Start_Date__c+1;
        insert lu2;
    }
     static testMethod void Test(){
         init();
         Test.startTest();
         try{
            insert lu;
         }catch(Exception e){
            System.debug(e);
         }
         
         
         Test.stopTest();
     }
       static testMethod void Test1(){
         init();
         Test.startTest();
         lu2.Update_LOI_Plans__c = true;
         update lu2;
         Test.stopTest();
     }      
}