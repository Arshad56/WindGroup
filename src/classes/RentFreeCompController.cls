public class RentFreeCompController {
	 @AuraEnabled
    public static Lease__c getLease(String recordId){
        Lease__c ls = [Select id,Rent_Free_Start_Date__c,Rent_Free_End_Date__c,Lease_Start_Date__c,Lease_End_Date__c from Lease__c where id=:recordId limit 1];
        return ls;
    }
    
    @AuraEnabled
    public static String saveLeaseRecord(Lease__c l){
        try{
            RentFreeLeaseController renFee = new RentFreeLeaseController();
            renFee.lease = l;
			renFee.proceed();
            
            if(renFee.success) 
            	return 'Success';
            else
                return 'Error';
        }catch(Exception e){            
            System.debug('###Lease Change Date Exception Occured:' + e.getMessage());
            return 'Error---:'+e.getMessage();
        }
    }
}