public class GenerateFitOutLcCmpController {
	 //This function is used to check Loi Already Cancelled or not
    @AuraEnabled
    public static String validateFitOutLC(String recordId) {
        String checkLoi = 'Success';
        List<Lease_Unit__c> luList = [SELECT Id,Name,Lease_Start_Date__c,Fit_Out_Date__c FROM Lease_Unit__c WHERE  Id =: recordId];
        
        Lease_Unit__c lu = luList.get(0);
        if(lu.Lease_Start_Date__c == null)
            checkLoi = 'Error: Please populate Lease Start Date.';
        else if(lu.Fit_Out_Date__c == null)
            checkLoi = 'Error: Please populate Fit Out Date.';
        else if(lu.Fit_Out_Date__c  >= lu.Lease_Start_Date__c)
            checkLoi = 'Error: Fit Out Date cannot be greater than or equal to Lease Start Date.';
        
        return checkLoi;
    }
    
    @AuraEnabled
    public static String saveLeaseUnit(String recordId) {
        String msg = '';
        try{
            Lease_Unit__c lcObj = new Lease_Unit__c(Id = recordId);
			lcObj.Generate_Fit_Out_LC__c  = true;
            update lcObj;
            msg = 'Success: Lease Unit Generate Fit Out LC Successfully';
        }catch(Exception e){
 			return 'Error: '+e.getMessage();           
        }
        
        return msg;
    }
}