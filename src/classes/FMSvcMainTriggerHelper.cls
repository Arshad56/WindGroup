public class FMSvcMainTriggerHelper {
    
    public static void validateServiceContractNumber (List<FM_Service_Contract__c> triggerList, List<FM_Service_Contract__c> oldtriggerList){
        
        Map<Id,String> serviceContractNameMap = new Map<Id,String>();
        
        for(FM_Service_Contract__c sv: oldtriggerList){
            serviceContractNameMap.put(sv.Id, sv.Name);
        }
             
        for(FM_Service_Contract__c sv: triggerList){ 
            
            if(sv.Name!=serviceContractNameMap.get(sv.Id)){
                sv.addError('Service Contract Number is not allow to change.');
            }
        }
    }
    
    public static void setSeviceContractNumber(List<FM_Service_Contract__c> triggerList){
        Set<Id> propertyId = new Set<Id>();
        for(FM_Service_Contract__c sv:triggerList){
            propertyId.add(sv.Property__c);
        }
        
        Map<Id,Property__c> propMap = new Map<Id,Property__c>([Select id, Service_Contract_Index__c, Short_Code__c from Property__c where id in:propertyId]);
        
        string curYear = ''+system.today().Year();
        string curMonth = (system.today().month()<10?'0'+system.today().month():''+system.today().month());
       
        Map<Id,integer> propToIndexMap = new Map<Id,Integer>();
        for(FM_Service_Contract__c sv:triggerList){
                Property__c prop = new Property__c();
            	prop.Id = sv.Property__c;
                if(propToIndexMap.containsKey(prop.Id)){
                    prop.Service_Contract_Index__c = propToIndexMap.get(prop.Id);
                }else{
                    if(propMap.get(prop.Id).Service_Contract_Index__c == null)
                        prop.Service_Contract_Index__c = 1;
                    else
                        prop.Service_Contract_Index__c = propMap.get(prop.Id).Service_Contract_Index__c;                  
                }
                prop.Short_Code__c = propMap.get(prop.Id).Short_Code__c;
                Integer IntIndex = 1;
                if(prop.Service_Contract_Index__c!=null && prop.Service_Contract_Index__c>0){
                    intIndex = Integer.valueOf(prop.Service_Contract_Index__c);
                }
                
                Integer indexSize = string.valueOf(intIndex).length();
                
                string index = '';
                for(integer i =1;i<=6-indexSize;i++){
                    index += '0';
                }
                index += string.valueOf(intIndex);
                prop.Service_Contract_Index__c = intIndex + 1;
                propToIndexMap.put(prop.Id,intIndex + 1); 
                sv.Name = prop.Short_Code__c + '-SC-'+curYear+curMonth+'-'+index;
        }
        
        List<property__c> propList = new List<Property__c>();
        for(Property__c prop : propMap.values()){
            prop.Service_Contract_Index__c = propToIndexMap.get(prop.Id);
            propList.add(prop);
        }
        
        update propList;

    }

}