({
    doInit : function(cmp, event, helper) {
        
        var action = cmp.get("c.checkStatus");
        action.setParams({ recordId : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var resString = response.getReturnValue();
            
            if(response.getState() === "SUCCESS" && resString.startsWith('Info')) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resString,
                    "type":"error"
                });
                toastEvent.fire();               
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire(); 
            }else{
                //var recId = cmp.get("v.recordId");
                //cmp.set("v.ifmsrc", "/apex/LoiLaConversion_Button?loiId="+recId);  
                //cmp.set("v.IsSpinner",false); 
               
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/servlet/servlet.FileDownload?file="+resString
                });
                urlEvent.fire();
                
                /*
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resString,
                    "type":"error"
                });
                toastEvent.fire();
                */
            }
        });
        
        $A.enqueueAction(action);
    }
})