public class GenerateRentSchedulesLsCmpController {
    @AuraEnabled
    public static String validateLeaseCharge(String recordId) {
        String msg = 'Success';
        try{
            List<Lease_Charges__c> lcList = [Select Id,Active__c,Start_Date__c,End_Date__c,Charge_Type__c 
                                             FROM Lease_Charges__c 
                                             WHERE Active__c=True AND Lease_Unit__c =:recordId order by Base_Charge_Type__c asc];
            if(lcList.size() > 0){
                Boolean isError = False;
                
                for(Lease_Charges__c lc: lCList){
                    for(Lease_Charges__c lcJ: lCList){
                        if(lcJ.Id != lc.Id && ((lc.Charge_Type__c=='Advance Rental' && lcJ.Charge_Type__c=='Advance Rental') || (lc.Charge_Type__c=='Rent' && lcJ.Charge_Type__c=='Rent'))){ 
                        	if((lc.Start_Date__c < lcJ.Start_Date__c && lc.End_Date__c > lcJ.End_Date__c) || (lc.Start_Date__c>=lcJ.Start_Date__c && lc.Start_Date__c<=lcJ.End_Date__c) || (lc.End_Date__c>=lcJ.Start_Date__c && lc.End_Date__c<=lcJ.End_Date__c)){ 
                                isError = True; 
                                msg = 'Info: Kindly review \'Start and End Date\' conflict in related Advance Rental or Rent (Lease Charges)'; 
                                return msg; 
                            } 
                        }
                    }
                }
            }
            
            return msg;
        }catch(Exception e){
            return 'ERROR: '+e.getMessage();
        }
    }
    
    @AuraEnabled
    public static String  generateRentSch(String recordId) {
        try{
        	List<Lease_Charges__c> lcList = [Select Id,Active__c,Start_Date__c,End_Date__c,Charge_Type__c 
                                             FROM Lease_Charges__c 
                                             WHERE Active__c=true AND Generate_Rent_Schedule__c=false AND Lease_Unit__c =:recordId order by Base_Charge_Type__c asc];
            if(lcList.size() > 0){
                for(Lease_Charges__c lc: lCList)
                	lc.Generate_Rent_Schedule__c = lc.Active__c; 
                
                update lCList;
            }
            return 'Success';
        }catch(Exception e){
            return 'Error: '+e.getMessage();           
        }
    }
}