public class LeaseUnitCancelCompController {
    
    @AuraEnabled
    public static string checkLeaseStatus(String recordId){
        String msg = 'success';
        Boolean displayPopup = false;
        
        List<Lease_Unit__c> luLst = [Select id,Cancel_Reason__c,Lease_Unit_Status__c,Unit__c,Lease_Start_Date__c,Lease_End_Date__c 
                                     FROM Lease_Unit__c WHERE Id =:recordId limit 1];
        
        if(luLst.size() > 0){
            Lease_Unit__c lsUnt = luLst.get(0);
            
            if(lsUnt.Lease_Unit_Status__c != 'Cancelled'){
                
                List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
                String MyProflieName = PROFILE[0].Name;
                
                if(MyProflieName == 'System Administrator'){
                    List<Rent_Schedules__c> rsList =  [Select id,Status__c from Rent_Schedules__c where Lease_Charge__r.Lease_Unit__c =:lsUnt.Id];
                    
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
                msg = 'Error: Lease Unit is already cancelled.';
            }
        }else{
            msg = 'Error: Lease Unit not found.';
        }
        
        return msg;
    }
    
    @AuraEnabled
    public static String cancelLeaseUnitRec(String recordId, String reasonForCancel){
        SavePoint sp = Database.setSavePoint();
        String msg = 'Success';
        try{
            Boolean bypass;
            List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            if(PROFILE[0].Name == 'System Administrator')
                bypass = true;
            
            Lease_Unit__c lsUnt = new Lease_Unit__c();
            for(Lease_Unit__c lu:[Select id,Cancel_Reason__c,Lease_Unit_Status__c,Unit__c,Lease_Start_Date__c,Lease_End_Date__c from Lease_Unit__c where id=:recordId limit 1])
                lsUnt = lu;
            
            if(lsUnt.Id!=null){
                lsUnt.Cancel_Reason__c = reasonForCancel;
                lsUnt.Lease_Unit_Status__c = 'Cancelled';
                update lsUnt;
                
                List<Lease_Plan__c> leasePlans = [Select id,Start_Date__c,End_Date__c from Lease_Plan__c where Lease_Unit__c=:lsUnt.Id];
                for(Lease_Plan__c lp: leasePlans){
                    if(lp.Start_Date__c>=lsUnt.Lease_Start_Date__c && lp.End_Date__c<=lsUnt.Lease_End_Date__c){
                        lp.Status__c = 'Vacant';
                        lp.Monthly_Committed_Budget__c = null;
                    }else if(lp.Start_Date__c>=lsUnt.Lease_Start_Date__c && lp.Start_Date__c<=lsUnt.Lease_End_Date__c && lp.End_Date__c>lsUnt.Lease_End_Date__c){
                        for(Date dt=lp.Start_Date__c;dt<=lsUnt.Lease_End_Date__c;dt=dt+1){
                            lp.put('Status_'+dt.day()+'__c','Vacant');
                            lp.put('Daily_Committed_Rate_'+dt.day()+'__c',null);
                            lp.put('Daily_LOI_Rate_'+dt.day()+'__c',null);
                        }                
                    }else if(lp.Start_Date__c<lsUnt.Lease_Start_Date__c && lp.End_Date__c>=lsUnt.Lease_Start_Date__c && lp.End_Date__c<=lsUnt.Lease_End_Date__c){
                        for(Date dt=lsUnt.Lease_Start_Date__c;dt<=lp.End_Date__c;dt=dt+1){
                            lp.put('Status_'+dt.day()+'__c','Vacant');
                            lp.put('Daily_Committed_Rate_'+dt.day()+'__c',null);
                            lp.put('Daily_LOI_Rate_'+dt.day()+'__c',null);
                        }
                    }else if(lp.Start_Date__c<lsUnt.Lease_Start_Date__c && lp.End_Date__c>lsUnt.Lease_End_Date__c){
                        for(Date dt=lsUnt.Lease_Start_Date__c;dt<=lsUnt.Lease_End_Date__c;dt=dt+1){
                            lp.put('Status_'+dt.day()+'__c','Vacant');
                            lp.put('Daily_Committed_Rate_'+dt.day()+'__c',null);
                            lp.put('Daily_LOI_Rate_'+dt.day()+'__c',null);
                        }
                    }
                    
                    lp.Lease_Unit__c = null;
                    
                    lp.LOI__c = false;
                    lp.Commited__c = false;
                    lp.LOI_Monthly_Budget__c = null;
                    lp.LOI_Unit__c = null;
                    
                }
                update leasePlans;
                
                
                List<Lease_Charges__c> lsChgList = [Select id,Active__c,Lease_Plan__c,Cancel_Reason__c,Start_Date__c,End_Date__c from Lease_Charges__c where Lease_Unit__c=:lsUnt.Id];
                
                if(lsChgList.size()>0){
                    Set<Id> lcIds = new Set<Id>();
                    Map<Id,Lease_Plan__c> lpMap = new Map<Id,Lease_Plan__c>();
                    for(Lease_Charges__c lc:lsChgList){
                        if(lc.Lease_Plan__c!=null && lc.Start_Date__c!=null && lc.End_Date__c!=null){
                            for(Date dt=lc.start_Date__c;dt<=lc.End_Date__c;dt=dt+1){
                                Lease_Plan__c lp = new Lease_Plan__c();
                                lp.Id = lc.Lease_Plan__c;
                                if(lpMap.containsKey(lp.Id)){
                                    lp = lpMap.get(lp.Id);
                                }
                                lp.put('Status_'+dt.day()+'__c','Vacant');
                                lp.put('Daily_Committed_Rate_'+dt.day()+'__c',null);
                                lp.put('Daily_LOI_Rate_'+dt.day()+'__c',null);
                                lpMap.put(lp.Id,lp);
                            }
                            lc.Lease_Plan__c = null;
                        }
                        lc.Active__c = false;
                        lcIds.add(lc.Id);
                    }
                    
                    if(lpMap.size()>0){
                        update lpMap.values();
                    }
                    
                    update lsChgList;
                    
                    List<Rent_Schedules__c> rsList = [Select id,Status__c from Rent_Schedules__c where Lease_Charge__c in:lcIds];
                    for(Rent_Schedules__c rs:rsList){
                        If(rs.Status__c=='Rent Roll Generated'){
                            if(!bypass){
                                msg = 'Error: Rent Roll already generated for this Lease Unit and cannot be Cancelled.';
                                Database.rollback(sp);
                                return msg;
                            }
                        }else{
                            rs.Status__c = 'Cancelled';
                        }
                    }
                    update rsList;
                }
                
            }else{
                 msg = 'Error: Lease Unit not found.';
            }
            
        }catch(exception e){
            msg = 'Error: '+e.getMessage();
            Database.rollback(sp);
        }
        return msg;
    }
    
}