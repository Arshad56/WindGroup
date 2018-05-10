({
    createLeaseRecord : function (component, event, helper) {
      // alert(component.get("v.recordId"));
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Lease_POS__c",
             "defaultFieldValues": {
                'Name' : '--system generated--',
                'Lease_Unit__c' : component.get("v.recordId")
            }
        });
        createRecordEvent.fire();
    }
})