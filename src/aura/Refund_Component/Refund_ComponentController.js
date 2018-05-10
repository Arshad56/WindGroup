({
	doInit : function(cmp, event, helper) {
        helper.checkStatusHelper(cmp);
        helper.fetchPickListVal(cmp, 'PV_Currency_Code__c', 'PVCurrencyCode');
        helper.fetchPickListVal(cmp, 'Refund_Mode__c', 'RefundMode');
        helper.fetchDepositHelper(cmp);
    },
    refundDeposit : function(component, event, helper){
        var isError = false;
        var inputCmp = component.find("PVCurrencyCode");
        
        if(!(inputCmp.get("v.value"))){
          inputCmp.set("v.errors", "Last Refund Currency Code is Required");
          isError = true;  
        }
        
        inputCmp = component.find("RefundMode");
        if(!(inputCmp.get("v.value"))){
        	inputCmp.set("v.errors", "Last Refund Mode is Required");
        	isError = true;  
        }
        
        if(isError == false){
    		helper.refundDepositHelper(component);
        }
    },
    close : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})