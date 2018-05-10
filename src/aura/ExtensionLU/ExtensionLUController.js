({
	doInit : function(component, event, helper) {
        var action = component.get("c.checkTermination");
        action.setParams({ 
        	recordId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            var resString = response.getReturnValue();
            if(response.getState() == "SUCCESS" && resString.startsWith('Success')) {
                var today = new Date();
                component.set('v.extDate', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
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
    proceedLU : function(cmp, event, helper) {
        cmp.set('v.IsSpinner',true);
        
        var action = cmp.get("c.checkDate");
        action.setParams({ 
        	recordId : cmp.get("v.recordId"),
        	extendedDate : cmp.get("v.extDate")
        })
        
        action.setCallback(this, function(response) {
            var resString = response.getReturnValue();
            
            if(response.getState() == "SUCCESS" && resString.startsWith('Success')) {
                cmp.set('v.IsSpinner',false);
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
              /*  cmp.set('v.IsSpinner',false);
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resString,
                    "type":"error"
                });
                toastEvent.fire();
                */
                cmp.set("v.displayErrorMsg",resString);
                cmp.set('v.IsSpinner',false);
            }
        });
        
        
        $A.enqueueAction(action);
    },
    close : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})