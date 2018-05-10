public with sharing class PaymentVoucherRefund_Aura {
    @AuraEnabled
    public static String validatePV(String recordId) {
        Payment_Voucher__c pv = [SELECT Id,Void__c,Status__c,Refunded_Amount__c,Refund_Mode__c,Lease_Id__c,Tenant_Id__c,Currency_Code__c,Outstanding_Amount__c FROM Payment_Voucher__c WHERE  Id =: recordId];
        
        if(pv.Void__c)
        	return 'This voucher is already Voided.';
        	
        if(!(pv.Refund_Mode__c == 'Offset Invoice' && pv.Status__c == 'New') )
            return 'Refund Mode must be Offset Invoice.';
        String resp = 'SUCCESS|'
        			+((pv.Status__c != null)?pv.Status__c:'')+'|'
        			+((pv.Lease_Id__c!= null)?pv.Lease_Id__c:'')+'|'
        			+((pv.Outstanding_Amount__c!= null)?pv.Outstanding_Amount__c+'':'')+'|'
        			+((pv.Currency_Code__c!= null)?pv.Currency_Code__c:'')+'|'
        			+((pv.Tenant_Id__c!= null)?pv.Tenant_Id__c:'');
        System.debug('resp-->'+resp);
        return resp;
    }
    @AuraEnabled
    public static String savePV(String recordId, String paymentMode) {
        Payment_Voucher__c pv = [SELECT Id,Void__c,Status__c,Refunded_Amount__c,Refund_Mode__c,Lease_Id__c,Tenant_Id__c,Currency_Code__c,Outstanding_Amount__c FROM Payment_Voucher__c WHERE  Id =: recordId];
        String status =((pv.Status__c != null)?pv.Status__c:'');
        String leaseId =((pv.Lease_Id__c!= null)?pv.Lease_Id__c:'');
        String outs =((pv.Outstanding_Amount__c!= null)?pv.Outstanding_Amount__c+'':'');
        String curr =((pv.Currency_Code__c!= null)?pv.Currency_Code__c:'');
        String tenant =((pv.Tenant_Id__c!= null)?pv.Tenant_Id__c:'');
        			
    	PaymentVoucherRefundController pvr = new PaymentVoucherRefundController(recordId,status,outs,leaseId,tenant,curr);
    	
    	String resp = ''; 
    	try{
    	    resp = pvr.checkData();
    		System.debug('resp-->'+resp);
    	}catch(Exception ex){
    		resp = ex.getMessage();
    	}
    	
    	return resp;
    }
}