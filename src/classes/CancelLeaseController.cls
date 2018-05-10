public class CancelLeaseController{
    public Boolean displayPopup {get;set;}
	public Boolean bypass{get;set;}
    public Boolean success{get;set;}
    public Lease__c lease{get;set;}
    public CancelLeaseController(){
        success = false; 
        displayPopup = false;
        lease = new Lease__c();
        For(Lease__c ls:[Select id,Cancel_Reason__c from lease__c where id=:Apexpages.CurrentPage().getParameters().get('Id') limit 1]){
            lease = ls;
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
			 List<Rent_Schedules__c> rsList = [Select id,Status__c from Rent_Schedules__c where Lease_Charge__r.Lease_Unit__r.Lease_Agreement_No__c =:lease.Id];
			 
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
        if(String.isBlank(lease.Cancel_Reason__c)){
        	//lease.Cancel_Reason__c.addError('Reason for Cancel is required.');
        	Apexpages.AddMessage(new Apexpages.message(Apexpages.Severity.Error,'Reason for Cancel is required.'));
            return;
        }
        try{
            if(lease.Id!=null){
                lease.Lease_Status__c = 'Cancelled';
                update lease;
                
                List<Lease_Unit__c> leaseUnitList = [Select id,Lease_Unit_Status__c,Unit__c,Lease_Start_Date__c,Lease_End_Date__c,(Select id,Start_Date__c,End_Date__c from Lease_Plans__r) from Lease_Unit__c where Lease_Agreement_No__c=:lease.Id];
                Set<Id> luIds = new Set<Id>();
                List<Lease_Plan__c> lpList = new List<Lease_Plan__c>();
                for(Lease_Unit__c lu:leaseUnitList){
                    lu.Lease_Unit_Status__c = 'Cancelled';
                    
                    luIds.add(lu.Id);
                    for(Lease_Plan__c lp:lu.Lease_Plans__r){
                        if(lp.Start_Date__c>=lu.Lease_Start_Date__c && lp.End_Date__c<=lu.Lease_End_Date__c){
                        	
                        	lp.LOI__c = false;
                        	lp.Commited__c = false;
                        	lp.LOI_Monthly_Budget__c = null;
                        	lp.LOI_Unit__c = null;
                        	
                            lp.Status__c = 'Vacant';
                            lp.Monthly_Committed_Budget__c = null;
                        }else if(lp.Start_Date__c>=lu.Lease_Start_Date__c && lp.Start_Date__c<=lu.Lease_End_Date__c && lp.End_Date__c>lu.Lease_End_Date__c){
                            for(Date dt=lp.Start_Date__c;dt<=lu.Lease_End_Date__c;dt=dt+1){
                                lp.put('Status_'+dt.day()+'__c','Vacant');
                                lp.put('Daily_Committed_Rate_'+dt.day()+'__c',null);
                                lp.put('Daily_LOI_Rate_'+dt.day()+'__c',null);
                            }                
                        }else if(lp.Start_Date__c<lu.Lease_Start_Date__c && lp.End_Date__c>=lu.Lease_Start_Date__c && lp.End_Date__c<=lu.Lease_End_Date__c){
                            for(Date dt=lu.Lease_Start_Date__c;dt<=lp.End_Date__c;dt=dt+1){
                                lp.put('Status_'+dt.day()+'__c','Vacant');
                                lp.put('Daily_Committed_Rate_'+dt.day()+'__c',null);
                                lp.put('Daily_LOI_Rate_'+dt.day()+'__c',null);
                            }
                        }else if(lp.Start_Date__c<lu.Lease_Start_Date__c && lp.End_Date__c>lu.Lease_End_Date__c){
                            for(Date dt=lu.Lease_Start_Date__c;dt<=lu.Lease_End_Date__c;dt=dt+1){
                                lp.put('Status_'+dt.day()+'__c','Vacant');
                                lp.put('Daily_Committed_Rate_'+dt.day()+'__c',null);
                                lp.put('Daily_LOI_Rate_'+dt.day()+'__c',null);
                            }
                        }
                        
                        lp.Lease_Unit__c = null;
                        
                        lpList.add(lp);
                    }
                }
                
                update leaseUnitList;
                
                update lpList;
                
                List<Lease_Charges__c> lsChgList = [Select id,Active__c,Lease_Plan__c,Cancel_Reason__c,Start_Date__c,End_Date__c from Lease_Charges__c where Lease_Unit__c in:luIds];
                
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
                        	if( !bypass){
                        		Apexpages.AddMessage(new Apexpages.message(Apexpages.Severity.Error,'Rent Roll already generated for this Lease and cannot be Cancelled.'));
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
                Apexpages.AddMessage(new APexpages.message(Apexpages.Severity.Error,'Lease not found.'));
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
        k=0;
        k=0;
        k=0;
        k=0;
        k=0;
        k=0;
        k=0;
    }
}