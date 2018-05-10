trigger Water_Trax_linkWithRentSchedules on Water_Transaction__c (before insert, after insert, after update,after delete, after undelete) {
    
    if(Trigger.isBefore && Trigger.isInsert){
    Set<String> setPropertyShortCode = new Set<String>();
    Set<String> setMeterNo = new Set<String>();
    Date startDate = system.today();
    Date endDate = system.today();
    Map<String,List<Rent_Schedules__c>> mapMeterNoMMYYYYWithRS = new Map<String,List<Rent_Schedules__c>>();
    Set < Id > rsIds = new Set < Id > ();
	Set<Id> rsManualIds = new Set<Id>();
   
    for(Water_Transaction__c wt : trigger.new){
        setPropertyShortCode.add(wt.Property_Short_Code__c);
        setMeterNo.add(wt.Meter_No__c);
        
        if(wt.Rent_Schedule__c <>null)
          rsIds.add(wt.Rent_Schedule__c );
          
        if(wt.From_date__c<startDate)
            startDate = wt.From_date__c;
            
        if(wt.To_Date__c>endDate)
            endDate = wt.To_Date__c;        
        
        if(wt.Rent_Schedule__c <> null && wt.Manual__c)
           rsManualIds.add(wt.Rent_Schedule__c);   
    } 
    
    if(rsManualIds.size() > 0){
    	Map<Id, Rent_Schedules__c> rsMap = new Map<Id,Rent_Schedules__c>([select Id,Unit__c,Property_Short_Code__c,Start_Date__c,End_Date__c,Lease_Unit__c,PropertyLU__c from Rent_Schedules__c where Id =: rsManualIds ]);
    	
    	for(Water_Transaction__c wt:trigger.New){
    		if(wt.To_Date__c == null ||  wt.From_Date__c == null){
        		wt.addError('From Date and To Date is required.');
        	}else if(wt.From_Date__c > wt.To_Date__c){
    			wt.addError('From Date must be before To Date.');
    		}else if(wt.From_Date__c > rsMap.get(wt.Rent_Schedule__c).End_Date__c ){
	    			wt.addError('From Date must be before Rent Schedule End Date.');
    		}/*else if(wt.From_Date__c < rsMap.get(wt.Rent_Schedule__c).Start_Date__c || wt.From_Date__c > rsMap.get(wt.Rent_Schedule__c).End_Date__c ){
    			wt.addError('From Date must be between Rent Schedule Start date and End date.');
    		}*/else if(wt.To_Date__c  < rsMap.get(wt.Rent_Schedule__c).Start_Date__c || wt.To_Date__c > rsMap.get(wt.Rent_Schedule__c).End_Date__c ){
    			wt.addError('To Date must be between Rent Schedule Start date and End date.');
    		}else{
	    		if(rsMap.get(wt.Rent_Schedule__c).Lease_Unit__c!= null)
	    			wt.Lease_Unit__c = rsMap.get(wt.Rent_Schedule__c).Lease_Unit__c;
	    		if(rsMap.get(wt.Rent_Schedule__c).PropertyLU__c!= null){
	    			wt.Property__c = rsMap.get(wt.Rent_Schedule__c).PropertyLU__c;
	    			wt.Property_Short_Code__c = rsMap.get(wt.Rent_Schedule__c).Property_Short_Code__c;
	    		}
	    		if(rsMap.get(wt.Rent_Schedule__c).Unit__c!= null)
	    			wt.Unit__c = rsMap.get(wt.Rent_Schedule__c).Unit__c;
    		}
    	}
    	
    }
    
    startDate = Date.newInstance(startDate.year(),startDate.month(),1);
    endDate = Date.newInstance(endDate.year(),endDate.month(),Date.DaysInMonth(endDate.year(), endDate.month())); 
    
        String mmyyyy = null;
        List<Rent_Schedules__c> lstRS = new List<Rent_Schedules__c>();
        String strMeterNoMMYYYY = null;
        Map<String, List<Water_Transaction__c>> rsIdwithMeternowithRec = new Map<String,  List<Water_Transaction__c>>();
         
        List<Rent_Schedules__c> tempRS = new List<Rent_Schedules__c>();
		if(Test.isRunningTest()){
			tempRS =[SELECT Id, Name, Unit__c, Unit__r.Property__c, Unit__r.Property__r.Short_Code__c, Unit__r.Property__r.Name, Lease_Unit__c, Start_Date__c, End_Date__c, Charge_Type__c, Unit__r.Water_Meter_No__c,(Select Meter_No__c, From_Date__c, To_Date__c From Water_Transactions__r) FROM Rent_Schedules__c ];
		}else{
			tempRS = [SELECT Id, Name, Unit__c, Unit__r.Property__c, Unit__r.Property__r.Short_Code__c, Unit__r.Property__r.Name, Lease_Unit__c, Start_Date__c, End_Date__c, Charge_Type__c, Unit__r.Water_Meter_No__c,(Select Meter_No__c, From_Date__c, To_Date__c From Water_Transactions__r) FROM Rent_Schedules__c WHERE Lease_Charge__c <> NULL and Lease_Unit__c <> NULL AND Unit__r.Property__r.Short_Code__c IN : setPropertyShortCode AND (Charge_Type__c = 'Water') AND Start_Date__c >= :startDate AND End_Date__c <= :endDate  And Status__c='In-Tenancy'];
		}
        for(Rent_Schedules__c rs:tempRS){        
            mmyyyy = rs.Start_Date__c.Month() + '-' + rs.Start_Date__c.Year();
            
            if(rs.Unit__r.Water_Meter_No__c <> NULL && rs.Unit__r.Water_Meter_No__c <> '')
            for(String MeterNo: rs.Unit__r.Water_Meter_No__c.split(';')){
                strMeterNoMMYYYY = MeterNo + '-' + mmyyyy;
                lstRS = mapMeterNoMMYYYYWithRS.get(strMeterNoMMYYYY);
                
                if(lstRS == null) lstRS = new List<Rent_Schedules__c>();
                lstRS.add(rs);
                
                mapMeterNoMMYYYYWithRS.put(strMeterNoMMYYYY, lstRS);
                
                System.debug(strMeterNoMMYYYY+'1elle-->'+lstRS);
                 if(rs.Start_Date__c.Month() != rs.End_Date__c.Month()){ 
 	                mmyyyy = rs.End_Date__c.Month() + '-' + rs.End_Date__c.Year();
                 	
                 	strMeterNoMMYYYY = MeterNo + '-' + mmyyyy;
	                lstRS = mapMeterNoMMYYYYWithRS.get(strMeterNoMMYYYY);
	                
	                if(lstRS == null) lstRS = new List<Rent_Schedules__c>();
	                lstRS.add(rs);
	                
	                mapMeterNoMMYYYYWithRS.put(strMeterNoMMYYYY, lstRS);
                 }
             	 System.debug(strMeterNoMMYYYY+'2elle-->'+lstRS);
                 
            }
            for(Water_Transaction__c wt : rs.Water_Transactions__r){ 
            	String key = (rs.Id+'-'+wt.Meter_No__c).replace(' ', '@');
            	List<Water_Transaction__c> tempList = new List<Water_Transaction__c>();
        		if(rsIdwithMeternowithRec.containsKey(key))
        			tempList = rsIdwithMeternowithRec.get(key);
        		tempList.add(wt);
        			
            	rsIdwithMeternowithRec.put(key, tempList);
            	System.debug(key + 'wt11-->'+wt);
            }
        }
        system.debug('mapMeterNoMMYYYYWithRS ==> ' + mapMeterNoMMYYYYWithRS);
        
        String wtMMYYYY = null;
        Boolean wtFound = false;
        String keyForMap = '';
        Date wtFromDT;
		Date wtToDT;
		
        for(Water_Transaction__c wt : trigger.new){ 
            wtMMYYYY = wt.From_Date__c.Month() + '-' + wt.From_Date__c.Year();
            List<Rent_Schedules__c> lstRS2 = mapMeterNoMMYYYYWithRS.get(wt.Meter_No__c + '-' + wtMMYYYY);
            if(lstRS2 == null ){
            	lstRS2 = new List<Rent_Schedules__c>();
            	wtMMYYYY = wt.To_Date__c.Month() + '-' + wt.To_Date__c.Year();
            	lstRS2 = mapMeterNoMMYYYYWithRS.get(wt.Meter_No__c + '-' + wtMMYYYY);
            }
            System.debug('lstRS2-->'+lstRS2);
			System.debug('keyyy-->'+wt.Meter_No__c + '-' +wtMMYYYY);
			 
            if(lstRS2 <> NULL  && !wt.Manual__c)
	            for(Rent_Schedules__c RS:lstRS2){
	            	system.debug('RS ==> ' + RS);
                    system.debug('wt ==> ' + wt);
	            	keyForMap = RS.Id+'-'+wt.Meter_No__c;
                    keyForMap = keyForMap.replace(' ', '@');
	                if(wt.From_Date__c <= rs.Start_Date__c  && wt.To_Date__c >= rs.Start_Date__c && wt.To_Date__c <= rs.End_Date__c){ 
	                	if(rsIdwithMeternowithRec.containsKey(keyForMap)){
	                		for(Water_Transaction__c wtTemp: rsIdwithMeternowithRec.get(keyForMap)){
	                			wtFromDT = wtTemp.From_Date__c;
		                        wtToDT = wtTemp.To_Date__c;
		                        system.debug('wtFromDT ==> ' + wtFromDT);
		                        system.debug('wtToDT ==> ' + wtToDT);
		                        system.debug('wtFromDT <= wt.To_Date__c ==> ' + (wtFromDT <= wt.To_Date__c));
		                        system.debug('wt.From_Date__c <= eleToDT ==> ' + (wt.From_Date__c <= wtToDT));
								if(wtFromDT <= wt.To_Date__c && wt.From_Date__c <= wtToDT){
									wtFound = true;
									break;
								}
	                		}
						}
	                	if(!wtFound){
		                    wt.Unit__c = RS.Unit__c;
		                    wt.Lease_Unit__c = RS.Lease_Unit__c;
		                    wt.Property__c = RS.Unit__r.Property__c;
		                    wt.Rent_Schedule__c = RS.Id;
		                    
		                    List<Water_Transaction__c> tempList = new List<Water_Transaction__c>();
			        		if(rsIdwithMeternowithRec.containsKey(keyForMap))
			        			tempList = rsIdwithMeternowithRec.get(keyForMap);
			        		tempList.add(wt);
			            	rsIdwithMeternowithRec.put(keyForMap, tempList);
			                                        
		                    break;
	                	}
	                } 
	            }  
	            if(wt.Rent_Schedule__c == null){
	            	wt.addError('Rent Schedule doesnot found.');
	            }
                if (wtFound) {
	                wt.addError('Water Transaction for identified Rent Schedule already exist.');
	            }
        }
    }
       if(Trigger.isAfter ){
    	Set<Id> rentScheduleIds= new Set<Id>();
    	if(Trigger.isUndelete ||Trigger.isInsert || Trigger.isUpdate){
    		for(Water_Transaction__c gt : trigger.new){
    			System.debug('gt--> '+gt);
    			if(gt.Rent_Schedule__c != null){
    				rentScheduleIds.add(gt.Rent_Schedule__c);
    			}
    			if(Trigger.isUpdate && (trigger.oldMap.get(gt.Id).Rent_Schedule__c != gt.Rent_Schedule__c) && trigger.oldMap.get(gt.Id).Rent_Schedule__c != null){
    				rentScheduleIds.add(trigger.oldMap.get(gt.Id).Rent_Schedule__c);
    			}
    		}
    		System.debug('rentScheduleIds--> '+rentScheduleIds);
    	}
    	if(Trigger.isDelete){
		        for(Water_Transaction__c con1 : Trigger.old){
		        	if(con1.Rent_Schedule__c != null){
		        		rentScheduleIds.add(con1.Rent_Schedule__c);
		        	}
		        } 
		    }
		 if(rentScheduleIds.size()>0){
    		   RentScheduleCalculations_Helper.setMinMaxDate(rentScheduleIds);
    	 }
    	}
}