({
    doInit : function(cmp, event, helper) {
        
        var action = cmp.get("c.checkDepositVoided");
        action.setParams({ recordId : cmp.get("v.recordId") });
        
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
            }
        });
        
        $A.enqueueAction(action);
    },
    unvoidDeposit : function(cmp, event, helper) {
        var action = cmp.get("c.saveUnvoidDeposit");
        action.setParams({ recordId : cmp.get("v.recordId") });
       
        action.setCallback(this, function(response) {
            var resString = response.getReturnValue();
            if(response.getState() == "SUCCESS" && resString.startsWith('Success')) {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": resString,
                    "type" : "success"
                });
                toastEvent.fire();
                $A.get("e.force:refreshView").fire();	
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
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})