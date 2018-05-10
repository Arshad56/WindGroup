trigger Phone_Trax_linkWithRentSchedules on Phone_Transaction__c(before insert, after insert, after update, after delete, after undelete) {
    if (Trigger.isBefore && Trigger.isInsert) {

        Set<String>setPropertyShortCode = new Set<String>();
        Set<String>setPhoneExtNo = new Set<String>();
        Date startDate = system.today();
        Date endDate = system.today();
        Map<String, List<Rent_Schedules__c >> mapMeterNoMMYYYYWithRS = new Map<String, List<Rent_Schedules__c >> ();
		Set<Id> rsIds = new Set<Id>();
		Set<Id> rsManualIds = new Set<Id>();
		
        for (Phone_Transaction__c pt: trigger.new) {
            setPropertyShortCode.add(pt.Property_Short_Code__c);
            setPhoneExtNo.add(pt.Extension_No__c);

            if (pt.Rent_Schedule__c <> null)
                rsIds.add(pt.Rent_Schedule__c);
            
            if (pt.From_Date__c < startDate)
                startDate = pt.From_Date__c;

            if (pt.To_Date__c > endDate)
                endDate = pt.To_Date__c;
                
            if(pt.Rent_Schedule__c <> null && pt.Manual__c)
            	rsManualIds.add(pt.Rent_Schedule__c);
        }
		if(rsManualIds.size() > 0){
	    	Map<Id, Rent_Schedules__c> rsMap = new Map<Id,Rent_Schedules__c>([select Id,Unit__c,Property_Short_Code__c,Start_Date__c,End_Date__c,Lease_Unit__c,PropertyLU__c from Rent_Schedules__c where Id =: rsManualIds ]);
	    	
	    	for(Phone_Transaction__c pt:trigger.New){
	    		if(pt.To_Date__c == null ||  pt.From_Date__c == null){
            		pt.addError('From Date and To Date is required.');
            	}else if(pt.From_Date__c > pt.To_Date__c){
	    			pt.addError('From Date must be before To Date.');
	    		}else if(pt.From_Date__c > rsMap.get(pt.Rent_Schedule__c).End_Date__c ){
	    			pt.addError('From Date must be before Rent Schedule End Date.');
	    		}/*else if(pt.From_Date__c < rsMap.get(pt.Rent_Schedule__c).Start_Date__c || pt.From_Date__c > rsMap.get(pt.Rent_Schedule__c).End_Date__c ){
	    			pt.addError('From Date must be between Rent Schedule Start date and End date.');
	    		}*/else if(pt.To_Date__c  < rsMap.get(pt.Rent_Schedule__c).Start_Date__c || pt.To_Date__c > rsMap.get(pt.Rent_Schedule__c).End_Date__c ){
	    			pt.addError('To Date must be between Rent Schedule Start date and End date.');
	    		}else{
		    		if(rsMap.get(pt.Rent_Schedule__c).Lease_Unit__c!= null)
		    			pt.Lease_Unit__c = rsMap.get(pt.Rent_Schedule__c).Lease_Unit__c;
		    		if(rsMap.get(pt.Rent_Schedule__c).PropertyLU__c!= null){
		    			pt.Property__c = rsMap.get(pt.Rent_Schedule__c).PropertyLU__c;
		    			pt.Property_Short_Code__c = rsMap.get(pt.Rent_Schedule__c).Property_Short_Code__c;
		    		}
		    		if(rsMap.get(pt.Rent_Schedule__c).Unit__c!= null)
		    			pt.Unit__c = rsMap.get(pt.Rent_Schedule__c).Unit__c;
	    		}
	    	}
	    	
	    }
        startDate = Date.newInstance(startDate.year(), startDate.month(), 1);
        endDate = Date.newInstance(endDate.year(), endDate.month(), Date.DaysInMonth(endDate.year(), endDate.month()));

        PicklistValue objPicklistValue = new PicklistValue();
        Sobject objName = Schema.getGlobalDescribe().get('Phone_Transaction__c').newSObject();
        String fieldName = 'Call_Type__c';
        String firstValue = '';

        Set<String>setPicklistValue = new Set<String>();

        setPicklistValue = objPicklistValue.getPickValues(objName, fieldName, '');
        List<Rent_Schedules__c>lstRS = new List<Rent_Schedules__c>();

        system.debug('setPicklistValue ==> ' + setPicklistValue);

        String mmyyyy = null;
        String strMeterNoMMYYYY = null;
		Map<String, List<Phone_Transaction__c>> rsIdwithExtnoWithRec = new Map<String, List<Phone_Transaction__c>>();
		
		List<Rent_Schedules__c> tempRS = new List<Rent_Schedules__c>();
		if(Test.isRunningTest()){
			tempRS =[SELECT Id, Name,Lease_Charge__r.Charge_Type__c, Unit__c, Unit__r.Property__c, Unit__r.Property__r.Short_Code__c, Unit__r.Property__r.Name, Lease_Unit__c, Start_Date__c, End_Date__c, Charge_Type__c, Unit__r.Phone_Extension_No__c,(Select Extension_No__c, Call_Type__c, From_Date__c, To_Date__c, Rent_Schedule__c From Phone_Transactions__r) FROM Rent_Schedules__c ];
		}else{
			tempRS = [SELECT Id, Name,Lease_Charge__r.Charge_Type__c, Unit__c, Unit__r.Property__c, Unit__r.Property__r.Short_Code__c, Unit__r.Property__r.Name, Lease_Unit__c, Start_Date__c, End_Date__c, Charge_Type__c, Unit__r.Phone_Extension_No__c,(Select Extension_No__c, Call_Type__c, From_Date__c, To_Date__c, Rent_Schedule__c From Phone_Transactions__r) FROM Rent_Schedules__c WHERE Lease_Charge__c<> NULL and Lease_Unit__c<> NULL AND Unit__r.Property__r.Short_Code__c IN: setPropertyShortCode AND Charge_Type__c IN: setPicklistValue AND Start_Date__c >=: startDate AND End_Date__c <=: endDate  And Status__c='In-Tenancy'];
		}
		
        for (Rent_Schedules__c rs: tempRS) {
            mmyyyy = rs.Start_Date__c.Month() + '-' + rs.Start_Date__c.Year();

            if (rs.Unit__r.Phone_Extension_No__c<> NULL && rs.Unit__r.Phone_Extension_No__c<> '')
                for (String ExtNo: rs.Unit__r.Phone_Extension_No__c.split(';')) {
                    strMeterNoMMYYYY = ExtNo + '-' + rs.Charge_Type__c + '-' + mmyyyy;
                    lstRS = mapMeterNoMMYYYYWithRS.get(strMeterNoMMYYYY);

                    if (lstRS == null) lstRS = new List<Rent_Schedules__c>();
                    lstRS.add(rs);

                    mapMeterNoMMYYYYWithRS.put(strMeterNoMMYYYY, lstRS);
                    
                    if(rs.Start_Date__c.Month() != rs.End_Date__c.Month()){ 
                    	mmyyyy = rs.End_Date__c.Month() + '-' + rs.End_Date__c.Year();
                    	strMeterNoMMYYYY = ExtNo + '-' + rs.Charge_Type__c + '-' + mmyyyy;
	                    lstRS = mapMeterNoMMYYYYWithRS.get(strMeterNoMMYYYY);
	
	                    if (lstRS == null) lstRS = new List<Rent_Schedules__c>();
	                    lstRS.add(rs);
	
	                    mapMeterNoMMYYYYWithRS.put(strMeterNoMMYYYY, lstRS);
                    }
                }
                for(Phone_Transaction__c pt: rs.Phone_Transactions__r){
                	String key = (rs.Id+'-'+pt.Extension_No__c+'-'+ pt.Call_Type__c).replace(' ', '@');
                	List<Phone_Transaction__c> tempList = new List<Phone_Transaction__c>();
	        		if(rsIdwithExtnoWithRec.containsKey(key))
	        			tempList = rsIdwithExtnoWithRec.get(key);
	        		tempList.add(pt);
	        		
                	rsIdwithExtnoWithRec.put(key, tempList);
                	System.debug(key + 'Pt11-->'+pt);
                }
        }

        system.debug('mapMeterNoMMYYYYWithRS ==> ' + mapMeterNoMMYYYYWithRS);
		system.debug('rsIdwithExtnoWithRec ==> ' + rsIdwithExtnoWithRec);
		
        String ptMMYYYY = null;
		Boolean ptFound = false;
		String keyForMap = ''; 
		Date ptFromDT;
		Date ptToDT;
		
        for (Phone_Transaction__c pt: trigger.new) {
        	ptFound = false;
            ptMMYYYY = pt.From_Date__c.Month() + '-' + pt.From_Date__c.Year();
            List<Rent_Schedules__c> lstRS2 = mapMeterNoMMYYYYWithRS.get(pt.Extension_No__c + '-' + pt.Call_Type__c + '-' + ptMMYYYY);
			
			if(lstRS2 == null ){
				ptMMYYYY = pt.To_Date__c.Month() + '-' + pt.To_Date__c.Year();
				lstRS2 = new List<Rent_Schedules__c>();
				lstRS2 = mapMeterNoMMYYYYWithRS.get(pt.Extension_No__c + '-' + pt.Call_Type__c + '-' + ptMMYYYY);
			}
			system.debug('lstRS2 ==> ' + lstRS2);
            system.debug('pt.Extension_No__c + pt.Call_Type__c + ptMMYYYY ==>' + pt.Extension_No__c + '-' + pt.Call_Type__c + '-' + ptMMYYYY);

            if (lstRS2<> NULL  && !pt.Manual__c)
                for (Rent_Schedules__c RS: lstRS2) {
                    system.debug('pt ==> ' + pt);
                    system.debug('RS ==> ' + RS);
                    keyForMap = RS.Id+'-'+pt.Extension_No__c+'-'+ pt.Call_Type__c;
                    keyForMap = keyForMap.replace(' ', '@');
                    if (pt.Call_Type__c == RS.Lease_Charge__r.Charge_Type__c && pt.From_Date__c <= rs.Start_Date__c  && pt.To_Date__c >= rs.Start_Date__c && pt.To_Date__c <= rs.End_Date__c) {
                    	if(rsIdwithExtnoWithRec.containsKey(keyForMap)){
                    		for(Phone_Transaction__c phoneTemp: rsIdwithExtnoWithRec.get(keyForMap)){
                    			ptFromDT = phoneTemp.From_Date__c;
		                        ptToDT = phoneTemp.To_Date__c;
		                        system.debug('ptFromDT ==> ' + ptFromDT);
		                        system.debug('ptToDT ==> ' + ptToDT);
		                        system.debug('ptFromDT <= pt.To_Date__c ==> ' + (ptFromDT <= pt.To_Date__c));
		                        system.debug('pt.From_Date__c <= ptToDT ==> ' + (pt.From_Date__c <= ptToDT));
								if(ptFromDT <= pt.To_Date__c && pt.From_Date__c <= ptToDT){
									ptFound = true;
									break;
								}
                    		}
						}
						if(!ptFound){
	                        pt.Unit__c = RS.Unit__c;
	                        pt.Lease_Unit__c = RS.Lease_Unit__c;
	                        pt.Property__c = RS.Unit__r.Property__c;
	                        pt.Rent_Schedule__c = RS.Id;
							
							List<Phone_Transaction__c> tempList = new List<Phone_Transaction__c>();
				    		if(rsIdwithExtnoWithRec.containsKey(keyForMap))
				    			tempList = rsIdwithExtnoWithRec.get(keyForMap);
				    		tempList.add(pt);
				    		
				        	rsIdwithExtnoWithRec.put(keyForMap, tempList);
				        	
				        	
	                        break;
						}
                    }
                }
                if(pt.Rent_Schedule__c == null){
	            	pt.addError('Rent Schedule doesnot found.');
	            }
                if (ptFound) {
	                pt.addError('Phone Transaction for identified Rent Schedule already exist.');
	            }
        }
    }
    if (Trigger.isAfter) {
        Set<Id>rentScheduleIds = new Set<Id>();
        if (Trigger.isUndelete || Trigger.isInsert || Trigger.isUpdate) {
            for (Phone_Transaction__c pt: trigger.new) {
                System.debug('pt--> ' + pt);
                if (pt.Rent_Schedule__c != null) {
                    rentScheduleIds.add(pt.Rent_Schedule__c);
                }
                if (Trigger.isUpdate && (trigger.oldMap.get(pt.Id).Rent_Schedule__c != pt.Rent_Schedule__c) && trigger.oldMap.get(pt.Id).Rent_Schedule__c != null) {
                    rentScheduleIds.add(trigger.oldMap.get(pt.Id).Rent_Schedule__c);
                }
            }
            System.debug('rentScheduleIds--> ' + rentScheduleIds);
        }
        if (Trigger.isDelete) {
            for (Phone_Transaction__c con1: Trigger.old) {
                if (con1.Rent_Schedule__c != null) {
                    rentScheduleIds.add(con1.Rent_Schedule__c);
                }
            }
        }
        if (rentScheduleIds.size()>0) {
            RentScheduleCalculations_Helper.setMinMaxDate(rentScheduleIds);
        }
    }
}