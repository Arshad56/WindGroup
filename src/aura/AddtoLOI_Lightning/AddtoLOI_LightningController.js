({
	doInit : function(cmp, event, helper) {
        
        var action = cmp.get("c.checkExpressionIntUnit");
        action.setParams({ recordId : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var resString = response.getReturnValue();
            
            if(response.getState() === "SUCCESS" && resString.startsWith('Error')) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resString,
                    "type":"error"
                });
                toastEvent.fire();               
                $A.get("e.force:closeQuickAction").fire(); 
            }else{
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                   "url": "/apex/generateLOIDescription?opr=AddNewLOI&"+resString 
                });
                urlEvent.fire(); 
            }
        });
        
        $A.enqueueAction(action);
    }
})