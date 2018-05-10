/*
    Name    :   PreTerminateLease_Extension
    Author  :   Arshad Shaikh (Techmatrix Consulting)
    Date    :   09/01/2017
    Description : This extension is used in  is used for PreTerminateLease Page.
            To Pre terminate Lease, Lease Unit, Rent Schedule and Lease Charges according to date input by user.
    Test Class: PreTerminate_Test
*/
public class PreTerminateLease_Extension {
    public Lease__c leaseOnUI{get;set;}
    public Boolean error{get;set;}
    public Boolean termError{get;set;}
    public String dtString{get;set;}
    public Boolean closePage{get;set;}
    public String selectedLease{get;set;}
    public Boolean displayPopup {get;set;}
    public String currentEndDate{get;set;}
    public Lease__c lc;
    public List < Rent_Schedules__c >  rsList;
    public Date EndDate{get;set;}
    public String errorMsg;
    public boolean isVF {get;set;}
    public PreTerminateLease_Extension() {
    	rsList = new List < Rent_Schedules__c >();
        rsList = new List < Rent_Schedules__c >();
        lc  = new Lease__c();
        isVF = false;
        errorMsg = '';
    }
    public PreTerminateLease_Extension(ApexPages.StandardController stdController) {
    	errorMsg = '';
    	isVF = true;
    	rsList = new List < Rent_Schedules__c >();
        rsList = new List < Rent_Schedules__c >();
        lc  = new Lease__c();
        this.leaseOnUI = (Lease__c) stdController.getRecord();
        leaseOnUI.Lease_Start_Date__c = System.today();
        currentEndDate = ApexPages.currentpage().getParameters().get('endDate');
        selectedLease = ApexPages.currentpage().getParameters().get('selectedLease');

        if (currentEndDate != null && currentEndDate != '') {
            EndDate = date.parse(currentEndDate);
        }
    }

    public String checkDate() {
        
        error = true;
        termError = false;
        lc = [select Id, Lease_Status__c,Pre_Terminated__c, Original_End_Date__c, Lease_Start_Date__c, Reason_for_Termination__c from Lease__c where Id =: selectedLease];
         rsList = [Select Id, Status__c, Start_Date__c, End_Date__c, Lease_Unit__c, Lease_Unit__r.Lease_Start_Date__c, Lease_Unit__r.Lease_End_Date__c, Lease_Unit__r.Lease_Agreement_No__r.Lease_Start_Date__c, Lease_Unit__r.Lease_Agreement_No__r.Original_End_Date__c from Rent_Schedules__c where Lease_Unit__r.Lease_Agreement_No__c =: selectedLease];
        if (leaseOnUI.Reason_for_Termination__c == null || leaseOnUI.Reason_for_Termination__c.trim() == '') {
            termError = true;
            errorMsg = 'Reason: Please add Reason for Termination';
        }else if (leaseOnUI.Lease_Start_Date__c == null) {
            errorMsg = 'Date: Please Select Termination Date';
        } else if (leaseOnUI.Lease_Start_Date__c <= lc.Lease_Start_Date__c) {
            errorMsg = 'Date: Pre-Termination Date must be after Lease Start Date.';
        } else if (leaseOnUI.Lease_Start_Date__c >= EndDate) {
            errorMsg = 'Date: Pre-Termination Date must be before Revised End Date.';
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
            if(isAdmin && PreTerminate_Helper.validateRS(leaseOnUI.Lease_Start_Date__c,rsList)){
                displayPopup = true;
                errorMsg = 'displayPopup.';
            }else if(!PreTerminate_Helper.validateRS(leaseOnUI.Lease_Start_Date__c,rsList)){
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
	        PreTerminate_Helper.updateRS(leaseOnUI.Lease_Start_Date__c,rsList);
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
        
        System.debug('lc--->' + lc);
        lc.Pre_Terminated__c = true;
        lc.Reason_for_Termination__c = leaseOnUI.Reason_for_Termination__c;
        lc.Original_End_Date__c = leaseOnUI.Lease_Start_Date__c;

        List < Lease_Unit__c > luList = [Select Id, Name, Original_End_Date__c,Pre_Termination__c, Lease_Start_Date__c, Lease_End_Date__c, Lease_Agreement_No__r.Lease_Start_Date__c, Lease_Agreement_No__r.Original_End_Date__c from Lease_Unit__c where Lease_Agreement_No__r.Id =: selectedLease];
        List < Rent_Schedules__c > rsList = new List < Rent_Schedules__c >();
        List < Lease_Charges__c > lcList = new List < Lease_Charges__c >();
        List<Lease_POS__c> posList = new List<Lease_POS__c>();
        Set < Id > luIds = new Set < Id > ();
        if (luList.size() > 0) {
            for (Lease_Unit__c lu: luList) {
                if (lu.Lease_End_Date__c > leaseOnUI.Lease_Start_Date__c) {
                    lu.Pre_Termination__c = true;
                    lu.Reason_for_Termination__c = leaseOnUI.Reason_for_Termination__c;
                    lu.Lease_End_Date__c = leaseOnUI.Lease_Start_Date__c;
                }
                luIds.add(lu.Id);
            }
            posList = [select Id, End_Date__c, Start_Date__c, Status__c from Lease_POS__c where Lease_Unit__c =: luIds And (Start_Date__c >=: leaseOnUI.Lease_Start_Date__c or End_Date__c >=: leaseOnUI.Lease_Start_Date__c)];
            for(Lease_POS__c lpos:posList){
                lpos.Start_Date__c = (lpos.Start_Date__c > leaseOnUI.Lease_Start_Date__c)?leaseOnUI.Lease_Start_Date__c:lpos.Start_Date__c;
                lpos.End_Date__c = leaseOnUI.Lease_Start_Date__c;
            }
            
            lcList = [Select Id, Start_Date__c,Pre_Termination__c, End_Date__c, Lease_Unit__c, Lease_Unit__r.Lease_Start_Date__c, Lease_Unit__r.Lease_End_Date__c, Lease_Unit__r.Lease_Agreement_No__r.Lease_Start_Date__c, Lease_Unit__r.Lease_Agreement_No__r.Original_End_Date__c from Lease_Charges__c where Lease_Unit__c =: luIds];
            if (lcList.size() > 0) {
                for (Lease_Charges__c lcl: lcList) {
                    lcl.Pre_Termination__c = true;
                    if (lcl.End_Date__c > leaseOnUI.Lease_Start_Date__c && lcl.Start_Date__c < leaseOnUI.Lease_Start_Date__c) {
                        lcl.End_Date__c = leaseOnUI.Lease_Start_Date__c;
                    }
                }
            }
        }
        if(!error){
            try {
                update lc;
                update luList;
                update posList;
                //update rsList; removed because RS is terminated from LC via Trigger. here rsList is used just for validation
                update lcList;
                closePage = true;
                errorMsg = 'Success';
            } catch (Exception e) {
                Database.rollback(sp);
                closePage = false;
                error = true;
                errorMsg = e.getMessage();
            }
            if(isVF)
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMsg));
        	return errorMsg;
        }
        return '';
    }
}