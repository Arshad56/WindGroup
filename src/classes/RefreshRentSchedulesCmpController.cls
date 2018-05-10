public class RefreshRentSchedulesCmpController {
    
    @AuraEnabled
    public static String  refreshRentShc(String recordId) {
        String retStr = '';
        try{
            List<Lease_Charges__c> leasChargLst = [SELECT id,Commercial_Tax_Apply__c,Lease_Unit__r.Lease_Agreement_No__r.Property__r.Comm_Tax__c,GTO_Cap__c,Cap_Applicable__c 
                                                   FROM Lease_Charges__c where id=:recordId];
            
            if(leasChargLst.size() > 0){
                Lease_Charges__c ls = leasChargLst.get(0);         	
                
                List<Rent_Schedules__c> renSch = [Select Id,Name from Rent_Schedules__c where Lease_Charge__c =: ls.Id];
                if(renSch.size() > 0){
                    for(Rent_Schedules__c rs : renSch){
                        if(ls.Commercial_Tax_Apply__c){ 
                            if(ls.Lease_Unit__r.Lease_Agreement_No__r.Property__r.Comm_Tax__c!=null){ 
                                rs.Comm_Tax__c = ls.Lease_Unit__r.Lease_Agreement_No__r.Property__r.Comm_Tax__c; 
                            }else{ 
                                rs.Comm_Tax__c = 5; 
                            } 
                        } 
                        rs.Cap_Applicable__c = ls.Cap_Applicable__c; 
                        rs.Cap_Value__c = ls.GTO_Cap__c; 
                    }
                    update renSch;
                    retStr = 'Success: Rent Schedules refreshed.';
                }else{
                    retStr = 'Error: No Rent Schedules.';
                }
            }else{
                retStr = 'Error: No lease charges.';
            }
            
        }catch(Exception e){
            return 'Error: '+e.getMessage();           
        }
        return retStr;
    }
}