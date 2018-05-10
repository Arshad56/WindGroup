trigger UpdateLeasePlanBooking on Expression_of_Interest__c (after insert,after update) {
    
    Date startDate = system.today();
    Date endDate = system.today();
    Set<Id> updateUnitId = new Set<Id>();
    
    
    for(Expression_of_Interest__c eoi: Trigger.new){
        Boolean isError= false;
        if(eoi.Unit_No__c != null && eoi.Commencement_Date__c != null && eoi.Expiry_Date__c != null){
            if(eoi.Expiry_Date__c < eoi.Commencement_Date__c){
                eoi.addError('Commencement Date should be before Expiry Date.');
                isError = true;
            }
            if(!isError){
                 if (eoi.Commencement_Date__c<startDate)
                    startDate = eoi.Commencement_Date__c;
        
                 if (eoi.Expiry_Date__c> endDate)
                    endDate = eoi.Expiry_Date__c;
                
                 updateUnitId.add(eoi.Unit_No__c);
            }
           
        }
    } 
    Integer totalDaysInEnd = Date.daysInMonth(endDate.year(), endDate.month());
    startDate = Date.newInstance(startDate.year(),startDate.Month(),1);
    endDate = Date.newInstance(endDate.year(),endDate.Month(),totalDaysInEnd);
    System.debug('startDate =>'+startDate);
    System.debug('endDate =>'+endDate);
    String  soqlQueryLP = 'select Id, Unit__c,Start_Date__c,End_Date__c,Status_1__c,Status_2__c,Status_3__c,Status_4__c,Status_5__c,Status_6__c,'
                        +'Day_1__c,Day_2__c,Day_3__c,Day_4__c,Day_5__c,'
                        +'Day_6__c,Day_7__c,Day_8__c,Day_9__c,Day_10__c,'
                        +'Day_11__c,Day_12__c,Day_13__c,Day_14__c,Day_15__c,'
                        +'Day_16__c,Day_17__c,Day_18__c,Day_19__c,Day_20__c,'
                        +'Day_21__c,Day_22__c,Day_23__c,Day_24__c,Day_25__c,Day_26__c,'
                        +'Day_27__c,Day_28__c,Day_29__c,Day_30__c,Day_31__c,'
                        +'Status_7__c,Status_8__c,Status_9__c,Status_10__c,'
                        +'Status_11__c,Status_12__c,Status_13__c,Status_14__c,Status_15__c,'
                        +'Status_16__c,Status_17__c,Status_18__c,Status_19__c,Status_20__c,'
                        +'Status_21__c,Status_22__c,Status_23__c,Status_24__c,Status_25__c,'
                        +'Status_26__c,Status_27__c,Status_28__c,Status_29__c,Status_30__c,Status_31__c '
                        +'from Lease_Plan__c where Unit__c IN: updateUnitId   And Unit__r.Charge_Method__c INCLUDES (\'Daily Rate\', \'Monthly Rate - CL\')';
    List<Lease_Plan__c> lpList= database.query(soqlQueryLP);
    
    
    System.debug('lpList.size==>'+lpList.size());
    System.debug('soqlQueryLP==>'+soqlQueryLP);
    List<Lease_Plan__c> updateLpList = new List<Lease_Plan__c>();
    Map<Id,List<Lease_Plan__c>> untIdLpMap = new Map<Id,List<Lease_Plan__c>>();
    for(Lease_Plan__c lp:lpList){
        List<Lease_Plan__c> tempLp=new List<Lease_Plan__c>();
        if(untIdLpMap.containsKey(lp.Unit__c))
            tempLp = untIdLpMap.get(lp.Unit__c);
        tempLp.add(lp);
        System.debug('lp==>'+lp);
        untIdLpMap.put(lp.Unit__c, tempLp);
    }
    for(Expression_of_Interest__c eoi: Trigger.new){
        if(eoi.Unit_No__c != null && eoi.Commencement_Date__c != null && eoi.Expiry_Date__c != null){
            if(untIdLpMap.containsKey(eoi.Unit_No__c)){
                for(Lease_Plan__c lp:untIdLpMap.get(eoi.Unit_No__c)){
                    System.debug('lp==>'+lp);
                    System.debug('untIdLpMap.get(eoi.Unit_No__c)==>'+untIdLpMap.get(eoi.Unit_No__c).size());
                    Date startDt = lp.Start_Date__c;
                    Integer totalDays = Date.daysInMonth(startDt.year(), startDt.month());
                    for(Integer j = 1; j <= 31; j++ ){
                        String tempStat = (String)  lp.get('Status_'+j+'__c');
                        if(j<= totalDays && tempStat != 'Committed' && tempStat != 'LOI'){
                            Date dayDate = Date.newInstance(startDt.year(),startDt.Month(),j);
                            if(dayDate >= eoi.Commencement_Date__c && dayDate <= eoi.Expiry_Date__c){
                                lp.put('Status_'+j+'__c', 'Booking');
                            }
                        }else{
                            lp.put('Status_'+j+'__c', 'N/A');
                        }
                    }
                    updateLpList.add(lp);
                }
            }
        }
    }
    update updateLpList;
}