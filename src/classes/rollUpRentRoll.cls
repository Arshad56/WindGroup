public with sharing class rollUpRentRoll {

          list<Rent_Schedules__c> rentList=new list<Rent_Schedules__c>();


	public rollUpRentRoll() {

                     rentList=[SELECT id,Unit__r.Property__c FROM Rent_Schedules__c where Billing_Date__c=TODAY];

                     System.debug('rentList'+rentList);


                     for(Rent_Schedules__c rs : rentList){

                                System.debug(rs.Unit__r.Property__c);
                     }
	}
}