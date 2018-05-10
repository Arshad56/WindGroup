public class Generate_PO_PDF_CompController {
    
    @AuraEnabled
    public static string checkStatus(string recordId){
        string msgStr = 'success';
        List<Purchase_Order__c> poList = [SELECT Id, Status__c, Generate_PO_PDF__c
                                          FROM Purchase_Order__c	
                                          WHERE Id =:recordId AND Generate_PO_PDF__c = false];
        if(poList.size() > 0 ){
            Purchase_Order__c po = poList.get(0);
            try{
                if(po.Status__c != 'Issued')
                    msgStr = 'Error: Status should be Issued';
                else{
                    po.Generate_PO_PDF__c = TRUE;
                    update po;
                    return 'success: Purchase Order PDF Generated Successfully.';
                }
            }
            catch(Exception e){
                return 'Error:'+e.getMessage();
            }
        }
        else
            msgStr = 'Error: Purchase Order is already Generated';
        return msgStr;
    }
    
}