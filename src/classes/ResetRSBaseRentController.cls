public with sharing class ResetRSBaseRentController {
	public String lcId{get;set;}
	public date startDate{get;set;}
    public date endDate{get;set;}
    public string errorMsg{get;set;}
    public Boolean isError{get;set;}
    public Boolean success{get;set;}
    public Lease_Charges__c lcUI{get;set;}
    public List<Rent_Schedules__c> listResetRS{get;set;}
    
    public ResetRSBaseRentController(){
    	lcId = Apexpages.currentPage().getParameters().get('Id');
    	listResetRS= new List<Rent_Schedules__c>();
    	
    	lcUI = new Lease_Charges__c();
    	lcUI = [select Id,Start_Date__c,End_Date__c,Lease_Unit__c,Parent_Lease_Charge__c from Lease_Charges__c where id=:lcId]; 
    	lcUI.Start_Date__c = null;
    	lcUI.End_Date__c = null;
    }
    public void generate(){
    	listResetRS= new List<Rent_Schedules__c>();
    	if(lcUI.Start_Date__c > lcUI.End_Date__c){
    		Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select valid Start End Date.'));
    	}else if(lcUI.Parent_Lease_Charge__c == null){
    		lcUI.Parent_Lease_Charge__c.addError('Please select Base Rent LC.');
    	}else{
    		List<Rent_Schedules__c> listBaseRRS=[select id,name,Start_Date__c,End_Date__c,Amount__c,Amount_Local__c,Amount_Foreign__c,
    											Calculated_Amount__c,Calculated_Amount_Foreign__c,Calculated_Amount_Local__c 
    											from Rent_Schedules__c where Lease_Charge__c =: lcUI.Parent_Lease_Charge__c];
    		
    		if(listBaseRRS.size() > 0){
    			listResetRS=[select id,name,Start_Date__c,End_Date__c,Amount__c,Base_Rent_RS_1__c,Base_Rent_RS_2__c,Amount_Local__c,
    						Amount_Foreign__c,Calculated_Amount__c,Calculated_Amount_Foreign__c,Calculated_Amount_Local__c 
    							from Rent_Schedules__c 
    							where Lease_Charge__c =: lcId and Start_Date__c >=: lcUI.Start_Date__c and End_Date__c <=: lcUI.End_Date__c 
    								and Status__c = 'In-Tenancy' ];
	    		Map<Id,Rent_Schedules__c> baseRsMap = new Map<Id,Rent_Schedules__c>();
	    		
	    		for(Rent_Schedules__c rs:listResetRS){
		            for(Rent_Schedules__c baseRs:listBaseRRS){
		                baseRsMap.put(baseRs.Id,baseRs);
		                if(rs.Start_Date__c>=baseRs.Start_Date__c && rs.Start_Date__c<=baseRs.End_Date__c){
		                    rs.Base_Rent_RS_1__c = baseRs.Id;
		                }
		                if(rs.End_Date__c>=baseRs.Start_Date__c && rs.End_Date__c<=baseRs.End_Date__c){
		                    if(baseRs.Id!=rs.Base_Rent_RS_1__c){
		                        rs.Base_Rent_RS_2__c = baseRs.Id;
		                    }
		                }
		            }
		            rs.Converted_Base_Rent__c = RSTrigger_Helper.doBRcalculation(rs, rs.Base_Rent_RS_1__c, rs.Base_Rent_RS_2__c ,baseRsMap);
		        }
    		}else{
    			Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please generate Base Rent RS first for selected period.'));
    		}
    	}
    }
    public void save(){
    	try{
    		update listResetRS;
    		success = true;
    	}catch(Exception e){
    		Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Exception Occured - '+e));
    	}
    }
    public void checkLC(){
    	listResetRS= new List<Rent_Schedules__c>();
    	if(lcUI.Parent_Lease_Charge__c != null)
	    	for(Lease_Charges__c lc:[select Id,Charge_Type__c,Base_Charge_Type__c from Lease_Charges__c where id =: lcUI.Parent_Lease_Charge__c]){
	    		/*if(lc.Base_Charge_Type__c == null){
	    			lcUI.Parent_Lease_Charge__c.addError('Please select Base Charge Type before reset Base Rent RS');
	    		}else*/ if(lc.Charge_Type__c != 'Advance Rental'){
	    			lcUI.Parent_Lease_Charge__c.addError('Please select Base Rent LC.');
	    		}
	    	}
    }
}