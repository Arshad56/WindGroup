({
	doInit : function(cmp, event, helper) {
       
        var action = cmp.get("c.checkStatus");
        action.setParams({ recordId : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var resString = response.getReturnValue();
            
            if(response.getState() === "SUCCESS" && resString.startsWith('Success')) {
                var recId = cmp.get("v.recordId");
              // 	cmp.set("v.ifmsrc", "/apex/LoiLaConversion_Button?loiId="+recId+"&isLightning=true");  
               // cmp.set("v.IsSpinner",false); 
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/apex/LoiLaConversion_Button?loiId="+recId+"&isLightning=true",
                  "isredirect": "true"
                });
                urlEvent.fire(); 
               
            }else{
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
	}
})