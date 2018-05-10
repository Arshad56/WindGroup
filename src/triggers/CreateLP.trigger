trigger CreateLP on Property__c (after update) {
    Set<Id> propIds = new Set<Id>();
    for(Property__c prop:Trigger.New){
        if(prop.End_Year__c!=null && prop.End_Year__c!=Trigger.oldMap.get(prop.Id).End_Year__c && Integer.valueOf(prop.End_Year__c) >= system.today().year()){
            propIds.add(prop.Id);
        }
    }
    if(propIds.size()>0){
        Map<Id,List<Units__c>> propToUnitMap = new Map<Id,List<Units__c>>();
        Set<Id> unitIds = new Set<Id>();
        Map<Id,Lease_Plan__c> unitToLastLPMap = new Map<Id,Lease_Plan__c>();
        Map<Id,List<Lease_Unit__c>> unitToLcMap = new Map<Id,List<Lease_Unit__c>>();
        Set<Id> leaseUnitIds = new Set<Id>();
        List<Units__c> unitList = [Select id,NLA_SQF__c,Start_Date__c,End_Date__c,Property__c,(Select id,End_Date__c,Start_Date__c from Lease_Plans__r order by End_Date__c Desc limit 1),(Select id,Lease_Start_Date__c,Lease_End_Date__c from Lease_Units__r) from Units__c where Property__c in:propIds and Active__c=true];
        for(Units__c unt:unitList){
            unitIds.add(unt.Id);
            
            List<Units__c> tempList = new List<Units__c>();
            if(propToUnitMap.containsKey(unt.Property__c)){
                tempList.addAll(propToUnitMap.get(unt.Property__c));
            }
            tempList.add(unt);
            propToUnitMap.put(unt.Property__c,tempList);
            if(unt.Lease_Plans__r.size()>0){
                unitToLastLPMap.put(unt.Id,unt.Lease_Plans__r[0]);
            }
            if(unt.Lease_Units__r.size()>0){
                unitToLcMap.put(unt.Id,unt.Lease_Units__r);
                for(Lease_Unit__c lu:unt.Lease_Units__r){
                    leaseUnitIds.add(lu.Id);
                }
            }
        }
        System.debug('unitList-->'+unitList);
        System.debug('unitIds.size()-->'+unitIds.size());
        if(unitIds.size()>0){
            List<Lease_Plan__c> leasePlanList = new List<Lease_Plan__c>();
            Map<Id,List<Lease_charges__c>> luToLcMap = new Map<Id,List<Lease_charges__c>>();
            for(Lease_Charges__c lc:[Select id,Base_Rent_Calculation__c,Start_Date__c,End_Date__c,Lease_Unit__c from Lease_Charges__c where Lease_Unit__c in:leaseUnitIds and (Charge_Type__c='Advance Rental' or Charge_Type__c='Rent')]){
                List<Lease_charges__c> tempList = new List<Lease_charges__c>();
                if(luToLcMap.containsKey(lc.Lease_Unit__c)){
                    tempList.addAll(luToLcMap.get(lc.Lease_Unit__c));
                }
                tempList.add(lc);
                luToLcMap.put(lc.Lease_Unit__c,tempList);
            }
            System.debug('unitToLastLPMap --> '+unitToLastLPMap);
            for(Property__c prop:Trigger.New){
                if(propIds.contains(prop.Id)){
                    if(propToUnitMap.containsKey(prop.Id)){
                        Date propEndYearDate = Date.NewInstance(Integer.valueOf(prop.End_Year__c),12,31);
                        for(Units__c unt:propToUnitMap.get(prop.Id)){
                            Date startDate = Date.NewInstance(system.today().year(),system.today().Month(),1);
                            System.debug('startDate --> '+startDate);
                            System.debug('unt.Id --> '+unt.Id);
                            System.debug('unitToLastLPMap.containsKey(unt.Id) --> '+unitToLastLPMap.containsKey(unt.Id));
                            if(unitToLastLPMap.containsKey(unt.Id)){
                            	System.debug(unitToLastLPMap.containsKey(unt.Id)+' mapp--> '+(unitToLastLPMap.get(unt.Id).End_Date__c > startDate));
                                //if(unitToLastLPMap.get(unt.Id).End_Date__c > startDate){
                                    startDate = unitToLastLPMap.get(unt.Id).End_Date__c + 1;
                                //}
                            }
                            System.debug('Start Date --> '+startDate);
                            Date endDate = (unt.End_Date__c > propEndYearDate?propEndYearDate:unt.End_Date__c);
                            
                            Integer startMonth = startDate.month();
                            Integer startYear = startDate.year();
                            Integer endMonth = endDate.month();
                            Integer endYear = endDate.Year();
                            
                            Integer incMonth = startMonth;
                            Integer incYear = startYear;
                            
                            While((IncMonth <= endMonth && IncYear <= endYear) || (incMonth>endMonth && incYear<endYear)){
                                Lease_Plan__c lp = new Lease_Plan__c();
                                lp.Unit__c = unt.Id;
                                lp.put('Status__c', 'Vacant');
                                lp.Vacant__c = true;
                                if(incMonth==startMonth && incYear==startYear){
                                    lp.Start_Date__c = date.NewInstance(incYear,incMonth,startDate.day());
                                }else{
                                    lp.Start_Date__c = date.NewInstance(incYear,incMonth,1);
                                }
                                
                                if(incMonth==endMonth && incYear==endYear){
                                    lp.End_Date__c = date.NewInstance(incYear,incMonth,endDate.day());
                                }else{
                                    lp.End_Date__c = date.NewInstance(incYear,incMonth,Date.DaysInMonth(incYear,incMonth));
                                }
                                System.debug('LP --> '+LP);
                                Integer commitCount = 0;
                                for(Integer x = 1; x<= 31; x++){
                                	if(x <= lp.End_Date__c.day()){
                                		lp.put('Day_'+x+'__c',  date.NewInstance(incYear,incMonth,x));
	                                    lp.put('Status_'+x+'__c', 'Vacant');
                                	}else{
                                		lp.put('Status_'+x+'__c', 'N/A');
                                	}
                                }
                                if(unitToLcMap.containsKey(unt.Id)){
                                    Map<Id,date> luStartDateMap = new Map<Id,date>();
                                    Map<Id,date> luEndDateMap = new Map<Id,date>();
                                    for(Lease_Unit__c lu:unitToLcMap.get(unt.Id)){
                                    	//luStartDateMap.put(lu.Id,lp.Start_Date__c);
                                    	//luEndDateMap.put(lu.Id,lp.End_Date__c);
                                        for(Date dt=lp.Start_Date__c;dt<=lp.End_Date__c;dt=dt+1){
                                            if(dt>=lu.Lease_Start_Date__c && dt<=lu.Lease_End_Date__c){
                                                if(!luStartDateMap.containsKey(lu.Id)){
                                                    luStartDateMap.put(lu.Id,dt);
                                                }
                                                luEndDateMap.put(lu.Id,dt);
                                            }
                                        }
                                    }
                                    if(luStartDateMap.size()>0 && luEndDateMap.size()>0){
                                        for(Id luId:luStartDateMap.keyset()){
                                            //if(lp.Lease_Unit__c==null){
                                            lp.Lease_Unit__c = luId;
                                            for(Date dt=luStartDateMap.get(luId);dt<=luEndDateMap.get(luId);dt=dt+1){
                                            	lp.put('Commited__c',true);
                                                lp.put('Day_'+dt.day()+'__c',dt);
                                                lp.put('Status_'+dt.day()+'__c','Committed');
                                            }
                                            
                                            lp.put('Status__c', 'Committed');
                                            for(Date dt=lp.Start_Date__c;dt<=lp.End_Date__c;dt=dt+1){
                                            	if(lp.get('Status_'+dt.day()+'__c') != 'Committed' && lp.get('Status_'+dt.day()+'__c') != 'N/A' ){
	                                            	lp.put('Status__c', 'Vacant');
	                                            }
                                            }
                                            
                                            
                                            //lp.End_Date__c = luEndDateMap.get(luId);
                                            if(luToLcMap.containsKey(luId)){
                                                for(Lease_Charges__c lc:luToLcMap.get(luId)){
                                                    if(lp.Start_Date__c>=lc.Start_Date__c && lp.Start_Date__c<=lc.End_Date__c){
                                                        if(unt.NLA_SQF__c>0){
                                                            lp.Monthly_Budget__c = lc.Base_Rent_Calculation__c/unt.NLA_SQF__c;
                                                        }
                                                    }
                                                }
                                            }
                                            /*}else{
                                                Lease_Plan__c lp1 = new Lease_Plan__c();
                                                lp1.Lease_Unit__c = luId;
                                                for(Date dt=luStartDateMap.get(luId);dt<=luEndDateMap.get(luId);dt=dt+1){
                                                    lp1.put('Commited__c',true);
                                                    lp1.put('Day_'+dt.day()+'__c',dt);
                                                    lp1.put('Status_'+dt.day()+'__c','Committed');
                                                    
                                                }
                                                lp1.Unit__c = unt.Id;
                                                lp1.put('Status__c', 'Vacant');
                                                lp1.Vacant__c = true;
                                                lp1.Start_Date__c = luStartDateMap.get(luId);
                                                lp1.End_Date__c = luEndDateMap.get(luId);
                                                if(luToLcMap.containsKey(luId)){
                                                    for(Lease_Charges__c lc:luToLcMap.get(luId)){
                                                        if(lp1.Start_Date__c>=lc.Start_Date__c && lp1.Start_Date__c<=lc.End_Date__c){
                                                            if(unt.NLA_SQF__c>0){
                                                                lp1.Monthly_Budget__c = lc.Base_Rent_Calculation__c/unt.NLA_SQF__c;
                                                            }
                                                        }
                                                    }
                                                }
                                                leasePlanList.add(lp1);
                                            }*/
                                        }
                                    }
                                }
                                leasePlanList.add(lp);
                                if(incMonth==12){
                                    incMonth = 1;
                                    incYear++;
                                }else{
                                    incMonth++;
                                }
                            }
                        }
                    }
                }
            }
            
            if(leasePlanList.size()>0){
                for(Lease_Plan__c lp:leasePlanList){
                    if(lp.Lease_Unit__c!=null){
                        for(Date dt=lp.Start_Date__c;dt<=lp.End_Date__c; dt=dt+1){
                            lp.put('Day_'+dt.day()+'__c',dt);
                        }
                    }
                }
                System.debug('leasePlanList.size()-->'+leasePlanList.size());
                insert leasePlanList;
                 System.debug('leasePlanList-->'+leasePlanList);
            }
        }
    }
    
}