({
	doInit : function(component, event, helper) {
        helper.getLeaseRecord(component);    
    },     
    processRecord : function(component, event, helper) {
        component.set("v.IsSpinner", true);
        var isError = false;
        var msg = '';
       
        if(!(component.get("v.lease.Rent_Free_Start_Date__c"))){
            isError = true;
            msg = 'Please Select Rent Free Start Date.';
        }else if(!(component.get("v.lease.Rent_Free_End_Date__c"))){
            isError = true;
            msg = 'Please select Rent Free End Date.';
        }else if(!(component.get("v.lease.Rent_Free_End_Date__c") > component.get("v.lease.Rent_Free_Start_Date__c"))){
            isError = true
            msg = 'Please select End Date more than Start Date.';
        }else if(!(component.get("v.lease.Rent_Free_Start_Date__c") >= component.get("v.lease.Lease_Start_Date__c") && component.get("v.lease.Rent_Free_End_Date__c") <= component.get("v.lease.Lease_End_Date__c"))){
            isError = true;
            msg = 'Rent Free Start and End Date should be betweeen Lease Start and End Date.';
        }
        
        if(isError){
            component.set("v.msgStr", msg);
        }else{            
            helper.saveLeasRecordHelper(component);              
        }
        component.set("v.IsSpinner", false);
    }, 
    close : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})