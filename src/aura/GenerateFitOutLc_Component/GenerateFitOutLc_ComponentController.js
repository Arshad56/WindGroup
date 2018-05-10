({
	doInit : function(cmp, event, helper) {
        
		var action = cmp.get("c.validateFitOutLC");
        action.setParams({ 
        	recordId : cmp.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var resString = response.getReturnValue();
            
            if(!(response.getState() == "SUCCESS" && resString == 'Success')) {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resString,
                    "type":"error"
                });
                toastEvent.fire();
            }else{
                cmp.set("v.displayCmp",true);
                cmp.set("v.IsSpinner",false);
            }
        });
        
        $A.enqueueAction(action);
	},
    generatFitOut : function(cmp, event, helper) {
        var action = cmp.get("c.saveLeaseUnit");
        action.setParams({ 
        	recordId : cmp.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var resString = response.getReturnValue();
            
            if(response.getState() == "SUCCESS" && resString.startsWith('Success')) {
            	$A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": resString,
                    "type" : "success"
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
    },
  
})