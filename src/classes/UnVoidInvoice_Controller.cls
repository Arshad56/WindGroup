public class UnVoidInvoice_Controller {
    @AuraEnabled
    public static String validateInvoice(String recordId) {
        Invoice__c inv = [SELECT Id,Voided__c,Amount_Paid__c,JV_Status__c FROM Invoice__c WHERE  Id =: recordId];
        System.debug('--validateInvoice--validateInvoice');
        System.debug('--inv--'+inv);
        if(!inv.Voided__c)
        	return 'Only voided Invoices can be Un-Voided.';
        	
        return 'SUCCESS';
    }
    @AuraEnabled
    public static String unVoidInvoicesComp(Id invoiceId) {
    	try{
    		InvoiceButtonClick.unvoidAllInvoices(invoiceId);
    		return 'Invoice Un-Voided Successfully';
        }catch(Exception e){
 			return 'Error: '+e.getMessage();           
        }
    }
}