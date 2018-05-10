({
	doInit : function(component, event, helper) {
		var action = component.get("c.validatePV");
        action.setParams({ recordId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var resString = response.getReturnValue();
            console.log('state--'+state);
            if(response.getState() === "SUCCESS" && resString == 'SUCCESS') {
                component.set("v.displayCmp",true);
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
	checkReason: function(component, event, helper) {
        component.set("v.isShowReason",true);
    },
    saveVoidPV : function(component, event, helper) {
        var reasStr = component.get("v.reason");
        
        if(reasStr){
            var action = component.get("c.voidPVComp");
            action.setParams({recordId : component.get("v.recordId"), "reason": reasStr});
            
            action.setCallback(this,function(response){
                var resString = response.getReturnValue();
                
                if(response.getState() === "SUCCESS" && resString.startsWith('Payment')) {
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
             var inputCmp = component.find("inputReason");
             inputCmp.set("v.errors", [{message:"Please Provide Reason for void."}]);             
        }
        
    },
    
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})