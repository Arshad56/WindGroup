@isTest(seeAllData=false)
public with sharing class MainEquipment_Test {
    static testMethod void createEquipmentndex() {
    	
    	Property__c prop = new Property__c();
        prop.Name = 'TestProperty';
        prop.Deposit_Refund_Index__c = null;
        insert prop;
        
    	Equipment__c ec = new Equipment__c();
    	ec.Name = 'System Generated';
    	ec.Property__c = prop.Id;
    	
    	insert ec;
    }
}