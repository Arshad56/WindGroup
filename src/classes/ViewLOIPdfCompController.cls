public class ViewLOIPdfCompController {
    //This function is used to check Loi Status
    @AuraEnabled
    public static String checkStatus(String recordId){
        String msg = 'Success';
        List<Loi__c> loiList = [SELECT Id,Name,Generated_LOI__c,(Select Id FROM Attachments ORDER BY CreatedDate DESC LIMIT 1) 
                                FROM Loi__c 
                                WHERE  Id =: recordId];
        
        if(loiList.size() > 0 ){
            Loi__c l = loiList.get(0);
            
            if(l.Generated_LOI__c == False){
                msg = 'Info: Please generate PDF LOI first.';
                return msg;
            }else if(l.Attachments.size() ==0){
                msg = 'Info: PDF is Not yet generated.';
                return msg;
            }
            
            msg = ''+l.Attachments.get(0).Id;
        }
        return msg;
    }
}