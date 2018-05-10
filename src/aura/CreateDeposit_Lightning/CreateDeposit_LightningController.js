({
    doInit : function(cmp, event, helper) {        
        var recId = cmp.get("v.recordId");
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/BulkDepositInterface?from=LeaseUnit&selectedLeaseUnits="+recId+"&isLightning=true",
            "isredirect": "true"
        });
        urlEvent.fire();
    }
})