({
    doInit : function(cmp, event, helper) {
        
        var action = cmp.get("c.depositVoid");
        action.setParams({ recordId : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var resString = response.getReturnValue();
            
            if(!(response.getState() == "SUCCESS" && resString == "Success")) {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resString,
                    "type" : "error"
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);
    },
    checkReason: function(component, event, helper) {
        component.set("v.isShowReason",true);
    },
    voidDeposit : function(cmp, event, helper) {
        var reasStr = cmp.get("v.reason");
        
        if(reasStr){            
            var action = cmp.get("c.saveVoidDeposit");
            action.setParams({ recordId : cmp.get("v.recordId"), "reason": reasStr});
            
            action.setCallback(this, function(response) {
                var resString = response.getReturnValue();
                
                if(response.getState() == "SUCCESS" && resString.startsWith("Success")) {
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
        }else{
            var inputCmp = cmp.find("inputReason");
            inputCmp.set("v.errors", [{message:"Please Enter Void Reason* (mandatory):"}]);             
        }
    },
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})