public  class PreTerminateLU_Extension {
    public Lease_Unit__c lu{get;set;}
    public Boolean termError{get;set;}
    public Boolean error{get;set;}
    public Boolean closePage{get;set;}
    public String dtString{get;set;}
    public String selectedLU{get;set;}
    public Boolean displayPopup {get;set;}
    public String currentEndDate{get;set;}
    public Lease_Unit__c leaseUnit;
    public Date EndDate{get;set;}
    public List < Rent_Schedules__c > rsList;
    public boolean isVF {get;set;}
    public String errorMsg;
    public PreTerminateLU_Extension(){
    	isVF = false;
    	errorMsg = '';
    	error = true;
    }
    public PreTerminateLU_Extension(ApexPages.StandardController stdController) {
    	isVF = true;
    	errorMsg = '';
        rsList = new List < Rent_Schedules__c >();
        displayPopup = false;
        this.lu = (Lease_Unit__c) stdController.getRecord();
        lu.Lease_End_Date__c = System.today();
        currentEndDate = ApexPages.currentpage().getParameters().get('endDate');
        selectedLU = ApexPages.currentpage().getParameters().get('selectedLeaseUnits');

        if (currentEndDate != null && currentEndDate != '') {
            EndDate = date.parse(currentEndDate);
        }
        error = true;
    }

    public String checkDate() {
       
        termError = false;
        error = false;
        System.debug('11111---');   
        leaseUnit = [Select Id, Name,Pre_Termination__c, Original_End_Date__c, Lease_Start_Date__c, Lease_End_Date__c, Lease_Agreement_No__r.Lease_Start_Date__c, Lease_Agreement_No__r.Lease_End_Date__c from Lease_Unit__c where Id =: selectedLU];
         rsList = [Select Id, Status__c, Start_Date__c, End_Date__c, Lease_Unit__c, Lease_Unit__r.Lease_Start_Date__c, Lease_Unit__r.Lease_End_Date__c from Rent_Schedules__c where Lease_Unit__c =: selectedLU];
        errorMsg = '';
        System.debug('2222---'+rsList);
        if (lu.Reason_for_Termination__c == null || lu.Reason_for_Termination__c.trim() == '') {
            termError = true;
            errorMsg = 'Reason: Please add Reason for Termination';
        }else if (lu.Lease_End_Date__c == null) {
            errorMsg = 'Date: Please Select Termination Date.';
        } else if (lu.Lease_End_Date__c <= leaseUnit.Lease_Start_Date__c) {
            errorMsg = 'Date: Termination Date must be after Lease Unit Start Date';
        } else if (lu.Lease_End_Date__c >= leaseUnit.Lease_End_Date__c) {
            if (lu.Lease_End_Date__c >= leaseUnit.Lease_End_Date__c) {
                errorMsg = 'Date: Termination Date must be before Lease Unit End Date';
            } else {
                errorMsg = 'Date: Termination Date must be before Lease Unit Original End Date';
            } 
        } 
        if(errorMsg != ''){
        	error = true;
        	if(isVF)
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMsg));
            return errorMsg;
        }
        error = false;
        if (!error && !termError) {
            Boolean isAdmin = PreTerminate_Helper.checkSysAdm();
            if(isAdmin && PreTerminate_Helper.validateRS(lu.Lease_End_Date__c,rsList)){
                displayPopup = true;
                errorMsg = 'displayPopup.';
            }else if(!PreTerminate_Helper.validateRS(lu.Lease_End_Date__c,rsList)){
            	 System.debug('rsList-->'+rsList);
            	try{
                	this.save();
                	return 'Success';
                }catch(Exception e){
                	errorMsg = e.getMessage();
                }
            }else{
                error = true;
                errorMsg = 'Rent Roll already generated for this Lease Unit and cannot be Terminated.';
            }
            if(isVF)
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMsg));
    		return errorMsg;
        }
        return '';
    }
    public String save(){
    	try{
    		this.saveLULC();
	        System.debug('rsList-->'+rsList);
	        PreTerminate_Helper.updateRS(lu.Lease_End_Date__c,rsList);
	        return 'Success';
    	}catch(Exception e){
        	errorMsg = e.getMessage();
        	if(isVF)
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMsg));
        	return errorMsg;
        }
        return 'Success';
    }
    public String saveLULC(){
        SavePoint sp = Database.setSavePoint();
        if (leaseUnit != null || Test.isRunningTest()) {
                closePage = true;
                leaseunit.Pre_Termination__c = true;
                leaseUnit.Reason_for_Termination__c = lu.Reason_for_Termination__c;
                leaseUnit.Lease_Start_Date__c = lu.Lease_Agreement_No__r.Lease_Start_Date__c;
                if (leaseUnit.Original_End_Date__c == null) {
                    leaseUnit.Original_End_Date__c = leaseUnit.Lease_End_Date__c;
                }
                leaseUnit.Lease_End_Date__c = lu.Lease_End_Date__c;
                
                List<Lease_POS__c> posList = [select Id, End_Date__c, Start_Date__c, Status__c from Lease_POS__c where Lease_Unit__c =: selectedLU And (Start_Date__c >=: lu.Lease_End_Date__c or End_Date__c >=: lu.Lease_End_Date__c)];
                for(Lease_POS__c lpos:posList){
                    lpos.Start_Date__c = (lpos.Start_Date__c > lu.Lease_End_Date__c)?lu.Lease_End_Date__c:lpos.Start_Date__c;
                    lpos.End_Date__c = lu.Lease_End_Date__c;
                }
                
                List< Lease_Charges__c > lcList = [Select Id,Pre_Termination__c, Start_Date__c, End_Date__c, Lease_Unit__c, Lease_Unit__r.Lease_Start_Date__c, Lease_Unit__r.Lease_End_Date__c from Lease_Charges__c where Lease_Unit__c =: selectedLU];
                if (lcList.size() > 0) {
                    for (Lease_Charges__c lcl: lcList) {
                        lcl.Pre_Termination__c = true;
                        if (lcl.End_Date__c > lu.Lease_End_Date__c && lcl.Start_Date__c < lu.Lease_End_Date__c) {
                            lcl.End_Date__c = lu.Lease_End_Date__c;
                        }
                    }
                }
                if(!error)
                    try {
                        update leaseUnit;
                        update posList;
                        //update rsList; removed because RS is terminated from LC via Trigger. here rsList is used just for validation
                        update lcList;
                        
                        errorMsg = 'Success';
			        	if(isVF)
			        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMsg));
			        	return errorMsg;
                         error = true;
                    } catch (Exception e) {
                        Database.rollback(sp);
                        closePage = false;
                        error = true;
                        errorMsg = e.getMessage();
			        	if(isVF)
			        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMsg));
			        	return errorMsg;
                    }
            }
             return '';
    }
}