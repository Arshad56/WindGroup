({
	editRecord : function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:editRecord");
        
        editRecordEvent.setParams({
            "recordId": component.get("v.lu.Id")
        });
        editRecordEvent.fire();
    },
    deleteRecord: function(component, event, helper) {
        var action = component.get("c.deleteLU");
	    action.setParams({
	        "id": component.get("v.lu.Id")
	    });
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        if (state === "SUCCESS") {
	            // Remove only the deleted expense from view
	            // Other client-side logic
	            $A.get('e.force:refreshView').fire();
	        }
	    });
	    $A.enqueueAction(action);
    },
    redirectLU : function(component, event, helper) {
			window.open('/' + component.get('v.lu.Id'));  
	},
	
    redirectUnit : function(component, event, helper) {
			window.open('/' + component.get('v.lu.Unit__c'));  
		
	}
})