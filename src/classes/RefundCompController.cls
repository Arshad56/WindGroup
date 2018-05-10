public class RefundCompController {
    //This function is used to check Deposit
    @AuraEnabled
    public static String checkStatus(String recordId){
        String msg = 'Success';
        List<Deposit__c> depList = [Select Id,Voided__c,Currency_Code__c, Status__c, tenant__c, Property__c, Exchange_Rate__c, 
                                           Lease__c,Lease__r.Lease_Status__c,Deposit_Amount__c,Amount_Paid__c,
                                           Remaining_Deposit__c,PV_Currency_Code__c 
                                    FROM Deposit__c WHERE Id=: recordId];
        
        if(depList.size() > 0 ){
            Deposit__c d = depList.get(0);
            
            if(d.Voided__c)
                msg = 'Error: Deposit is already voided so it cannot be refunded.';
            else if(d.Amount_Paid__c == null || d.Amount_Paid__c == 0)
                msg = 'Error: No available deposit amount for refund.';
            else if(d.Lease__r.Lease_Status__c!='Expired' && d.Lease__r.Lease_Status__c!='Renewed')
                msg = 'Note : Lease is not Expired or Renewed yet.';
        }else{
            msg = 'Error: Deposit not found.';
        }
        return msg;
    }
    
     @AuraEnabled
    public static Deposit__c fetchDeposit(String recordId){
        List<Deposit__c> depList = [Select Id,Voided__c,Currency_Code__c, Status__c, tenant__c, Property__c, Exchange_Rate__c,
                                    Lease__c,Lease__r.Lease_Status__c,Deposit_Amount__c,Amount_Paid__c,Remaining_Deposit__c,
                                    PV_Currency_Code__c FROM Deposit__c WHERE Id=: recordId];
                                    
        
        if(depList.size() > 0 ){
            Deposit__c d = depList.get(0);
            d.Requested_Amount__c = 0.0;
            return d;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static String refund(Deposit__c deposit){
        String msg = '';
        try{
            
            if(deposit.Id !=null && !Approval.isLocked(deposit.Id)){
                      
                if(deposit.Requested_Amount__c > deposit.Remaining_Deposit__c){
                    msg = 'Error: Total Requested amount cannot exceed amount paid.';
                    return msg;
                }    
                
                if(deposit.Status__c != 'Paid'){
                    msg = 'Error: Deposit must be fully paid.';
                    return msg;
                }
                
                List<Payment_Voucher__c> existingPvList = [Select id from Payment_Voucher__c where Deposit__c=:deposit.Id and Status__c='New'];
                if(deposit.Requested_Amount__c<=deposit.Remaining_Deposit__c){
                    if(deposit.Refund_Mode__c=='Cash' || deposit.Refund_Mode__c=='Cheque'){
                        List<Invoice__c> invList = [Select id from Invoice__c  where Status__c in ('Outstanding','Partially Paid') and Property__c = :deposit.Property__c and tenant__c= :deposit.Tenant__c and billing_Type__c != 'Credit Note' and Voided__c = false];
                        List<Deposit__c> depList = [Select id from Deposit__c  where Status__c in ('Outstanding','Partially Paid') and Property__c = :deposit.Property__c and tenant__c= :deposit.Tenant__c and Voided__c = false];
                        
                        if(invList.size()>0 || depList.size()>0){
                            msg = 'Error: Outstanding Invoices/Deposits are present under this Lease.Please refund using Offset Invoice.';
                            return msg;
                        }
                    }
                    deposit.Refund_Status__c = 'New';
                    
                    update deposit;
                    
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(deposit.Id);
                    req1.setSubmitterId(UserInfo.getUserId()); 
                    Approval.ProcessResult result = Approval.process(req1);
                    msg = 'Success';
                }else{
                    msg = 'Error: No available deposit amount for refund.';
                }
                
            }else{
                msg = 'Error: This deposit record is locked for approval.';
            }
            
        }catch(exception e){
            msg = 'Error: '+e.getMessage();
        }
        return msg;
    }
    
    
    
    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld) {
      
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        allOpts.sort();
        return allOpts;
    }
}