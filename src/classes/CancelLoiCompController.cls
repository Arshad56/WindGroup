public class CancelLoiCompController {
	  //This function is used to check Loi Already Cancelled or not
    @AuraEnabled
    public static String checkLoiIsAlreadyCancelled(String recordId) {
        String checkLoi = 'Success';
        List<Loi__c> loiList = [SELECT Id,Name,LOI_Status__c FROM Loi__c WHERE  Id =: recordId AND LOI_Status__c = 'Cancelled'];
        if(loiList.size() > 0)
            checkLoi = 'LOI already cancelled';
        
        return checkLoi;
    }
    
    @AuraEnabled
    public static String cancelLoi(String recordId,String reason) {
        String msg = '';
        try{
            Loi__c loiObj = new Loi__c(Id = recordId);
            loiObj.Reason_for_Termination__c = reason;
			loiObj.LOI_Status__c = 'Cancelled';
            update loiObj;
            msg = 'LOI Cancelled Successfully';
        }catch(Exception e){
 			return 'Error: '+e.getMessage();           
        }
        
        return msg;
    }
}