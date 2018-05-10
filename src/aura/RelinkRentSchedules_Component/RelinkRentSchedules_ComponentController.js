({
	 doInit : function(cmp, event, helper) {
        var today = new Date();
        var setReqAmt = cmp.get("c.initRelink");
        setReqAmt.setParams({recordId:cmp.get("v.recordId")});
        setReqAmt.setCallback(this, function(response) {
        	var eleMeter = response.getReturnValue();
	        if(response.getState() == "SUCCESS"){
	        	cmp.set("v.meterNo",eleMeter.Meter_No__c);
	        	cmp.set("v.oldMeterNo",eleMeter.Meter_No__c);
	        	cmp.set("v.status",eleMeter.Status__c);
    	        cmp.set('v.startDate', eleMeter.Start_Date__c );
	        } 
        });
          
		$A.enqueueAction(setReqAmt);
    },
    relinkSave: function(cmp, event, helper) {
    console.log('relink-->');
    	var meterNo = cmp.get("v.meterNo");
        var status = cmp.get("v.status");
        var startDate = cmp.get("v.startDate");
        var endDate = cmp.get("v.endDate");         
        console.log('startDate-->'+startDate);
        console.log('endDate-->'+endDate);
        if(startDate == null){
            var inputCmp = cmp.find("startDate");
            inputCmp.set("v.errors", [{message:"Please input Start Date."}]);           
            console.log('startDate-->'); 
        }else if(endDate == null){   
             var inputCmp = cmp.find("endDate");
            inputCmp.set("v.errors", [{message:"Please input End Date."}]);            
            console.log('endDate-->');   
        }else if(!meterNo){
        	var inputCmp = cmp.find("meterNo");
            inputCmp.set("v.errors", [{message:"Please enter meter no* (mandatory):"}]);           
            console.log('meterNo-->');
        }else{          
        	console.log('else-->');
            var action = cmp.get("c.relinkRSSave");
            action.setParams({ 
            	recordId : cmp.get("v.recordId"), 
            	newMeterNo : meterNo,
            	status : status, 
            	startDate : startDate+'',
            	endDate : endDate+'',
            	oldMeterNo : cmp.get("v.oldMeterNo")
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