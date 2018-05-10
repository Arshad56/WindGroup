public class CloseRequestCompController {
	 @AuraEnabled
    public static String checkStatus(String recordId) {
        String msg = 'Success';
        List<Request__c> reqList = [SELECT Id,Name,Status__c FROM Request__c WHERE  Id =: recordId AND Status__c = 'Completed'];
        if(reqList.size() > 0)
            msg = 'This Request has been already marked as Completed!';
        
        return msg;
    }
    
    @AuraEnabled
    public static String saveCloseRequest(String recordId) {
        String msg = '';
        try{
            Request__c reqObj = new Request__c(Id = recordId);
			reqObj.Status__c  = 'Completed';
            reqObj.Date_Time_Closed__c = System.now();
            update reqObj;
            msg = 'Success: Request closed Successfully';
        }catch(Exception e){
 			return 'Error: '+e.getMessage();           
        }
        
        return msg;
    }
}