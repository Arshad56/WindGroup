public with sharing class PreTerminate_Controller {
    @AuraEnabled
    public static String checkTermination(String recordId) {
    	Schema.SObjectType sobjectType = Id.valueOf(recordId).getSObjectType();
		String sobjectName = sobjectType.getDescribe().getName();
		System.debug('sobjectName-->'+sobjectName);
		String sobjectLabel = sobjectType.getDescribe().getLabel();
		System.debug('describe.getLabel()-->'+sobjectLabel);
		
		String lcType = Schema.SObjectType.Lease_Charges__c.getKeyPrefix();
		String luType = Schema.SObjectType.Lease_Unit__c.getKeyPrefix();
		String leaseType = Schema.SObjectType.Lease__c.getKeyPrefix();
		String resp = 'SUCCESS|';
		if(recordId.startsWithIgnoreCase(lcType)){
        	Lease_Charges__c lc = [SELECT Id,Pre_Termination__c,End_Date__c FROM Lease_Charges__c WHERE  Id =: recordId];
        	if(lc.Pre_Termination__c)
        		return 'This '+sobjectLabel+' is already Terminated.';
        	if(lc.End_Date__c <= System.today())
            	return 'Sorry you cant Pre-Terminate this '+sobjectLabel+'.';
			list<Lease_Charges__c> discLClist = [select Id,Parent_Lease_Charge__c,Pre_Termination__c,(select id, Name from Rent_Schedules__r where status__c NOT IN ('Cancelled','Terminated')) from Lease_Charges__c where Parent_Lease_Charge__c =: recordId And Parent_Lease_Charge__r.Pre_Termination__c = false];
			if(discLClist.size()>0 && discLClist[0].Rent_Schedules__r <> NULL && discLClist[0].Rent_Schedules__r.size() > 0)
				return 'Please Terminate dependent '+sobjectLabel+' and related Rent Schedule(s) before you proceed.'; 
			resp += ((lc.End_Date__c!= null)?lc.End_Date__c.Month()+'/'+lc.End_Date__c.day()+'/'+lc.End_Date__c.year():'')+'|';
		}else if(recordId.startsWithIgnoreCase(luType)){
			Lease_Unit__c lu = [SELECT Id,Pre_Termination__c,Lease_End_Date__c FROM Lease_Unit__c WHERE  Id =: recordId];
        	if(lu.Pre_Termination__c)
        		return 'This '+sobjectLabel+' is already Terminated.';
        	if(lu.Lease_End_Date__c <= System.today())
            	return 'Sorry you cant Pre-Terminate this '+sobjectLabel+'.';
			
			resp += ((lu.Lease_End_Date__c!= null)?lu.Lease_End_Date__c.Month()+'/'+lu.Lease_End_Date__c.day()+'/'+lu.Lease_End_Date__c.year():'')+'|';
		}else if(recordId.startsWithIgnoreCase(leaseType)){
			Lease__c lease = [SELECT Id,Pre_Terminated__c,Lease_End_Date__c FROM Lease__c WHERE  Id =: recordId];
        	if(lease.Pre_Terminated__c)
        		return 'This '+sobjectLabel+' is already Terminated.';
        	if(lease.Lease_End_Date__c <= System.today())
            	return 'Sorry you cant Pre-Terminate this '+sobjectLabel+'.';
			
			resp += ((lease.Lease_End_Date__c!= null)?lease.Lease_End_Date__c.Month()+'/'+lease.Lease_End_Date__c.day()+'/'+lease.Lease_End_Date__c.year():'')+'|';
		}else{
			return 'Terminate Process Doesnt Exist.';
		}
		  
         
        resp += sobjectLabel;
        System.debug('resp-->'+resp);
        return resp;
    } 
    @AuraEnabled
    public static String preTerminate(String recordId,String termDate, String isByPass, String reason){
    	Schema.SObjectType sobjectType = Id.valueOf(recordId).getSObjectType();
		String sobjectName = sobjectType.getDescribe().getName();
		System.debug('sobjectName-->'+sobjectName);
		String sobjectLabel = sobjectType.getDescribe().getLabel();
		System.debug('describe.getLabel()-->'+sobjectLabel);
		
		String lcType = Schema.SObjectType.Lease_Charges__c.getKeyPrefix();
		String luType = Schema.SObjectType.Lease_Unit__c.getKeyPrefix();
		String leaseType = Schema.SObjectType.Lease__c.getKeyPrefix();
		String resp = 'SUCCESS|';
		
		if(String.isBlank(reason) && sobjectLabel != 'Lease Charge'){
			return 'Reason: Please add Reason for Termination.';
		}
		System.debug('termDate-->'+termDate);
		
		if(recordId.startsWithIgnoreCase(lcType)){
	    	PreTerminateLC_Extension preT = new PreTerminateLC_Extension();
	    	preT.isVF = false;
	    	preT.rsList = new List < Rent_Schedules__c >();
	        preT.lcTerminate = new Lease_Charges__c();
	        preT.leaseCharge = [select id from Lease_Charges__c where id =: recordId];
	        preT.selectedLeaseCharge =  recordId;
	        preT.leaseCharge.End_Date__c = PreTerminate_Controller.setStringToDateFormat(termDate);
	        
	        if(isByPass == 'false'){
	        	resp = preT.checkDate();
	        }else{
	        	resp = preT.save();
	        }
		    
		}else if(recordId.startsWithIgnoreCase(luType)){
			PreTerminateLU_Extension preT = new PreTerminateLU_Extension();
			preT.errorMsg = '';
	        preT.rsList = new List < Rent_Schedules__c >();
	        preT.displayPopup = false;
	        preT.lu = [select id,Reason_for_Termination__c,Lease_End_Date__c from Lease_Unit__c where id =: recordId];
	        System.debug('111');
	        preT.lu.Lease_End_Date__c = System.today();
	        System.debug('222');
	        preT.lu.Reason_for_Termination__c  = reason;
	        System.debug('333');
	        preT.selectedLU = recordId;
	        System.debug('444');
	        preT.EndDate = PreTerminate_Controller.setStringToDateFormat(termDate);
	        preT.lu.Lease_End_Date__c  = preT.EndDate;
	        System.debug('555');
	        preT.error = true; 
	        System.debug('666-->'+isByPass);
	        
	        if(isByPass == 'false'){
	        	resp = preT.checkDate();
	        }else{
	        	resp = preT.save();
	        }
		}else if(recordId.startsWithIgnoreCase(leaseType)){
	    	PreTerminateLease_Extension ptExt = new PreTerminateLease_Extension();
	        ptExt.leaseOnUI = [select Id,Lease_Start_Date__c from Lease__c where id =: recordId];
	        ptExt.EndDate = PreTerminate_Controller.setStringToDateFormat(termDate);
	        
	        ptExt.leaseOnUI.Lease_Start_Date__c = System.today();
	        ptExt.selectedLease = recordId;
	
	    }else{
			return 'Terminate Process Doesnt Exist.';
		}
		
        return resp;
    }
     private static Date setStringToDateFormat(String myDate) {
	   String[] strDate = myDate.split('/');
	   if(!(strDate.size() > 1))
	   	strDate = myDate.split('-');
	   Integer myIntDate = integer.valueOf(strDate[2]);
	   Integer myIntMonth = integer.valueOf(strDate[1]);
	   Integer myIntYear = integer.valueOf(strDate[0]);
	   Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
	   return d;
	}
}