({
	doInit : function(component, event, helper) {
		var action = component.get("c.validatePaidPV");
        action.setParams({ recordId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var resString = response.getReturnValue();
            console.log('state--'+state);
            if(response.getState() === "SUCCESS" && resString == 'SUCCESS Cheque') {
                component.set("v.displayCmp",true);
            }else if(resString == 'SUCCESS Cash'){
            	$A.get('e.force:refreshView').fire(); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Vocher Paid Successfully",
                    "type":"success"
                });
                toastEvent.fire();
                 
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();   
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
        console.log('action--');
        $A.enqueueAction(action);
	},
    savePV : function(component, event, helper) {
        var chqNO = component.get("v.chqNO");
        
        if(chqNO){
            var action = component.get("c.savePaidPV");
            action.setParams({recordId : component.get("v.recordId"), "chqNO": chqNO});
            
            action.setCallback(this,function(response){
                var resString = response.getReturnValue();
                
                if(response.getState() === "SUCCESS" && resString.startsWith('Vocher')) {
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
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": resString,
                        "type":"error"
                    });
                    toastEvent.fire();                
                }
                
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire(); 
                
                $A.get("e.force:refreshView").fire();
            });
            $A.enqueueAction(action);
        }else{
             var inputCmp = component.find("chqNo");
             inputCmp.set("v.errors", [{message:"Please Enter Cheque No."}]);             
        }
        
    },
    
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})