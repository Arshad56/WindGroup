({
    doInit : function(cmp, event, helper) {
        
        var action = cmp.get("c.checkStatus");
        action.setParams({ 
            recordId : cmp.get("v.recordId")
        })
        
        action.setCallback(this, function(response) {
            var resString = response.getReturnValue();
            
            if(response.getState() == "SUCCESS" && resString.startsWith('Success')) {
                var recId = cmp.get("v.recordId");
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/apex/Resurvey?unitId="+recId+"&isLightning=true",
                    "isredirect": "true"
                });
                urlEvent.fire();
            }else{
                cmp.set('v.IsSpinner',false);
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