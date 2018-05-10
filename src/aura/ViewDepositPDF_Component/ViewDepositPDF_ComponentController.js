({
	doInit : function(component, event, helper) {
        var action = component.get("c.checkStatus");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state==='SUCCESS' && resp.startsWith('Info')){
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resp,
                    "type":"error"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            else{
                var attchUrlEvent = $A.get("e.force:navigateToURL");
                attchUrlEvent.setParams({
                    "url" :"/servlet/servlet.FileDownload?file="+resp
                });
                attchUrlEvent.fire();
            }
        });
		$A.enqueueAction(action);
	}
})