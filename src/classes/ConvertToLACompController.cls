public class ConvertToLACompController {
    //This function is used to check Loi Status
    @AuraEnabled
    public static String checkStatus(String recordId){
        String msg = 'Success';
        List<Loi__c> loiList = [SELECT Id,Name,LOI_Status__c,Charge_Method__c FROM Loi__c 
                                WHERE  Id =: recordId];
        
        if(loiList.size() > 0 ){
            Loi__c l = loiList.get(0);
            if(l.LOI_Status__c == 'Converted'){
                msg = 'The LOI is already converted to LA.';
            }else if(l.LOI_Status__c == 'Cancelled'){
                msg = 'The LOI is Cancelled.';
            }
        }
        return msg;
    }
}