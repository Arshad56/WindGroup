@RestResource(urlMapping='/CheckList/*')
global class CheckListRestAPI {
    /*HttpPost method is used to capture a HttpPost request has been sent to our rest apex class.  
    Used to retrieve data coming in the request body and performing corressponding actions*/  
   
   /*
    @HttpPost  
    global static void doPost() {  
     
     //Returns the RestRequest object for our Apex REST method.  
     RestRequest request = RestContext.request;  
     
     //Returns the RestResponse for our Apex REST method.  
     RestResponse response = RestContext.response;  
     
     //Access the request body with input data coming in the JSON format.  
     String jSONRequestBody = request.requestBody.toString().trim();  
     System.debug('>>>jSONRequestBody'+jSONRequestBody);
        
     //Deserializes the input JSON string into an CheckList,CheckList Item and CheckList Remark object.  
     CheckListData chekListObj = (CheckListData)JSON.deserializeStrict(jSONRequestBody,CheckListData.class);  
     System.debug('>>>chekListObj'+chekListObj);
      
     if(chekListObj != null){
        List<Checklist_Item__c> checkListItemToUpsert = new List<Checklist_Item__c>();
        List<Checklist_Remarks__c> checkListRemarksToInsert = new List<Checklist_Remarks__c>();
     
     
        for(CheckListData.CheckListItemWrapper chkDataItemWrap : chekListObj.checkListItemList){
            
            Checklist_Item__c chkItem = (chkDataItemWrap.checkListItemId == null || chkDataItemWrap.checkListItemId.trim().length() == 0)? 
            new Checklist_Item__c(Name = chkDataItemWrap.name,  Checklist__c = chkDataItemWrap.checkListId,
            Action_Date_Time__c = chkDataItemWrap.actionDateTime, Condition__c = chkDataItemWrap.condition,
            Description__c = chkDataItemWrap.description, Number__c = chkDataItemWrap.num,
            SN__c = chkDataItemWrap.serialNumber, Status__c = chkDataItemWrap.status):
            
            new Checklist_Item__c(Id = chkDataItemWrap.checkListItemId, Name = chkDataItemWrap.name, Checklist__c = chkDataItemWrap.checkListId,
            Action_Date_Time__c = chkDataItemWrap.actionDateTime, Condition__c = chkDataItemWrap.condition,
            Description__c = chkDataItemWrap.description, Number__c = chkDataItemWrap.num,
            SN__c = chkDataItemWrap.serialNumber, Status__c = chkDataItemWrap.status);
            
            checkListItemToUpsert.add(chkItem);
        }  
         
        //upsert CheckList Items ;
        try{ 
            upsert checkListItemToUpsert;
        }
        catch(DMLException e){
            System.debug('Exception--->'+ e.getMessage() + 'At Line Number: '+ e.getLineNumber());
        }
            
        for(CheckListData.CheckListItemWrapper chkDataItemWrap : chekListObj.checkListItemList){
            for(CheckListData.CheckListRemarkWrapper chkDataItemRemarkWrap : chkDataItemWrap.checkListRemarkList){
                checkListRemarksToInsert.add(new Checklist_Remarks__c(Checklist_Item__c = chkDataItemRemarkWrap.checkListItemId, Remarks__c = chkDataItemRemarkWrap.remark));
            }
        } 
     
        //insert CheckList Remarks ;
        try{ 
            insert checkListRemarksToInsert;
        }
        catch(DMLException e){
            System.debug('Exception--->'+ e.getMessage() + 'At Line Number: '+ e.getLineNumber());
        }
     } 
  }*/  
}