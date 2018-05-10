({
    doInit : function(cmp, event, helper) {
        
        var setCurrAction = cmp.get("c.getCurrency");
        setCurrAction.setParams({ recordId : cmp.get("v.recordId")});
        setCurrAction.setCallback(this, function(response) {
        var resString = response.getReturnValue();
	        if(response.getState() == "SUCCESS"){
	        	cmp.set("v.isShowReason",false);
	        }
        });
        var setReqAmt = cmp.get("c.getBalance");
        setReqAmt.setParams({recordId:cmp.get("v.recordId")});
        setReqAmt.setCallback(this, function(response) {
        var resBalance = response.getReturnValue();
	        if(response.getState() == "SUCCESS"){
	        	cmp.set("v.requestedAmount",resBalance);
	        	cmp.set("v.invBal",resBalance);
	        }
        });
        
        var action = cmp.get("c.invRefundValidate");
        action.setParams({ recordId : cmp.get("v.recordId") });
        console.log('action-->'+action);
        
        action.setCallback(this, function(response) {
            var resString = response.getReturnValue();
            console.log('resString-->'+resString);
            if(response.getState() == "SUCCESS"){
            	if(resString == "Success") {
	               cmp.set("v.isShowReason",true);
	               cmp.set("v.showInterface",true);
	               
	               console.log('showInterface-->'+cmp.get("v.showInterface"));
	            }else if(resString == 'Warning'){
	            	cmp.set("v.showInterface",true);
	            	cmp.set("v.isShowReason",false);
	            }else{
	            	 $A.get("e.force:closeQuickAction").fire();
	                var toastEvent = $A.get("e.force:showToast");
	                toastEvent.setParams({
	                    "title": "Error!",
	                    "message": resString,
	                    "type" : "error"
	                });
	                toastEvent.fire();
	            }
            }
        });
        console.log('end11-->'+action);
        $A.enqueueAction(setCurrAction);
		$A.enqueueAction(setReqAmt);
        $A.enqueueAction(action);
        console.log('end22-->'+action);
        
        
    },
    checkReason: function(cmp, event, helper) {
        cmp.set("v.isShowReason",true);
    },
    refundInvoice : function(cmp, event, helper) {
        var selectedPO = cmp.get("v.selectedPO");
        var reqAmt = cmp.get("v.requestedAmount");
        var selectCurr = cmp.get("v.selectedCurr");
        var invBal = cmp.get("v.invBal");         
        
        if(!selectCurr){
           // alert('Please select Refund Currency Code.')         
        }else if(reqAmt == 0 || reqAmt == null){
        	var inputCmp = cmp.find("reqAmt");
            inputCmp.set("v.errors", [{message:"Please Enter valid refund amount* (mandatory):"}]);   
        }else if(reqAmt > invBal ){
        	var inputCmp = cmp.find("reqAmt");
            inputCmp.set("v.errors", [{message:"Total Requested amount cannot exceed outstanding amount."}]);  
        }else{          
        	console.log('else-->');
            var action = cmp.get("c.saveInvoiceRefund");
            action.setParams({ 
            	recordId : cmp.get("v.recordId"), 
            	paymentMode : selectedPO,
            	invBalance : reqAmt+'', 
            	refundCurrCode : selectCurr
            });
            
            action.setCallback(this, function(response) {
                var resString = response.getReturnValue();
                console.log('resString-->'+resString);
                if(response.getState() == "SUCCESS" && resString.startsWith("Success")) {
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
        }
    },
    close : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})