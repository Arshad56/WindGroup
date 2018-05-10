({
    doInit : function(component, event, helper) {
        component.set("v.IsSpinner",true);
        helper.checkLeaseChargeActiveHelper(component);       
        component.set("v.IsSpinner",false);
    },
    processYes : function(cmp, event, helper) {
        cmp.set("v.displayMessage",false);
    },
    cancelLeaseCharge : function(cmp, event, helper) {
        cmp.set("v.IsSpinner",true);
        helper.cancelLeaseChargeHelper(cmp);
        cmp.set("v.IsSpinner",false);
        cmp.set("v.displayMessage",false);
    },
    close : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})