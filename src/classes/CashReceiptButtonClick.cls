global class CashReceiptButtonClick {
    webservice static void voidAllCashReceipts(Id crId, String reason) { 
        System.debug('Button clicked-->'+ crId);
        if(crId != null || crId != ''){
            Cash_Receipt__c cahRec = new Cash_Receipt__c( id = crId, Void__c = true,Void_Reason__c = reason,Void_Datetime__c = System.now());
            List<Cash_Detail__c> listCashDetails = [select id from Cash_Detail__c where Cash_Receipt__c =: crId];
            for(Cash_Detail__c cd: listCashDetails){
                cd.Void__c = true;
                cd.Void_Datetime__c = System.now(); 
            }
            try{
                update cahRec;
                update listCashDetails;
            }catch(Exception e){
                System.debug('Exception Occured--> '+e);
            }
        }
    }
}