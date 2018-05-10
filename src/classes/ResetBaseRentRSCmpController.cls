public class ResetBaseRentRSCmpController {
  
    @AuraEnabled
    public static string checkChargeType(String recordId){
        String msg = 'Success';
        
        try{
            List<Lease_Charges__c > leaseChargeLst = [SELECT Id FROM Lease_Charges__c WHERE Id=:recordId AND Base_Charge_Type__c = null];
            
            if(leaseChargeLst.size() > 0)
                return 'Info: Please select Base Charge Type before reset Base Rent RS.';
            
        }catch(Exception e){    
            msg = 'Error : '+e.getMessage();
        }
        return msg;
    }
}