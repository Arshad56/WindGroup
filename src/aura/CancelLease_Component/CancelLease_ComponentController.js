({
    doInit : function(component, event, helper) {
        component.set("v.IsSpinner",true);
        helper.checkLeaseActiveHelper(component);       
        component.set("v.IsSpinner",false);
    },
    processYes : function(cmp, event, helper) {
        cmp.set("v.displayMessage",false);
    },
    cancelLease : function(cmp, event, helper) {
        cmp.set("v.IsSpinner",true);
        helper.cancelLeaseHelper(cmp);
        cmp.set("v.displayMessage",false);
    },
    close : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
    /*
    doInit : function(component, event, helper) {
        var action = component.get("c.checkLeaseStatus");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var retValue = response.getReturnValue();
            if(!(response.getState()==='SUCCESS' && retValue=='success')){
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": retValue,
                    "type":"error"
                });
                toastEvent.fire();
            }
            else{
                $A.get("e.force:closeQuickAction").fire();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/apex/CancelLease?Id="+component.get("v.recordId")
                });
                urlEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }*/
    
})