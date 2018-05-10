public class InvoiceRefund_Controller {
    //This function is used to check
    @AuraEnabled
    public static String invRefundValidate(String recordId) {
        try{
			String msg = 'Success';
        	Invoice__c selectedInvoice = [select Id,Tenant__c,Status__c,Requested_Amount__c,Refund_Status__c,Outstanding_Amount__c,
        									Outstanding_Amount_Local__c,Total_Refunded_Amount__c,Amount__c,Amount_Foreign__c,
        									Amount_Local__c,Amount_Paid__c,Amount_Paid_Foreign__c,Amount_Paid_Local__c,
        									Currency_Code__c,Billing_Type__c,Voided__c from Invoice__c where id =: recordId ];
            Id profileId=userinfo.getProfileId();
			String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            decimal totalOuts = 0;
            if(selectedInvoice.Tenant__c != null){
            	for(Invoice__c inv: [Select Name, Id, Outstanding_Amount__c,Billing_Type__c from Invoice__c where Tenant__c =: selectedInvoice.Tenant__c and Status__c != 'Cancelled' and Billing_Type__c != 'Credit Note']){
            		totalOuts += (inv.Outstanding_Amount__c != null)?inv.Outstanding_Amount__c:0;
            	}
            }
            
            decimal balance = selectedInvoice.Amount__c + selectedInvoice.Amount_Paid__c;
			decimal reqRefAmount = selectedInvoice.Total_Refunded_Amount__c;
			decimal outStanding = selectedInvoice.Outstanding_Amount__c;
			           
			if(selectedInvoice.Billing_Type__c != 'Credit Note'){ 
				msg = 'Only Credit Note Invoices can be refunded.'; 
			}else if(selectedInvoice.Status__c == 'Cancelled'){ 
				msg = 'The Credit Note is already cancelled and can\'t be refunded.'; 
			}else if(selectedInvoice.Voided__c){ 
				msg = 'The Credit Note is already voided and can\'t be refunded.'; 
			}else if(selectedInvoice.Refund_Status__c == 'Submitted'){
				msg = 'This Invoice record is locked for approval.'; 
			}else if( outStanding >= 0 ){
				msg = 'There is no balance for this Credit Note to refund.'; 
			}else if(totalOutS > 0){
				if(profileName == 'System Administrator'){
					//var r = confirm("There are outstanding payment for the tenant. \nDo you still want to proceed to refund?';
					//if (r == true) {
						//window.location='/apex/InvoiceRefund?id={!Invoice__c.Id}';
						//  msg = 'Success';
					//}
					msg = 'Warning';
				}else{
					msg = 'There are outstanding payments and Credit Note can\'t be refunded for the Tenant.'; 
				}
			}else if(outStanding >= reqRefAmount){
				msg = 'There is no available balance to be refunded';
			}else{ 
			    msg = 'Success';
			}
            return msg;
        }catch(Exception e){
            return 'Error: '+e.getMessage();           
        }
    }
    
    @AuraEnabled
    public static String getCurrency(String recordId) {
    	Invoice__c selectedInvoice = [select Id,Currency_Code__c from Invoice__c where id =: recordId ];
    	return selectedInvoice.Currency_Code__c;
    }
    @AuraEnabled
    public static Decimal getBalance(String recordId) {
    	Invoice__c selectedInvoice = [select Id,Status__c,Requested_Amount__c,Refund_Status__c,Outstanding_Amount__c,Outstanding_Amount_Local__c,Total_Refunded_Amount__c,Amount__c,Amount_Foreign__c,Amount_Local__c,Amount_Paid__c,Amount_Paid_Foreign__c,Amount_Paid_Local__c,Currency_Code__c from Invoice__c where id =: recordId ];
    	Decimal invBalance = 0;
    	if(selectedInvoice.Amount_Foreign__c == null )
    		selectedInvoice.Amount_Foreign__c = 0;
    	if(selectedInvoice.Amount_Paid_Foreign__c == null)
    		selectedInvoice.Amount_Paid_Foreign__c = 0; 
    	
    	selectedInvoice.Total_Refunded_Amount__c = (selectedInvoice.Total_Refunded_Amount__c!= null)?selectedInvoice.Total_Refunded_Amount__c:0;
		selectedInvoice.Requested_Amount__c = (selectedInvoice.Requested_Amount__c!= null)?selectedInvoice.Requested_Amount__c:0;
		Decimal refundedAmt = selectedInvoice.Total_Refunded_Amount__c - ((selectedInvoice.Refund_Status__c =='Submitted')?selectedInvoice.Requested_Amount__c:0);
		
		invBalance = selectedInvoice.Outstanding_Amount_Local__c - refundedAmt;
        invBalance = -invBalance;  
        
    	return invBalance;
    }
    @AuraEnabled
    public static String saveInvoiceRefund(String recordId,String paymentMode, String invBalance,String refundCurrCode){
    	System.debug('--saveInvoiceRefund--');
		try{
			Invoice__c updateInv =  new Invoice__c();
	    	updateInv.id = Id.valueof(recordId);
	    	updateInv.Refund_Mode__c = paymentMode;
	    	updateInv.Refund_Status__c = 'Requested';
	    	updateInv.Approved_Amount__c = 0;
	    	updateInv.Refund_Currency_Code__c = refundCurrCode;
	    	updateInv.Requested_Amount__c = Decimal.valueof(invBalance);
	    	update updateInv;
	    	System.debug('--updateInv--'+updateInv);
	    	if(!Test.isRunningTest()){
	    		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		        req1.setObjectId(updateInv.Id);
		        req1.setSubmitterId(UserInfo.getUserId()); 
		        Approval.ProcessResult result = Approval.process(req1);
		        System.debug('--approval--');
	    	}
	    	return 'Success';
		}catch(Exception e){
			System.debug('--e--'+e);
			return 'Error: '+e.getMessage();
		}
	}
}