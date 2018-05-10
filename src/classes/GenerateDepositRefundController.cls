public class GenerateDepositRefundController{
    public Cash_Receipt__c cr {get;set;}
    public Contact con {get;set;}
    public Rent_Roll__c rroll {get;set;}
    public Boolean showResult {get;set;}
    public List<displayWrapper> displayWrapList{get;set;}
    public GenerateDepositRefundController(){
        showResult = false;
        cr = new Cash_Receipt__c();
        cr.Payment_Currency__c = label.Default_Currency;
        con = new Contact();
        rroll = new Rent_Roll__c();
        displayWrapList = new List<DisplayWrapper>();
    }
    
    public void search(){
        displayWrapList = new List<DisplayWrapper>();
        showResult = false;
        try{
             if(rroll.Property__c!=null && con.AccountId!=null){
                 List<Cash_Detail__c> cdList = [Select id,Amount_Paid__c,Payment_Mode__c,Payment_Voucher__r.Name,Cheque_No__c,Refund_Mode__c from Cash_Detail__c where Void__c=false and paid__c=false and Payment_Mode__c='Payment Voucher' and Amount_Paid__c!=0 and Payment_Voucher__r.Lease__r.Property__c=:rRoll.Property__c and Payment_Voucher__r.Lease__r.Tenant__c=:con.accountId and Currency_Code__c=:cr.Payment_Currency__c];
                 if(cdList.size()>0){
                     for(Cash_Detail__c cd:cdList){
                         displayWrapper dw = new displayWrapper();
                         dw.cd = cd;
                         displayWrapList.add(dw);
                         showResult = true;
                     }
                 }else{
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No outstanding record found. Please filter your search criteria.'));
                 }
             }else{
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please enter Property and Tenant.'));
             }
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        }
    }
    
    public pageReference depositRefund(){
        Integer totalSelected = 0;
        List<Cash_Detail__c> cashDetailList = new List<Cash_Detail__c>();
        for(displayWrapper dw:displayWrapList){
            if(dw.selectRecord){
                totalSelected++;
                
                if(dw.cd.Refund_Mode__c=='Cheque' && (dw.cd.Cheque_No__c==null || dw.cd.Cheque_No__c.trim().length()==0)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Cheque No. where Refund Mode is Cheque.'));
                    return null;                    
                }
                
                dw.cd.paid__c = true;
                
                cashDetailList.add(dw.cd);
                
            }
        }
         if(totalSelected>0){
             update cashDetailList;
             
             return new pageReference('/apex/GenerateDepositRefund').setredirect(true);
         }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select atleast 1 record.'));
        }
        return null;
    }
    
    public class displayWrapper{
        public Boolean selectRecord{get;set;}
        public Cash_Detail__c cd{get;set;}
        public displayWrapper(){
            selectRecord = false;
            cd = new Cash_Detail__c();
        }
    }
}