public with sharing class PDFComponent_Utility {
    @AuraEnabled
    public static String checkAlreadyGeneratePdf(String recordId,String objLabel,String objName, String fieldName) {
    	
		String query = 'select Id from '+objName+' where id =:recordId and '+fieldName+' = true';
		String msg = '';
        try{
        	if(Database.query(query).size() > 0)
	            msg = 'Error: '+ objLabel +' PDF is already Generated';
	        else
	            msg = 'Success';
	        return msg;
        }catch(Exception e){
        	return 'ERROR: '+e;
        }
    }
    
    //Check for LOI
    @AuraEnabled
    public static String checkAlreadyGeneratePdfForLOI(String recordId) {
        String msg = 'Success';
        List<Loi__c> loiList = [SELECT Id,Name,LOI_Status__c,Charge_Method__c FROM Loi__c 
                                WHERE  Id =: recordId AND Generated_LOI__c = False];
        
        if(loiList.size() > 0){
            try{
                Loi__c l = loiList.get(0);
                if(l.Charge_Method__c == 'Monthly Rate - CL' || l.Charge_Method__c == 'Daily Rate')
                    msg = 'Error: There is no available PDF for Casual Leasing.'; 
            }catch(Exception e){
                return 'Error: '+e.getMessage();           
            }
        }else{
            msg = 'Error: PDF is Already generated';
        }
        return msg;
    }
	
    //Check for LOI
    @AuraEnabled
    public static String checkAlreadyGeneratePdfForLease(String recordId) {
        String msg = 'Success';
        List<Lease__c> leaseList = [SELECT Id,Charge_Method__c,Generated_LA_PDF__c FROM Lease__c 
                                WHERE  Id =: recordId AND Generated_LA_PDF__c = False];
        
        if(leaseList.size() > 0){
            try{
                Lease__c l = leaseList.get(0);
                if(l.Charge_Method__c == 'Monthly Rate - CL' || l.Charge_Method__c == 'Daily Rate')
                    msg = 'Error: There is no available PDF for this Lease.'; 
            }catch(Exception e){
                return 'Error: '+e.getMessage();           
            }
        }else{
            msg = 'Error: PDF is Already generated';
        }
        return msg;
    }
	
    
    //Check for PurchaseOrder
    @AuraEnabled
    public static String checkAlreadyGeneratePdfForPurchaseOrder(String recordId) {
        string msgStr = 'Success';
        List<Purchase_Order__c> poList = [SELECT Id, Status__c, Generate_PO_PDF__c
                                          FROM Purchase_Order__c	
                                          WHERE Id =:recordId AND Generate_PO_PDF__c = false];
        if(poList.size() > 0 ){
            Purchase_Order__c po = poList.get(0);
            if(po.Status__c != 'Issued')
                msgStr = 'Error: Status should be Issued';
        }else{
            msgStr = 'Error: Purchase Order pdf is already Generated';
        }
        return msgStr;
    }
    
    @AuraEnabled
    public static String  generatePdf(String recordId,String objLabel,String objName, String fieldName) {
        try{
        	
            //Check for LOI object
            if(objLabel.equalsIgnoreCase('Loi__c'))
            	LoiDocumentGenerator.generateLoi(recordId);
            //Check for Lease object
            if(objLabel.equalsIgnoreCase('Lease__c') && !(fieldName.equalsIgnoreCase('Deposit_Pdf__c')))
            	LAPDFGenerator.generatePDF(recordId);
            
			sObject obj = Schema.getGlobalDescribe().get(objName).newSObject() ;
			obj.put('Id',recordId);           
            obj.put(fieldName, true); 
            update obj;
            return 'Success: '+objLabel+' Pdf generated Successfully.';
        }catch(Exception e){
            return 'Error: '+e.getMessage();           
        }
    }
    @AuraEnabled 
    public static string getAttachId(string recordId){
        string infoMsg = 'Success';
        List<Attachment> attach = [SELECT Id FROM Attachment  WHERE ParentId =:recordId ORDER BY CreatedDate DESC LIMIT 1];
        if(attach.size() > 0){
            return ''+attach[0].Id;
        }else{
        	return 'Info: Attachment Not found, Please make sure pdf is generated. ';
        }
    }
    
}