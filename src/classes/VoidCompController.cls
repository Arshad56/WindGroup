public class VoidCompController {
    //This function is used to check
    @AuraEnabled
    public static String depositVoid(String recordId) {
        try{
			String msg = 'Success';
            List<Deposit__c> depList = [SELECT Id,Voided__c,Status__c,Amount_Paid__c FROM Deposit__c
                                      WHERE  Id =: recordId];
            
            if(depList.size() > 0){
                Deposit__c d = depList.get(0);
                
                if(d.Voided__c){
                    msg = 'Error: This Deposit is already Voided.';
                }else if(d.Status__c == 'Cancelled' || d.Status__c== 'Rejected'){
                    msg = 'Error: Cancelled or Rejected Deposits can\'t be Voided.';    
                }else if(d.Amount_Paid__c != null && d.Amount_Paid__c != 0){
                    msg = 'Error: Deposit already paid, can\'t be Voided.';    
                }else{
                    msg = 'Success';
                }   
            }
            return msg;
        }catch(Exception e){
            return 'Error: '+e.getMessage();           
        }
    }
    
    @AuraEnabled
    public static String  saveVoidDeposit(String recordId,String reason) {
        try{
            Deposit__c dep = new Deposit__c(Id = recordId);  
            dep.Void_Reason__c = reason; 
            dep.Voided__c = true; 
            dep.Void_Datetime__c = System.now(); 
            update dep;
            return 'Success: Deposit Voided Successfully.';
        }catch(Exception e){
            return 'Error: '+e.getMessage();           
        }
    }
}