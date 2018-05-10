public class VoidInvoice_Controller {
    @AuraEnabled
    public static String validateInvoice(String recordId) {
        Invoice__c inv = [SELECT Id,Voided__c,Amount_Paid__c,JV_Status__c FROM Invoice__c WHERE  Id =: recordId];
        System.debug('--validateInvoice--validateInvoice');
        System.debug('--inv--'+inv);
        if(inv.Voided__c)
        	return 'This Invoice is already Voided.';
        	
        if(inv.Amount_Paid__c != null && inv.Amount_Paid__c != 0 )
            return 'Paid Invoices cannot be Voided.';
        
        if(inv.JV_Status__c == 'Generated' && inv.JV_Status__c == 'Posted' )
            return 'Generated/Posted Invoices cannot be Voided.';
         
        return 'SUCCESS';
    }
    @AuraEnabled
    public static String voidInvoicesComp(Id invoiceId, String reason) {
    	try{
    		InvoiceButtonClick.voidAllInvoices(invoiceId,reason);
    		return 'Invoice Voided Successfully';
        }catch(Exception e){
 			return 'Error: '+e.getMessage();           
        }
    }
}