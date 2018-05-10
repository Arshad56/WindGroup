public class GenerateLoiPdfCompController {
    //This function is used to check Loi Status
    @AuraEnabled
    public static String generatePdf(String recordId) {
        String msg = '';
        List<Loi__c> loiList = [SELECT Id,Name,LOI_Status__c,Charge_Method__c FROM Loi__c 
                                WHERE  Id =: recordId AND Generated_LOI__c = False];
        
        if(loiList.size() > 0){
            try{
                Loi__c l = loiList.get(0);
                if(l.Charge_Method__c == 'Monthly Rate - CL' || l.Charge_Method__c == 'Daily Rate'){
                    msg = 'There is no available PDF for Casual Leasing.'; 
                }else{
                    LoiDocumentGenerator.generateLoi(recordId);
                    
                    l.Generated_LOI__c= True; 
                    update l;
                    msg = 'Success: LOI Pdf generated Successfully.';
                }
            }catch(Exception e){
                return 'Error: '+e.getMessage();           
            }
        }else{
            msg = 'Error: PDF is Already generated';
        }
        return msg;
    }
}