({
    doInit : function(component, event, helper) {
        component.set("v.IsSpinner",true);
        helper.checkLeaseUnitActiveHelper(component);       
        component.set("v.IsSpinner",false);
    },
    processYes : function(cmp, event, helper) {
        cmp.set("v.displayMessage",false);
    },
    cancelLeaseUnit : function(cmp, event, helper) {
        cmp.set("v.IsSpinner",true);
        helper.cancelLeaseUnitHelper(cmp);
        cmp.set("v.IsSpinner",false);
        cmp.set("v.displayMessage",false);
    },
    close : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
    /*
	doInit : function(component, event, helper) {
		var action = component.get("c.checkLeaseStatus");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var retStr = response.getReturnValue();
             if(response.getState() === "SUCCESS" && retStr.startsWith('Error')) {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": retStr,
                    "type" : "Error"
                });
                toastEvent.fire();
                $A.get("e.force:refreshView").fire();	
            }else{
                $A.get("e.force:closeQuickAction").fire();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/apex/CancelLeaseUnit?Id="+component.get("v.recordId")
                });
                urlEvent.fire();           
            }
             
           $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
	}*/
})