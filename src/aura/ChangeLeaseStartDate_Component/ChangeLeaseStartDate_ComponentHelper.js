({
    getTenureDays :function(component){
        var action = component.get("c.getLeaseTenureMonths");
        
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
    saveLeasRecord :function(component){
        var action = component.get("c.saveLeaseRec");
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
                    "type":"info"
                });
                toastEvent.fire();
            }else{
                if(resString.includes("FIELD_CUSTOM_VALIDATION_EXCEPTION")){
                    var ss = resString.split("FIELD_CUSTOM_VALIDATION_EXCEPTION,"); 
                    component.set("v.msgStr", ss[1]);
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
            }
        });
        
        $A.enqueueAction(action);
    }
})