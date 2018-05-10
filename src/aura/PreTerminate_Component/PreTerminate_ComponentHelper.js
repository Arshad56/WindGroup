({
	saveCall : function(cmp, bypass) {
    	console.log('termDate-->'+cmp.get("v.termDate"));
    	var termReason = cmp.get("v.reason");
        var action = cmp.get("c.preTerminate");
        action.setParams({ 
        	recordId : cmp.get("v.recordId"),
        	termDate : cmp.get("v.termDate"),
        	isByPass : bypass+'',
        	reason : termReason
        }) 
        action.setCallback(this, function(response) {
            var resString = response.getReturnValue();
            console.log('resString-->'+resString);
            if(response.getState() == "SUCCESS" && resString.startsWith('Success')) {
                cmp.set('v.IsSpinner',false);
            	$A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": resString,
                    "type" : "success"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }else if(resString.startsWith('displayPopup')){
            	cmp.set("v.isByPass",true);
            }else if(resString.startsWith('Date:')){
            	resString = resString.replace("Date:","");
            	alert(resString);
            }else if(resString.startsWith('Reason:')){
            	resString = resString.replace("Reason:","");
            	alert(resString);
            }else{
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resString,
                    "type":"error"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    }
})