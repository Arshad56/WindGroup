public with sharing class LeasePOSController {
    
    public LeasePOSController(){
        
    }
    
     public static void executePushPOSAPI(String action, List<Lease_POS__c> newLeasePosList, List<Lease_POS__c>oldLeasePosList){
        boolean isTesting = false;
        if(newLeasePosList.get(0).Name.contains('TEST'))
            isTesting = true;
         
        if('insert'.equals(action))
            AWSIntegration_PushPOSInformation.processPush(isTesting,newLeasePosList.get(0).Id);
        else if('update'.equals(action)){
            
            Lease_POS__c newLeasePOS = newLeasePosList.get(0); 
            Lease_POS__c oldLeasePOS = oldLeasePosList.get(0); 

            Map<String, Schema.SObjectField> M = Schema.SObjectType.Lease_POS__c.fields.getMap(); 
            for (String str : M.keyset()) {
                  if(newLeasePOS.get(str) != oldLeasePOS.get(str)){
                      AWSIntegration_PushPOSInformation.processPush(isTesting,newLeasePosList.get(0).Id);   
                      break;
                  }
            }
            
        }   
    }

}