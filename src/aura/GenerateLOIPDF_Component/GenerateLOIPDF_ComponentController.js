({
    /*
	doInit : function(cmp, event, helper) {
		
        var action = cmp.get("c.generatePdf");
        action.setParams({ recordId : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
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
                $A.get("e.force:refreshView").fire();	
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
        });
        
        $A.enqueueAction(action);
	}*/
    
    doInit : function(cmp, event, helper) {
        
		var action = cmp.get("c.checkAlreadyGeneratePdfForLOI");
        action.setParams({recordId : cmp.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var resString = response.getReturnValue();
            
            if(!(response.getState() == "SUCCESS" && resString == 'Success')) {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resString,
                    "type":"error"
                });
                toastEvent.fire();
            }else{
                cmp.set("v.displayCmp",true);
            }
        });
        
        $A.enqueueAction(action);
	},
    generatPDF : function(cmp, event, helper) {
        alert('Rajesh');
        var action = cmp.get("c.generatePdf");
        action.setParams({ 
        	recordId : cmp.get("v.recordId"),
        	objLabel : cmp.get("v.objLabel"),
        	objName : cmp.get("v.objName"),
        	fieldName : cmp.get("v.fieldName")
        });
        
        action.setCallback(this, function(response) {
            var resString = response.getReturnValue();
            
            if(response.getState() == "SUCCESS" && resString.startsWith('Success')) {
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
    close : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})