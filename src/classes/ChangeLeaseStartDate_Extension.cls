public with sharing class ChangeLeaseStartDate_Extension {

	public Lease__c lease{get;set;}
    public String selectedLease{get;set;}
    public Boolean closePage{get;set;}
    public Boolean error{get;set;}
    public String dtString{get;set;}

    public ChangeLeaseStartDate_Extension (ApexPages.standardController std) {
		this.lease = (Lease__c) std.getRecord();
		lease.Lease_Start_Date__c = System.today();
        lease.Lease_Tenure_Mths__c = Integer.valueOf(ApexPages.currentpage().getParameters().get('tenureMth'));
        lease.Lease_Tenure_Days__c = ApexPages.currentpage().getParameters().get('tenureDay'); 
		selectedLease =  ApexPages.currentpage().getParameters().get('selectedLease');
    }

    public void checkData() {

        error = false;
        if(lease.Lease_Start_Date__c == null ){
            error = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select Lease Start Date.'));
       }else if(lease.Lease_Tenure_Mths__c == null){
            error = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter Lease Tenure (Mths).'));
       }else if(lease.Lease_Tenure_Days__c == null){
            error = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter Lease Tenure (Days).'));
       }else if(Integer.valueOf(lease.Lease_Tenure_Mths__c) == 0 && Integer.valueOf(lease.Lease_Tenure_Days__c) == 0){
            error = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Both Lease Tenure (Mths) and Lease Tenure (Days) Value is 0.'));
       }else{
            error = false;
            dtString = DateTime.newInstance(lease.Lease_Start_Date__c.year(),lease.Lease_Start_Date__c.month(),lease.Lease_Start_Date__c.day()).format('YYYY/MM/d');

            Lease__c ls = [select Id, Lease_Status__c, Lease_Tenure_Mths__c, Lease_Tenure_Days__c, Original_End_Date__c, Lease_Start_Date__c from Lease__c where Id =: selectedLease];
            ls.Lease_Start_Date__c = lease.Lease_Start_Date__c;
            ls.Lease_Tenure_Mths__c = lease.Lease_Tenure_Mths__c;
            ls.Lease_Tenure_Days__c = lease.Lease_Tenure_Days__c;
            ls.Change_Lease_Start_Date__c = true;

            try{
                update ls;
                closePage = true;
            }catch(Exception e){
                closePage = false;
                System.debug('###Lease Change Date Exception Occured:' + e.getMessage());
            }
       }
    }

}