public class Lightning_Utility {
    @AuraEnabled        
	public static List<String> getPickListValuesIntoList(String objectType, String selectedField){
        system.debug('>>objectType>>'+objectType);
        List<String> pickListValuesList = new List<String>();
		if(selectedField == 'RecordType'){
	        for(RecordType rt : [SELECT Id,Name,IsActive FROM RecordType WHERE SobjectType=:objectType and IsActive = true]){
	            pickListValuesList.add(rt.Name);
	        }        
	        return pickListValuesList;
		}else{
		    Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
		    Schema.DescribeSObjectResult res = convertToObj.getDescribe();
		    Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
		    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		    for( Schema.PicklistEntry pickListVal : ple){
		        pickListValuesList.add(pickListVal.getLabel());
		    }     
		    return pickListValuesList;
		}
	}
}