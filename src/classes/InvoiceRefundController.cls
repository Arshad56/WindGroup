/*
Author - Arshad Shaikh (TMC)
Description - To initiate refund for Invoice

Test Class - InvoiceRefundController_Test
*/
public class InvoiceRefundController {
	public Invoice__c updateInv{get;set;}
	public String invId{get;set;} 
   // public String pvLeaseId{get;set;}
    public String paymentMode{get;set;}
    public Decimal invBalance{get;set;}
    public String invCurrency{get;set;}
    public String invStatus{get;set;}
    public Invoice__c selectedInvoice{get;set;}
    
    public List<SelectOption> getPaymentModeOptions() {
        List<SelectOption> pvOption = new List<SelectOption>();
        //pvOption.add(new SelectOption('','-None-'));
        pvOption.add(new SelectOption('Cash','Cash'));
        pvOption.add(new SelectOption('Cheque','Cheque'));
        return pvOption;
    }
    public InvoiceRefundController(){
        invId = Apexpages.CurrentPage().getParameters().get('id');
        
        System.debug('invId-->'+invId);
        selectedInvoice = [select Id,Status__c,Requested_Amount__c,Refund_Status__c,Outstanding_Amount__c,Outstanding_Amount_Local__c,Total_Refunded_Amount__c,Amount__c,Amount_Foreign__c,Amount_Local__c,Amount_Paid__c,Amount_Paid_Foreign__c,Amount_Paid_Local__c,Currency_Code__c from Invoice__c where id =: invId ];
    	System.debug('selectedInvoice-->'+selectedInvoice);
    	invCurrency = selectedInvoice.Currency_Code__c;
    	invStatus = selectedInvoice.Status__c;
    	if(selectedInvoice.Amount_Foreign__c == null )
    		selectedInvoice.Amount_Foreign__c = 0;
    	if(selectedInvoice.Amount_Paid_Foreign__c == null)
    		selectedInvoice.Amount_Paid_Foreign__c = 0; 
    	
    	selectedInvoice.Total_Refunded_Amount__c = (selectedInvoice.Total_Refunded_Amount__c!= null)?selectedInvoice.Total_Refunded_Amount__c:0;
		selectedInvoice.Requested_Amount__c = (selectedInvoice.Requested_Amount__c!= null)?selectedInvoice.Requested_Amount__c:0;
		Decimal refundedAmt = selectedInvoice.Total_Refunded_Amount__c - ((selectedInvoice.Refund_Status__c =='Submitted')?selectedInvoice.Requested_Amount__c:0);
		
		invBalance = selectedInvoice.Outstanding_Amount_Local__c - refundedAmt;
        invBalance = -invBalance;                  		
    	/*if(selectedInvoice.Currency_Code__c == label.Default_Currency){
    		invBalance = (selectedInvoice.Outstanding_Amount__c != null)?-selectedInvoice.Outstanding_Amount__c:0;
    		if(selectedInvoice.Refund_Status__c != null && selectedInvoice.Requested_Amount__c != null)
    		invBalance += (selectedInvoice.Refund_Status__c == 'Requested')? selectedInvoice.Requested_Amount__c:0;
    	}else{
    		invBalance = (selectedInvoice.Outstanding_Amount_Local__c != null)?-selectedInvoice.Outstanding_Amount_Local__c:0;
    		if(selectedInvoice.Refund_Status__c != null && selectedInvoice.Requested_Amount__c != null)
    		invBalance += (selectedInvoice.Refund_Status__c == 'Requested')? selectedInvoice.Requested_Amount__c:0;
    	}*/
    	//invBalance = (selectedInvoice.Outstanding_Amount__c != null)?-selectedInvoice.Outstanding_Amount__c:0;
    	//invBalance += (selectedInvoice.Total_Refunded_Amount__c != null)? selectedInvoice.Total_Refunded_Amount__c:0;
    	
    	updateInv = new Invoice__c();
    	updateInv.Requested_Amount__c = invBalance;
    	updateInv.Refund_Currency_Code__c = label.Default_Currency;
    }
    public pageReference generateRefund(){
    	if(updateInv.Requested_Amount__c <= 0){
    		Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,'Please Enter valid refund amount'));
    	}else if(updateInv.Requested_Amount__c > invBalance){
    		 Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,'Total Requested amount cannot exceed outstanding amount.'));
    	}else{
    		 ///updateInv = new Invoice__c();
	    	updateInv.id = Id.valueof(invId);
	    	updateInv.Refund_Mode__c = paymentMode;
	    	updateInv.Refund_Status__c = 'Requested';
	    	updateInv.Approved_Amount__c = 0;
	    	//updateInv.Requested_Amount__c = invBalance;
	    	update updateInv;
	    	if(!Test.isRunningTest() ){
	    		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		        req1.setObjectId(updateInv.Id);
		        req1.setSubmitterId(UserInfo.getUserId()); 
		        Approval.ProcessResult result = Approval.process(req1);
	    	}
	    	return new pageReference('/'+invId);
    	}
    	return null;
    }
    public pageReference cancel(){
        if(invId != null){
            return new pageReference('/'+invId);
        }else{
            Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,'Invoice not found.'));
        }
        return null;
    }
    
}