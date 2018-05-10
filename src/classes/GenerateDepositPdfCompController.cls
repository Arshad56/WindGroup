public class GenerateDepositPdfCompController {
    //This function is used to check
    @AuraEnabled
    public static String checkAlreadyGeneratePdf(String recordId) {
		String msg = '';
		
        List<Deposit__c> depList = [SELECT Id,Name,Deposit_Generated__c FROM Deposit__c
                                	WHERE  Id =: recordId AND Deposit_Generated__c = true];
        
        if(depList.size() > 0)
            msg = 'Error: Deposit PDF is already Generated';
        else
            msg = 'Success';
        return msg;
    }
    
    
    @AuraEnabled
    public static String  generatePdf(String recordId) {
        try{
			Deposit__c dep = new Deposit__c(Id = recordId);            
            dep.Deposit_Generated__c = True; 
            update dep;
            return 'Success: Deposit Pdf generated Successfully.';
        }catch(Exception e){
            return 'Error: '+e.getMessage();           
        }
    }
    
}