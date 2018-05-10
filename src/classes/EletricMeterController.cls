public class EletricMeterController {
    
    public EletricMeterController(){
        
    }
    
     public static void executePushElectricMeterAPI(String action, List<Electric_Meter__c> newElectricMeterList, List<Electric_Meter__c> oldElectricMeterList){
        boolean isTesting = false;
        if(newElectricMeterList.get(0).Name.contains('TEST'))
            isTesting = true;
         
        if('insert'.equals(action))
            AWSIntegration_PushElectricMeter.processPush(isTesting,newElectricMeterList.get(0).Id);
        else if('update'.equals(action)){
            
            Electric_Meter__c newElectricMeter = newElectricMeterList.get(0); 
            Electric_Meter__c oldElectricMeter = oldElectricMeterList.get(0); 

            Map<String, Schema.SObjectField> M = Schema.SObjectType.Electric_Meter__c.fields.getMap(); 
            for (String str : M.keyset()) {
                  if(newElectricMeter.get(str) != oldElectricMeter.get(str)){
                      AWSIntegration_PushElectricMeter.processPush(isTesting,newElectricMeterList.get(0).Id);   
                      break;
                  }
            }
            
        }  
     }
}