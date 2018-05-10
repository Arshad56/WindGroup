({
    doInit : function(cmp, event, helper) {
        
        var action = cmp.get("c.checkStatus");
        action.setParams({ recordId : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var resString = response.getReturnValue();
            
            if(!(response.getState() === "SUCCESS" && resString == 'Success')) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resString,
                    "type":"error"
                });
                toastEvent.fire();
                
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();  
            }
        });
        
        $A.enqueueAction(action);
    },
    closeRequest : function(component, event, helper) {
        
        var action = component.get("c.saveCloseRequest");
        action.setParams({recordId : component.get("v.recordId")});
        
        action.setCallback(this,function(response){
            var resString = response.getReturnValue();
            
            if(response.getState() === "SUCCESS" && resString.startsWith('Success')) {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": resString,
                    "type" : "success"
                });
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resString,
                    "type":"error"
                });
                toastEvent.fire();               
            }
            
            $A.get("e.force:closeQuickAction").fire(); 
            $A.get("e.force:refreshView").fire();
        });
        $A.enqueueAction(action);
    },
    
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})