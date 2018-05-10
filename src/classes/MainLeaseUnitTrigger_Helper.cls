public class MainLeaseUnitTrigger_Helper { 
    public static void updateLeasePlans(Map<Id, Lease_Unit__c> newLUs, Map<Id, Lease_Unit__c> oldLUs, Set<Id> unitIds){
         Map<Id, Map<String,Lease_Plan__c>> mapLeaseplanwithMonths = new Map<Id, Map<String,Lease_Plan__c>>();
       String  soqlQueryUnit = 'select Id,Monthly_Budget__c,Unit__c,Start_Date__c,End_Date__c,Commited__c,Day_1__c,Day_2__c,Day_3__c,Day_4__c,Day_5__c,'
                                +'Day_6__c,Day_7__c,Day_8__c,Day_9__c,Day_10__c,'
                                +'Day_11__c,Day_12__c,Day_13__c,Day_14__c,Day_15__c,'
                                +'Day_16__c,Day_17__c,Day_18__c,Day_19__c,Day_20__c,'
                                +'Day_21__c,Day_22__c,Day_23__c,Day_24__c,Day_25__c,Day_26__c,'
                                +'Day_27__c,Day_28__c,Day_29__c,Day_30__c,Day_31__c,'
                                +'Status_1__c,Status_2__c,Status_3__c,Status_4__c,Status_5__c,Status_6__c,'
                                +'Status_7__c,Status_8__c,Status_9__c,Status_10__c,'
                                +'Status_11__c,Status_12__c,Status_13__c,Status_14__c,Status_15__c,'
                                +'Status_16__c,Status_17__c,Status_18__c,Status_19__c,Status_20__c,'
                                +'Status_21__c,Status_22__c,Status_23__c,Status_24__c,Status_25__c,'
                                +'Status_26__c,Status_27__c,Status_28__c,Status_29__c,Status_30__c,Status_31__c,'
                                +'Daily_Rate_1__c,Daily_Rate_2__c,Daily_Rate_3__c,Daily_Rate_4__c,Daily_Rate_5__c,Daily_Rate_6__c,'
                                +'Daily_Rate_7__c,Daily_Rate_8__c,Daily_Rate_9__c,Daily_Rate_10__c,'
                                +'Daily_Rate_11__c,Daily_Rate_12__c,Daily_Rate_13__c,Daily_Rate_14__c,Daily_Rate_15__c,'
                                +'Daily_Rate_16__c,Daily_Rate_17__c,Daily_Rate_18__c,Daily_Rate_19__c,Daily_Rate_20__c,'
                                +'Daily_Rate_21__c,Daily_Rate_22__c,Daily_Rate_23__c,Daily_Rate_24__c,Daily_Rate_25__c,'
                                +'Daily_Rate_26__c,Daily_Rate_27__c,Daily_Rate_28__c,Daily_Rate_29__c,Daily_Rate_30__c,Daily_Rate_31__c '
                                +'from Lease_Plan__c where Unit__c =: unitIds';
        
        List<Lease_Plan__c> listLP =  database.query(soqlQueryUnit);
        List<Lease_Unit__c> listLU = [select Id,Unit__r.NLA_SQF__c, Unit__c, Unit__r.Charge_Method__c ,Lease_Agreement_No__r.Lease_Start_Date__c,
                                        Lease_Agreement_No__r.Lease_End_Date__c,Lease_Start_Date__c,Lease_End_Date__c, 
                                        (Select Id, Start_Date__c, Base_Rent_Calculation__c, Charge_Type__c, End_Date__c ,Charge_Rate__c
                                        From Lease_Charges__r where Charge_Type__c ='Advance Rental') 
                                      from Lease_Unit__c where Id =: oldLUs.KeySet()];
        Map<String,Lease_Plan__c> tempInner;
        for(Lease_Plan__c lp:listLP){
            if(mapLeaseplanwithMonths.containsKey(lp.Unit__c)) {
                Map<String,Lease_Plan__c> tempMap = mapLeaseplanwithMonths.get(lp.Unit__c);
                tempMap.put(lp.Start_Date__c.Month()+''+lp.Start_Date__c.Year(),lp);
                mapLeaseplanwithMonths.put(lp.Unit__c, tempMap);
            } else {
                tempInner = new Map<String,Lease_Plan__c>();
                tempInner.put(lp.Start_Date__c.Month()+''+lp.Start_Date__c.Year(),lp);
                mapLeaseplanwithMonths.put(lp.Unit__c, tempInner);
            }
        }
        System.debug('mapLeaseplanwithMonths-->'+mapLeaseplanwithMonths);
        Lease_Plan__c lp;
        Date Everyday;
        Date beforeDate;
        Date endStartDTLP;
        for(Lease_Unit__c lu: listLU){ 
            
            Integer totalMonths = 0;
            Date tempStartDate;
            Date endDate;
            Boolean isVacant=false;
            if(oldLUs.get(lu.Id).Lease_End_Date__c > lu.Lease_End_Date__c ){
                //Pre Termination
               totalMonths = lu.Lease_End_Date__c.monthsBetween(oldLUs.get(lu.Id).Lease_End_Date__c);
               tempStartDate = lu.Lease_End_Date__c;
               endDate = oldLUs.get(lu.Id).Lease_End_Date__c;
               isVacant = true;
            }else{
                // Extension
                totalMonths = oldLUs.get(lu.Id).Lease_End_Date__c.monthsBetween(lu.Lease_End_Date__c);
                tempStartDate = oldLUs.get(lu.Id).Lease_End_Date__c;
                endDate = lu.Lease_End_Date__c;
            }
            endStartDTLP = tempStartDate;
            System.debug('tempStartDate-->'+tempStartDate);
            System.debug('endDate-->'+endDate);
            System.debug('totalMonths-->'+totalMonths);
            for(Integer i = 0; i <= totalMonths; i++){
                lp = new Lease_Plan__c();
                if(lu.Unit__c != null  && tempStartDate != null){
                    if(mapLeaseplanwithMonths.containsKey(lu.Unit__c)){
                        System.debug('mapLeaseplanwithMonths.get(lu.Unit__c)-->'+mapLeaseplanwithMonths.get(lu.Unit__c));
                        System.debug('mnth-->'+tempStartDate.Month()+''+tempStartDate.Year());
                        if(mapLeaseplanwithMonths.get(lu.Unit__c).containsKey(tempStartDate.Month()+''+tempStartDate.Year())){
                            
                            Integer numberOfDays = Date.daysInMonth(tempStartDate.year(), tempStartDate.month());
                            Integer endOfMonth = Date.daysInMonth(tempStartDate.year(), tempStartDate.month());
                            if(tempStartDate.month() == endDate.month() && tempStartDate.year() == endDate.year()){
                                numberOfDays = endDate.day();
                            }
                            lp = mapLeaseplanwithMonths.get(lu.Unit__c).get(tempStartDate.Month()+''+tempStartDate.Year());
                            lp.Lease_Unit__c = lu.Id;
                            Everyday = tempStartDate;
                            beforeDate = Date.newInstance(Everyday.year(),Everyday.Month(),1);
                           // lp.put('Status__c', 'Committed');
                            lp.Lease_Unit__c = lu.Id;
                            
                            if(lu.Unit__r.Charge_Method__c.contains('Monthly Rate - CL') || lu.Unit__r.Charge_Method__c.contains('Monthly Rate - L')){
                                //System.debug('lu.Lease_Charges__r->'+lu.Lease_Charges__r);
                                for(Lease_Charges__c lulc : lu.Lease_Charges__r){
                                    if(((lp.Start_Date__c <= lulc.Start_Date__c && lp.End_Date__c >= lulc.Start_Date__c)||(lp.Start_Date__c >= lulc.Start_Date__c && lp.Start_Date__c <= lulc.End_Date__c)) && lulc.Charge_Rate__c != null){
                                        lp.put('Monthly_Committed_Budget__c', lulc.Charge_Rate__c);//endOfMonth);
                                        //System.debug('lp.Monthly_Committed_Budget__c->'+lp.Monthly_Committed_Budget__c);
                                        break;
                                    }
                                }
                                
                            } 
                            Decimal tempCommittedRate = (lp.Monthly_Committed_Budget__c != null) ? lp.Monthly_Committed_Budget__c : 0 ;
                            //System.debug(lp.Monthly_Committed_Budget__c+' tempCommittedRate-->'+tempCommittedRate);
                            if(!isVacant){
                                lp.Lease_Unit__c = lu.Id;
                                lp.put('Status__c','Committed');
                                lp.put('Monthly_Committed_Budget__c', tempCommittedRate);
                                lp.put('Commited__c',true);
                                //System.debug('1111lp.Status__c-->'+lp.Status__c);
                            }else{
                                lp.Lease_Unit__c = null;
                                lp.put('Status__c','Vacant');
                                lp.put('Commited__c',false);
                                lp.put('Monthly_Committed_Budget__c', null);
                                //System.debug('2222lp.Status__c-->'+lp.Status__c);
                            }
                            if(tempStartDate.month() == endStartDTLP.month() && tempStartDate.year() == endStartDTLP.year()){
                                lp.put('Status__c',(lu.Lease_End_Date__c.day() != endOfMonth) ? 'Vacant' : 'Committed');
                                lp.Lease_Unit__c = lu.Id;
                                lp.put('Commited__c',true);
                                lp.put('Monthly_Committed_Budget__c', tempCommittedRate);
                                //System.debug('333lp.Status__c-->'+lp.Status__c);
                            }
                            System.debug('lp-->'+lp.Id);
                            Boolean vac=false;
                            Boolean comm=false;
                            for(Integer j = 1; j <= 31; j++){
                                //System.debug('(j <= endOfMonth)-->'+(j <= endOfMonth));
                                if(j <= endOfMonth){
                                    //if(lp.Monthly_Budget__c > 0){
                                        //lp.put('Daily_Rate_'+j+'__c', lp.Monthly_Budget__c/endOfMonth);
                                    //}
                                    
                                    String tempStat = (String) lp.get('Status_'+j+'__c');
                                    //System.debug(isVacant+' '+j +'  '+numberOfDays+' ' + beforeDate+' beforeDate-->'+tempStartDate);
                                    //System.debug(tempStartDate+' endStartDTLP-->'+endStartDTLP);
                                    //System.debug('condition-->'+(beforeDate >= tempStartDate) + ' ' + (j <= numberOfDays)+ ' '+(tempStartDate != endStartDTLP));
                                    
                                    lp.put('Day_'+j+'__c', beforeDate);
                                    Everyday = Everyday +1;
                                    if(beforeDate >= tempStartDate && j <= numberOfDays && beforeDate != endStartDTLP){
                                        
                                        lp.put('Daily_Committed_Rate_'+j+'__c', null);
                                        lp.put('Daily_LOI_Rate_'+j+'__c', null);
                                        lp.put('Status_'+j+'__c', (isVacant) ? 'Vacant': 'Committed');
                                    }
                                    //System.debug(' lpStat day-->'+lp.get('Status_'+j+'__c'));
                                    beforeDate = beforeDate +1;
                                }else{
                                    lp.put('Day_'+j+'__c', null);
                                    lp.put('Status_'+j+'__c', 'N/A');
                                }
                                if(lp.get('Status_'+j+'__c') == 'Committed'){
                                   comm=true;
                                }else if(lp.get('Status_'+j+'__c') == 'Vacant'){
                                    vac=true;
                                }
                            }
                            
                            if(!vac && comm){
                                lp.put('Status__c','Committed');
                                lp.put('Commited__c',true); 
                            }else if(vac && !comm){
                                lp.put('Status__c','Vacant');
                                lp.put('Commited__c',false); 
                            }else if(vac && comm){
                                lp.put('Status__c','Vacant');
                                lp.put('Commited__c',true);     
                            }
                            if(lp.Commited__c)
                                lp.put('Monthly_Committed_Budget__c', tempCommittedRate);
                            Map<String,Lease_Plan__c> tempMap = mapLeaseplanwithMonths.get(lp.Unit__c);
                            tempMap.put(lp.Start_Date__c.Month()+''+lp.Start_Date__c.Year(),lp);
                            mapLeaseplanwithMonths.put(lp.Unit__c, tempMap);
                        }
                    }
                    tempStartDate = Date.newInstance(tempStartDate.year(), tempStartDate.month()+1, 1);
                }
                
            }
        }
        List<Lease_Plan__c> updateLPs= new List<Lease_Plan__c>();
        for(Id ids:mapLeaseplanwithMonths.keySet()){
            for(String dateCode: mapLeaseplanwithMonths.get(ids).keySet()){
                updateLPs.add(mapLeaseplanwithMonths.get(ids).get(dateCode));
            }
        }
        update updateLPs;
        
    }
    public static void updateLeasePlans(Set<Id> leaseUnitIds,Set<Id> unitIds){
        Map<Id, Map<String,Lease_Plan__c>> mapLeaseplanwithMonths = new Map<Id, Map<String,Lease_Plan__c>>();
       String  soqlQueryUnit = 'select Id,Monthly_Budget__c,Unit__c,Start_Date__c,End_Date__c,Commited__c,Day_1__c,Day_2__c,Day_3__c,Day_4__c,Day_5__c,'
                                +'Day_6__c,Day_7__c,Day_8__c,Day_9__c,Day_10__c,'
                                +'Day_11__c,Day_12__c,Day_13__c,Day_14__c,Day_15__c,'
                                +'Day_16__c,Day_17__c,Day_18__c,Day_19__c,Day_20__c,'
                                +'Day_21__c,Day_22__c,Day_23__c,Day_24__c,Day_25__c,Day_26__c,'
                                +'Day_27__c,Day_28__c,Day_29__c,Day_30__c,Day_31__c,'
                                +'Status_1__c,Status_2__c,Status_3__c,Status_4__c,Status_5__c,Status_6__c,'
                                +'Status_7__c,Status_8__c,Status_9__c,Status_10__c,'
                                +'Status_11__c,Status_12__c,Status_13__c,Status_14__c,Status_15__c,'
                                +'Status_16__c,Status_17__c,Status_18__c,Status_19__c,Status_20__c,'
                                +'Status_21__c,Status_22__c,Status_23__c,Status_24__c,Status_25__c,'
                                +'Status_26__c,Status_27__c,Status_28__c,Status_29__c,Status_30__c,Status_31__c,'
                                +'Daily_Rate_1__c,Daily_Rate_2__c,Daily_Rate_3__c,Daily_Rate_4__c,Daily_Rate_5__c,Daily_Rate_6__c,'
                                +'Daily_Rate_7__c,Daily_Rate_8__c,Daily_Rate_9__c,Daily_Rate_10__c,'
                                +'Daily_Rate_11__c,Daily_Rate_12__c,Daily_Rate_13__c,Daily_Rate_14__c,Daily_Rate_15__c,'
                                +'Daily_Rate_16__c,Daily_Rate_17__c,Daily_Rate_18__c,Daily_Rate_19__c,Daily_Rate_20__c,'
                                +'Daily_Rate_21__c,Daily_Rate_22__c,Daily_Rate_23__c,Daily_Rate_24__c,Daily_Rate_25__c,'
                                +'Daily_Rate_26__c,Daily_Rate_27__c,Daily_Rate_28__c,Daily_Rate_29__c,Daily_Rate_30__c,Daily_Rate_31__c '
                                +'from Lease_Plan__c where Unit__c =: unitIds';
        
        List<Lease_Plan__c> listLP =  database.query(soqlQueryUnit);
        List<Lease_Unit__c> listLU = [select Id,Unit__r.NLA_SQF__c, Unit__c, Unit__r.Charge_Method__c ,Lease_Agreement_No__r.Lease_Start_Date__c,
                                        Fit_Out_Date__c,Lease_Agreement_No__r.Lease_End_Date__c,Lease_Start_Date__c,Lease_End_Date__c, 
                                        (Select Id, Start_Date__c, Base_Rent_Calculation__c, Charge_Type__c, End_Date__c ,Charge_Rate__c
                                        From Lease_Charges__r where Charge_Type__c ='Advance Rental') 
                                      from Lease_Unit__c where Id =: leaseUnitIds];
        Map<String,Lease_Plan__c> tempInner;
        for(Lease_Plan__c lp:listLP){
            if(mapLeaseplanwithMonths.containsKey(lp.Unit__c)) {
                Map<String,Lease_Plan__c> tempMap = mapLeaseplanwithMonths.get(lp.Unit__c);
                tempMap.put(lp.Start_Date__c.Month()+''+lp.Start_Date__c.Year(),lp);
                mapLeaseplanwithMonths.put(lp.Unit__c, tempMap);
                System.debug('lp.Unit__c mnth1 -> '+tempMap);
            } else {
                tempInner = new Map<String,Lease_Plan__c>();
                tempInner.put(lp.Start_Date__c.Month()+''+lp.Start_Date__c.Year(),lp);
                mapLeaseplanwithMonths.put(lp.Unit__c, tempInner);
                System.debug('lp.Unit__c mnth2 -> '+tempInner);
            }
        }
        Lease_Plan__c lp;
        Date Everyday;
        Date beforeDate;
        for(Lease_Unit__c lu: listLU){ 
            
            Integer totalMonths = 0;
            if((lu.Fit_Out_Date__c!= null || lu.Lease_Start_Date__c != null) && lu.Lease_End_Date__c != null){
               //totalMonths = lu.Lease_Agreement_No__r.Lease_Start_Date__c.monthsBetween(lu.Lease_Agreement_No__r.Lease_End_Date__c);
               //lu.Lease_Start_Date__c = lu.Lease_Agreement_No__r.Lease_Start_Date__c;
               //lu.Lease_End_Date__c = lu.Lease_Agreement_No__r.Lease_End_Date__c;
                totalMonths = (lu.Fit_Out_Date__c!= null)?lu.Fit_Out_Date__c.monthsBetween(lu.Lease_End_Date__c):lu.Lease_Start_Date__c.monthsBetween(lu.Lease_End_Date__c);
            }

            Date tempStartDate = (lu.Fit_Out_Date__c!= null)?lu.Fit_Out_Date__c:lu.Lease_Start_Date__c;
            System.debug(tempStartDate + ' tempStartDate -- '+lu.Lease_End_Date__c+' '+lu.Id +' totalMonths--> '+totalMonths);
            for(Integer i = 0; i <= totalMonths; i++){
                lp = new Lease_Plan__c();
                if(lu.Unit__c != null  && tempStartDate != null){
                    System.debug('Contains1 -> '+mapLeaseplanwithMonths.containsKey(lu.Unit__c));
                    if(mapLeaseplanwithMonths.containsKey(lu.Unit__c)){
                        System.debug('contains2 --> '+mapLeaseplanwithMonths.get(lu.Unit__c).containsKey(tempStartDate.Month()+''+tempStartDate.Year()));
                        if(mapLeaseplanwithMonths.get(lu.Unit__c).containsKey(tempStartDate.Month()+''+tempStartDate.Year())){
                            Integer numberOfDays = Date.daysInMonth(tempStartDate.year(), tempStartDate.month());
                            Integer endOfMonth = Date.daysInMonth(tempStartDate.year(), tempStartDate.month());
                            if(tempStartDate.month() == lu.Lease_End_Date__c.month() && tempStartDate.year() == lu.Lease_End_Date__c.year()){
                                numberOfDays = lu.Lease_End_Date__c.day();
                            }
                            lp = mapLeaseplanwithMonths.get(lu.Unit__c).get(tempStartDate.Month()+''+tempStartDate.Year());
                            lp.Lease_Unit__c = lu.Id;
                            Everyday = tempStartDate;
                            beforeDate = Date.newInstance(Everyday.year(),Everyday.Month(),1);
                            lp.put('Status__c', 'Committed');
                            if(lu.Unit__r.Charge_Method__c != null)
                                if(lu.Unit__r.Charge_Method__c.contains('Monthly Rate - CL') || lu.Unit__r.Charge_Method__c.contains('Monthly Rate - L')){
                                    for(Lease_Charges__c lulc : lu.Lease_Charges__r){
                                        if(((lp.Start_Date__c <= lulc.Start_Date__c && lp.End_Date__c >= lulc.Start_Date__c)||(lp.Start_Date__c >= lulc.Start_Date__c && lp.Start_Date__c <= lulc.End_Date__c)) && lulc.Charge_Rate__c != null){
                                            lp.put('Monthly_Committed_Budget__c', lulc.Charge_Rate__c);//endOfMonth);
                                            break;
                                        }
                                    }
                                }
                            System.debug('LP Id -> '+lp.Id);
                            for(Integer j = 1; j <= 31; j++){
                                if(j <= endOfMonth){
                                    if(lp.Monthly_Budget__c > 0){
                                        lp.put('Daily_Rate_'+j+'__c', lp.Monthly_Budget__c/endOfMonth);
                                    }
                                    lp.put('Day_'+j+'__c', beforeDate);
                                    Everyday = Everyday +1;
                                    String tempStat = (String) lp.get('Status_'+j+'__c');
                                    if(beforeDate >= lu.Fit_Out_Date__c && beforeDate < lu.Lease_Start_Date__c && j <= numberOfDays){
                                        lp.put('Status_'+j+'__c', 'Fitout');
                                        lp.put('Fit_out__c',true);
                                    }else if(beforeDate >= tempStartDate && j <= numberOfDays){
                                        lp.put('Status_'+j+'__c', 'Committed');
                                        lp.put('Commited__c',true);
                                    }else if(tempStat != 'LOI' && tempStat != 'Committed' && tempStat != 'Fitout' ){
                                        lp.put('Day_'+j+'__c',  beforeDate);
                                        lp.put('Status_'+j+'__c', 'Vacant');
                                        lp.put('Status__c', 'Vacant');
                                    }
                                    beforeDate = beforeDate +1;
                                }else{
                                    lp.put('Day_'+j+'__c', null);
                                    lp.put('Status_'+j+'__c', 'N/A');
                                }
                            }
                            Map<String,Lease_Plan__c> tempMap = mapLeaseplanwithMonths.get(lp.Unit__c);
                            tempMap.put(lp.Start_Date__c.Month()+''+lp.Start_Date__c.Year(),lp);
                            mapLeaseplanwithMonths.put(lp.Unit__c, tempMap);
                        }
                    }
                    tempStartDate = Date.newInstance(tempStartDate.year(), tempStartDate.month()+1, 1);
                }
                
            }
        }
        List<Lease_Plan__c> updateLPs= new List<Lease_Plan__c>();
        for(Id ids:mapLeaseplanwithMonths.keySet()){
            for(String dateCode: mapLeaseplanwithMonths.get(ids).keySet()){
                updateLPs.add(mapLeaseplanwithMonths.get(ids).get(dateCode));
            }
        }
        update updateLPs;
    }
}