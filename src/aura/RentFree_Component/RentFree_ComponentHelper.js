({
	getLeaseRecord :function(component){
        var action = component.get("c.getLease");
        action.setParams({ 
        	recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var resString = response.getReturnValue();
           
            if(response.getState() == "SUCCESS") {
                 component.set("v.lease", resString);
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
    saveLeasRecordHelper :function(component){
        var action = component.get("c.saveLeaseRecord");
        action.setParams({ 
        	l : component.get("v.lease")
        });
        
        action.setCallback(this, function(response){
            var resString = response.getReturnValue();
            
            if(response.getState() == "SUCCESS" && resString.startsWith('Success')) {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Info!",
                    "message": resString,
                    "type":"success"
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
	}
})