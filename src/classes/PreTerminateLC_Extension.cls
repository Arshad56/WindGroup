public  class PreTerminateLC_Extension {
    public Lease_Charges__c leaseCharge{get;set;}
    public String selectedLeaseCharge{get;set;}
    public Boolean closePage{get;set;}
    public Boolean error{get;set;}
    public Boolean termError{get;set;}
    public String dtString{get;set;}
    public String currentEndDate{get;set;}
    public Boolean displayPopup {get;set;}
    public Lease_Charges__c lcTerminate;
    public Date EndDate{get;set;}
    public List<Rent_Schedules__c> rsList;
    public Boolean erroOnLoad{get;set;}
    public boolean isVF {get;set;}
    String errorMsg;
    public PreTerminateLC_Extension(){
    	isVF = false;
    	errorMsg = '';
    }
    public PreTerminateLC_Extension(ApexPages.StandardController stdController) {
    	errorMsg = '';
    	isVF = true;
        rsList = new List < Rent_Schedules__c >();
        lcTerminate = new Lease_Charges__c();
        this.leaseCharge = (Lease_Charges__c)stdController.getRecord();
        selectedLeaseCharge =  ApexPages.currentpage().getParameters().get('selectedLeaseCharges');
        currentEndDate =   ApexPages.currentpage().getParameters().get('endDate'); 
        
        leaseCharge.End_Date__c = date.parse(currentEndDate);
        
        list<Lease_Charges__c> discLClist = [select Id,Parent_Lease_Charge__c,Pre_Termination__c,(select id, Name from Rent_Schedules__r where status__c NOT IN ('Cancelled','Terminated')) from Lease_Charges__c where Parent_Lease_Charge__c =: selectedLeaseCharge And Parent_Lease_Charge__r.Pre_Termination__c = false];
        System.debug('discLClist-->'+discLClist);
        
        //added by myat to exclude validation checking for RS with status "Cancelled". apr-12-2018
        if(discLClist.size()>0 && discLClist[0].Rent_Schedules__r <> NULL && discLClist[0].Rent_Schedules__r.size() > 0){
            erroOnLoad =true;
            error = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Terminate dependent Lease Charge and related Rent Schedule(s) before you proceed.')); 
        }
    }
    
    public String  checkDate() {
        error = true;
        errorMsg = '';
        
        Lease_Charges__c lcTerminate = [select Id, Pre_Termination__c,Parent_Lease_Charge__c,Parent_Lease_Charge__r.Pre_Termination__c  ,Start_Date__c, End_Date__c from Lease_Charges__c where id =: selectedLeaseCharge];
        rsList=[Select Id,Status__c,Start_Date__c, End_Date__c, Lease_Charge__c, Lease_Charge__r.Start_Date__c, Lease_Charge__r.End_Date__c from Rent_Schedules__c where Lease_Charge__c =:selectedLeaseCharge];
        System.debug('111-->'+rsList);
        
        if(leaseCharge.End_Date__c == null){
            errorMsg = 'Date: Please Select Termination Date.';
        }else if( leaseCharge.End_Date__c < lcTerminate.Start_Date__c){
            errorMsg = 'Date: Termination Date must be after Lease Charge Start Date.';
        }else if(leaseCharge.End_Date__c >= lcTerminate.End_Date__c ){
            errorMsg = 'Date: Termination Date must be before Lease Charge End Date.';
        }
        if(errorMsg != ''){
        	if(isVF)
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMsg));
            return errorMsg;
        }
        System.debug('222-->'+error);
        error = false;
        if(!error){
            
            Boolean isAdmin = PreTerminate_Helper.checkSysAdm();
            System.debug('333-->'+isAdmin +' -- '+PreTerminate_Helper.validateRS(leaseCharge.End_Date__c,rsList));
            if(isAdmin && PreTerminate_Helper.validateRS(leaseCharge.End_Date__c,rsList)){
                System.debug('444-->');
                displayPopup = true;
                return 'displayPopup';
            }else if(!PreTerminate_Helper.validateRS(leaseCharge.End_Date__c,rsList)){
                System.debug('555-->');
                try{
                	this.save();
                	return 'Success';
                }catch(Exception e){
                	errorMsg = e.getMessage();
                	if(isVF)
	            		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMsg));
	            	return errorMsg;
                }
            }else{ 
                System.debug('666-->');
                error = true;
            	errorMsg = 'Rent Roll already generated for this Lease Charge and cannot be Terminated.';
	            if(isVF)
	            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMsg));
	            return errorMsg;
            }
            System.debug('777-->');
        }
        return errorMsg;
    }
    public String save(){
    	try{
    		this.saveLULC();
	        System.debug('rsList-->'+rsList);
	        PreTerminate_Helper.updateRS(leaseCharge.End_Date__c,rsList);
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
        if(leaseCharge != null || Test.isRunningTest()){
            
            lcTerminate.Id = selectedLeaseCharge;
            lcTerminate.End_Date__c =  leaseCharge.End_Date__c;
            lcTerminate.Pre_Termination__c   = true;
            
            try{
                update lcTerminate;
                closePage = true;
                return 'Success';
                //update rsList; removed because RS is terminated from LC via Trigger. here rsList is used just for validation
            }catch(Exception e){
                Database.rollback(sp);
                closePage = false;
                error = true;
                errorMsg = 'Exception Occured- '+e.getMessage();
            	if(isVF)
            		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMsg));
            	return errorMsg;
            }
        }
    	return 'Lease Charge is null';
    }
}