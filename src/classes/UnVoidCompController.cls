public class UnVoidCompController {
    //This function is used to check
    @AuraEnabled
    public static String checkDepositVoided(String recordId) {
        String msg = '';
        List<Deposit__c> depList = [SELECT Id,Voided__c FROM Deposit__c
                                  WHERE  Id =: recordId AND Voided__c = False];
        
        if(depList.size() > 0)
            msg = 'Error: Only voided Deposits can be Un-Voided.';
        else
            msg = 'Success';
        return msg;
    }
    
    @AuraEnabled
    public static String  saveUnvoidDeposit(String recordId) {
        try{
            Deposit__c dep = new Deposit__c(Id = recordId);  
            dep.Void_Reason__c = null; 
            dep.Voided__c = false; 
            dep.Void_Datetime__c = null; 
            update dep;
            return 'Success: Deposit Un-Voided Successfully.';
        }catch(Exception e){
            return 'Error: '+e.getMessage();           
        }
    }
    
}