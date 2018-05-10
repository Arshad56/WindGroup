public with sharing class RequestTaskHistoryTracking_Helper {
    public static void generateTSKName(Set<Id> reqIds, List<Task> tskList){
    	Map<Id, Request__c> listRequest= new Map<Id, Request__c>([select Id,Name,Person_In_Charge__r.Email,Property__c,Property__r.Short_Code__c, Property__r.Task_Index__c from Request__c where id =:reqIds]);
    	Map<Id, Property__c> mapRequest = new Map<Id, Property__c>();
    	Map<Id, Integer> mapCount = new Map<Id, Integer>();
    	String code;
    	Integer countLabel = Integer.valueof(Count_Index__c.getValues('Task_ST_Index').Count__c);
    	Count_Index__c lst= Count_Index__c.getValues('Task_ST_Index');
    	for(Task tsk: tskList){
    		if(tsk.WhatId != null && listRequest.containsKey(tsk.WhatId) && tsk.Property__c!=null){
    			code  =  listRequest.get(tsk.WhatId).Property__r.Short_Code__c; 
    			code += '-WT-';
    			code += System.today().Year();
    			if(System.today().Month() < 10){
    				code += '0';
    			}
    			code += System.today().Month();
    			code += '-';
    			Integer temp;
    			if(mapRequest.containsKey(listRequest.get(tsk.WhatId).Id)){
    				temp = Integer.valueOf(mapRequest.get(listRequest.get(tsk.WhatId).Property__c).Task_Index__c);
    			}else{
    				temp =  Integer.valueof(listRequest.get(tsk.WhatId).Property__r.Task_Index__c);
    			}
    			String tempNo;
    			if(temp == 0 || temp == null){
    				temp   = 1;
    			}
				tempNo = ''+temp;
    			for(integer i =1;i<=6-tempNo.length();i++){
                    code += '0';
                }
    			code += tempNo; 
    			tsk.Task_ID__c = code;
    			if(listRequest.get(tsk.WhatId).Property__c != null){
    				Property__c pr = new Property__c();
	    			pr.Id = listRequest.get(tsk.WhatId).Property__c;
	    			if(mapRequest.containsKey(pr.Id)){
	    				//pr.Task_Index__c = temp;
	    				mapRequest.get(pr.Id).Task_Index__c += 1;
	    			}else{
	    				temp += 1;
	    				pr.Task_Index__c = temp;
	    				mapRequest.put(pr.Id, pr);
	    			}
	    			
    			}
    		}else{
    			code  =  'ST';
    			code += '-WT-';
    			code += System.today().Year();
    			if(System.today().Month() < 10){
    				code += '0';
    			}
    			code += System.today().Month();
    			code += '-';
    			Integer temp;
    			
    			temp = countLabel;
    			
    			String tempNo;
    			if(temp == 0 || temp == null){
    				temp   = 1;
    				countLabel = temp+1;
    				tempNo = ''+temp;
    			}else{
    				temp += 1;
    				countLabel++;
    				tempNo = ''+temp; 
    			}
    			for(integer i =1;i<=6-tempNo.length();i++){
                    code += '0';
                }
    			code += ''+temp;
    			tsk.Task_ID__c = code;
    			tsk.PIC_Email_Id__c = listRequest.get(tsk.WhatId).Person_In_Charge__r.Email;
    			tsk.Request_Name__c = listRequest.get(tsk.WhatId).Name;
    		}
    	}
    	try{
            lst.Count__c = countLabel;
            update lst;
    		update mapRequest.values();
    	}catch(Exception e){
    		System.debug('Exception occured -- > '+e);
    	}
    }
}