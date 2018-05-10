({
	doInit : function(cmp, event, helper) {
		cmp.set("v.displayCmp",true);
        cmp.set("v.IsSpinner",false);
	},
    populateBaseRentRs : function(cmp, event, helper) {
        cmp.set("v.IsSpinner",true);
        var action = cmp.get("c.populateBaseRent");
        action.setParams({ 
        	recordId : cmp.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var resString = response.getReturnValue();
            cmp.set("v.IsSpinner",false);
            if(response.getState() == "SUCCESS" && resString.startsWith('Info')) {
            	$A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": resString,
                    "type" : "info"
                });
                toastEvent.fire();
            }else{
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resString,
                    "type":"error"
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);
    },
    close : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})