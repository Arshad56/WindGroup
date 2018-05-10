public class CashReceiptPDFController{
    public Cash_Receipt__c cashReceipt{get;set;}
    public string concatIncAddFields{get;set;}
    public List<CashDetailWrapper> cashDetWrapList{get;set;}
    public CashReceiptPDFController(){
        cashDetWrapList = new List<CashDetailWrapper>();
        concatIncAddFields = '';
        cashReceipt = new Cash_Receipt__c();
        string cashRptId = Apexpages.currentPage().getParameters().get('Id');
        List<Cash_Receipt__c> cashReceipts = [Select id,Payment_Amount__c,Offset_Amount__c,Payment_Reference__c,Name,Tenant__c,Tenant__r.Customer_Code__c,Tenant__r.Name,Tenant__r.BillingStreet,Tenant__r.Phone,Tenant__r.BillingCity,Tenant__r.BillingState,Tenant__r.BillingCountry,Property__c,Property__r.Logo__c,Property__r.Name,Property__r.Address__c,Total_Paid__c,Remarks__c,Payment_Date__c,Payment_Mode__c,Payment_Currency__c,(Select id,Amount_Paid__c,Deposit__c,Deposit__r.Name,Invoice__c,Invoice__r.Name,Invoice__r.Rent_Roll__r.Billing_Type__c,Payment_Mode__c,Remarks__c,Payment_Voucher__r.Name from Cash_Details__r) from Cash_Receipt__c where id=:cashRptId];
        if(cashReceipts.size()>0){
            cashReceipt = cashReceipts[0];
            
            for(Cash_Detail__c cd:cashReceipt.Cash_Details__r){
                CashDetailWrapper cdw = new CashDetailWrapper();
                cdw.name = (cd.Deposit__r.Name!=null?cd.Deposit__r.Name:(cd.Invoice__r.Name!=null?cd.Invoice__r.Name:cd.Payment_Voucher__r.Name));
                cdw.cd.remarks__c = cd.Remarks__c;
                cdw.amount = cd.Amount_Paid__c;
                cashDetWrapList.add(cdw);
            }
            if(cashReceipt.Offset_Amount__c!=null && cashReceipt.Offset_Amount__c!=0){
                CashDetailWrapper cdw = new CashDetailWrapper();
                cdw.name = '';
                cdw.cd.remarks__c = 'Offset';
                cdw.amount = cashReceipt.Offset_Amount__c;
                cashDetWrapList.add(cdw);
            }
            
            concatIncAddFields = (cashReceipt.Tenant__r.BillingCity!=null?cashReceipt.Tenant__r.BillingCity+',':'') + (cashReceipt.Tenant__r.BillingState!=null?cashReceipt.Tenant__r.BillingState+',':'') + cashReceipt.Tenant__r.BillingCountry!=null?cashReceipt.Tenant__r.BillingCountry:'';
            if(concatIncAddFields!=null && concatIncAddFields.endsWith(',')){
                concatIncAddFields = concatIncAddFields.subString(0,concatIncAddFields.length()-1);
            }
        }
    }
    
    public class CashDetailWrapper{
        public string name{get;set;}
        public decimal amount{get;set;}
        public Cash_Detail__c cd{get;set;}
        public CashDetailWrapper(){
            cd = new Cash_Detail__c();
        }
    }
}