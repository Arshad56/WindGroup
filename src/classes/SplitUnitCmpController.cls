public class SplitUnitCmpController {
  
    @AuraEnabled
    public static string checkMainUnit(String recordId){
        String msg = 'Success';
        
        try{
            List<Units__c> unitLst = [SELECT Id FROM Units__c WHERE Id=:recordId AND Main_Unit__c != null];
            
            if(unitLst.size() > 0)
                return 'Info: This Unit is already Split Unit.';
            
        }catch(Exception e){    
            msg = 'Error : '+e.getMessage();
        }
        return msg;
    }
}