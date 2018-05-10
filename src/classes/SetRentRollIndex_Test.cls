@isTest(seeAllData=false)
public with sharing class SetRentRollIndex_Test {
    static TestMethod void Test(){
        Property__c prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;
        rentRoll.Total_Amount__c = 100;
        
        insert rentRoll;
    }
}