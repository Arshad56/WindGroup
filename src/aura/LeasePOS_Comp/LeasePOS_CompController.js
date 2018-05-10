({
    createLeaseRecord : function (component, event, helper) {
        var editRecordEvent = $A.get("e.force:editRecord");
        
        editRecordEvent.setParams({
            "recordId": "a1O5D0000009TTU",
        });
        editRecordEvent.fire();
    }
})