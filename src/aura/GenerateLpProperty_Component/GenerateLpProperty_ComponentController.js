({
	doInit : function(component, event, helper) {
      /*  alert(cmp.get("v.recordId"));
	    $A.get("e.force:closeQuickAction").fire();
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/CreateLPFromProperty?Id="+component.get("v.recordId")
        });
        urlEvent.fire();*/
        
        var action = component.get("c.getYearOptions");
        action.setParams({ 
        	recordId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            var resString = response.getReturnValue();
            if(response.getState() == "SUCCESS") {
                 component.set("v.options", resString);
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
    proceedProperty : function(cmp, event, helper) {
        var action = cmp.get("c.updateProperty");
        action.setParams({ 
        	recordId : cmp.get("v.recordId"),
        	selYear : cmp.get("v.selectedYear")
        })
        
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
    }
})