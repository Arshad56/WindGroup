/*
*    Name           :        CreatePaymentAssigment
*    Author         :        Mohd Anas
*    Created Date   :        27th Jun 2017  
*    Description    :        Webservice to support payment assignment on purchase record detail page button
*                            Insert the PO payment arrangement from the vendor payment arrangement 
*/
global class CreatePaymentAssigment{

    webservice static void createRecord(Id purOrderId){
        
        List<Payment_Arrangement__c> payAggrList = new List<Payment_Arrangement__c>();
        payAggrList = [select Payment_Due__c,Payment_Term__c,Vendor_Name__c from Payment_Arrangement__c where Vendor_Name__c in (select vendor_name__c from Purchase_Order__c where id = :purOrderId)];
        
        List<PO_Payment_Arrangement__c> poPaymentArList = new List<PO_Payment_Arrangement__c>();
        poPaymentArList = [select id from PO_Payment_Arrangement__c where Purchase_Order__c=:purOrderId];
        
        if(poPaymentArList.size()>0){
                Delete poPaymentArList;
                poPaymentArList.clear();
            }
            
        if(payAggrList.size()>0){
            for(Payment_Arrangement__c pa : payAggrList){
                PO_Payment_Arrangement__c temp = new PO_Payment_Arrangement__c();
                temp.vendor_name__c = pa.vendor_name__c;
                temp.Payment_Arrangement__c = pa.id;
                temp.Payment_Due__c = pa.Payment_Due__c;
                temp.Payment_Term__c = pa.Payment_Term__c;
                temp.Purchase_Order__c = purOrderId;
                poPaymentArList.add(temp);
            }
        }
        
        if(poPaymentArList.size()>0)
            insert poPaymentArList;
        
    }
}