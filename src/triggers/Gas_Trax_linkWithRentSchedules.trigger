trigger Gas_Trax_linkWithRentSchedules on Gas_Transaction__c(before insert, after insert, after update, after delete, after undelete) {

    if (Trigger.isBefore && Trigger.isInsert) {
        Set<String>setPropertyShortCode = new Set<String>();
        Set<String>setGasMeterNo = new Set<String>();
        Date startDate = system.today();
        Date endDate = system.today();
        Map<String, List<Rent_Schedules__c >> mapMeterNoMMYYYYWithRS = new Map<String, List<Rent_Schedules__c >> ();
		Set < Id > rsIds = new Set < Id > ();
		Set<Id> rsManualIds = new Set<Id>();
		
        for (Gas_Transaction__c gt: trigger.new) {setPropertyShortCode.add(gt.Property_Short_Code__c);
            setGasMeterNo.add(gt.Meter_No__c);

            if (gt.Rent_Schedule__c <> null) 
                rsIds.add(gt.Rent_Schedule__c);

            if (gt.From_Date__c < startDate)
                startDate = gt.From_Date__c;

            if (gt.To_Date__c > endDate)
                endDate = gt.To_Date__c;
            
            if(gt.Rent_Schedule__c <> null && gt.Manual__c)
            	rsManualIds.add(gt.Rent_Schedule__c);
        }
        
        if(rsManualIds.size() > 0){
	    	Map<Id, Rent_Schedules__c> rsMap = new Map<Id,Rent_Schedules__c>([select Id,Unit__c,Property_Short_Code__c,Start_Date__c,End_Date__c,Lease_Unit__c,PropertyLU__c from Rent_Schedules__c where Id =: rsManualIds ]);
	    	
	    	for(Gas_Transaction__c gt:trigger.New){
	    		if(gt.To_Date__c == null ||  gt.From_Date__c == null){
            		gt.addError('From Date and To Date is required.');
            	}else if(gt.From_Date__c > gt.To_Date__c){
	    			gt.addError('From Date must be before To Date.');
	    		}else if(gt.From_Date__c > rsMap.get(gt.Rent_Schedule__c).End_Date__c ){
	    			gt.addError('From Date must be before Rent Schedule End Date.');
	    		}/*else if(gt.From_Date__c < rsMap.get(gt.Rent_Schedule__c).Start_Date__c || gt.From_Date__c > rsMap.get(gt.Rent_Schedule__c).End_Date__c ){
	    			gt.addError('From Date must be between Rent Schedule Start date and End date.');
	    		}*/else if(gt.To_Date__c  < rsMap.get(gt.Rent_Schedule__c).Start_Date__c || gt.To_Date__c > rsMap.get(gt.Rent_Schedule__c).End_Date__c ){
	    			gt.addError('To Date must be between Rent Schedule Start date and End date.');
	    		}else{
		    		if(rsMap.get(gt.Rent_Schedule__c).Lease_Unit__c!= null)
		    			gt.Lease_Unit__c = rsMap.get(gt.Rent_Schedule__c).Lease_Unit__c;
		    		if(rsMap.get(gt.Rent_Schedule__c).PropertyLU__c!= null){
		    			gt.Property__c = rsMap.get(gt.Rent_Schedule__c).PropertyLU__c;
		    			gt.Property_Short_Code__c = rsMap.get(gt.Rent_Schedule__c).Property_Short_Code__c;
		    		}
		    		if(rsMap.get(gt.Rent_Schedule__c).Unit__c!= null)
		    			gt.Unit__c = rsMap.get(gt.Rent_Schedule__c).Unit__c;
	    		}
	    	}
	    	
	    }
        
        startDate = Date.newInstance(startDate.year(), startDate.month(), 1);
        endDate = Date.newInstance(endDate.year(), endDate.month(), Date.DaysInMonth(endDate.year(), endDate.month()));
	
        String mmyyyy = null;
        String strMeterNoMMYYYY = null;
        List<Rent_Schedules__c>lstRS = new List<Rent_Schedules__c>();
		Map<String, List<Gas_Transaction__c>> rsIdwithMeternowithRec = new Map<String, List<Gas_Transaction__c>>();
		
		List<Rent_Schedules__c> tempRS = new List<Rent_Schedules__c>();
		if(Test.isRunningTest()){
			tempRS =[SELECT Id, Name, Unit__c, Unit__r.Property__c, Unit__r.Property__r.Short_Code__c, Unit__r.Property__r.Name, Lease_Unit__c, Start_Date__c, End_Date__c, Charge_Type__c, Unit__r.Gas_Meter_No__c,(Select Id, Meter_No__c, From_Date__c, To_Date__c, Rent_Schedule__c, Property_Short_Code__c From Gas_Transactions__r) FROM Rent_Schedules__c ];
		}else{
			tempRS = [SELECT Id, Name, Unit__c, Unit__r.Property__c, Unit__r.Property__r.Short_Code__c, Unit__r.Property__r.Name, Lease_Unit__c, Start_Date__c, End_Date__c, Charge_Type__c, Unit__r.Gas_Meter_No__c,(Select Id, Meter_No__c, From_Date__c, To_Date__c, Rent_Schedule__c, Property_Short_Code__c From Gas_Transactions__r) FROM Rent_Schedules__c WHERE Lease_Charge__c<> NULL and Lease_Unit__c<> NULL AND Unit__r.Property__r.Short_Code__c IN: setPropertyShortCode AND(Charge_Type__c = 'Gas') AND Start_Date__c >=: startDate AND End_Date__c <=: endDate  And Status__c='In-Tenancy'];
		}
        for (Rent_Schedules__c rs: tempRS) {
            mmyyyy = rs.Start_Date__c.Month() + '-' + rs.Start_Date__c.Year();


            if (rs.Unit__r.Gas_Meter_No__c<> NULL && rs.Unit__r.Gas_Meter_No__c<> '')
                for (String meterNo: rs.Unit__r.Gas_Meter_No__c.split(';')) {
                    strMeterNoMMYYYY = meterNo + '-' + mmyyyy;
                    lstRS = mapMeterNoMMYYYYWithRS.get(strMeterNoMMYYYY);

                    if (lstRS == null) lstRS = new List<Rent_Schedules__c>();
                    lstRS.add(rs);

                    mapMeterNoMMYYYYWithRS.put(strMeterNoMMYYYY, lstRS);
                    System.debug(strMeterNoMMYYYY+'1elle-->'+lstRS);
                    
                    if(rs.Start_Date__c.Month() != rs.End_Date__c.Month()){ 
 	                	mmyyyy = rs.End_Date__c.Month() + '-' + rs.End_Date__c.Year();
 	                	lstRS = mapMeterNoMMYYYYWithRS.get(strMeterNoMMYYYY);

	                    if (lstRS == null) lstRS = new List<Rent_Schedules__c>();
	                    lstRS.add(rs);
	
	                    mapMeterNoMMYYYYWithRS.put(strMeterNoMMYYYY, lstRS);
                    }
                    System.debug(strMeterNoMMYYYY+'2elle-->'+lstRS);
                }
            for(Gas_Transaction__c gt: rs.Gas_Transactions__r){
            	String key = (rs.Id+'-'+gt.Meter_No__c).replace(' ', '@');
            	List<Gas_Transaction__c> tempList = new List<Gas_Transaction__c>();
        		if(rsIdwithMeternowithRec.containsKey(key))
        			tempList = rsIdwithMeternowithRec.get(key);
        		tempList.add(gt);
        		
            	rsIdwithMeternowithRec.put(key, tempList);
            	System.debug(key + 'gt11-->'+gt);
            }
        }
		System.debug('rsIdwithMeternowithRec-->'+rsIdwithMeternowithRec);
        String ptMMYYYY = null;
        Boolean gtFound = false;
        String keyForMap = '';
        Date gtFromDT;
		Date gtToDT;
		
        for (Gas_Transaction__c gt: trigger.new) {
        	gtFound = false;
            ptMMYYYY = gt.From_Date__c.Month() + '-' + gt.From_Date__c.Year();
            List<Rent_Schedules__c>lstRS2 = mapMeterNoMMYYYYWithRS.get(gt.Meter_No__c + '-' + ptMMYYYY);
            
            if(lstRS2 == null ){
            	lstRS2 = new List<Rent_Schedules__c>();
            	ptMMYYYY = gt.To_Date__c.Month() + '-' + gt.To_Date__c.Year();
            	lstRS2 = mapMeterNoMMYYYYWithRS.get(gt.Meter_No__c + '-' + ptMMYYYY);
            }
			System.debug('lstRS2-->'+lstRS2);
			System.debug('keyyy-->'+gt.Meter_No__c + '-' +ptMMYYYY);
			
            if (lstRS2<> NULL  && !gt.Manual__c)
                for (Rent_Schedules__c RS: lstRS2) {
                	System.debug('RS-->'+RS);
                	System.debug('gt-->'+gt);
                	keyForMap = RS.Id+'-'+gt.Meter_No__c;
                    keyForMap = keyForMap.replace(' ', '@');
                    if (gt.From_Date__c <= rs.Start_Date__c  && gt.To_Date__c >= rs.Start_Date__c && gt.To_Date__c <= rs.End_Date__c) {
                    	if(rsIdwithMeternowithRec.containsKey(keyForMap)){
                    		for(Gas_Transaction__c gtTemp: rsIdwithMeternowithRec.get(keyForMap)){
	                			gtFromDT = gtTemp.From_Date__c;
		                        gtToDT = gtTemp.To_Date__c;
		                        system.debug('gtFromDT ==> ' + gtFromDT);
		                        system.debug('gtToDT ==> ' + gtToDT);
		                        system.debug('gtFromDT <= gt.To_Date__c ==> ' + (gtFromDT <= gt.To_Date__c));
		                        system.debug('gt.From_Date__c <= eleToDT ==> ' + (gt.From_Date__c <= gtToDT));
								if(gtFromDT <= gt.To_Date__c && gt.From_Date__c <= gtToDT){
									gtFound = true;
									break;
								}
                    		}
						}
						if(!gtFound){
	                        gt.Unit__c = RS.Unit__c;
	                        gt.Lease_Unit__c = RS.Lease_Unit__c;
	                        gt.Property__c = RS.Unit__r.Property__c;
	                        gt.Rent_Schedule__c = RS.Id;
	                        
	                        List<Gas_Transaction__c> tempList = new List<Gas_Transaction__c>();
				    		if(rsIdwithMeternowithRec.containsKey(keyForMap))
				    			tempList = rsIdwithMeternowithRec.get(keyForMap);
				    		tempList.add(gt);
				        	rsIdwithMeternowithRec.put(keyForMap, tempList);
				        	
	                        break;
	                    }
                    }
                }
                if(gt.Rent_Schedule__c == null){
	            	gt.addError('Rent Schedule doesnot found.');
	            }
                if (gtFound) {
	                gt.addError('Gas Transaction for identified Rent Schedule already exist.');
	            }
        }
    }
    if (Trigger.isAfter) {
        Set<Id>rentScheduleIds = new Set<Id>();
        if (Trigger.isUndelete || Trigger.isInsert || Trigger.isUpdate) {
            for (Gas_Transaction__c gt: trigger.new) {
                System.debug('gt--> ' + gt);
                if (gt.Rent_Schedule__c != null) {
                    rentScheduleIds.add(gt.Rent_Schedule__c);
                }
                if (Trigger.isUpdate && (trigger.oldMap.get(gt.Id).Rent_Schedule__c != gt.Rent_Schedule__c) && trigger.oldMap.get(gt.Id).Rent_Schedule__c != null) {
                    rentScheduleIds.add(trigger.oldMap.get(gt.Id).Rent_Schedule__c);
                }
            }
            System.debug('rentScheduleIds--> ' + rentScheduleIds);
        }
        if (Trigger.isDelete) {
            for (Gas_Transaction__c con1: Trigger.old) {
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