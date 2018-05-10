trigger UpdateRentalSchedules_BillingTemplates on Lease_Charges__c (after insert,after update) {
    //added by myat oct-28 for CT(%)
    Map<Id,Decimal> mapUnitIdCT = new Map<Id,Decimal>();    
    Map<Id,Property__c> mapProperty = new Map<Id,Property__c>([SELECT Id, Name, Comm_Tax__c FROM Property__c]);
    if(Utility.firstRun){
        Utility.firstRun = false;
            Set<Id> unitIds = new Set<Id>();
            Set<Id> leaseUnitIds = new Set<Id>();
            Set<Id> leaseChargeIds = new Set<Id>();
            Map<Id,Id> leaseUnitToUnitMap = new Map<Id,Id>();
            Set<String> baseCharges = new Set<String>();
            Set<Id> applChgIds = new Set<Id>();
             Map<Id,Lease_Charges__c> currencyLC = new Map<Id,Lease_Charges__c>();
            for(Lease_Charges__c lc:Trigger.New){
                // [SJ - 21/8/2017 - Commented Lease Type check so that Rs can be generated for LOI types also]
                if(/*lc.Lease_Type__c!='LOI' &&*/ lc.Charge_Type__c!='Late Charge'  && lc.Charge_Type__c!='Invoice Discount'){
                    if((Trigger.isInsert && lc.Generate_Rent_Schedule__c) || (Trigger.isUpdate && lc.Generate_Rent_Schedule__c==true && (lc.Generate_Rent_Schedule__c!=Trigger.OldMap.get(lc.Id).Generate_Rent_Schedule__c || lc.End_Date__c!=Trigger.OldMap.get(lc.Id).End_Date__c))){
                        if(lc.Start_Date__c!=null && lc.End_Date__c!=null){
                            leaseUnitIds.add(lc.Lease_Unit__c);
                            leaseChargeIds.add(lc.Id);
                            if(lc.Charge__c!=null){
                                applChgIds.add(lc.Charge__c);
                            }
                        }
                    }
                }
                currencyLC.put(lc.Id,lc);
            }
            
            if(leaseUnitIds.size()>0){
                Map<Id,string> unitNameMap = new Map<Id,string>();
                Map<Id,string> propertyFillerMap = new Map<Id,string>();
                Map<Id,string> tenantFillerMap = new Map<Id,string>();
                Map<Id,Lease_Unit__c> leaseUnitMap = new Map<Id,Lease_Unit__c>();
                for(Lease_Unit__c lu:[Select Id,Unit__c,Unit__r.Name, Unit__r.Property__c, Unit__r.Property__r.Comm_Tax__c,Lease_Agreement_No__r.Property__c,Lease_Agreement_No__r.Tenant__c,Fit_Out_Date__c from Lease_Unit__c where id in:leaseUnitIds]){
                    leaseUnitMap.put(lu.Id,lu);
                    unitIds.add(lu.Unit__c);
                    leaseUnitToUnitMap.put(lu.Id,lu.Unit__c);
                    unitNameMap.put(lu.Unit__c,lu.unit__r.Name);                    
                    
                    if(lu.Lease_Agreement_No__r.Property__c!=null)
                        propertyFillerMap.put(lu.Id,lu.Lease_Agreement_No__r.Property__c);
                        
                    if(lu.Lease_Agreement_No__r.Tenant__c!=null)
                        tenantFillerMap.put(lu.Id,lu.Lease_Agreement_No__r.Tenant__c);
                                        
                    //added by myat oct-28 for CT(%)
                    Property__c pp = mapProperty.get(lu.Unit__r.Property__c);
                    if(pp <> Null)                    
                     mapUnitIdCT.put(lu.Unit__c,pp.Comm_Tax__c);
                    else
                     mapUnitIdCT.put(lu.Unit__c,5.00);
                }
                
                if(unitIds.size()>0){
                    List<Electric_Meter__c> elcMtrList = [Select id,Name,Meter_Type__c,Unit__c,Meter_No__c from Electric_Meter__c where Unit__c in:unitIds];
                    Map<Id,Map<string,List<Electric_Meter__c>>> unitToElcMtrMap = new Map<Id,Map<string,List<Electric_Meter__c>>>();
                    for(Electric_Meter__c em:elcMtrList){
                        Map<string,List<Electric_Meter__c>> tempMap = new Map<string,List<Electric_Meter__c>>();
                        List<Electric_Meter__c> tempList = new List<Electric_Meter__c>();
                        if(unitToElcMtrMap.containsKey(em.Unit__c)){
                            tempMap = unitToElcMtrMap.get(em.Unit__c);
                        }
                        if(tempMap.containsKey(em.Meter_Type__c)){
                            tempList.addAll(tempMap.get(em.Meter_Type__c));
                        }
                        tempList.add(em);
                        tempMap.put(em.Meter_Type__c,tempList);
                        unitToElcMtrMap.put(em.Unit__c,tempMap);
                    }

                    List<Rent_Schedules__c> rentSchList = [Select id,Unit__c,Status__c,Start_Date__c,End_Date__c from Rent_Schedules__c where Unit__c in:unitIds];
                    Map<Id,List<Rent_Schedules__c>> rentScheduleMap = new Map<Id,List<Rent_Schedules__c>>();
                    for(Rent_Schedules__c rs:rentSchList){
                        List<Rent_Schedules__c> tempList = new List<Rent_Schedules__c>();
                        if(rentScheduleMap.containsKey(rs.Unit__c)){
                            tempList.addAll(rentScheduleMap.get(rs.Unit__c));
                        }
                        tempList.add(rs);
                        rentScheduleMap.put(rs.Unit__c,tempList);
                    }
                    
                    if(rentScheduleMap.size()>0){
                        List<Rent_Schedules__c> delRentSchList = new List<Rent_Schedules__c>();
                        List<Rent_Schedules__c> updRentSchList = new List<Rent_Schedules__c>();
                        Set<Id> dupCheckForDelete = new Set<Id>();
                        Set<Id> dupCheckForUpdate = new Set<Id>();
                        for(Lease_Charges__c lc:Trigger.New){
                            if(lc.Start_Date__c!=null && lc.End_Date__c!=null){
                                Date endDate = lc.End_Date__c;
                                
                                if(leaseUnitToUnitMap.containsKey(lc.Lease_Unit__c) && rentScheduleMap.containsKey(leaseUnitToUnitMap.get(lc.Lease_Unit__c))){
                                    for(Rent_Schedules__c rs:rentScheduleMap.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c))){                                    
                                    //added by myat oct-28 for CT
                                    if(lc.Commercial_Tax_Apply__c)
                                     rs.Comm_Tax__c = mapUnitIdCT.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c));
                                    else
                                     rs.Comm_Tax__c = 0.00;
                                    
                                        if(rs.status__c=='In-Tenancy'){
                                            /*
                                                If Record is alread in Tenancy ; then we have to consider End Date Scenarios.
                                            */
                                        }else if(rs.status__c=='Vacancy'){
                                            if(rs.Start_Date__c>=lc.Start_Date__c && rs.End_Date__c<=endDate){
                                                if(!dupCheckForDelete.contains(rs.Id)){
                                                    delRentSchList.add(rs);
                                                    dupCheckForDelete.add(rs.Id);
                                                }
                                            }else if(rs.start_Date__c<lc.Start_Date__c && rs.End_Date__c>lc.Start_Date__c){
                                                rs.End_Date__c = lc.Start_Date__c - 1;
                                                if(!dupCheckForUpdate.contains(rs.Id)){
                                                    updRentSchList.add(rs);
                                                    dupCheckForUpdate.add(rs.Id);
                                                }
                                            }else if(rs.Start_Date__c>lc.Start_date__c && rs.Start_Date__c<endDate && rs.End_Date__c>endDate){
                                                rs.Start_Date__c = endDate + 1;
                                                if(!dupCheckForUpdate.contains(rs.Id)){
                                                    updRentSchList.add(rs);
                                                    dupCheckForUpdate.add(rs.Id);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if(updRentSchList.size()>0){
                            update updRentSchList;
                        }
                        
                        if(delRentSchList.size()>0){
                            delete delRentSchList;                    
                        }
                        
                    }
                    
                    List<RecordType> rcdTypeList = [Select id,Name from RecordType where sobjectType='Rent_Schedules__c'];
                    Map<String,Id> rentRcdMap = new Map<String,Id>();
                    for(RecordType rcd:rcdTypeList){
                        rentRcdMap.put(rcd.Name,rcd.Id);
                    }
                    
                    rcdTypeList = [Select id,Name from RecordType where sobjectType='Lease_Charges__c'];
                    Map<Id,string> chargeRcdMap = new Map<Id,String>();
                    for(RecordType rcd:rcdTypeList){
                        chargeRcdMap.put(rcd.Id,rcd.Name);
                    }
                    
                    Map<Id,List<Rent_Schedules__c>> lcToExistingLastRsMap = new Map<Id,List<Rent_Schedules__c>>();
                    for(Lease_Charges__c lc:[Select id,(Select id,Start_Date__c,End_Date__c from Rent_Schedules__r order by End_Date__c desc) from Lease_Charges__c where id in:leaseChargeIds and Charge_Method__c='Transaction Rate' and Lease_Unit__r.Unit__r.Charge_Method__c includes ('Daily Rate')]){ 
                        if(lc.Rent_Schedules__r.size()>0){
                            Date endDate;
                            List<Rent_Schedules__c> tempList = new List<Rent_Schedules__c>();
                            for(Rent_Schedules__c rs:lc.Rent_Schedules__r){
                                if(endDate==null || endDate==rs.End_Date__c){
                                    endDate = rs.End_Date__c;
                                    tempList.add(rs);
                                }
                            }
                            lcToExistingLastRsMap.put(lc.Id,tempList);
                        }
                    }
                    List<Rent_Schedules__c> existingRentSchList = new List<Rent_Schedules__c>();
                    List<Rent_Schedules__c> newRentSchList = new List<Rent_Schedules__c>();
                    for(Lease_Charges__c lc:Trigger.New){
                        // [SJ - 21/8/2017 - Commented Lease Type check so that Rs can be generated for LOI types also]
                        if(/*lc.Lease_Type__c!='LOI'  &&*/ lc.Charge_Type__c!='Late Charge' && lc.Charge_Type__c!='Invoice Discount'){
                            if((Trigger.isInsert && lc.Generate_Rent_Schedule__c) || (Trigger.isUpdate && lc.Generate_Rent_Schedule__c==true && (lc.Generate_Rent_Schedule__c!=Trigger.OldMap.get(lc.Id).Generate_Rent_Schedule__c || lc.End_Date__c!=Trigger.OldMap.get(lc.Id).End_Date__c))){
                                if(lc.Start_Date__c!=null && lc.End_Date__c!=null && leaseUnitToUnitMap.containsKey(lc.Lease_Unit__c)){
                                    Date endDate = lc.End_Date__c;                            
                                    Date lcStartDate = lc.Start_Date__c;
                                    
                                    if(Trigger.isUpdate && lc.End_Date__c!=Trigger.OldMap.get(lc.Id).End_Date__c && Trigger.OldMap.get(lc.Id).End_Date__c != null){
                                          lcStartDate = Trigger.OldMap.get(lc.Id).End_Date__c + 1;
                                          if(lc.Charge_Method__c=='Transaction Rate' && lcToExistingLastRsMap.containsKey(lc.Id)){
                                                List<Rent_Schedules__c> tempRsList = lcToExistingLastRsMap.get(lc.Id);
                                                if(tempRsList.size()>0){
                                                    if(tempRsList[0].End_Date__c.Month()==endDate.month() && tempRsList[0].End_Date__c.Year()==endDate.Year()){
                                                        for(Rent_Schedules__c rs:tempRsList){
                                                            if(lc.Billing_Terms__c=='Non-prorate' || (lc.Charge_Start_Day__c!=null && lc.Charge_Start_Day__c!='0')){
                                                                if(lc.Charge_Start_Day__c!=null && lc.Charge_Start_Day__c!='0'){
                                                                    
                                                                    if(rs.Start_Date__c.Day()!=1){
                                                                        if(rs.Start_Date__c.day()<Integer.valueOf(lc.Charge_Start_Day__c)){
                                                                            if(rs.Start_Date__c.Month()==rs.End_Date__c.Month()){
                                                                                Integer tmpYr,tmpMth;
                                                                                if(rs.End_Date__c.Month()==12){
                                                                                    tmpYr = rs.End_Date__c.Year()+1;
                                                                                    tmpMth = 1;
                                                                                }else{
                                                                                    tmpYr = rs.End_Date__c.Year();
                                                                                    tmpMth = rs.End_Date__c.Month()+1;
                                                                                }
                                                                                rs.End_Date__c = Date.NewInstance(tmpYr,tmpMth,rs.Start_Date__c.day()-1);
                                                                            }else{
                                                                                rs.End_Date__c = Date.NewInstance(rs.End_date__c.Year(),rs.End_date__c.Month(),rs.Start_Date__c.day()-1);
                                                                            }
                                                                            
                                                                        }else{
                                                                            if(rs.Start_Date__c.Month()==rs.End_Date__c.Month()){
                                                                                Integer tmpYr,tmpMth;
                                                                                if(rs.End_Date__c.Month()==12){
                                                                                    tmpYr = rs.End_Date__c.Year()+1;
                                                                                    tmpMth = 1;
                                                                                }else{
                                                                                    tmpYr = rs.End_Date__c.Year();
                                                                                    tmpMth = rs.End_Date__c.Month()+1;
                                                                                }
                                                                                rs.End_Date__c = Date.NewInstance(tmpYr,tmpMth,Integer.valueOf(lc.Charge_Start_Day__c)-1);
                                                                            }else{
                                                                                rs.End_Date__c = Date.NewInstance(rs.End_date__c.Year(),rs.End_date__c.Month(),Integer.valueOf(lc.Charge_Start_Day__c)-1);
                                                                            }
                                                                        }
                                                                    }else{
                                                                        if(Integer.valueOf(lc.Charge_Start_Day__c)!=1){
                                                                            rs.End_Date__c = Date.NewInstance(rs.Start_date__c.Year(),rs.Start_date__c.Month(),Integer.valueOf(lc.Charge_Start_Day__c)-1);
                                                                        }else{
                                                                            rs.End_Date__c = Date.NewInstance(rs.Start_date__c.Year(),rs.Start_date__c.Month(),Date.DaysInMonth(rs.Start_date__c.Year(),rs.Start_date__c.Month()));
                                                                        }
                                                                    }
                                                                    
                                                                    if(rs.End_Date__c > endDate){
                                                                        rs.End_Date__c  = endDate;
                                                                    }
                                                                }else{
                                                                    if(rs.Start_Date__c.Day()!=1){
                                                                        if(rs.Start_Date__c.Month()!=rs.End_Date__c.Month()){
                                                                            Date tempDate = Date.NewInstance(rs.End_Date__c.Year(),rs.End_Date__c.Month(),rs.Start_Date__c.day()-1);
                                                                            if(endDate > tempDate){
                                                                                rs.End_Date__c = tempDate;
                                                                            }else{
                                                                                rs.End_Date__c = endDate;
                                                                            }
                                                                        }else{
                                                                            rs.End_Date__c = endDate;
                                                                        }
                                                                    }else{
                                                                        rs.End_Date__c = endDate;
                                                                    }
                                                                }
                                                            }else{
                                                                rs.End_Date__c = endDate;
                                                            }
                                                            existingRentSchList.add(rs);
                                                        }
                                                    }else{                                                      
                                                        for(Rent_Schedules__c rs:tempRsList){
                                                            if(lc.Billing_Terms__c=='Non-prorate' || (lc.Charge_Start_Day__c!=null && lc.Charge_Start_Day__c!='0')){
                                                                if(lc.Charge_Start_Day__c!=null && lc.Charge_Start_Day__c!='0'){
                                                                    if(rs.Start_Date__c.Day()!=1){
                                                                        if(rs.Start_Date__c.day()<Integer.valueOf(lc.Charge_Start_Day__c)){
                                                                            if(rs.Start_Date__c.Month()==rs.End_Date__c.Month()){
                                                                                Integer tmpYr,tmpMth;
                                                                                if(rs.End_Date__c.Month()==12){
                                                                                    tmpYr = rs.End_Date__c.Year()+1;
                                                                                    tmpMth = 1;
                                                                                }else{
                                                                                    tmpYr = rs.End_Date__c.Year();
                                                                                    tmpMth = rs.End_Date__c.Month()+1;
                                                                                }
                                                                                rs.End_Date__c = Date.NewInstance(tmpYr,tmpMth,rs.Start_Date__c.day()-1);
                                                                            }else{
                                                                                rs.End_Date__c = Date.NewInstance(rs.End_date__c.Year(),rs.End_date__c.Month(),rs.Start_Date__c.day()-1);
                                                                            }
                                                                            
                                                                        }else{
                                                                            if(rs.Start_Date__c.Month()==rs.End_Date__c.Month()){
                                                                                Integer tmpYr,tmpMth;
                                                                                if(rs.End_Date__c.Month()==12){
                                                                                    tmpYr = rs.End_Date__c.Year()+1;
                                                                                    tmpMth = 1;
                                                                                }else{
                                                                                    tmpYr = rs.End_Date__c.Year();
                                                                                    tmpMth = rs.End_Date__c.Month()+1;
                                                                                }
                                                                                rs.End_Date__c = Date.NewInstance(tmpYr,tmpMth,Integer.valueOf(lc.Charge_Start_Day__c)-1);
                                                                            }else{
                                                                                rs.End_Date__c = Date.NewInstance(rs.End_date__c.Year(),rs.End_date__c.Month(),Integer.valueOf(lc.Charge_Start_Day__c)-1);
                                                                            }
                                                                        }
                                                                    }else{
                                                                        if(Integer.valueOf(lc.Charge_Start_Day__c)!=1){
                                                                            rs.End_Date__c = Date.NewInstance(rs.Start_date__c.Year(),rs.Start_date__c.Month(),Integer.valueOf(lc.Charge_Start_Day__c)-1);
                                                                        }else{
                                                                            rs.End_Date__c = Date.NewInstance(rs.Start_date__c.Year(),rs.Start_date__c.Month(),Date.DaysInMonth(rs.Start_date__c.Year(),rs.Start_date__c.Month()));
                                                                        }
                                                                    }
                                                                    
                                                                    if(rs.End_Date__c > endDate){
                                                                        rs.End_Date__c  = endDate;
                                                                    }
                                                                }else{
                                                                    if(rs.Start_Date__c.Day()!=1){
                                                                        if(rs.Start_Date__c.Month()!=rs.End_Date__c.Month()){
                                                                            rs.End_Date__c = Date.NewInstance(rs.End_Date__c.Year(),rs.End_Date__c.Month(),rs.Start_Date__c.day()-1);
                                                                        }else{
                                                                            Date tempDate = Date.NewInstance(endDate.Year(),endDate.Month(),rs.Start_Date__c.day()-1);
                                                                            if(endDate>tempDate){
                                                                                rs.End_Date__c = tempDate;
                                                                            }else{
                                                                                rs.End_Date__c = endDate;
                                                                            }
                                                                        }
                                                                    }else{
                                                                        rs.End_Date__c = Date.NewInstance(lcStartDate.Year(),lcStartDate.month(),Date.DaysInMonth(lcStartDate.year(),lcStartDate.month()));
                                                                    }
                                                                }
                                                            }else{
                                                                rs.End_Date__c = Date.NewInstance(rs.Start_Date__c.Year(),rs.Start_Date__c.month(),Date.DaysInMonth(rs.Start_Date__c.year(),rs.Start_Date__c.month()));
                                                            }
                                                            existingRentSchList.add(rs);
                                                        }
                                                    }
                                                    lcStartDate = tempRsList[0].End_Date__c + 1;
                                                }
                                          }
                                    }
                                    
                                    
                                    Integer lcStartDay = lcStartDate.day();
                                    Integer lcStartMonth = lcStartDate.Month();
                                    Integer lcStartYear = lcStartDate.Year();
                                    Integer lcEndDay = endDate.day();
                                    Integer lcEndMonth = endDate.Month();
                                    Integer lcEndYear = endDate.Year();
                                    
                                    
                                    
                                    Integer incMonth = lcStartMonth;
                                    Integer incYear = lcStartYear;
                                    
                                    if(lcStartDate>endDate){
                                        break;
                                    }
                                                                    
                                    List<Electric_Meter__c> emList = new List<Electric_Meter__c>();
                                    if(leaseUnitToUnitMap.containsKey(lc.Lease_Unit__c) && unitToElcMtrMap.containsKey(leaseUnitToUnitMap.get(lc.Lease_Unit__c)) && unitToElcMtrMap.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c)).containsKey(lc.Charge_Type__c)){
                                        emList = unitToElcMtrMap.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c)).get(lc.Charge_Type__c);
                                    }
                                    
                                    if((lc.Charge_Type__c=='Generator' || lc.Charge_Type__c=='Gov Meter' || lc.Charge_Type__c=='Sub Meter') && lc.Type__c=='Meter Units'){
                                        if(emList.size()>0){
                                            if(lc.Multiple_Rental_Schedule__c){
                                                if(lc.Billing_Terms__c=='Non-prorate' || (lc.Charge_Start_Day__c!=null && lc.Charge_Start_Day__c!='0')){
                                                    Integer quarterCount = 0;
                                                    Integer halfYearCount = 0;
                                                    Integer yearCount = 0;
                                                    Date prevDate = null;
                                                    date tempDate = lcStartDate;
                                                    
                                                    if(lc.Charge_Start_Day__c!=null && lc.Charge_Start_Day__c!='0'){
                                                        Integer chargeStartDay = Integer.valueOf(lc.Charge_Start_Day__c);
                                                        if(chargeStartDay != tempDate.day()){
                                                            Date nextStartDate = null;
                                                            for(Electric_Meter__c em:emList){
                                                                Rent_Schedules__c rs = new Rent_Schedules__c();
                                                                rs.Cap_Value__c = lc.GTO_Cap__c;
                                                                rs.Cap_Applicable__c = lc.Cap_Applicable__c;
                                                                rs.Unit__c = leaseUnitToUnitMap.get(lc.Lease_Unit__c);
                                                                if(propertyFillerMap.containsKey(lc.Lease_Unit__c)){
                                                                    rs.PropertyLU__c = propertyFillerMap.get(lc.Lease_Unit__c);
                                                                }
                                                                if(tenantFillerMap.containsKey(lc.Lease_Unit__c)){
                                                                    rs.TenantLU__c = tenantFillerMap.get(lc.Lease_Unit__c);
                                                                }
                                                                rs.Status__c = 'In-Tenancy';
                                                                rs.Lease_Charge__c = lc.Id;
                                                                rs.Expected_Amount__c = lc.Expected_Charge__c;
                                                                rs.Lease_Unit__c = lc.Lease_Unit__c;
                                                                rs.recordTypeId = rentRcdMap.get(chargeRcdMap.get(lc.RecordTypeId));
                                                                rs.Electric_Meter__c = em.Id;
                                                                rs.Electric_Meter_Number__c = em.Meter_No__c;
                                                                if(lc.Type__c=='Meter Units'){
                                                                    rs.Transaction_Status__c = 'Applicable - Not Imported';
                                                                }
                                                                
                                                                rs.Remarks__c = lc.Charge_Type__c;
                                                                
                                                                //added by myat oct-28 for CT
                                                                if(lc.Commercial_Tax_Apply__c)
                                                                 rs.Comm_Tax__c = mapUnitIdCT.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c));
                                                                else
                                                                 rs.Comm_Tax__c = 0.00;
                                                                
                                                                
                                                                rs.Start_Date__c = tempdate;
                                                                
                                                                Integer lastDayOfMonth = Date.DaysInMonth(tempDate.Year(),tempDate.month());
                                                                
                                                                if(chargeStartDay>(lastDayOfMonth+1)){
                                                                    rs.End_Date__c = Date.newInstance(tempDate.Year(),tempDate.month(),lastDayOfMonth);
                                                                }else{
                                                                    rs.End_Date__c = Date.newInstance(tempDate.Year(),tempDate.month(),chargeStartDay - 1);
                                                                }
                                                                
                                                                if(chargeStartDay < tempDate.day()){
                                                                    rs.End_Date__c = rs.End_Date__c.addMonths(1);
                                                                }
                                                                
                                                                if(rs.End_Date__c>endDate){
                                                                    rs.End_Date__c = endDate;
                                                                }
                                                                
                                                                nextStartDate = rs.End_Date__c+1;
                                                                
                                                                if(lc.Frequency__c=='Monthly'){
                                                                    if(lc.Billing_Days__c!=null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                        }
                                                                    }
                                                                }else if(lc.Frequency__c=='One Time'){
                                                                    rs.Billing_Date__c = lcStartDate;
                                                                    if(lc.Due_Month_Formula__c!=null && lc.Due_Month_Formula__c!='0'){
                                                                        Integer monthValue = lcStartDate.Month() + Integer.valueOf(lc.Due_Month_Formula__c);
                                                                        Integer yrValue = lcStartDate.Year();
                                                                        if(monthValue>12){
                                                                            monthValue = MonthValue - 12;
                                                                            yrValue = yrValue + 1;
                                                                        }
                                                                        if(lcStartDate.day()<Date.daysInMonth(yrValue,monthValue)){
                                                                            rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,lcStartDate.day());
                                                                        }else{
                                                                            rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,Date.daysInMonth(yrValue,monthValue));
                                                                        }                                                                    
                                                                    }
                                                                }else if(lc.Frequency__c=='Quarterly'){
                                                                    if(lc.Billing_Days__c!=null){
                                                                        if(prevDate==null){
                                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                                            if(tempList.size()>0){
                                                                                Helper(lc,rs,tempList[0]);
                                                                                prevDate = rs.Billing_Date__c;
                                                                                quarterCount++;
                                                                            }
                                                                        }else{
                                                                            rs.Billing_Date__c = prevDate;
                                                                            quarterCount++;
                                                                            if(quarterCount==(3*emList.size())){
                                                                                quarterCount = 0;
                                                                                prevDate = null;
                                                                            }
                                                                        }
                                                                    }
                                                                
                                                                }else if(lc.Frequency__c=='Half-Yearly'){
                                                                    if(lc.Billing_Days__c!=null){
                                                                        if(prevDate==null){
                                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                                            if(tempList.size()>0){
                                                                                Helper(lc,rs,tempList[0]);
                                                                                prevDate = rs.Billing_Date__c;
                                                                                quarterCount++;
                                                                            }
                                                                        }else{
                                                                            rs.Billing_Date__c = prevDate;
                                                                            quarterCount++;
                                                                            if(quarterCount==6*emList.size()){
                                                                                quarterCount = 0;
                                                                                prevDate = null;
                                                                            }
                                                                        }
                                                                    }
                                                                }else if(lc.Frequency__c=='Yearly'){
                                                                    if(lc.Billing_Days__c!=null){
                                                                        if(prevDate==null){
                                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                                            if(tempList.size()>0){
                                                                                Helper(lc,rs,tempList[0]);
                                                                                prevDate = rs.Billing_Date__c;
                                                                                quarterCount++;
                                                                            }
                                                                        }else{
                                                                            rs.Billing_Date__c = prevDate;
                                                                            quarterCount++;
                                                                            if(quarterCount==12*emList.size()){
                                                                                quarterCount = 0;
                                                                                prevDate = null;
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                newRentSchList.add(rs);
                                                            }
                                                            
                                                            tempDate = nextStartDate;
                                                        }
                                                    }
                                                    
                                                    while(tempDate <= lc.End_Date__c){
                                                        for(Electric_Meter__c em:emList){
                                                            Rent_Schedules__c rs = new Rent_Schedules__c();
                                                            rs.Cap_Value__c = lc.GTO_Cap__c;
                                                            rs.Cap_Applicable__c = lc.Cap_Applicable__c;
                                                            rs.Unit__c = leaseUnitToUnitMap.get(lc.Lease_Unit__c);
                                                            if(propertyFillerMap.containsKey(lc.Lease_Unit__c)){
                                                                rs.PropertyLU__c = propertyFillerMap.get(lc.Lease_Unit__c);
                                                            }
                                                            if(tenantFillerMap.containsKey(lc.Lease_Unit__c)){
                                                                rs.TenantLU__c = tenantFillerMap.get(lc.Lease_Unit__c);
                                                            }
                                                            rs.Status__c = 'In-Tenancy';
                                                            rs.Lease_Charge__c = lc.Id;
                                                            rs.Expected_Amount__c = lc.Expected_Charge__c;
                                                            rs.Lease_Unit__c = lc.Lease_Unit__c;
                                                            rs.recordTypeId = rentRcdMap.get(chargeRcdMap.get(lc.RecordTypeId));
                                                            rs.Electric_Meter__c = em.Id;
                                                            rs.Electric_Meter_Number__c = em.Meter_No__c;
                                                            if(lc.Type__c=='Meter Units'){
                                                                rs.Transaction_Status__c = 'Applicable - Not Imported';
                                                            }
                                                            
                                                            rs.Remarks__c = lc.Charge_Type__c;
                                                            
                                                            //added by myat oct-28 for CT
                                                            if(lc.Commercial_Tax_Apply__c)
                                                             rs.Comm_Tax__c = mapUnitIdCT.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c));
                                                            else
                                                             rs.Comm_Tax__c = 0.00;
                                                            
                                                            
                                                            rs.Start_Date__c = tempdate;                                            
                                                                
                                                            tempDate = tempDate.addMonths(1) - 1;
                                                            if(tempDate>endDate){
                                                                rs.End_Date__c = lc.End_Date__c;
                                                            }else{
                                                                rs.End_Date__c = tempDate;
                                                            }
                                                            
                                                            tempDate = tempDate + 1;
                                                            
                                                            if(lc.Frequency__c=='Monthly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    List<string> tempList = lc.Billing_Days__c.split(';');
                                                                    if(tempList.size()>0){
                                                                        Helper(lc,rs,tempList[0]);
                                                                    }
                                                                }
                                                            }else if(lc.Frequency__c=='One Time'){
                                                                rs.Billing_Date__c = lcStartDate;
                                                                if(lc.Due_Month_Formula__c!=null && lc.Due_Month_Formula__c!='0'){
                                                                    Integer monthValue = lcStartDate.Month() + Integer.valueOf(lc.Due_Month_Formula__c);
                                                                    Integer yrValue = lcStartDate.Year();
                                                                    if(monthValue>12){
                                                                        monthValue = MonthValue - 12;
                                                                        yrValue = yrValue + 1;
                                                                    }
                                                                    if(lcStartDate.day()<Date.daysInMonth(yrValue,monthValue)){
                                                                        rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,lcStartDate.day());
                                                                    }else{
                                                                        rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,Date.daysInMonth(yrValue,monthValue));
                                                                    }                                                                    
                                                                }
                                                            }else if(lc.Frequency__c=='Quarterly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    if(prevDate==null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                            prevDate = rs.Billing_Date__c;
                                                                            quarterCount++;
                                                                        }
                                                                    }else{
                                                                        rs.Billing_Date__c = prevDate;
                                                                        quarterCount++;
                                                                        if(quarterCount==(3*emList.size())){
                                                                            quarterCount = 0;
                                                                            prevDate = null;
                                                                        }
                                                                    }
                                                                }
                                                            
                                                            }else if(lc.Frequency__c=='Half-Yearly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    if(prevDate==null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                            prevDate = rs.Billing_Date__c;
                                                                            quarterCount++;
                                                                        }
                                                                    }else{
                                                                        rs.Billing_Date__c = prevDate;
                                                                        quarterCount++;
                                                                        if(quarterCount==6*emList.size()){
                                                                            quarterCount = 0;
                                                                            prevDate = null;
                                                                        }
                                                                    }
                                                                }
                                                            }else if(lc.Frequency__c=='Yearly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    if(prevDate==null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                            prevDate = rs.Billing_Date__c;
                                                                            quarterCount++;
                                                                        }
                                                                    }else{
                                                                        rs.Billing_Date__c = prevDate;
                                                                        quarterCount++;
                                                                        if(quarterCount==12*emList.size()){
                                                                            quarterCount = 0;
                                                                            prevDate = null;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            
                                                            newRentSchList.add(rs);
                                                        }
                                                        if(incMonth==12){
                                                            incMonth = 1;
                                                            incYear++;
                                                        }else{
                                                            incMonth++;
                                                        }
                                                    }
                                                }else{
                                                    Integer quarterCount = 0;
                                                    Integer halfYearCount = 0;
                                                    Integer yearCount = 0;
                                                    Date prevDate = null;
                                                    While((IncMonth <= lcendMonth && IncYear <= lcendYear) || (incMonth>lcendMonth && incYear<lcendYear)){
                                                        for(Electric_Meter__c em:emList){
                                                            Rent_Schedules__c rs = new Rent_Schedules__c();
                                                            rs.Cap_Value__c = lc.GTO_Cap__c;
                                                            rs.Cap_Applicable__c = lc.Cap_Applicable__c;
                                                            rs.Unit__c = leaseUnitToUnitMap.get(lc.Lease_Unit__c);
                                                            if(propertyFillerMap.containsKey(lc.Lease_Unit__c)){
                                                                rs.PropertyLU__c = propertyFillerMap.get(lc.Lease_Unit__c);
                                                            }
                                                            if(tenantFillerMap.containsKey(lc.Lease_Unit__c)){
                                                                rs.TenantLU__c = tenantFillerMap.get(lc.Lease_Unit__c);
                                                            }
                                                            rs.Status__c = 'In-Tenancy';
                                                            rs.Lease_Charge__c = lc.Id;
                                                            rs.Expected_Amount__c = lc.Expected_Charge__c;
                                                            rs.Lease_Unit__c = lc.Lease_Unit__c;
                                                            rs.recordTypeId = rentRcdMap.get(chargeRcdMap.get(lc.RecordTypeId));
                                                            rs.Electric_Meter__c = em.Id;
                                                            rs.Electric_Meter_Number__c = em.Meter_No__c;
                                                            
                                                            if(lc.Type__c=='Meter Units'){
                                                                rs.Transaction_Status__c = 'Applicable - Not Imported';
                                                            }
                                                            
                                                            rs.Remarks__c = lc.Charge_Type__c;
                                                            
                                                            //added by myat oct-28 for CT
                                                            if(lc.Commercial_Tax_Apply__c)
                                                             rs.Comm_Tax__c = mapUnitIdCT.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c));
                                                            else
                                                             rs.Comm_Tax__c = 0.00;
                                                            
                                                            
                                                            if(incMonth==lcstartMonth && incYear==lcstartYear){
                                                                rs.Start_Date__c = date.NewInstance(incYear,incMonth,lcStartday);
                                                            }else{
                                                                rs.Start_Date__c = date.NewInstance(incYear,incMonth,1);
                                                            }
                                                            
                                                            if(incMonth==lcendMonth && incYear==lcendYear){
                                                                rs.End_Date__c = date.NewInstance(incYear,incMonth,lcEndday);
                                                            }else{
                                                                rs.End_Date__c = date.NewInstance(incYear,incMonth,Date.DaysInMonth(incYear,incMonth));
                                                            }
                                                            
                                                            if(lc.Frequency__c=='Monthly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    List<string> tempList = lc.Billing_Days__c.split(';');
                                                                    if(tempList.size()>0){
                                                                        Helper(lc,rs,tempList[0]);
                                                                    }
                                                                }
                                                            }else if(lc.Frequency__c=='One Time'){
                                                                rs.Billing_Date__c = lcStartDate;
                                                                if(lc.Due_Month_Formula__c!=null && lc.Due_Month_Formula__c!='0'){
                                                                    Integer monthValue = lcStartDate.Month() + Integer.valueOf(lc.Due_Month_Formula__c);
                                                                    Integer yrValue = lcStartDate.Year();
                                                                    if(monthValue>12){
                                                                        monthValue = MonthValue - 12;
                                                                        yrValue = yrValue + 1;
                                                                    }
                                                                    if(lcStartDate.day()<Date.daysInMonth(yrValue,monthValue)){
                                                                        rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,lcStartDate.day());
                                                                    }else{
                                                                        rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,Date.daysInMonth(yrValue,monthValue));
                                                                    }                                                                    
                                                                }
                                                            }else if(lc.Frequency__c=='Quarterly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    if(prevDate==null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                            prevDate = rs.Billing_Date__c;
                                                                            quarterCount++;
                                                                        }
                                                                    }else{
                                                                        rs.Billing_Date__c = prevDate;
                                                                        quarterCount++;
                                                                        if(quarterCount==(3*emList.size())){
                                                                            quarterCount = 0;
                                                                            prevDate = null;
                                                                        }
                                                                    }
                                                                }
                                                            
                                                            }else if(lc.Frequency__c=='Half-Yearly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    if(prevDate==null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                            prevDate = rs.Billing_Date__c;
                                                                            quarterCount++;
                                                                        }
                                                                    }else{
                                                                        rs.Billing_Date__c = prevDate;
                                                                        quarterCount++;
                                                                        if(quarterCount==6*emList.size()){
                                                                            quarterCount = 0;
                                                                            prevDate = null;
                                                                        }
                                                                    }
                                                                }
                                                            }else if(lc.Frequency__c=='Yearly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    if(prevDate==null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                            prevDate = rs.Billing_Date__c;
                                                                            quarterCount++;
                                                                        }
                                                                    }else{
                                                                        rs.Billing_Date__c = prevDate;
                                                                        quarterCount++;
                                                                        if(quarterCount==12*emList.size()){
                                                                            quarterCount = 0;
                                                                            prevDate = null;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            
                                                            newRentSchList.add(rs);
                                                        }
                                                        if(incMonth==12){
                                                            incMonth = 1;
                                                            incYear++;
                                                        }else{
                                                            incMonth++;
                                                        }
                                                    }
                                                }
                                            }else{
                                                if(lc.Billing_Terms__c=='Non-prorate' || (lc.Charge_Start_Day__c!=null && lc.Charge_Start_Day__c!='0')){
                                                    Integer quarterCount = 0;
                                                    Integer halfYearCount = 0;
                                                    Integer yearCount = 0;
                                                    Date prevDate = null;
                                                    if(leaseUnitToUnitMap.containsKey(lc.Lease_Unit__c) && unitToElcMtrMap.containsKey(leaseUnitToUnitMap.get(lc.Lease_Unit__c))){
                                                        date tempDate = lcStartDate;
                                                        
                                                        if(lc.Charge_Start_Day__c!=null && lc.Charge_Start_Day__c!='0'){
                                                            Integer chargeStartDay = Integer.valueOf(lc.Charge_Start_Day__c);
                                                            if(chargeStartDay != tempDate.day()){
                                                                Rent_Schedules__c rs = new Rent_Schedules__c();
                                                                rs.Cap_Value__c = lc.GTO_Cap__c;
                                                                rs.Cap_Applicable__c = lc.Cap_Applicable__c;
                                                                rs.Unit__c = leaseUnitToUnitMap.get(lc.Lease_Unit__c);
                                                                if(propertyFillerMap.containsKey(lc.Lease_Unit__c)){
                                                                    rs.PropertyLU__c = propertyFillerMap.get(lc.Lease_Unit__c);
                                                                }
                                                                if(tenantFillerMap.containsKey(lc.Lease_Unit__c)){
                                                                    rs.TenantLU__c = tenantFillerMap.get(lc.Lease_Unit__c);
                                                                }
                                                                
                                                                //added by myat oct-28 for CT
                                                                if(lc.Commercial_Tax_Apply__c)
                                                                 rs.Comm_Tax__c = mapUnitIdCT.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c));
                                                                else
                                                                 rs.Comm_Tax__c = 0.00;
                                                                
                                                                rs.Status__c = 'In-Tenancy';
                                                                rs.Lease_Charge__c = lc.Id;
                                                                rs.Expected_Amount__c = lc.Expected_Charge__c;
                                                                rs.Lease_Unit__c = lc.Lease_Unit__c;
                                                                rs.recordTypeId = rentRcdMap.get(chargeRcdMap.get(lc.RecordTypeId));
                                                                
                                                                if(lc.Type__c=='Meter Units'){
                                                                    rs.Transaction_Status__c = 'Applicable - Not Imported';
                                                                }
                                                                
                                                                rs.Remarks__c = lc.Charge_Type__c;
                                                                
                                                                rs.Start_Date__c = tempdate;                                            
                                                                
                                                                Integer lastDayOfMonth = Date.DaysInMonth(tempDate.Year(),tempDate.month());
                                                                
                                                                if(chargeStartDay>(lastDayOfMonth+1)){
                                                                    rs.End_Date__c = Date.newInstance(tempDate.Year(),tempDate.month(),lastDayOfMonth);
                                                                }else{
                                                                    rs.End_Date__c = Date.newInstance(tempDate.Year(),tempDate.month(),chargeStartDay - 1);
                                                                }
                                                                
                                                                if(chargeStartDay < tempDate.day()){
                                                                    rs.End_Date__c = rs.End_Date__c.addMonths(1);
                                                                }
                                                                
                                                                if(rs.End_Date__c>endDate){
                                                                    rs.End_Date__c = endDate;
                                                                }
                                                                
                                                                tempDate = rs.End_Date__c + 1;
                                                                
                                                                if(lc.Frequency__c=='Monthly'){
                                                                    if(lc.Billing_Days__c!=null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                        }
                                                                    }
                                                                }else if(lc.Frequency__c=='One Time'){
                                                                    rs.Billing_Date__c = lcStartDate;
                                                                    if(lc.Due_Month_Formula__c!=null && lc.Due_Month_Formula__c!='0'){
                                                                        Integer monthValue = lcStartDate.Month() + Integer.valueOf(lc.Due_Month_Formula__c);
                                                                        Integer yrValue = lcStartDate.Year();
                                                                        if(monthValue>12){
                                                                            monthValue = MonthValue - 12;
                                                                            yrValue = yrValue + 1;
                                                                        }
                                                                        if(lcStartDate.day()<Date.daysInMonth(yrValue,monthValue)){
                                                                            rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,lcStartDate.day());
                                                                        }else{
                                                                            rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,Date.daysInMonth(yrValue,monthValue));
                                                                        }                                                                    
                                                                    }
                                                                }else if(lc.Frequency__c=='Quarterly'){
                                                                    if(lc.Billing_Days__c!=null){
                                                                        if(prevDate==null){
                                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                                            if(tempList.size()>0){
                                                                                Helper(lc,rs,tempList[0]);
                                                                                prevDate = rs.Billing_Date__c;
                                                                                quarterCount++;
                                                                            }
                                                                        }else{
                                                                            rs.Billing_Date__c = prevDate;
                                                                            quarterCount++;
                                                                            if(quarterCount==(3)){
                                                                                quarterCount = 0;
                                                                                prevDate = null;
                                                                            }
                                                                        }
                                                                    }
                                                                
                                                                }else if(lc.Frequency__c=='Half-Yearly'){
                                                                    if(lc.Billing_Days__c!=null){
                                                                        if(prevDate==null){
                                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                                            if(tempList.size()>0){
                                                                                Helper(lc,rs,tempList[0]);
                                                                                prevDate = rs.Billing_Date__c;
                                                                                quarterCount++;
                                                                            }
                                                                        }else{
                                                                            rs.Billing_Date__c = prevDate;
                                                                            quarterCount++;
                                                                            if(quarterCount==6){
                                                                                quarterCount = 0;
                                                                                prevDate = null;
                                                                            }
                                                                        }
                                                                    }
                                                                }else if(lc.Frequency__c=='Yearly'){
                                                                    if(lc.Billing_Days__c!=null){
                                                                        if(prevDate==null){
                                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                                            if(tempList.size()>0){
                                                                                Helper(lc,rs,tempList[0]);
                                                                                prevDate = rs.Billing_Date__c;
                                                                                quarterCount++;
                                                                            }
                                                                        }else{
                                                                            rs.Billing_Date__c = prevDate;
                                                                            quarterCount++;
                                                                            if(quarterCount==12){
                                                                                quarterCount = 0;
                                                                                prevDate = null;
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                rs.Electric_Meter_Number__c = '';
                                                                for(Electric_Meter__c em:emList){
                                                                    rs.Electric_Meter_Number__c += em.Meter_No__c+';';
                                                                }
                                                                if(rs.Electric_Meter_Number__c!=null && rs.Electric_Meter_Number__c.trim().length()>0){
                                                                    rs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c.substring(0,rs.Electric_Meter_Number__c.trim().length()-1);
                                                                    newRentSchList.add(rs);
                                                                }
                                                            
                                                            }
                                                        }
                                                        
                                                        
                                                        while(tempDate <= lc.End_Date__c){
                                                            Rent_Schedules__c rs = new Rent_Schedules__c();
                                                            rs.Cap_Value__c = lc.GTO_Cap__c;
                                                            rs.Cap_Applicable__c = lc.Cap_Applicable__c;
                                                            rs.Unit__c = leaseUnitToUnitMap.get(lc.Lease_Unit__c);
                                                            if(propertyFillerMap.containsKey(lc.Lease_Unit__c)){
                                                                rs.PropertyLU__c = propertyFillerMap.get(lc.Lease_Unit__c);
                                                            }
                                                            if(tenantFillerMap.containsKey(lc.Lease_Unit__c)){
                                                                rs.TenantLU__c = tenantFillerMap.get(lc.Lease_Unit__c);
                                                            }
                                                            
                                                            //added by myat oct-28 for CT
                                                            if(lc.Commercial_Tax_Apply__c)
                                                             rs.Comm_Tax__c = mapUnitIdCT.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c));
                                                            else
                                                             rs.Comm_Tax__c = 0.00;
                                                            
                                                            rs.Status__c = 'In-Tenancy';
                                                            rs.Lease_Charge__c = lc.Id;
                                                            rs.Expected_Amount__c = lc.Expected_Charge__c;
                                                            rs.Lease_Unit__c = lc.Lease_Unit__c;
                                                            rs.recordTypeId = rentRcdMap.get(chargeRcdMap.get(lc.RecordTypeId));
                                                            
                                                            if(lc.Type__c=='Meter Units'){
                                                                rs.Transaction_Status__c = 'Applicable - Not Imported';
                                                            }
                                                            
                                                            rs.Remarks__c = lc.Charge_Type__c;
                                                            
                                                            rs.Start_Date__c = tempdate;                                            
                                                                
                                                            tempDate = tempDate.addMonths(1) - 1;
                                                            if(tempDate>endDate){
                                                                rs.End_Date__c = lc.End_Date__c;
                                                            }else{
                                                                rs.End_Date__c = tempDate;
                                                            }
                                                            
                                                            tempDate = tempDate + 1;
                                                            
                                                            if(lc.Frequency__c=='Monthly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    List<string> tempList = lc.Billing_Days__c.split(';');
                                                                    if(tempList.size()>0){
                                                                        Helper(lc,rs,tempList[0]);
                                                                    }
                                                                }
                                                            }else if(lc.Frequency__c=='One Time'){
                                                                rs.Billing_Date__c = lcStartDate;
                                                                if(lc.Due_Month_Formula__c!=null && lc.Due_Month_Formula__c!='0'){
                                                                    Integer monthValue = lcStartDate.Month() + Integer.valueOf(lc.Due_Month_Formula__c);
                                                                    Integer yrValue = lcStartDate.Year();
                                                                    if(monthValue>12){
                                                                        monthValue = MonthValue - 12;
                                                                        yrValue = yrValue + 1;
                                                                    }
                                                                    if(lcStartDate.day()<Date.daysInMonth(yrValue,monthValue)){
                                                                        rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,lcStartDate.day());
                                                                    }else{
                                                                        rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,Date.daysInMonth(yrValue,monthValue));
                                                                    }                                                                    
                                                                }
                                                            }else if(lc.Frequency__c=='Quarterly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    if(prevDate==null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                            prevDate = rs.Billing_Date__c;
                                                                            quarterCount++;
                                                                        }
                                                                    }else{
                                                                        rs.Billing_Date__c = prevDate;
                                                                        quarterCount++;
                                                                        if(quarterCount==(3)){
                                                                            quarterCount = 0;
                                                                            prevDate = null;
                                                                        }
                                                                    }
                                                                }
                                                            
                                                            }else if(lc.Frequency__c=='Half-Yearly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    if(prevDate==null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                            prevDate = rs.Billing_Date__c;
                                                                            quarterCount++;
                                                                        }
                                                                    }else{
                                                                        rs.Billing_Date__c = prevDate;
                                                                        quarterCount++;
                                                                        if(quarterCount==6){
                                                                            quarterCount = 0;
                                                                            prevDate = null;
                                                                        }
                                                                    }
                                                                }
                                                            }else if(lc.Frequency__c=='Yearly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    if(prevDate==null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                            prevDate = rs.Billing_Date__c;
                                                                            quarterCount++;
                                                                        }
                                                                    }else{
                                                                        rs.Billing_Date__c = prevDate;
                                                                        quarterCount++;
                                                                        if(quarterCount==12){
                                                                            quarterCount = 0;
                                                                            prevDate = null;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            
                                                            rs.Electric_Meter_Number__c = '';
                                                            for(Electric_Meter__c em:emList){
                                                                rs.Electric_Meter_Number__c += em.Meter_No__c+';';
                                                            }
                                                            if(rs.Electric_Meter_Number__c!=null && rs.Electric_Meter_Number__c.trim().length()>0){
                                                                rs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c.substring(0,rs.Electric_Meter_Number__c.trim().length()-1);
                                                                newRentSchList.add(rs);
                                                            }
                                                                
                                                            if(incMonth==12){
                                                                incMonth = 1;
                                                                incYear++;
                                                            }else{
                                                                incMonth++;
                                                            }
                                                        }
                                                    }
                                                }else{                                                
                                                    Integer quarterCount = 0;
                                                    Integer halfYearCount = 0;
                                                    Integer yearCount = 0;
                                                    Date prevDate = null;
                                                    if(leaseUnitToUnitMap.containsKey(lc.Lease_Unit__c) && unitToElcMtrMap.containsKey(leaseUnitToUnitMap.get(lc.Lease_Unit__c))){
                                                        While((IncMonth <= lcendMonth && IncYear <= lcendYear) || (incMonth>lcendMonth && incYear<lcendYear)){
                                                            Rent_Schedules__c rs = new Rent_Schedules__c();
                                                            rs.Cap_Value__c = lc.GTO_Cap__c;
                                                            rs.Cap_Applicable__c = lc.Cap_Applicable__c;
                                                            rs.Unit__c = leaseUnitToUnitMap.get(lc.Lease_Unit__c);
                                                            if(propertyFillerMap.containsKey(lc.Lease_Unit__c)){
                                                                rs.PropertyLU__c = propertyFillerMap.get(lc.Lease_Unit__c);
                                                            }
                                                            if(tenantFillerMap.containsKey(lc.Lease_Unit__c)){
                                                                rs.TenantLU__c = tenantFillerMap.get(lc.Lease_Unit__c);
                                                            }
                                                                        
                                                            //added by myat oct-28 for CT
                                                            if(lc.Commercial_Tax_Apply__c)
                                                             rs.Comm_Tax__c = mapUnitIdCT.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c));
                                                            else
                                                             rs.Comm_Tax__c = 0.00;
                                                            
                                                            rs.Status__c = 'In-Tenancy';
                                                            rs.Lease_Charge__c = lc.Id;
                                                            rs.Expected_Amount__c = lc.Expected_Charge__c;
                                                            rs.Lease_Unit__c = lc.Lease_Unit__c;
                                                            rs.recordTypeId = rentRcdMap.get(chargeRcdMap.get(lc.RecordTypeId));
                                                            
                                                            if(lc.Type__c=='Meter Units'){
                                                                rs.Transaction_Status__c = 'Applicable - Not Imported';
                                                            }
                                                            
                                                            rs.Remarks__c = lc.Charge_Type__c;
                                                            
                                                            if(incMonth==lcstartMonth && incYear==lcstartYear){
                                                                rs.Start_Date__c = date.NewInstance(incYear,incMonth,lcStartday);
                                                            }else{
                                                                rs.Start_Date__c = date.NewInstance(incYear,incMonth,1);
                                                            }
                                                            
                                                            if(incMonth==lcendMonth && incYear==lcendYear){
                                                                rs.End_Date__c = date.NewInstance(incYear,incMonth,lcEndday);
                                                            }else{
                                                                rs.End_Date__c = date.NewInstance(incYear,incMonth,Date.DaysInMonth(incYear,incMonth));
                                                            }
                                                            
                                                            if(lc.Frequency__c=='Monthly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    List<string> tempList = lc.Billing_Days__c.split(';');
                                                                    if(tempList.size()>0){
                                                                        Helper(lc,rs,tempList[0]);
                                                                    }
                                                                }
                                                            }else if(lc.Frequency__c=='One Time'){
                                                                rs.Billing_Date__c = lcStartDate;
                                                                if(lc.Due_Month_Formula__c!=null && lc.Due_Month_Formula__c!='0'){
                                                                    Integer monthValue = lcStartDate.Month() + Integer.valueOf(lc.Due_Month_Formula__c);
                                                                    Integer yrValue = lcStartDate.Year();
                                                                    if(monthValue>12){
                                                                        monthValue = MonthValue - 12;
                                                                        yrValue = yrValue + 1;
                                                                    }
                                                                    if(lcStartDate.day()<Date.daysInMonth(yrValue,monthValue)){
                                                                        rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,lcStartDate.day());
                                                                    }else{
                                                                        rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,Date.daysInMonth(yrValue,monthValue));
                                                                    }                                                                    
                                                                }
                                                            }else if(lc.Frequency__c=='Quarterly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    if(prevDate==null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                            prevDate = rs.Billing_Date__c;
                                                                            quarterCount++;
                                                                        }
                                                                    }else{
                                                                        rs.Billing_Date__c = prevDate;
                                                                        quarterCount++;
                                                                        if(quarterCount==(3)){
                                                                            quarterCount = 0;
                                                                            prevDate = null;
                                                                        }
                                                                    }
                                                                }
                                                            
                                                            }else if(lc.Frequency__c=='Half-Yearly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    if(prevDate==null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                            prevDate = rs.Billing_Date__c;
                                                                            quarterCount++;
                                                                        }
                                                                    }else{
                                                                        rs.Billing_Date__c = prevDate;
                                                                        quarterCount++;
                                                                        if(quarterCount==6){
                                                                            quarterCount = 0;
                                                                            prevDate = null;
                                                                        }
                                                                    }
                                                                }
                                                            }else if(lc.Frequency__c=='Yearly'){
                                                                if(lc.Billing_Days__c!=null){
                                                                    if(prevDate==null){
                                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                                        if(tempList.size()>0){
                                                                            Helper(lc,rs,tempList[0]);
                                                                            prevDate = rs.Billing_Date__c;
                                                                            quarterCount++;
                                                                        }
                                                                    }else{
                                                                        rs.Billing_Date__c = prevDate;
                                                                        quarterCount++;
                                                                        if(quarterCount==12){
                                                                            quarterCount = 0;
                                                                            prevDate = null;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            
                                                            rs.Electric_Meter_Number__c = '';
                                                            for(Electric_Meter__c em:emList){
                                                                rs.Electric_Meter_Number__c += em.Meter_No__c+';';
                                                            }
                                                            if(rs.Electric_Meter_Number__c!=null && rs.Electric_Meter_Number__c.trim().length()>0){
                                                                rs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c.substring(0,rs.Electric_Meter_Number__c.trim().length()-1);
                                                                newRentSchList.add(rs);
                                                            }
                                                                
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
                                        }else{
                                            lc.addError('Please create meter records under Unit.');
                                        }
                                    }else{
                                        Integer quarterCount = 0;
                                        Integer halfYearCount = 0;
                                        Integer yearCount = 0;
                                        Date prevDate = null;
                                        if(lc.Billing_Terms__c=='Non-prorate' || (lc.Charge_Start_Day__c!=null && lc.Charge_Start_Day__c!='0')){
                                            date tempDate = lcStartDate;
                                            
                                            if(lc.Charge_Start_Day__c!=null && lc.Charge_Start_Day__c!='0'){
                                                Integer chargeStartDay = Integer.valueOf(lc.Charge_Start_Day__c);
                                                if(chargeStartDay != tempDate.day()){
                                                    Rent_Schedules__c rs = new Rent_Schedules__c();
                                                    rs.Cap_Value__c = lc.GTO_Cap__c;
                                                    rs.Cap_Applicable__c = lc.Cap_Applicable__c;
                                                    rs.Unit__c = leaseUnitToUnitMap.get(lc.Lease_Unit__c);
                                                    if(propertyFillerMap.containsKey(lc.Lease_Unit__c)){
                                                        rs.PropertyLU__c = propertyFillerMap.get(lc.Lease_Unit__c);
                                                    }
                                                    if(tenantFillerMap.containsKey(lc.Lease_Unit__c)){
                                                        rs.TenantLU__c = tenantFillerMap.get(lc.Lease_Unit__c);
                                                    }
                                                                        
                                                    //added by myat oct-28 for CT
                                                    if(lc.Commercial_Tax_Apply__c)
                                                     rs.Comm_Tax__c = mapUnitIdCT.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c));
                                                    else
                                                     rs.Comm_Tax__c = 0.00;
                                                    
                                                    rs.Status__c = 'In-Tenancy';
                                                    rs.Lease_Charge__c = lc.Id;
                                                    rs.Expected_Amount__c = lc.Expected_Charge__c;
                                                    rs.Lease_Unit__c = lc.Lease_Unit__c;
                                                    rs.recordTypeId = rentRcdMap.get(chargeRcdMap.get(lc.RecordTypeId));
                                                    
                                                    if(lc.Type__c=='Meter Units' || lc.Charge_Type__c=='GTO Rent'){
                                                        rs.Transaction_Status__c = 'Applicable - Not Imported';
                                                    }
                                                    
                                                    rs.Remarks__c = lc.Charge_Type__c;
                                                                        
                                                    rs.Start_Date__c = tempdate;                                            
                                                    
                                                    Integer lastDayOfMonth = Date.DaysInMonth(tempDate.Year(),tempDate.month());
                                                    
                                                    if(chargeStartDay>(lastDayOfMonth+1)){
                                                        rs.End_Date__c = Date.newInstance(tempDate.Year(),tempDate.month(),lastDayOfMonth);
                                                    }else{
                                                        rs.End_Date__c = Date.newInstance(tempDate.Year(),tempDate.month(),chargeStartDay - 1);
                                                    }
                                                    
                                                    if(chargeStartDay < tempDate.day()){
                                                        rs.End_Date__c = rs.End_Date__c.addMonths(1);
                                                    }
                                                    
                                                    if(rs.End_Date__c>endDate){
                                                        rs.End_Date__c = endDate;
                                                    }
                                                    
                                                    tempDate = rs.End_Date__c + 1;
                                                                                                        
                                                    
                                                    if(lc.Frequency__c=='Monthly'){
                                                        if(lc.Billing_Days__c!=null){
                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                            if(tempList.size()>0){
                                                                Helper(lc,rs,tempList[0]);
                                                            }
                                                        }
                                                    }else if(lc.Frequency__c=='One Time'){
                                                        rs.Billing_Date__c = lcStartDate;
                                                        if(lc.Due_Month_Formula__c!=null && lc.Due_Month_Formula__c!='0'){
                                                            Integer monthValue = lcStartDate.Month() + Integer.valueOf(lc.Due_Month_Formula__c);
                                                            Integer yrValue = lcStartDate.Year();
                                                            if(monthValue>12){
                                                                monthValue = MonthValue - 12;
                                                                yrValue = yrValue + 1;
                                                            }
                                                            if(lcStartDate.day()<Date.daysInMonth(yrValue,monthValue)){
                                                                rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,lcStartDate.day());
                                                            }else{
                                                                rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,Date.daysInMonth(yrValue,monthValue));
                                                            }                                                                    
                                                        }
                                                    }else if(lc.Frequency__c=='Quarterly'){
                                                        if(lc.Billing_Days__c!=null){
                                                            if(prevDate==null){
                                                                List<string> tempList = lc.Billing_Days__c.split(';');
                                                                if(tempList.size()>0){
                                                                    Helper(lc,rs,tempList[0]);
                                                                    prevDate = rs.Billing_Date__c;
                                                                    quarterCount++;
                                                                }
                                                            }else{
                                                                rs.Billing_Date__c = prevDate;
                                                                quarterCount++;
                                                                if(quarterCount==3){
                                                                    quarterCount = 0;
                                                                    prevDate = null;
                                                                }
                                                            }
                                                        }
                                                    
                                                    }else if(lc.Frequency__c=='Half-Yearly'){
                                                        if(lc.Billing_Days__c!=null){
                                                            if(prevDate==null){
                                                                List<string> tempList = lc.Billing_Days__c.split(';');
                                                                if(tempList.size()>0){
                                                                    Helper(lc,rs,tempList[0]);
                                                                    prevDate = rs.Billing_Date__c;
                                                                    quarterCount++;
                                                                }
                                                            }else{
                                                                rs.Billing_Date__c = prevDate;
                                                                quarterCount++;
                                                                if(quarterCount==6){
                                                                    quarterCount = 0;
                                                                    prevDate = null;
                                                                }
                                                            }
                                                        }
                                                    }else if(lc.Frequency__c=='Yearly'){
                                                        if(lc.Billing_Days__c!=null){
                                                            if(prevDate==null){
                                                                List<string> tempList = lc.Billing_Days__c.split(';');
                                                                if(tempList.size()>0){
                                                                    Helper(lc,rs,tempList[0]);
                                                                    prevDate = rs.Billing_Date__c;
                                                                    quarterCount++;
                                                                }
                                                            }else{
                                                                rs.Billing_Date__c = prevDate;
                                                                quarterCount++;
                                                                if(quarterCount==12){
                                                                    quarterCount = 0;
                                                                    prevDate = null;
                                                                }
                                                            }
                                                        }
                                                    }
                                                    newRentSchList.add(rs);
                                                }
                                            }
                                            while(tempDate <= lc.End_Date__c){
                                                Rent_Schedules__c rs = new Rent_Schedules__c();
                                                rs.Cap_Value__c = lc.GTO_Cap__c;
                                                rs.Cap_Applicable__c = lc.Cap_Applicable__c;
                                                rs.Unit__c = leaseUnitToUnitMap.get(lc.Lease_Unit__c);
                                                if(propertyFillerMap.containsKey(lc.Lease_Unit__c)){
                                                    rs.PropertyLU__c = propertyFillerMap.get(lc.Lease_Unit__c);
                                                }
                                                if(tenantFillerMap.containsKey(lc.Lease_Unit__c)){
                                                    rs.TenantLU__c = tenantFillerMap.get(lc.Lease_Unit__c);
                                                }
                                                                    
                                                //added by myat oct-28 for CT
                                                if(lc.Commercial_Tax_Apply__c)
                                                 rs.Comm_Tax__c = mapUnitIdCT.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c));
                                                else
                                                 rs.Comm_Tax__c = 0.00;
                                                
                                                rs.Status__c = 'In-Tenancy';
                                                rs.Lease_Charge__c = lc.Id;
                                                rs.Expected_Amount__c = lc.Expected_Charge__c;
                                                rs.Lease_Unit__c = lc.Lease_Unit__c;
                                                rs.recordTypeId = rentRcdMap.get(chargeRcdMap.get(lc.RecordTypeId));
                                                
                                                if(lc.Type__c=='Meter Units' || lc.Charge_Type__c=='GTO Rent'){
                                                    rs.Transaction_Status__c = 'Applicable - Not Imported';
                                                }
                                                
                                                rs.Remarks__c = lc.Charge_Type__c;
                                                                    
                                                rs.Start_Date__c = tempdate;                                            
                                            
                                                tempDate = tempDate.addMonths(1) - 1;
                                                if(tempDate>endDate){
                                                    rs.End_Date__c = endDate;
                                                }else{
                                                    rs.End_Date__c = tempDate;
                                                }
                                                
                                                tempDate = tempDate + 1;
                                                
                                                if(lc.Frequency__c=='Monthly'){
                                                    if(lc.Billing_Days__c!=null){
                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                        if(tempList.size()>0){
                                                            Helper(lc,rs,tempList[0]);
                                                        }
                                                    }
                                                }else if(lc.Frequency__c=='One Time'){
                                                    rs.Billing_Date__c = lcStartDate;
                                                    if(lc.Due_Month_Formula__c!=null && lc.Due_Month_Formula__c!='0'){
                                                        Integer monthValue = lcStartDate.Month() + Integer.valueOf(lc.Due_Month_Formula__c);
                                                        Integer yrValue = lcStartDate.Year();
                                                        if(monthValue>12){
                                                            monthValue = MonthValue - 12;
                                                            yrValue = yrValue + 1;
                                                        }
                                                        if(lcStartDate.day()<Date.daysInMonth(yrValue,monthValue)){
                                                            rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,lcStartDate.day());
                                                        }else{
                                                            rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,Date.daysInMonth(yrValue,monthValue));
                                                        }                                                                    
                                                    }
                                                }else if(lc.Frequency__c=='Quarterly'){
                                                    if(lc.Billing_Days__c!=null){
                                                        if(prevDate==null){
                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                            if(tempList.size()>0){
                                                                Helper(lc,rs,tempList[0]);
                                                                prevDate = rs.Billing_Date__c;
                                                                quarterCount++;
                                                            }
                                                        }else{
                                                            rs.Billing_Date__c = prevDate;
                                                            quarterCount++;
                                                            if(quarterCount==3){
                                                                quarterCount = 0;
                                                                prevDate = null;
                                                            }
                                                        }
                                                    }
                                                
                                                }else if(lc.Frequency__c=='Half-Yearly'){
                                                    if(lc.Billing_Days__c!=null){
                                                        if(prevDate==null){
                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                            if(tempList.size()>0){
                                                                Helper(lc,rs,tempList[0]);
                                                                prevDate = rs.Billing_Date__c;
                                                                quarterCount++;
                                                            }
                                                        }else{
                                                            rs.Billing_Date__c = prevDate;
                                                            quarterCount++;
                                                            if(quarterCount==6){
                                                                quarterCount = 0;
                                                                prevDate = null;
                                                            }
                                                        }
                                                    }
                                                }else if(lc.Frequency__c=='Yearly'){
                                                    if(lc.Billing_Days__c!=null){
                                                        if(prevDate==null){
                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                            if(tempList.size()>0){
                                                                Helper(lc,rs,tempList[0]);
                                                                prevDate = rs.Billing_Date__c;
                                                                quarterCount++;
                                                            }
                                                        }else{
                                                            rs.Billing_Date__c = prevDate;
                                                            quarterCount++;
                                                            if(quarterCount==12){
                                                                quarterCount = 0;
                                                                prevDate = null;
                                                            }
                                                        }
                                                    }
                                                }
                                                newRentSchList.add(rs);
                                            }
                                        }else{
                                            While((IncMonth <= lcendMonth && IncYear <= lcendYear) || (incMonth>lcendMonth && incYear<lcendYear)){
                                                Rent_Schedules__c rs = new Rent_Schedules__c();
                                                rs.Cap_Value__c = lc.GTO_Cap__c;
                                                rs.Cap_Applicable__c = lc.Cap_Applicable__c;
                                                rs.Unit__c = leaseUnitToUnitMap.get(lc.Lease_Unit__c);
                                                if(propertyFillerMap.containsKey(lc.Lease_Unit__c)){
                                                    rs.PropertyLU__c = propertyFillerMap.get(lc.Lease_Unit__c);
                                                }
                                                if(tenantFillerMap.containsKey(lc.Lease_Unit__c)){
                                                    rs.TenantLU__c = tenantFillerMap.get(lc.Lease_Unit__c);
                                                }
                                                
                                                //added by myat oct-28 for CT
                                                if(lc.Commercial_Tax_Apply__c)
                                                 rs.Comm_Tax__c = mapUnitIdCT.get(leaseUnitToUnitMap.get(lc.Lease_Unit__c));
                                                else
                                                 rs.Comm_Tax__c = 0.00;
                                                
                                                rs.Status__c = 'In-Tenancy';
                                                rs.Lease_Charge__c = lc.Id;
                                                rs.Expected_Amount__c = lc.Expected_Charge__c;
                                                rs.Lease_Unit__c = lc.Lease_Unit__c;
                                                rs.recordTypeId = rentRcdMap.get(chargeRcdMap.get(lc.RecordTypeId));
                                                
                                                if(lc.Type__c=='Meter Units' || lc.Charge_Type__c=='GTO Rent'){
                                                    rs.Transaction_Status__c = 'Applicable - Not Imported';
                                                }
                                                
                                                rs.Remarks__c = lc.Charge_Type__c;
                                                                    
                                                if(incMonth==lcstartMonth && incYear==lcstartYear){
                                                    rs.Start_Date__c = date.NewInstance(incYear,incMonth,lcStartday);
                                                }else{
                                                    rs.Start_Date__c = date.NewInstance(incYear,incMonth,1);
                                                }
                                                
                                                if(incMonth==lcendMonth && incYear==lcendYear){
                                                    rs.End_Date__c = date.NewInstance(incYear,incMonth,lcEndday);
                                                }else{
                                                    rs.End_Date__c = date.NewInstance(incYear,incMonth,Date.DaysInMonth(incYear,incMonth));
                                                }
                                                
                                                if(lc.Frequency__c=='Monthly'){
                                                    if(lc.Billing_Days__c!=null){
                                                        List<string> tempList = lc.Billing_Days__c.split(';');
                                                        if(tempList.size()>0){
                                                            Helper(lc,rs,tempList[0]);
                                                        }
                                                    }
                                                }else if(lc.Frequency__c=='One Time'){
                                                    rs.Billing_Date__c = lcStartDate;
                                                    if(lc.Due_Month_Formula__c!=null && lc.Due_Month_Formula__c!='0'){
                                                        Integer monthValue = lcStartDate.Month() + Integer.valueOf(lc.Due_Month_Formula__c);
                                                        Integer yrValue = lcStartDate.Year();
                                                        if(monthValue>12){
                                                            monthValue = MonthValue - 12;
                                                            yrValue = yrValue + 1;
                                                        }
                                                        if(lcStartDate.day()<Date.daysInMonth(yrValue,monthValue)){
                                                            rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,lcStartDate.day());
                                                        }else{
                                                            rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,Date.daysInMonth(yrValue,monthValue));
                                                        }                                                                    
                                                    }
                                                }else if(lc.Frequency__c=='Quarterly'){
                                                    if(lc.Billing_Days__c!=null){
                                                        if(prevDate==null){
                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                            if(tempList.size()>0){
                                                                Helper(lc,rs,tempList[0]);
                                                                prevDate = rs.Billing_Date__c;
                                                                quarterCount++;
                                                            }
                                                        }else{
                                                            rs.Billing_Date__c = prevDate;
                                                            quarterCount++;
                                                            if(quarterCount==3){
                                                                quarterCount = 0;
                                                                prevDate = null;
                                                            }
                                                        }
                                                    }
                                                
                                                }else if(lc.Frequency__c=='Half-Yearly'){
                                                    if(lc.Billing_Days__c!=null){
                                                        if(prevDate==null){
                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                            if(tempList.size()>0){
                                                                Helper(lc,rs,tempList[0]);
                                                                prevDate = rs.Billing_Date__c;
                                                                quarterCount++;
                                                            }
                                                        }else{
                                                            rs.Billing_Date__c = prevDate;
                                                            quarterCount++;
                                                            if(quarterCount==6){
                                                                quarterCount = 0;
                                                                prevDate = null;
                                                            }
                                                        }
                                                    }
                                                }else if(lc.Frequency__c=='Yearly'){
                                                    if(lc.Billing_Days__c!=null){
                                                        if(prevDate==null){
                                                            List<string> tempList = lc.Billing_Days__c.split(';');
                                                            if(tempList.size()>0){
                                                                Helper(lc,rs,tempList[0]);
                                                                prevDate = rs.Billing_Date__c;
                                                                quarterCount++;
                                                            }
                                                        }else{
                                                            rs.Billing_Date__c = prevDate;
                                                            quarterCount++;
                                                            if(quarterCount==12){
                                                                quarterCount = 0;
                                                                prevDate = null;
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                newRentSchList.add(rs);
                                                
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
                        }
                    }
                    
                    
                    if(existingRentSchList.size()>0){
                        update existingRentSchList;
                    }
    
                    for (Rent_Schedules__c rs:newRentSchList ){
                        if(currencyLC.containsKey(rs.Lease_Charge__c) && currencyLC.get(rs.Lease_Charge__c).Currency_Code__c!=null){
                            rs.Currency_Code__c = currencyLC.get(rs.Lease_Charge__c).Currency_Code__c;
                        }
                        
                        if (rs.Start_Date__c   == rs.Lease_Charge__r.Start_Date__c) {
                            rs.first_RentalSchedule__c = true; 
                        }else if(rs.End_Date__c   == rs.Lease_Charge__r.End_Date__c){
                            rs.last_RentalSchedule__c = true;
                        }   //Assign Start Date and End Dates Flags.  
                    }    
                                                   
                    if(newRentSchList.size()>0){
                        insert newRentSchList;
                        
                        Set<Id> lcIds = new Set<Id>();
                        Set<Id> newRsIds = new Set<Id>();
                        for(Rent_Schedules__c rs:newRentSchList){
                            lcIds.add(rs.Lease_Charge__c);
                            newRsIds.add(rs.Id);
                        }
                        
                        Map<Id,Lease_Charges__c> leaseChgMap = new Map<Id,Lease_Charges__c>();
                        List<Lease_Charges__c> discountChgList = new List<Lease_Charges__c>();
                        Set<Id> luIds = new Set<Id>();
                        Set<string> baseChgTypes = new Set<string>();
                        for(Lease_Charges__c lc:[Select id,Lease_Unit__c,Parent_Lease_Charge__c,Charge_Rate__c,Type__c,Charge_Type__c,Base_Charge_Type__c from Lease_Charges__c where id in:lcIds]){
                            if(lc.Charge_Type__c=='Discount'){
                                discountChgList.add(lc);
                            }else{
                                if(lc.Base_Charge_Type__c!=null && lc.Charge_Type__c!='Advance Rental' && lc.Charge_Type__c!='Rent'){
                                    baseChgTypes.add(lc.Base_Charge_Type__c);
                                    leaseChgMap.put(lc.Id,lc);
                                    luIds.add(lc.Lease_Unit__c);
                                }
                            }
                        }
                        if(leaseChgMap.size()>0){
                            Map<Id,Map<string,List<Rent_Schedules__c>>> luToBaseChgRentScheduleMap = new Map<Id,Map<string,List<Rent_Schedules__c>>>();
                            List<Lease_Charges__c> baseLeaseChargeList = [Select id,Lease_Unit__c,Charge_Type__c,(Select id,Start_Date__c,End_Date__c,Amount__c,Amount_Local__c,Amount_Foreign__c,Calculated_Amount__c,Calculated_Amount_Foreign__c,Calculated_Amount_Local__c from Rent_Schedules__r where Billing_Type__c=null or Billing_Type__c='Rent') from Lease_Charges__c where Lease_Unit__c in:luIds and Charge_Type__c in:baseChgTypes];
                            
                            for(Lease_Charges__c blc:baseLeaseChargeList){
                                Map<string,List<Rent_Schedules__c>> tempMap = new Map<string,List<Rent_Schedules__c>>();
                                if(luToBaseChgRentScheduleMap.containsKey(blc.Lease_Unit__c)){
                                    tempMap = luToBaseChgRentScheduleMap.get(blc.Lease_Unit__c);
                                }
                                List<Rent_Schedules__c> tempList = new List<Rent_Schedules__c>();
                                
                                if(tempMap.containsKey(blc.Charge_Type__c)){
                                    tempList.addAll(tempMap.get(blc.Charge_Type__c));
                                }
                                tempList.addAll(blc.Rent_Schedules__r);
                                tempMap.put(blc.Charge_Type__c,tempList);
                                luToBaseChgRentScheduleMap.put(blc.Lease_Unit__c,tempMap);
                                
                            }
                            
                            Map<Id,Rent_Schedules__c> baseRsMap = new Map<Id,Rent_Schedules__c>();
                            for(Rent_Schedules__c rs:newRentSchList){
                                if(leaseChgMap.containsKey(rs.Lease_Charge__c) && leaseChgMap.get(rs.Lease_Charge__c).Base_Charge_Type__c!=null && luToBaseChgRentScheduleMap.containsKey(leaseChgMap.get(rs.Lease_Charge__c).Lease_Unit__c) && luToBaseChgRentScheduleMap.get(leaseChgMap.get(rs.Lease_Charge__c).Lease_Unit__c).containsKey(leaseChgMap.get(rs.Lease_Charge__c).Base_Charge_Type__c)){
                                    for(Rent_Schedules__c baseRs:luToBaseChgRentScheduleMap.get(leaseChgMap.get(rs.Lease_Charge__c).Lease_Unit__c).get(leaseChgMap.get(rs.Lease_Charge__c).Base_Charge_Type__c)){
                                        baseRsMap.put(baseRs.Id,baseRs);
                                        if(rs.Start_Date__c>=baseRs.Start_Date__c && rs.Start_Date__c<=baseRs.End_Date__c){
                                            rs.Base_Rent_RS_1__c = baseRs.Id;
                                        }
                                        if(rs.End_Date__c>=baseRs.Start_Date__c && rs.End_Date__c<=baseRs.End_Date__c){
                                            if(baseRs.Id!=rs.Base_Rent_RS_1__c){
                                                rs.Base_Rent_RS_2__c = baseRs.Id;
                                            }
                                        }
                                    }
                                    
                                    rs.Converted_Base_Rent__c = RSTrigger_Helper.doBRcalculation( rs, rs.Base_Rent_RS_1__c, rs.Base_Rent_RS_2__c ,baseRsMap);
                                    /*if(rs.Base_Rent_RS_1__c!=null && rs.Base_Rent_RS_2__c==null){
                                        decimal proRateDays = 1.00*(rs.Start_Date__c.daysBetween(rs.End_Date__c)+1)/Date.DaysInMonth(rs.Start_Date__c.Year(),rs.Start_Date__c.Month());
                                        proRateDays = proRateDays.setScale(4);
                                        if(rs.Currency_Code__c!=label.Default_Currency){
                                            if(baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Foreign__c!=null){
                                                rs.Converted_Base_Rent__c = proRateDays*baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Foreign__c;
                                            }
                                        }else{
                                            if(baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Local__c!=null){
                                                rs.Converted_Base_Rent__c = proRateDays*baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Local__c;
                                            }
                                        }
                                    }else if(rs.Base_Rent_RS_1__c!=null && rs.Base_Rent_RS_2__c!=null){
                                        decimal amount1 = 0;
                                        decimal amount2 = 0;
                                        decimal proRateDays1 = 1.00*(rs.Start_Date__c.daysBetween(baseRsMap.get(rs.Base_Rent_RS_1__c).End_Date__c) + 1)/Date.DaysInMonth(rs.Start_Date__c.year(),rs.Start_Date__c.Month());
                                        proRateDays1 = proRateDays1.setScale(4);
                                        decimal proRateDays2 = 1.00*(baseRsMap.get(rs.Base_Rent_RS_2__c).Start_Date__c.DaysBetween(rs.End_Date__c)+1)/Date.DaysInMonth(rs.Start_Date__c.year(),rs.Start_Date__c.Month());
                                        proRateDays2 = proRateDays2.setScale(4);
                                        if(rs.Currency_Code__c!=label.Default_Currency){
                                            if(baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Foreign__c!=null){
                                                amount1 = proRateDays1*baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Foreign__c;
                                            }
                                            if(baseRsMap.get(rs.Base_Rent_RS_2__c).Amount_Foreign__c!=null){
                                                amount2 = proRateDays2*baseRsMap.get(rs.Base_Rent_RS_2__c).Amount_Foreign__c;
                                            }
                                        }else{
                                            if(baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Local__c!=null){
                                                amount1 = proRateDays1*baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Local__c;
                                            }
                                            
                                            if(baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Local__c!=null){
                                                amount2 = proRateDays2*baseRsMap.get(rs.Base_Rent_RS_2__c).Amount_Local__c;
                                            }
                                        }
                                        rs.Converted_Base_Rent__c = amount1 + amount2;
                                    }*/
                                }
                            }
                            update newRentSchList;
                        }
                        
                        if(discountChgList.size()>0){
                            newRentSchList = [Select id,Lease_Charge__c,Start_Date__c,Amount__c,Calc_No_of_Days_Pro_Rated__c from Rent_Schedules__c where id in:newRsIds];
                            lcIds = new Set<Id>();
                            Map<Id,Lease_Charges__c> lcMap = new Map<Id,Lease_Charges__c>();
                            for(Lease_Charges__c lc:discountChgList){
                                lcMap.put(lc.Id,lc);
                                if(lc.Parent_Lease_Charge__c!=null){
                                    lcIds.add(lc.Parent_Lease_Charge__c);
                                }
                            }
                            
                            if(lcIds.size()>0){
                                Map<Id,List<Rent_Schedules__c>> lcToRSMap = new Map<Id,List<Rent_Schedules__c>>();
                                for(Rent_Schedules__c rs:[Select id,Amount__c,Start_Date__c,End_Date__c,Lease_Charge__c from Rent_Schedules__c where Lease_Charge__c in:lcIds and Charge_Type__c!='Discount']){
                                    List<Rent_Schedules__c> tempList = new List<Rent_Schedules__c>();
                                    if(lcToRSMap.containsKey(rs.Lease_Charge__c)){
                                        tempList.addAll(lcToRSMap.get(rs.Lease_Charge__c));
                                    }
                                    tempList.add(rs);
                                    lcToRSMap.put(rs.Lease_Charge__c,tempList);
                                }
                                
                                if(lcToRSMap.size()>0){
                                    for(Rent_Schedules__c childRs:newRentSchList){
                                        if(lcMap.containsKey(childRs.Lease_Charge__c) && lcMap.get(childRs.Lease_Charge__c).Parent_Lease_Charge__c!=null && lcToRSMap.containsKey(lcMap.get(childRs.Lease_Charge__c).Parent_Lease_Charge__c)){
                                             for(Rent_Schedules__c parentRs:lcToRSMap.get(lcMap.get(childRs.Lease_Charge__c).Parent_Lease_Charge__c)){
                                                 if(childRs.Start_Date__c>=parentRs.Start_Date__c && childRs.Start_Date__c<=parentRs.End_Date__c){
                                                     childRs.Parent_Rent_Schedule__c = parentRs.Id;
                                                     if(lcMap.get(childRs.Lease_Charge__c).Type__c=='Fixed'){
                                                         if(lcMap.get(childRs.Lease_Charge__c).Charge_Rate__c!=null){
                                                             childRs.Amount__c = -(lcMap.get(childRs.Lease_Charge__c).Charge_Rate__c);
                                                             childRs.Amount__c = childRs.Amount__c.setScale(2);
                                                         }
                                                     }else if(lcMap.get(childRs.Lease_Charge__c).Type__c=='By Percent'){
                                                         if(lcMap.get(childRs.Lease_Charge__c).Charge_Rate__c!=null && parentRs.Amount__c!=null){
                                                             childRs.Amount__c = -(parentRs.Amount__c*lcMap.get(childRs.Lease_Charge__c).Charge_Rate__c/100);
                                                             childRs.Amount__c = childRs.Amount__c.setScale(2);
                                                         }
                                                     }
                                                     break;
                                                 }
                                             }
                                        }
                                    }
                                    update newRentSchList;
                                }
                            }
                        }
                    }
                }
            }
    }
    
    public void Helper(Lease_Charges__c lc,Rent_Schedules__c rs,string tempVar){
        Integer dayValue = Integer.valueOf(tempVar);
        /* AMS94** Changed By AS 
         * Date 19th Jan 2018
         * Changed To Start Date 
         * billing due date is wrong when start and end date is cross month 
         * as current logic is taking rent schedule end date to calculate billing date
        */
        Integer stYr = rs.Start_Date__c.Year();    
        Integer stMth = rs.Start_Date__c.Month();
        Integer lastDay = Date.daysInMonth(styr,stMth);
        if(lc.Due_Month_Formula__c!=null && lc.Due_Month_Formula__c!='0'){
            Integer monthValue = stMth + Integer.valueOf(lc.Due_Month_Formula__c);
            Integer yrValue = stYr;
            if(monthValue>12){
                monthValue = MonthValue - 12;
                yrValue = yrValue + 1;
            }
            lastDay = Date.daysInMonth(yrValue,monthValue);
            if(lastDay<dayValue){
                rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,lastDay);
            }else{
                rs.Billing_Date__c = date.NewInstance(yrValue,monthValue,dayValue);
            }
            
        }else{
            if(lastDay<dayValue){
                rs.Billing_Date__c = date.NewInstance(styr,stMth,lastDay);
            }else{
                rs.Billing_Date__c = date.NewInstance(styr,stMth,dayValue);
            }
            if(rs.End_Date__c < rs.Billing_Date__c || rs.Start_Date__c > rs.Billing_date__c){
                rs.Billing_Date__c = rs.End_Date__c;
            }
        }
    }
}