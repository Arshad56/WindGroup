public class UpdateDailyRateController{
    List<Lease_Plan__c> leasePlan;
    public date startDate{get;set;}
    public date endDate{get;set;}
    public string weekDays{get;set;}
    public string bulkUpdateBy{get;set;}
    public decimal bulkUpdateValue{get;set;}
    string unitIds;
    public Boolean success{get;set;}
    public string chargeMethod{get;set;}
    public Integer startMonth{get;set;}
    public Integer startYear{get;set;}
    public Integer endMonth{get;set;}
    public Integer endYear{get;set;}
    public UpdateDailyRateController(){
        success = false;
        leasePlan = new List<Lease_Plan__c>();
        unitIds = Apexpages.currentPage().getParameters().get('unitIds');
        System.debug('unitIds-->'+unitIds);
        System.debug('unitIds.split()-->'+unitIds.split(','));
        if(unitIds!=null){
            List<Units__c> unitList = [Select id,Charge_Method__c from Units__c where id in:unitIds.split(',')];
            if(unitList.size()>0){
                chargeMethod = unitList[0].Charge_Method__c;
            }
        }
        Integer month;
        if(Apexpages.currentPage().getParameters().get('month')!=null){
            month = Integer.valueOf(Apexpages.currentPage().getParameters().get('month'));
        }
        
        Integer year;
        if(Apexpages.currentPage().getParameters().get('year')!=null){
            year = Integer.ValueOf(Apexpages.currentPage().getParameters().get('year'));
        }
        if(month!=null && year!=null){
            startDate = Date.NewInstance(year,month,1);
            startMonth = month;
            startYear = year;
            if(month==12){
                month = 1;
                year++;
            }else{
                month++;
            }
            endDate = Date.NewInstance(year,month,Date.DaysInMonth(year,Month));
            endMonth = month;
            endYear = year;
        }
        weekdays = 'All';
    }
    
    public void updateRate(){
        Set<String> unitIdSet = new Set<String>();
        
        if(chargeMethod!=null && chargeMethod.contains('Daily Rate')){
            if(weekDays==null || weekDays.trim().length()==0){
                apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select weekdays'));
                return;
            }
            if(startDate == null || endDate == null){
                apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Start date and End date can not be null'));
                return;
            }
            if(startDate > endDate){
                apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Start date can not be greater than End date'));
                return;
            }
            
            success = true;
            
            if(unitIds!=null && unitIds.trim().length()>0){
                
                unitIdSet = new Set<String>(unitIds.split(','));
                Set<Integer> monthset = new Set<Integer>();
                Set<Integer> Yearset = new Set<Integer>();
                /*for(Integer i=startDate.Month();i<=endDate.month();i++){
                    monthSet.add(i);
                }*/
                
                Date startMonth = Date.newInstance(startDate.year(), startDate.month(), 1);
                
                while(startMonth <= endDate){
                    system.debug(startMonth+' startMonth.Month()==='+startMonth.Month());
                    monthSet.add(startMonth.Month());
                    startMonth = startMonth.addMonths(1);
                }
                
                for(Integer i=startDate.year();i<=endDate.year();i++){
                    yearSet.add(i);
                }
                
                String  soqlQueryUnit = 'Select id,Unit__c,Start_Date__c,End_Date__c,Daily_Rate_1__c,Daily_Rate_2__c,Daily_Rate_3__c,'
                                    +'Daily_Rate_4__c,Daily_Rate_5__c,Daily_Rate_6__c,Daily_Rate_7__c,Daily_Rate_8__c,'
                                    +'Daily_Rate_9__c,Daily_Rate_10__c,Daily_Rate_11__c,Daily_Rate_12__c,Daily_Rate_13__c,'
                                    +'Daily_Rate_14__c,Daily_Rate_15__c,Daily_Rate_16__c,Daily_Rate_17__c,Daily_Rate_18__c,'
                                    +'Daily_Rate_19__c,Daily_Rate_20__c,Daily_Rate_21__c,Daily_Rate_22__c,Daily_Rate_23__c,'
                                    +'Daily_Rate_24__c,Daily_Rate_25__c,Daily_Rate_26__c,Daily_Rate_27__c,Daily_Rate_28__c,'
                                    +'Daily_Rate_29__c,Daily_Rate_30__c,Daily_Rate_31__c,Status_1__c,Status_2__c,Status_3__c,'
                                    +'Status_4__c,Status_5__c,Status_6__c,Status_7__c,Status_8__c,Status_9__c,Status_10__c,'
                                    +'Status_11__c,Status_12__c,Status_13__c,Status_14__c,Status_15__c,Status_16__c,Status_17__c,'
                                    +'Status_18__c,Status_19__c,Status_20__c,Status_21__c,Status_22__c,Status_23__c,Status_24__c,'
                                    +'Status_25__c,Status_26__c,Status_27__c,Status_28__c,Status_29__c,Status_30__c,Status_31__c '
                                    +'from Lease_Plan__c ' 
                                    +'where Unit__c in:unitIdSet and CALENDAR_Month(Start_Date__c) in:monthset and CALENDAR_YEAR(Start_Date__c) in:yearSet';
                leasePlan = database.query(soqlQueryUnit);
                system.debug('StartDate==='+startDate);
                system.debug('EndDate==='+endDate);
                System.debug('leasePlan.size ==>'+leasePlan.size());
                System.debug('leasePlan ==>'+leasePlan);

                if(leasePlan.size()>0){
                    for(Lease_Plan__c lp:leasePlan){
                        for(Date dt=(lp.Start_Date__c<startDate?startDate:lp.Start_Date__c);dt<=(lp.End_Date__c>endDate?endDate:lp.End_Date__c);dt = dt + 1){
                            System.debug('status ==>'+(string)lp.get('Status_'+dt.day()+'__c'));
                            if((string)lp.get('Status_'+dt.day()+'__c')=='Vacant' || (string)lp.get('Status_'+dt.day()+'__c')=='Booking' || (string)lp.get('Status_'+dt.day()+'__c') == null || (string)lp.get('Status_'+dt.day()+'__c') == ''){
                                Datetime dtm = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0));
                                String dayofDate = dtm.format('EEEE');
                                
                                System.debug('dayofDate ==>'+dayofDate);
                                System.debug('weekDays ==>'+weekDays);
                                System.debug('lp ==>'+lp.get('Daily_Rate_'+dt.day()+'__c'));
                                
                                if(weekDays.contains('All') || weekDays.contains(dayofDate)){
                                    if(bulkUpdateBy=='Absolute'){
                                        lp.put('Daily_Rate_'+dt.day()+'__c',bulkUpdateValue);
                                    }else if(bulkUpdateBy=='Incremental Change'){
                                        decimal prevVal = (decimal)lp.get('Daily_Rate_'+dt.day()+'__c');
                                        if(prevVal!=null){
                                            lp.put('Daily_Rate_'+dt.day()+'__c',(prevVal + bulkUpdateValue));
                                        }
                                    }else if(bulkUpdateBy=='% Rate Change'){
                                        decimal prevVal = (decimal)lp.get('Daily_Rate_'+dt.day()+'__c');
                                        if(prevVal!=null){
                                            decimal newVal = prevVal*bulkUpdateValue/100.00;
                                            lp.put('Daily_Rate_'+dt.day()+'__c',(prevVal + newVal));
                                        }
                                    }
                                }
                                System.debug('lp11 ==>'+lp.get('Daily_Rate_'+dt.day()+'__c'));
                            }
                        }
                    }
                    update leasePlan;
                }
            }
        }else{
            success = true;
            if(unitIds!=null && unitIds.trim().length()>0){
                startDate = date.NewInstance(startYear,startMonth,1);
                endDate = date.NewInstance(endYear,endMonth,Date.DaysInMonth(endYear,endMonth));
                
                unitIdSet = new Set<String>(unitIds.split(','));
                String  soqlQueryUnit = 'Select id,Monthly_Budget__c,Unit__c,Start_Date__c,End_Date__c,Daily_Rate_1__c,'
                            +'Daily_Rate_2__c,Daily_Rate_3__c,Daily_Rate_4__c,Daily_Rate_5__c,Daily_Rate_6__c,'
                            +'Daily_Rate_7__c,Daily_Rate_8__c,Daily_Rate_9__c,Daily_Rate_10__c,Daily_Rate_11__c,'
                            +'Daily_Rate_12__c,Daily_Rate_13__c,Daily_Rate_14__c,Daily_Rate_15__c,Daily_Rate_16__c,'
                            +'Daily_Rate_17__c,Daily_Rate_18__c,Daily_Rate_19__c,Daily_Rate_20__c,Daily_Rate_21__c,'
                            +'Daily_Rate_22__c,Daily_Rate_23__c,Daily_Rate_24__c,Daily_Rate_25__c,Daily_Rate_26__c,'
                            +'Daily_Rate_27__c,Daily_Rate_28__c,Daily_Rate_29__c,Daily_Rate_30__c,Daily_Rate_31__c,'
                            +'Status_1__c,Status_2__c,Status_3__c,Status_4__c,Status_5__c,Status_6__c,Status_7__c,'
                            +'Status_8__c,Status_9__c,Status_10__c,Status_11__c,Status_12__c,Status_13__c,Status_14__c,'
                            +'Status_15__c,Status_16__c,Status_17__c,Status_18__c,Status_19__c,Status_20__c,Status_21__c,'
                            +'Status_22__c,Status_23__c,Status_24__c,Status_25__c,Status_26__c,Status_27__c,Status_28__c,'
                            +'Status_29__c,Status_30__c,Status_31__c '
                            +'from Lease_Plan__c '
                            +'where Unit__c in:unitIdSet and Start_Date__c >=:startDate and End_Date__c <=:endDate and (Status__c=\'Vacant\' or  Status__c=\'Booking\' or Status__c = null or Status__c = \'\')';
                leasePlan = database.query(soqlQueryUnit);

                if(leasePlan.size()>0){
                    for(Lease_Plan__c lp:leasePlan){
                        if(bulkUpdateBy=='Absolute'){
                            lp.Monthly_Budget__c = bulkUpdateValue;
                        }else if(bulkUpdateBy=='Incremental Change'){
                            if(lp.Monthly_Budget__c!=null){
                                lp.Monthly_Budget__c = lp.Monthly_Budget__c + bulkUpdateValue;
                            }
                        }else if(bulkUpdateBy=='% Rate Change'){
                            if(lp.Monthly_Budget__c!=null){
                                decimal newVal = lp.Monthly_Budget__c*bulkUpdateValue/100.00;
                                lp.Monthly_Budget__c = lp.Monthly_Budget__c + newVal;
                            }
                        }
                    }
                    update leasePlan;
                }
            }
        }
    }
    
    public List<SelectOption> getMonthList(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectoption('1','Jan'));
        options.add(new selectoption('2','Feb'));
        options.add(new selectoption('3','Mar'));
        options.add(new selectoption('4','Apr'));
        options.add(new selectoption('5','May'));
        options.add(new selectoption('6','Jun'));
        options.add(new selectoption('7','Jul'));
        options.add(new selectoption('8','Aug'));
        options.add(new selectoption('9','Sep'));
        options.add(new selectoption('10','Oct'));
        options.add(new selectoption('11','Nov'));
        options.add(new selectoption('12','Dec'));
        return options;
    }
    
    public List<SelectOption> getyearList(){
        List<SelectOption> options = new List<SelectOption>();
        for(Integer i = system.today().year() - 5;i<=system.today().year()+5;i++){
            options.add(new SelectOption(i+'',i+''));
        }
        return options;
    }
}