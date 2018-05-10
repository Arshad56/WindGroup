public class VoidPV_Controller {
	 @AuraEnabled
    public static String validatePaidPV(String recordId) {
        Payment_Voucher__c pv = [SELECT Id,Void__c,Status__c,Refunded_Amount__c,Refund_Mode__c FROM Payment_Voucher__c WHERE  Id =: recordId];
        System.debug('--validatePV--validatePV');
        System.debug('--pv--'+pv);
        
        if(pv.Void__c)
        	return 'This voucher is already Voided.';
        	
        if(pv.Status__c == 'Closed' )
            return 'This Voucher is already Closed.';
        
        if(pv.Status__c == 'Paid' )
            return 'This Voucher is already refunded.';
        
        if(pv.Status__c == 'Paid' && pv.Refund_Mode__c == 'Offset Invoice' )
            return 'Refund Mode must be Cash/Cheque.';
        
        if(pv.Refund_Mode__c == 'Cheque'){
        	return 'SUCCESS Cheque';
        }else{
        	pv.Status__c = 'Paid';
        	update pv;
        	return 'SUCCESS Cash';
        }
         
        return 'SUCCESS';
    }
    @AuraEnabled
    public static String savePaidPV(Id recordId, String chqNO) {
    	try{
	    	Payment_Voucher__c pv = new Payment_Voucher__c();
	    	pv.id = recordId;
	    	pv.cheque_no__c = chqNO;
	    	pv.Status__c = 'Paid';
	    	update pv;
    		return 'Vocher Paid Successfully';
        }catch(Exception e){
 			return 'Error: '+e.getMessage();           
        }
    }
    @AuraEnabled
    public static String validatePV(String recordId) {
        Payment_Voucher__c pv = [SELECT Id,Void__c,Status__c,Refunded_Amount__c FROM Payment_Voucher__c WHERE  Id =: recordId];
        System.debug('--validatePV--validatePV');
        System.debug('--pv--'+pv);
        
        if(pv.Void__c)
        	return 'This voucher is already Voided.';
        	
        if(pv.Status__c == 'Paid' )
            return 'This voucher is refunded so it cannot be voided.';
        
        if(pv.Refunded_Amount__c != 0 && pv.Refunded_Amount__c != null )
            return 'Payment Voucher is used. It is not allow for void.';
         
        return 'SUCCESS';
    }
    @AuraEnabled
    public static String voidPVComp(Id recordId, String reason) {
    	try{
    		Payment_Voucher__c pv= new Payment_Voucher__c(); 
			pv.Id = recordId; 
			pv.Void_Reason__c = reason;
			pv.Void__c = true;
			pv.Void_Datetime__c = System.now();
			update pv;
			
			VoidpaymentVoucherController.void(recordId);
			
    		return 'Payment Vocher Voided Successfully';
        }catch(Exception e){
 			return 'Error: '+e.getMessage();           
        }
    }
}