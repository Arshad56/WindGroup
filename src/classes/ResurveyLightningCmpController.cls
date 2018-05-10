public class ResurveyLightningCmpController {
  
    @AuraEnabled
    public static string checkStatus(String recordId){
        String msg = 'Success';
        
        try{
            List<Units__c> unitLst = [SELECT Id FROM Units__c WHERE Id=:recordId AND Active__c=false];
            
            if(unitLst.size() > 0)
                return 'Info: This Unit is In-Active.';
            
        }catch(Exception e){    
            msg = 'Error : '+e.getMessage();
        }
        return msg;
    }
}