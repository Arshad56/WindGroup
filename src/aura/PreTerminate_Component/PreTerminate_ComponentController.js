({
	doInit : function(cmp, event, helper) {
        var action = cmp.get("c.checkTermination");
        action.setParams({ 
        	recordId : cmp.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            var resString = response.getReturnValue();
            if(response.getState() == "SUCCESS" && resString.startsWith('SUCCESS')) {
                var allData = resString.split('|');
            	console.log('allData-->'+allData);
            	console.log('allData size-->'+allData.length);
            	
			    cmp.set("v.termDate",allData[1]);
            	cmp.set("v.label",allData[2]);
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
        
	}, 
    proceedTerm : function(cmp, event, helper) {
    	console.log('termDate-->'+cmp.get("v.termDate"));
    	helper.saveCall(cmp, false);
    },
    byPass : function(cmp, event, helper) {
    	helper.saveCall(cmp, true);
    },
    close : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})