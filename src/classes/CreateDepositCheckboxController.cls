public with sharing class CreateDepositCheckboxController {
 
    @AuraEnabled
    public static list <Lease_Unit__c> fetchLeaseUnit(String recordId) {
        return [SELECT Id,Name,Unit__c,Unit__r.Name,Area_Sq_Ft__c,Handover_Date__c From Lease_Unit__c WHERE Lease_Agreement_No__c =: recordId];
    }
 
    @AuraEnabled
    public static String processRecords(List <String> lstRecordId) {
        return '';
    }
    @AuraEnabled
	public static String deleteLU(Id id) {
	    // Perform isDeletable() check here 
	     
	    delete new Lease_Unit__c( Id = id);
	    return '';
	}
}