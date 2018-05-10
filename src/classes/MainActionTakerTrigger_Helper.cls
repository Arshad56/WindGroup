public with sharing class MainActionTakerTrigger_Helper {
    public static void checkDuplicate(List<Action_Taker__c> newList){
    	//List<Action_Taker__c> actNewMap= [select Id,Property__c,Department__c,Action_Taker__c,Job_Request__c from Action_Taker__c where id=:newMap.KeySet()];
    	Map<Id,Action_Taker__c> actOldMap= new Map<Id,Action_Taker__c>([select Id,Name,Property__c,Job_Type__c,Department__c,Job_Request__c,Admin_Team__c from Action_Taker__c where Status__c =: 'Active']);
    	//Map<Id,Action_Taker__c> actOldMap= new Map<Id,Action_Taker__c>([select Id,Name,Property__c,Job_Type__c,Department__c,Job_Request__c from Action_Taker__c ]);
    	
    	System.debug('newList-->'+newList);     
        System.debug('actOldMap-->'+actOldMap);
        Boolean duplicateFound;
    	for(Action_Taker__c nn: newList){
    		List<String> tempString = new List<String>();
			tempString.add(nn.Job_Type__c);
			System.debug('nn.Id-->'+nn.Id);
			System.debug('nn.Job_Type__c-->'+nn.Job_Type__c);
			//System.debug(nn.Job_Type__c.contains(';')+'nn.Job_Type__c-->'+nn.Job_Type__c);
			if(nn.Job_Type__c!= null){
				if(nn.Job_Type__c.contains(';')){
					tempString = new List<String>();
					tempString = nn.Job_Type__c.split(';');
				}
			}
    		for(Id oo: actOldMap.KeySet()){ 
    			if(nn.Job_Request__c == actOldMap.get(oo).Job_Request__c && oo != nn.id){
    				System.debug('tempString-->'+tempString);
    				duplicateFound = false;
    				for(String ss:tempString){
    					System.debug('oo-->'+oo);
    					System.debug('actOldMap.get(oo).Job_Type__c-->'+actOldMap.get(oo).Job_Type__c);
    					if(actOldMap.get(oo).Job_Type__c != null && actOldMap.get(oo).Job_Type__c != '' && ss != null){
    						if(actOldMap.get(oo).Job_Type__c.contains(ss)){
	    						duplicateFound = true;
	    					}
    					}
    				}
    				if(nn.Job_Type__c == null && actOldMap.get(oo).Job_Type__c == null){
    					duplicateFound = true;
    				}
    				if(nn.Status__c == 'Active'&&  nn.Property__c == actOldMap.get(oo).Property__c && nn.Department__c == actOldMap.get(oo).Department__c && duplicateFound && !actOldMap.get(oo).Admin_Team__c){
    					nn.addError('Duplicate Active Record Found with Same Property and Department: <a href=\''+Label.InstanceURL+oo+'\'>'+actOldMap.get(oo).Name+'</a>',false);
    				}
    			}
    			if(actOldMap.get(oo).Admin_Team__c && nn.Admin_Team__c && nn.Status__c == 'Active' && oo != nn.id){
	    			nn.addError('Duplicate Active \'Admin Team\' Found : <a href=\''+Label.InstanceURL+oo+'\'>'+actOldMap.get(oo).Name+'</a>',false);
	    		}
    		}
    		
    	}
        Integer i = 0;
         i = 1;
         i = 1;
         i = 1;
         i = 1;
    }
}