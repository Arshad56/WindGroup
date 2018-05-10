({
    onLoad: function(component, event) {
        console.log('onLoad call');
        //call apex class method
        var action = component.get('c.fetchLeaseUnit');
        action.setParams({ 
            recordId : component.get("v.recordId")
        })
        
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in ListOfLeaseUnit attribute on component.
                component.set('v.ListOfLeaseUnit', response.getReturnValue());
                // set deafult count and select all checkbox value to false on load 
                component.set("v.selectedCount", 0);
                //component.find("box3").set("v.value", false);
            }
        });
        $A.enqueueAction(action);
    },
    
})