public class PopulateBaseRentRsCmpController {
	  @AuraEnabled
    public static String  populateBaseRent(String recordId) {
        try{
            List<Lease_Charges__c> leaseChargeList = [SELECT Id,Base_Charge_Type__c FROM Lease_Charges__c 
                                					  WHERE  Id =: recordId];
            Lease_Charges__c lc = leaseChargeList.get(0);
            String retVal = PopulateBaseRentRsController.pplBaseRent(lc.Id, lc.Base_Charge_Type__c);
            
            return 'Info: '+retVal;
        }catch(Exception e){
            return 'Error: '+e.getMessage();           
        }
    }
}