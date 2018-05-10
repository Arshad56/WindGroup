public Class DepositRefundController{
    public Deposit__c deposit{get;set;}    
    public string warningMsg{get;set;}
    public DepositRefundController(){
        deposit = new Deposit__c();
        for(Deposit__c dp:[Select id,Currency_Code__c, Status__c, tenant__c, Property__c, Exchange_Rate__c, Lease__c,Lease__r.Lease_Status__c,Deposit_Amount__c,Amount_Paid__c,Remaining_Deposit__c,PV_Currency_Code__c from Deposit__c where id=:Apexpages.currentPage().getParameters().get('Id')]){
            deposit = dp;
            deposit.Requested_Amount__c = 0.0;
        }
        
        if(deposit.Id!=null){
            if(deposit.Lease__r.Lease_Status__c!='Expired' && deposit.Lease__r.Lease_Status__c!='Renewed'){
                warningMsg = 'Note : Lease is not Expired or Renewed yet.';
            }
        }
    }
    
    public pageReference refund(){
        try{
            
            if(deposit.Id !=null && !Approval.isLocked(deposit.Id)){
                      
                if(deposit.Requested_Amount__c > deposit.Remaining_Deposit__c){
                    Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,'Total Requested amount cannot exceed amount paid.'));
                    return null;
                }
                
                if(deposit.Status__c != 'Paid'){
                    Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,'Deposit must be fully paid.'));
                    return null;
                }
                
                List<Payment_Voucher__c> existingPvList = [Select id from Payment_Voucher__c where Deposit__c=:deposit.Id and Status__c='New'];
                if(deposit.Requested_Amount__c<=deposit.Remaining_Deposit__c){
                    if(deposit.Refund_Mode__c=='Cash' || deposit.Refund_Mode__c=='Cheque'){
                        List<Invoice__c> invList = [Select id from Invoice__c  where Status__c in ('Outstanding','Partially Paid') and Property__c = :deposit.Property__c and tenant__c= :deposit.Tenant__c and billing_Type__c != 'Credit Note' and Voided__c = false];
                        List<Deposit__c> depList = [Select id from Deposit__c  where Status__c in ('Outstanding','Partially Paid') and Property__c = :deposit.Property__c and tenant__c= :deposit.Tenant__c and Voided__c = false];
                        
                        if(invList.size()>0 || depList.size()>0){
                            Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,'Outstanding Invoices/Deposits are present under this Lease.Please refund using Offset Invoice.'));
                            return null;
                        }
                    }
                    deposit.Refund_Status__c = 'New';
                    
                    update deposit;
                    
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(deposit.Id);
                    req1.setSubmitterId(UserInfo.getUserId()); 
                    Approval.ProcessResult result = Approval.process(req1);
                    
                    return new pageReference('/'+deposit.Id);
                    
                }else{
                    Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,'No available deposit amount for refund.'));
                }
                
            }else{
                Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,'This deposit record is locked for approval.'));
            }
            
        }catch(exception e){
            Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,e.getMessage()));
        }
        return null;
    }
    
    public pageReference cancel(){
        if(deposit.Id!=null){
            return new pageReference('/'+deposit.Id);
        }else{
            Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,'Deposit not found.'));
        }
        return null;
    }
}