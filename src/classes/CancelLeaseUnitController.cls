public class CancelLeaseUnitController{
    public Boolean displayPopup {get;set;}
	
    public Lease_Unit__c lsUnt{get;set;} 
    public Boolean success{get;set;} 
    public Boolean bypass{get;set;}
    public CancelLeaseUnitController(){  
    	displayPopup = false;
        success = false;
        lsUnt = new Lease_Unit__c();
        for(Lease_Unit__c lu:[Select id,Cancel_Reason__c,Lease_Unit_Status__c,Unit__c,Lease_Start_Date__c,Lease_End_Date__c from Lease_Unit__c where id=:Apexpages.CurrentPage().getParameters().get('Id') limit 1]){
            lsUnt = lu;
        }
        checkSysAdmin();
    }
     /* To allow admins to cacel all even if RR is generated*/
    /* By AS 23rmd March 18
    */
    public void checkSysAdmin(){
    	List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
		String MyProflieName = PROFILE[0].Name;
		
		if(MyProflieName == 'System Administrator'){
			bypass = true;
			 List<Rent_Schedules__c> rsList = [Select id,Status__c from Rent_Schedules__c where Lease_Charge__r.Lease_Unit__c =:lsUnt.Id];
			 
			 for(Rent_Schedules__c rs:rsList){
                If(rs.Status__c=='Rent Roll Generated' ){
					displayPopup = true;
					break;
                }
            }
		}
		
    }
    public void proceed(){
    	displayPopup = false;
    }
    public void save(){
        SavePoint sp = Database.setSavePoint();
        /* Made Cancel Reason Mandate*/
        /*By AS 28th March 18
        */
        if(String.isBlank(lsUnt.Cancel_Reason__c)){
        	Apexpages.AddMessage(new Apexpages.message(Apexpages.Severity.Error,'Reason for Cancel is required.'));
            return;
        }
        try{
            success = false;
            if(lsUnt.Id!=null){
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
                         		Apexpages.AddMessage(new Apexpages.message(Apexpages.Severity.Error,'Rent Roll already generated for this Lease Unit and cannot be Cancelled.'));
		                        Database.rollback(sp);
		                        return;
                         	}
                        }else{
                            rs.Status__c = 'Cancelled';
                        }
                    }
                    update rsList;
                }
                
                success = true;
            }else{
                Apexpages.AddMessage(new APexpages.message(Apexpages.Severity.Error,'Lease Unit not found.'));
            }
        }catch(exception e){
            Apexpages.AddMessage(new APexpages.message(Apexpages.Severity.Error,e.getMessage()));
            Database.rollback(sp);
        }
        Integer k = 0;
        k=0;
        k=0;
        k=0;
        k=0;
    }
}