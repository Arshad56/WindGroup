public class CancelLeaseChargeController{
	    public Boolean displayPopup {get;set;}
	
    public Lease_Charges__c lsChg{get;set;} 
    public Boolean success{get;set;}
    public Boolean bypass{get;set;}
    public CancelLeaseChargeController(){
    	displayPopup = false;
        success = false;
        lsChg = new Lease_Charges__c();
        for(Lease_Charges__c lc:[Select id,Active__c,Lease_Plan__c,Cancel_Reason__c,Start_Date__c,End_Date__c from Lease_Charges__c where id=:Apexpages.CurrentPage().getParameters().get('Id') limit 1]){
            lsChg = lc;
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
			 List<Rent_Schedules__c> rsList = [Select id,Status__c from Rent_Schedules__c where Lease_Charge__c =:lsChg.Id];
			 
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
    	 /* Made Cancel Reason Mandate*/
        /*By AS 28th March 18
        */
        if(String.isBlank(lsChg.Cancel_Reason__c)){
        	Apexpages.AddMessage(new Apexpages.message(Apexpages.Severity.Error,'Reason for Cancel is required.'));
            return;
        }
        try{
            success = false;
            if(lsChg.Id!=null){
                if(lsChg.Active__c){
                    List<Rent_Schedules__c> rsList = [Select id,Status__c from Rent_Schedules__c where Lease_Charge__c=:lsChg.Id];
                    for(Rent_Schedules__c rs:rsList){
                        if(rs.Status__c=='Rent Roll Generated'){
                        	if(!bypass){
                        		Apexpages.AddMessage(new Apexpages.message(Apexpages.Severity.Error,'Rent Roll already generated for this Lease Charge and cannot be Cancelled.'));
                           		return;
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
                    
                    lsChg.Active__c = false;
                    lsChg.Lease_Plan__c = null;
                    update lsChg;
                    
                    success = true; 
                }else{
                    Apexpages.AddMessage(new APexpages.message(Apexpages.Severity.Error,'Lease Charge is Inactive..'));
                }    
            }else{
                Apexpages.AddMessage(new APexpages.message(Apexpages.Severity.Error,'Lease Charge not found.'));
            }
        }catch(exception e){
            Apexpages.AddMessage(new APexpages.message(Apexpages.Severity.Error,e.getMessage()));
        }
        
    }
}