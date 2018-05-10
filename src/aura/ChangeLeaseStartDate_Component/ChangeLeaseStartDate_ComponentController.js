({
    doInit : function(component, event, helper) {
        helper.getTenureDays(component);
        helper.getLeaseRecord(component);       
    }, 
    close : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    },
    saveLease : function(component, event, helper) {
        var isError = false;
        var msg = '';
        
        if(!(component.get("v.lease.Lease_Start_Date__c"))){
            isError = true;
            msg = 'Please Select Lease Start Date.';
        }else if(!(component.get("v.lease.Lease_Tenure_Mths__c"))){
            isError = true;
            msg = 'Please Enter Lease Tenure (Mths).';
        }else if(!(component.get("v.lease.Lease_Tenure_Days__c"))){
            isError = true
            msg = 'Please Enter Lease Tenure (Days).';
        }else if(component.get("v.lease.Lease_Tenure_Days__c") == 0 && component.get("v.lease.Lease_Tenure_Mths__c") == 0){
            isError = true;
            msg = 'Both Lease Tenure (Mths) and Lease Tenure (Days) Value is 0.';
        }
        
        if(isError){
            component.set("v.msgStr", msg);
           /* var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": msg,
                "type":"error"
            });
            toastEvent.fire();*/
        }else{
            component.set("v.IsSpinner", true);
            helper.saveLeasRecord(component);  
            component.set("v.IsSpinner", false);
        }
    }, 
})