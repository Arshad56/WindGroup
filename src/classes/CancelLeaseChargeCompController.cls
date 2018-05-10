public class CancelLeaseChargeCompController {
    
    @AuraEnabled
    public static string checkLeaseStatus(String recordId){
        String msg = 'success';
        Boolean displayPopup = false;
        
        List<Lease_Charges__c> leasChargList = [SELECT Id, Active__c FROM Lease_Charges__c 
                                                WHERE Id =:recordId];
        if(leasChargList.size() > 0){
            Lease_Charges__c lc = leasChargList.get(0);
            
            if(lc.Active__c){
                
                List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
                String MyProflieName = PROFILE[0].Name;
                
                if(MyProflieName == 'System Administrator'){
                    List<Rent_Schedules__c> rsList = [Select id,Status__c from Rent_Schedules__c where Lease_Charge__c =:recordId];
                    
                    for(Rent_Schedules__c rs:rsList){
                        If(rs.Status__c=='Rent Roll Generated' ){
                            displayPopup = true;
                            break;
                        }
                    }
                }
                
                if(displayPopup){
                    msg = 'DisplayPopup';
                }
            }else{
                msg = 'Error: Lease Charge is already cancelled.';
            }
        }else{
            msg = 'Error: Lease Charge not found.';
        }
        
        return msg;
    }
    
    @AuraEnabled
    public static String cancelLeaseChargeRec(String recordId, String reasonForCancel){
        String msg = 'Success';
        SavePoint sp = Database.setSavePoint();
        try{
            Boolean bypass;
            List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            if(PROFILE[0].Name == 'System Administrator')
                bypass = true;
            
            Lease_Charges__c lsChg = new Lease_Charges__c();
            for(Lease_Charges__c lc:[Select id,Active__c,Lease_Plan__c,Cancel_Reason__c,Start_Date__c,End_Date__c from Lease_Charges__c where id=:recordId limit 1])
                lsChg = lc;
            
            
            if(lsChg.Id!=null){
                if(lsChg.Active__c){
                    List<Rent_Schedules__c> rsList = [Select id,Status__c from Rent_Schedules__c where Lease_Charge__c=:lsChg.Id];
                    for(Rent_Schedules__c rs:rsList){
                        if(rs.Status__c=='Rent Roll Generated'){
                            if(!bypass){
                                msg = 'Error: Rent Roll already generated for this Lease Charge and cannot be Cancelled.';
                                return msg;
                            }
                        }else{
                            rs.Status__c = 'Cancelled';
                        }
                    }
                    update rsList;
                    
                    if(lsChg.Lease_Plan__c!=null && lsChg.start_Date__c!=null && lsChg.End_Date__c!=null){
                        List<Lease_Plan__c> lpList = [Select id from Lease_Plan__c where id=:lsChg.Lease_Plan__c limit 1];
                        if(lpList.size()>0){
                            for(Date dt=lsChg.start_Date__c;dt<=lsChg.End_Date__c;dt=dt+1){
                                lpList[0].put('Status_'+dt.day()+'__c','Vacant');
                                lpList[0].put('Daily_Committed_Rate_'+dt.day()+'__c',null);
                            }
                            update lplist;
                        }
                    }
                    lsChg.Cancel_Reason__c = reasonForCancel;
                    lsChg.Active__c = false;
                    lsChg.Lease_Plan__c = null;
                    update lsChg;
                }else{
                    msg = 'Error: Lease Charge is Inactive..';
                }    
            }else{
                msg = 'Error: Lease Charge not found.';
            }
        }catch(exception e){
            msg = 'Error: '+e.getMessage();
            Database.rollback(sp);
        }
        return msg;
    }
}