global class VoidpaymentVoucherController{
    webservice static string void(string pvId){
        try{
            List<Cash_Detail__c> cdList = [Select id from Cash_Detail__c where Payment_Voucher__c=:pvId];
            Payment_Voucher__c pv = [Select id, Void__c from Payment_Voucher__c where Id=:pvId];
            pv.Void__c = true;
            update pv;
            
            if(cdList.size()>0){
                return 'This Payment Voucher is already used so it cannot be voided.';
            }
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(pvId);
            req1.setSubmitterId(UserInfo.getUserId()); 
            Approval.ProcessResult result = Approval.process(req1);
            
            return 'Record submitted for approval successfully.';
        }catch(exception e){
            return e.getMessage();
        }
        return null;        
    }
}