public with sharing class MainEquipment_Helper {
     public static void generateEQName(Set<Id> propIds, List<Equipment__c> equipments){
    	Map<Id, Property__c> listprops= new Map<Id, Property__c>([select Id,Short_Code__c,Equipment_Index__c from Property__c where id =:propIds]);
    	Map<Id, Property__c> listProperties = new Map<Id, Property__c>();
    	String code;
    	for(Equipment__c eq: equipments){
    		if(listprops.containsKey(eq.Property__c)){ 
    			code  = listprops.get(eq.Property__c).Short_Code__c;
    			code += '-EQ-';
    			Integer temp;
    			if(listProperties.containsKey(listprops.get(eq.Property__c).Id)){
    				temp = Integer.valueOf(listProperties.get(listprops.get(eq.Property__c).Id).Equipment_Index__c);
    			}else{
    				temp =  Integer.valueof(listprops.get(eq.Property__c).Equipment_Index__c);
    			}
    			String tempNo;
    			if(temp == 0 || temp == null){
    				temp   = 1;
    				tempNo = ''+temp;
    			}else{
    				tempNo = ''+temp;
    			}
    			for(integer i =1;i<=8-tempNo.length();i++){
                    code += '0';
                }
    			code += tempNo;
    			eq.Equipment_ID__c = code;
    			if(eq.Property__c != null){
    				Property__c pr = new Property__c();
	    			pr.Id = eq.Property__c;
	    			if(listProperties.containsKey(pr.Id)){
	    				listProperties.get(pr.Id).Equipment_Index__c += 1;
	    			}else{
	    				temp += 1;
	    				pr.Equipment_Index__c = temp;
	    				listProperties.put(pr.Id, pr);
	    			}
	    			
    			}
    		}
    	}
    	try{
    		update listProperties.values();
    	}catch(Exception e){
    		System.debug('Exception occured -- > '+e);
    	}
    }
}