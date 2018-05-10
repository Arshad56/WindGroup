({
    loadLeaseUnitList: function(component, event, helper) {
        // call the helper function for fetch contact from apex class 
        helper.onLoad(component, event);
    },
    checkboxSelect: function(component, event, helper) {
        // get the selected checkbox value  
        var selectedRec = event.getSource().get("v.value");
        // get the selectedCount attrbute value(default is 0) for add/less numbers. 
        var getSelectedNumber = component.get("v.selectedCount");
        // check, if selected checkbox value is true then increment getSelectedNumber with 1 
        // else Decrement the getSelectedNumber with 1     
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        // set the actual value on selectedCount attribute to show on header part. 
        component.set("v.selectedCount", getSelectedNumber);
    },
    
    
    // For select all Checkboxes 
    selectAll: function(component, event, helper) {
        //get the header checkbox value  
        var selectedHeaderCheck = event.getSource().get("v.value");
        // get all checkbox on table with "boxPack" aura id (all iterate value have same Id)
        // return the List of all checkboxs element 
        var getAllId = component.find("boxPack");
        // If the local ID is unique[in single record case], find() returns the component. not array   
        var luList = component.get("v.ListOfLeaseUnit");
        var  i = 0;
        for( i = 0; i <  luList.length; i++){
        	luList[i].Pre_Termination__c = selectedHeaderCheck;
        	console.log(luList[i].Id+ ' check-->'+luList[i].Pre_Termination__c);
        }   
        component.set("v.ListOfLeaseUnit",luList);     
    },
    
    //For process selected records 
    processSelected: function(component, event, helper) {
        // create var for store record id's for selected checkboxes  
        var processId = [];
        // get all checkboxes 
        //var getAllId = component.find("boxPack");
       
        var luList = component.get("v.ListOfLeaseUnit");
        var  i = 0;
        for( i = 0; i <  luList.length; i++){
        	console.log(luList[i].Id+ ' check-->'+luList[i].Pre_Termination__c);
        	if(luList[i].Pre_Termination__c){
        		processId.push(luList[i].Id);
        	}
        }
        if(processId.length > 0){
            var recId = component.get("v.recordId");
            
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/apex/BulkDepositInterface?selectedLeaseUnits="+processId+"&isLightning=true&leaseId="+recId,
                "isredirect": "true"
            });
            urlEvent.fire();
        }else{
            alert('Please select at least one Lease Unit to create Deposit!');
        }
        // If the local ID is unique[in single record case], find() returns the component. not array
        /*if(! Array.isArray(getAllId)){
            if (getAllId.get("v.value") == true) {
                processId.push(getAllId.get("v.text"));
            }
        }else{
            // play a for loop and check every checkbox values 
            // if value is checked(true) then add those Id (store in Text attribute on checkbox) in processId var.
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    processId.push(getAllId[i].get("v.text"));
                }
            }
            
            if(processId.length > 0){
                var recId = component.get("v.recordId");
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/apex/BulkDepositInterface?selectedLeaseUnits="+processId+"&isLightning=true&leaseId="+recId,
                    "isredirect": "true"
                });
                urlEvent.fire();
            }else{
                alert('Please select at least one Lease Unit to create Deposit!');
            }
        } */
    },
    close : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();	
    }
})