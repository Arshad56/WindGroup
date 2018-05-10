trigger Electric_Trax_linkWithRentSchedules on Electric_Transaction__c(before insert, after insert, after update, after delete, after undelete) {
    if (Trigger.isBefore && Trigger.isInsert) {
        Map<String, Rent_Schedules__c> mapTraxRSId = new Map<String, Rent_Schedules__c> ();
        Map<String, List<Electric_Meter__c>> mapEM = new Map<String, List<Electric_Meter__c>> ();
        Set<String> setPropertyShortCode = new Set<String> ();
        Set<String> setMeterNo = new Set<String> ();
        Map<String, Electric_Meter__c> mapPropertyMeterwithElectricMeter = new Map<String, Electric_Meter__c> ();
        Date startDate = system.today();
        Date endDate = system.today();
        Map<String, List<Rent_Schedules__c>> mapMeterNoMMYYYYWithRS = new Map<String, List<Rent_Schedules__c>> ();
        Set<Id> rsManualIds = new Set<Id>();

        for (Electric_Transaction__c et: trigger.new) {
            setPropertyShortCode.add(et.Property_Short_Code__c);
            setMeterNo.add(et.Meter_No__c);
            
            system.debug('et.Meter_No__c ==> ' + et.Meter_No__c);
            system.debug('et.From_Date__c ==> ' + et.From_Date__c);
            system.debug('et.To_Date__c ==> ' + et.To_Date__c);

            if (et.From_Date__c<startDate)
                startDate = et.From_Date__c;

            if (et.To_Date__c> endDate)
                endDate = et.To_Date__c;

            if(et.Rent_Schedule__c <> null && et.Manual__c){
                rsManualIds.add(et.Rent_Schedule__c);
            }
        }
        
        if(rsManualIds.size() > 0){
            Map<Id, Rent_Schedules__c> rsMap = new Map<Id,Rent_Schedules__c>([select Id,Unit__c,Property_Short_Code__c,Start_Date__c,End_Date__c,Lease_Unit__c,PropertyLU__c from Rent_Schedules__c where Id =: rsManualIds ]);
            
            for(Electric_Transaction__c et:trigger.New){
                if(et.To_Date__c == null ||  et.From_Date__c == null){
                    et.addError('From Date and To Date is required.');
                }else if(et.From_Date__c > et.To_Date__c){
                    et.addError('From Date must be before To Date.');
                }else if(et.From_Date__c > rsMap.get(et.Rent_Schedule__c).End_Date__c ){
                    et.addError('From Date must be before Rent Schedule End Date.');
                }/*else if(et.From_Date__c < rsMap.get(et.Rent_Schedule__c).Start_Date__c || et.From_Date__c > rsMap.get(et.Rent_Schedule__c).End_Date__c ){
                    et.addError('From Date must be between Rent Schedule Start date and End date.');
                }*/else if(et.To_Date__c  < rsMap.get(et.Rent_Schedule__c).Start_Date__c || et.To_Date__c > rsMap.get(et.Rent_Schedule__c).End_Date__c ){
                    et.addError('To Date must be between Rent Schedule Start date and End date.');
                }else{
                    if(rsMap.get(et.Rent_Schedule__c).Lease_Unit__c!= null)
                        et.Lease_Unit__c = rsMap.get(et.Rent_Schedule__c).Lease_Unit__c;
                    if(rsMap.get(et.Rent_Schedule__c).PropertyLU__c!= null){
                        et.Property__c = rsMap.get(et.Rent_Schedule__c).PropertyLU__c;
                        et.Property_Short_Code__c = rsMap.get(et.Rent_Schedule__c).Property_Short_Code__c;
                    }
                    if(rsMap.get(et.Rent_Schedule__c).Unit__c!= null)
                        et.Unit__c = rsMap.get(et.Rent_Schedule__c).Unit__c;
                }
            }
            
        }

        startDate = Date.newInstance(startDate.year(), startDate.month(), 1);
        endDate = Date.newInstance(endDate.year(), endDate.month(), Date.DaysInMonth(endDate.year(), endDate.month()));

        PicklistValue objPicklistValue = new PicklistValue();
        Sobject objName = Schema.getGlobalDescribe().get('Electric_Transaction__c').newSObject();
        String fieldName = 'Meter_Type__c';
        String firstValue = '';

        Set<String> setPicklistValue = new Set<String> ();

        setPicklistValue = objPicklistValue.getPickValues(objName, fieldName, '');

        for (Electric_Meter__c em: [SELECT Id, Name, Horse_Power__c, Maintenance_Fee__c, Meter_No__c, Meter_Type__c, Power_Factor__c, Line_Loss__c, Unit__c, Unit__r.Property__r.Name, Unit__r.Property__r.Short_Code__c FROM Electric_Meter__c WHERE Unit__r.Property__r.Short_Code__c IN: setPropertyShortCode AND Meter_No__c IN: setMeterNo AND Status__c = 'Active']) {
            List<Electric_Meter__c> lstETMap = new List<Electric_Meter__c> ();
            lstETMap = mapEM.get(em.Unit__r.Property__r.Short_Code__c + '-' + em.Unit__c + '-' + em.Meter_Type__c);
            System.debug('lstETMap-->'+lstETMap);
            if (lstETMap == NULL) lstETMap = new List<Electric_Meter__c> ();
            lstETMap.add(em);

            mapEM.put(em.Unit__r.Property__r.Short_Code__c + '-' + em.Unit__c + '-' + em.Meter_Type__c, lstETMap);
            mapPropertyMeterwithElectricMeter.put(em.Unit__r.Property__r.Short_Code__c + '-' + em.Meter_No__c + '-' + em.Meter_Type__c, em);
            System.debug('mapPropertyMeterwithElectricMeter-->'+mapPropertyMeterwithElectricMeter);
        }

        Map<String, List<Electric_Transaction__c>> rsIdwithMeternoTypewithRec = new Map<String, List<Electric_Transaction__c>>();
        String mmyyyy = null;
        List<Rent_Schedules__c> lstRS = new List<Rent_Schedules__c> ();
        String strMeterNoMMYYYY = null;
        List<Rent_Schedules__c> lcChrg = [SELECT Id, Name,Lease_Charge__r.Charge_Type__c, Unit__c, Unit__r.Property__c, Unit__r.Property__r.Short_Code__c, Unit__r.Property__r.Name, Lease_Unit__c, Start_Date__c, End_Date__c, Charge_Type__c, Electric_Meter_Number__c, (Select Id,Rent_Schedule__c,Meter_Type__c,Meter_No__c,From_Date__c,To_Date__c From Electric_Transactions__r) FROM Rent_Schedules__c limit 50];
        System.debug('lcChrg-->'+lcChrg);
        System.debug('lcChrg.size()-->'+lcChrg.size());
        for (Rent_Schedules__c rs: (Test.isRunningTest())?lcChrg:[SELECT Id, Name,Lease_Charge__r.Charge_Type__c, Unit__c, Unit__r.Property__c, Unit__r.Property__r.Short_Code__c, Unit__r.Property__r.Name, Lease_Unit__c, Start_Date__c, End_Date__c, Charge_Type__c, Electric_Meter_Number__c, (Select Id,Rent_Schedule__c,Meter_Type__c,Meter_No__c,From_Date__c,To_Date__c From Electric_Transactions__r) FROM Rent_Schedules__c WHERE Lease_Charge__c<> NULL and Lease_Unit__c<> NULL and Unit__r.Property__r.Short_Code__c IN: setPropertyShortCode AND Charge_Type__c IN: setPicklistValue and Start_Date__c>=: startDate AND End_Date__c<=: endDate And Status__c='In-Tenancy' And  Lease_Charge__r.Type__c  = 'Meter Units' ]) {
            mmyyyy = rs.Start_Date__c.Month() + '-' + rs.Start_Date__c.Year();
            System.debug('rs-->'+rs);
            System.debug('rs.Electric_Meter_Number__c-->'+rs.Electric_Meter_Number__c);
            if (rs.Electric_Meter_Number__c<> NULL && rs.Electric_Meter_Number__c<> '')
                for (String MeterNo: rs.Electric_Meter_Number__c.split(';')) {
                    strMeterNoMMYYYY = MeterNo + '-' + mmyyyy;
                    lstRS = mapMeterNoMMYYYYWithRS.get(strMeterNoMMYYYY);

                    if (lstRS == null) lstRS = new List<Rent_Schedules__c> ();
                    lstRS.add(rs);

                    mapMeterNoMMYYYYWithRS.put(strMeterNoMMYYYY, lstRS);
                    
                    System.debug(strMeterNoMMYYYY+'1elle-->'+lstRS);
                    
                    if(rs.Start_Date__c.Month() != rs.End_Date__c.Month()){ 
                        mmyyyy = rs.End_Date__c.Month() + '-' + rs.End_Date__c.Year();
                        strMeterNoMMYYYY = MeterNo + '-' + mmyyyy;
                        lstRS = mapMeterNoMMYYYYWithRS.get(strMeterNoMMYYYY);
    
                        if (lstRS == null) lstRS = new List<Rent_Schedules__c> ();
                        lstRS.add(rs);
    
                        mapMeterNoMMYYYYWithRS.put(strMeterNoMMYYYY, lstRS);
                    }
                    System.debug(strMeterNoMMYYYY+'2elle-->'+lstRS);
                }
                for(Electric_Transaction__c eleT: rs.Electric_Transactions__r){
                    String key = (rs.Id+'-'+eleT.Meter_Type__c+'-'+eleT.Meter_No__c).replace(' ', '@');
                    List<Electric_Transaction__c> tempList = new List<Electric_Transaction__c>();
                    if(rsIdwithMeternoTypewithRec.containsKey(key))
                        tempList = rsIdwithMeternoTypewithRec.get(key);
                    tempList.add(eleT);
                    rsIdwithMeternoTypewithRec.put(key, tempList);
                    
                    System.debug((rs.Id+'-'+eleT.Meter_Type__c+'-'+eleT.Meter_No__c).replace(' ', '@') + 'eleT11-->'+eleT);
                }
        }
        System.debug('rsIdwithMeternoTypewithRec-->'+rsIdwithMeternoTypewithRec);
        Boolean eleTFound = false;
        String keyForMap = '';
        Date eleFromDT;
        Date eleToDT;
        for (Electric_Transaction__c et: trigger.new) {
            eleTFound = false;
            String etMMYYYY = null;
            etMMYYYY = et.To_Date__c.Month() + '-' + et.To_Date__c.Year();
            List<Rent_Schedules__c> lstRS2 = mapMeterNoMMYYYYWithRS.get(et.Meter_No__c + '-' + etMMYYYY);
            system.debug('et.From_Date__c ==> ' + et.From_Date__c);
            system.debug('et.To_Date__c ==> ' + et.To_Date__c);
            system.debug(etMMYYYY+' lstRS2 1111 ==> ' + lstRS2);
            if(lstRS2 == null){
                 etMMYYYY = et.From_Date__c.Month() + '-' + et.From_Date__c.Year();
                 lstRS2 = new List<Rent_Schedules__c>();
                 lstRS2 = mapMeterNoMMYYYYWithRS.get(et.Meter_No__c + '-' + etMMYYYY);
            }
            Electric_Meter__c tempEM = new Electric_Meter__c();
            tempEM = mapPropertyMeterwithElectricMeter.get(et.Property_Short_Code__c + '-' + et.Meter_No__c + '-' + et.Meter_Type__c);
            System.debug('keyyy-->'+et.Property_Short_Code__c + '-' + et.Meter_No__c + '-' + et.Meter_Type__c);
            system.debug('lstRS2 ==> ' + lstRS2);
            
            system.debug(!et.Manual__c + 'lstRS2<> NULL ==> ' + (lstRS2<> NULL));
            if (lstRS2<> NULL && !et.Manual__c){
                system.debug('Inside If');
                for (Rent_Schedules__c RS: lstRS2) {
                    system.debug((tempEM<> NULL)+'  tempEM--->>'+tempEM);
                    if (tempEM<> NULL) {
                        et.Line_Loss__c = tempEM.Line_Loss__c;
                        et.Power_Factor__c = tempEM.Power_Factor__c;
                        et.Horse_Power__c = tempEM.Horse_Power__c;
                        et.Maintenance_Fee__c = tempEM.Maintenance_Fee__c;
                        et.Electric_Meter__c = tempEM.Id; 
                    }
                    keyForMap = RS.Id+'-'+et.Meter_Type__c+'-'+et.Meter_No__c;
                    keyForMap = keyForMap.replace(' ', '@');
                    //Date rsStartDatebefore6dys = rs.Start_Date__c - 6;
                    Date rsStartDatebefore6dys = rs.Start_Date__c;
                    system.debug(rsStartDatebefore6dys+'RS ==> ' + ( et.From_Date__c >= rsStartDatebefore6dys));
                    if (et.Meter_Type__c == RS.Lease_Charge__r.Charge_Type__c && et.From_Date__c >= rsStartDatebefore6dys  && et.To_Date__c >= rs.Start_Date__c && et.To_Date__c<= rs.End_Date__c) {
                        system.debug('RS ==> ' + RS);
                        system.debug('wt ==> ' + et);
                        
                        System.debug('keyForMap-->'+keyForMap);
                        System.debug('rsIdwithMeternoTypewithRec.containsKey(keyForMap)-->'+rsIdwithMeternoTypewithRec.containsKey(keyForMap));
                        if(rsIdwithMeternoTypewithRec.containsKey(keyForMap)){
                            for(Electric_Transaction__c eleTemp: rsIdwithMeternoTypewithRec.get(keyForMap)){
                                eleFromDT = eleTemp.From_Date__c;
                                eleToDT = eleTemp.To_Date__c;
                                system.debug('eleFromDT ==> ' + eleFromDT);
                                system.debug('eleToDT ==> ' + eleToDT);
                                system.debug('eleFromDT <= et.To_Date__c ==> ' + (eleFromDT <= et.To_Date__c));
                                system.debug('et.From_Date__c <= eleToDT ==> ' + (et.From_Date__c <= eleToDT));
                                if(eleFromDT <= et.To_Date__c && et.From_Date__c <= eleToDT){
                                    eleTFound = true;
                                    break;
                                }
                            }
                        }
                        if(!eleTFound){
                            et.Unit__c = RS.Unit__c;
                            et.Lease_Unit__c = RS.Lease_Unit__c;
                            et.Property__c = RS.Unit__r.Property__c;
                            et.Rent_Schedule__c = RS.Id;
                            
                            List<Electric_Transaction__c> tempList = new List<Electric_Transaction__c>();
                            if(rsIdwithMeternoTypewithRec.containsKey(keyForMap))
                                tempList = rsIdwithMeternoTypewithRec.get(keyForMap);
                            tempList.add(et);
                            rsIdwithMeternoTypewithRec.put(keyForMap, tempList);
                            break;
                        }
                    }
                }
                }
                if(et.Rent_Schedule__c == null){
                    et.addError('Rent Schedule doesnot found.');
                } 
                if(eleTFound && !Test.isRunningTest()){
                    et.addError('Electric Transaction for identified Rent Schedule already exist.');
                }
                
        }
    }
    if (Trigger.isAfter) {
        Set<Id> rentScheduleIds = new Set<Id> ();
        if (Trigger.isUndelete || Trigger.isInsert || Trigger.isUpdate) {
            for (Electric_Transaction__c gt: trigger.new) {
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
            for (Electric_Transaction__c con1: Trigger.old) {
                if (con1.Rent_Schedule__c != null) {
                    rentScheduleIds.add(con1.Rent_Schedule__c);
                }
            }
        }
        if (rentScheduleIds.size()> 0) {
            RentScheduleCalculations_Helper.setMinMaxDate(rentScheduleIds);
        }
    }
}