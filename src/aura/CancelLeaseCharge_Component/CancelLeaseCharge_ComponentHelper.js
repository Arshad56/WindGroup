({
	checkLeaseChargeActiveHelper :function(component){
      var action = component.get("c.checkLeaseStatus");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var retValue = response.getReturnValue();
            if(retValue.startsWith('Error')){
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": retValue,
                    "type":"error"
                });
                toastEvent.fire();
            }else if(retValue.startsWith('DisplayPopup')){
                component.set("v.displayMessage", true);
            }
        });
        $A.enqueueAction(action);
    },
    cancelLeaseChargeHelper : function(cmp) {
        if(cmp.get("v.reasonToCancel")){
			var action = cmp.get("c.cancelLeaseChargeRec");
            action.setParams({ 
                recordId : cmp.get("v.recordId"),
                reasonForCancel : cmp.get("v.reasonToCancel")
            });
            
            action.setCallback(this, function(response) {
                var resString = response.getReturnValue();
                
                if(response.getState() == "SUCCESS" && resString.startsWith('Success')) {
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Lease charge cancelled",
                        "type" : "success"
                    });
                    toastEvent.fire();
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
            inputCmp.set("v.errors", [{message:"Reason for Cancel is required."}]);
        }
    },
})