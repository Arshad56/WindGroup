({
	doInit : function(component, event, helper) {
		var action = component.get("c.validatePV");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resString = response.getReturnValue();
            console.log('state--'+state);
            if(response.getState() === "SUCCESS" && resString.startsWith('SUCCESS')) {
            	console.log('resString-->'+resString);
            	var allData = resString.split('|');
            	console.log('allData-->'+allData);
            	console.log('allData size-->'+allData.length);

            	component.set("v.pvStatus",allData[1]);
            	component.set("v.leaseId",allData[2]);
            	component.set("v.pvBalance",allData[3]);
            	component.set("v.pvCurrency",allData[4]);
            	component.set("v.tenantId",allData[5]);
            	
                component.set("v.displayCmp",true);
            }else{
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
	checkReason: function(component, event, helper) {
        component.set("v.isShowReason",true);
    },
    savePVrefund : function(component, event, helper) {
        var paymentMode = component.get("v.paymentMode");
        
        if(paymentMode){
            var action = component.get("c.savePV");
            action.setParams({recordId : component.get("v.recordId"), "paymentMode": paymentMode});
            
            action.setCallback(this,function(response){
                var resString = response.getReturnValue();
                
                if(response.getState() === "SUCCESS" && resString.startsWith('Payment')) {
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
                
                $A.get("e.force:refreshView").fire();
            });
            $A.enqueueAction(action);
        }else{
             var inputCmp = component.find("popt");
             inputCmp.set("v.errors", [{message:"Please Provide Payment Mode."}]);             
        }
        
    },
    
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})