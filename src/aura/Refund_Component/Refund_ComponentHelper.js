({
    checkStatusHelper: function(cmp) {
   		var action = cmp.get("c.checkStatus");
        action.setParams({ recordId : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var resString = response.getReturnValue();
            
            
            if(response.getState() === "SUCCESS" && resString.startsWith('Note')) {
               cmp.set("v.displayMessage",true);
            }else if(resString.startsWith('Error')){
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
    refundDepositHelper: function(cmp) {
   		var action = cmp.get("c.refund");
        action.setParams({ deposit : cmp.get("v.objInfo") });
        
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
                cmp.set("v.displayErrorMsg",resString);
            }
        });
        
        $A.enqueueAction(action);
    },    
    fetchDepositHelper: function(cmp) {
   		var action = cmp.get("c.fetchDeposit");
        action.setParams({ recordId : cmp.get("v.recordId") });
		        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var resString = response.getReturnValue();
            
            if(response.getState() === "SUCCESS" ) {                
               cmp.set("v.objInfo",response.getReturnValue());
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
    fetchPickListVal: function(component, fieldName, elementId) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.find(elementId).set("v.options", opts);
                
            }
        });
        $A.enqueueAction(action);
    }
})