global class CalPercentage_ByLease_Helper {
    @future  
    public static void updateRS(set<Id> rsIds){
        List<Rent_Schedules__c> listRs= [select Id,GTO_Monthly_Total__c,GTO_Monthly_Total_Converted__c from Rent_Schedules__c where id =: rsIds];
        //System.debug('Update listRs--> '+listRs);
        try{
            Utility.doGTO = true;
            update listRs;
        }catch(Exception e){
            //System.debug('Exception --'+e);
        }
    }
    public static void doGTOcalculation(set<Id> leaseId, set<Id> rsId){
        list<Rent_Schedules__c> rsList= new list<Rent_Schedules__c>();
        Set<String> chargeType = new Set<String>();
        Date startDate = System.today();
        Date endDate = System.today();
        for(Rent_Schedules__c rsl:[Select Id,Tiered__c,Transaction_Status__c,GTO_Monthly_Total__c,Exchange_Rate__c,GTO_Amount_By_Lease__c,Calc_NonCumulative_Tiered__c,Calc_Cumulative_Tiered__c,
                                                Cap_Value__c,of_Converted_Base_Rent__c,Converted_Base_Rent__c,Unit__c,Calc_No_of_Days_Pro_Rated_2__c,
                                                 GTO_Rent_By_Lease__c,Cumulative__c,Charge_Type__c,Currency_Code__c,
                                                Start_Date__c, End_Date__c, Status__c, Lease_Charge__c, Lease_Unit__r.Lease_Agreement_No__c,
                                                 Amount_Foreign__c,Amount_Local__c,Calculated_Amount__c,Calculated_Amount_Foreign__c,Calculated_Amount_Local__c,
                                                (Select Id From Monthly_Transaction_Summary__r)
                                                From Rent_Schedules__c where id=: rsId]){
            chargeType.add(rsl.Charge_Type__c);
            
            if(rsl.Start_Date__c < startDate)
                startDate = rsl.Start_Date__c;
            if(rsl.End_Date__c < endDate)
                endDate = rsl.End_Date__c;
            if(rsl.Monthly_Transaction_Summary__r.size() > 0)
                rsList.add(rsl);
        }       
        startDate = Date.newInstance(startDate.year(), startDate.month(), 1);
        endDate = Date.newInstance(endDate.year(), endDate.month(), Date.DaysInMonth(endDate.year(), endDate.month()));
        startDate -= 365;    
        endDate += 365;   
                        
        List<POS_Transaction__c> posList = [select Id,GTO_Amount__c,Rent_Schedule__c from POS_Transaction__c where Rent_Schedule__c =: rsId];
        Map<Id,Decimal> rsWithGTOamount = new Map<Id,Decimal>();
        for(POS_Transaction__c po:posList){
            po.GTO_Amount__c = (po.GTO_Amount__c != null )?po.GTO_Amount__c:0;
            Decimal amtGT = po.GTO_Amount__c+(rsWithGTOamount.containsKey(po.Rent_Schedule__c)?rsWithGTOamount.get(po.Rent_Schedule__c):0);
            rsWithGTOamount.put(po.Rent_Schedule__c, amtGT);
            //System.debug('rsWithGTOamount-->'+rsWithGTOamount);
        }
        
        set<Id> dupRSIds= new Set<Id>();
        List<Rent_Schedules__c>  rsToUpdate= new List<Rent_Schedules__c>();
         map<Id,Lease_Unit__c> luWithLCRSMap = new Map<Id,Lease_Unit__c>([select ID,Unit__c, Lease_Agreement_No__c, Lease_Agreement_No__r.GTO_Billed__c,
                                              (Select Id,Tiered__c,Transaction_Status__c,GTO_Monthly_Total__c,Exchange_Rate__c,GTO_Amount_By_Lease__c,Calc_NonCumulative_Tiered__c,Calc_Cumulative_Tiered__c,
                                                Cap_Value__c,of_Converted_Base_Rent__c,Converted_Base_Rent__c,Unit__c,Calc_No_of_Days_Pro_Rated_2__c,
                                                GTO_Rent_By_Lease__c, Start_Date__c, End_Date__c, Status__c, Amount_Foreign__c,Amount_Local__c,
                                                Lease_Charge__c, Lease_Unit__r.Lease_Agreement_No__c,Cumulative__c,Charge_Type__c,Calculated_Amount__c,Calculated_Amount_Foreign__c,Calculated_Amount_Local__c
                                                 From Rent_Schedules__r where (Charge_Type__c =: chargeType and Start_Date__c >=: startDate  and End_Date__c <=: endDate) or Charge_Type__c = 'Advance Rental'), 
                                              (Select Id, Currency_Code__c, Base_Rent_Calculation_Local__c, Base_Rent_Calculation_Foreign__c, Charge_Type__c, Start_Date__c, End_Date__c, Type__c, 
                                              Charge_Rate__c From Lease_Charges__r)
                                       from Lease_Unit__c where Lease_Agreement_No__c =: leaseId]);
        map<Id,list<Lease_Unit__c>> leaseIdandLU = new Map<Id,list<Lease_Unit__c>>();
        set<Id> unitIds= new set<Id>();
        for(Lease_Unit__c lu: luWithLCRSMap.values()){
            list<Lease_Unit__c> tempList= new list<Lease_Unit__c>();
            if(leaseIdandLU.containsKey(lu.Lease_Agreement_No__c)){
                tempList.addAll(leaseIdandLU.get(lu.Lease_Agreement_No__c));
            }
            tempList.add(lu);
            
            unitIds.add(lu.Unit__c);
            
            System.debug(lu.id+' tempList-->'+tempList.size());
            
            leaseIdandLU.put(lu.Lease_Agreement_No__c, tempList);
        }
        
        Map<Id, Lease__c> leaseRecMap = new Map<Id, Lease__c>([select Id, GTO_Billed__c from Lease__c where id =: leaseId]);
        Map<Id, Lease_Charges__c> leaseMap = new Map<Id, Lease_Charges__c>([select Id, Charge_Rate__c, Base_Rent_Calculation__c, Billing_Terms__c, Billing_Frequency__c, End_Date__c, Charge_Type__c, Type__c from Lease_Charges__c where Lease_Unit__r.Lease_Agreement_No__c In: leaseId]);
        Map<Id, Units__c> unitMap = new Map<Id, Units__c>([select Id, Charge_Method__c, NLA_SQF__c from Units__c where id =: unitIds]);
        
        list<CalPercentageWrap> mainWrap = new list<CalPercentageWrap>();
        Map<Id,Rent_Schedules__c> baseRsMap = new Map<Id,Rent_Schedules__c>();
        for(Rent_Schedules__c rsl: rsList){
        System.debug('rsl**-->'+rsl.id);
            //System.debug('rsl.Monthly_Transaction_Summary__r.size()-->'+rsl.Monthly_Transaction_Summary__r.size());
            if(rsl.Monthly_Transaction_Summary__r.size() > 0){
                CalPercentageWrap cpw = new CalPercentageWrap();
                cpw.rs = rsl;
                if(leaseRecMap.containsKey(rsl.Lease_Unit__r.Lease_Agreement_No__c)){
                    cpw.lease = leaseRecMap.get(rsl.Lease_Unit__r.Lease_Agreement_No__c);
                }
                System.debug(rsl.Lease_Unit__r.Lease_Agreement_No__c+' leaseIdandLU-->'+leaseIdandLU.get(rsl.Lease_Unit__r.Lease_Agreement_No__c).size() );
                for(Lease_Unit__c lus: leaseIdandLU.get(rsl.Lease_Unit__r.Lease_Agreement_No__c)){
                    if(lus.Lease_Agreement_No__r.GTO_Billed__c == 'By Lease (Lease Unit)'){
                        cpw.percentApplicable = true;
                    }
                    System.debug('cpw.percentApplicable-->'+cpw.percentApplicable);
                    System.debug('lus.Id-->'+lus.Id);
                    LUwrap luwr = new LUwrap();
                    luwr.leaseUnt = lus;
                    System.debug(rsl.Currency_Code__c+ ' lus.Lease_Charges__r--> '+ lus.Lease_Charges__r);
                    for(Rent_Schedules__c rs:lus.Rent_Schedules__r){
                        //System.debug('rs--> '+ rs);
                        if(rs.Charge_Type__c == 'Advance Rental'){
                            baseRsMap.put(rs.Id,rs);
                            /*//System.debug('start-->  '+rsl.Start_Date__c +' '+rs.Start_Date__c+ ' '+rs.End_Date__c);
                            //System.debug('End--> '+rsl.End_Date__c +' '+rs.Start_Date__c+ ' '+rs.End_Date__c);
                            //System.debug('1st --> '+(rsl.Start_Date__c>=rs.Start_Date__c && rsl.Start_Date__c<=rs.End_Date__c));
                            //System.debug('2nd--> '+ (rsl.End_Date__c>=rs.Start_Date__c && rsl.End_Date__c<=rs.End_Date__c)+' '+(rs.Id!=luwr.rs1));*/
                            if(rsl.Start_Date__c>=rs.Start_Date__c && rsl.Start_Date__c<=rs.End_Date__c){
                                luwr.rs1 = rs.Id;
                            }
                            if(rsl.End_Date__c>=rs.Start_Date__c && rsl.End_Date__c<=rs.End_Date__c){
                                if(rs.Id!=luwr.rs1){
                                    luwr.rs2 = rs.Id;
                                }
                            }
                        }
                    }
                    /* To calculate Base Rent from sibling Advanced RS
                     * get RS based on Proration logic.
                     * Commented lines are proration %. since the value is already prorated so removed the logic.
                     */
                    System.debug('luwr.rs--> '+ luwr.rs1 +' -- '+luwr.rs2);
                    luwr.baseRent = RSTrigger_Helper.doBRcalculation( rsl, luwr.rs1, luwr.rs2 ,baseRsMap);
                    cpw.totalBaseRent += luwr.baseRent;
                    /*
                     * ***************************************************
                     */
                    System.debug(luwr.baseRent+ ' cpw.totalBaseRent--> '+cpw.totalBaseRent);
                    cpw.lulistwrap.add(luwr);
                    System.debug('lus.Rent_Schedules__r-->'+lus.Rent_Schedules__r.size());
                    if(cpw.percentApplicable){
                        for(Rent_Schedules__c rs:lus.Rent_Schedules__r){
                            ////System.debug('rs.Id-->'+rs.Id);
                            if(rs.Start_Date__c == rsl.Start_Date__c && rs.End_Date__c == rsl.End_Date__c && rs.Charge_Type__c == rsl.Charge_Type__c){
                                for(LUwrap luwr1:cpw.lulistwrap){
                                    if(rs.Lease_Unit__c == luwr1.leaseUnt.Id){
                                        luwr1.rsLU = rs;
                                        rs.Cap_Value__c = (rs.Cap_Value__c != null)?rs.Cap_Value__c:0;
                                        cpw.totalCapValue += rs.Cap_Value__c;
                                        
                                        unitMap.get(rs.Unit__c).NLA_SQF__c = (unitMap.get(rs.Unit__c).NLA_SQF__c != null)?unitMap.get(rs.Unit__c).NLA_SQF__c:0;
                                        
                                        cpw.totalCapAmount += rs.Cap_Value__c * unitMap.get(rs.Unit__c).NLA_SQF__c;
    
                                        cpw.totalNLASqft += unitMap.get(rs.Unit__c).NLA_SQF__c; 
                                        //System.debug(cpw.totalNLASqft+'   Area -->'+unitMap.get(rs.Unit__c).NLA_SQF__c);
                                        //System.debug('1111rs.Id-->'+rs.Id);
                                        break;
                                    }
                                }
                            }
                        }
                    }else{
                        //cpw.rs;
                        //cpw.totalCapValue += cpw.rs.Cap_Value__c;
                        // cpw.totalCapAmount += cpw.rs.Cap_Amount__c;
                        
                        cpw.totalNLASqft += (unitMap.get(lus.Unit__c).NLA_SQF__c != null)?unitMap.get(lus.Unit__c).NLA_SQF__c:0; 
                        System.debug(lus.Unit__c+' cpw.totalNLASqft-->'+cpw.totalNLASqft +' '+unitMap.get(lus.Unit__c).NLA_SQF__c);
                    }
                }
                if(!cpw.percentApplicable){
                     cpw.totalCapValue = (cpw.rs.Cap_Value__c != null)?cpw.rs.Cap_Value__c:0;
                     cpw.totalCapAmount = cpw.totalCapValue * cpw.totalNLASqft;
                }
                mainWrap.add(cpw);
            }
        }       
        
        for(CalPercentageWrap cpw:mainWrap){
               Decimal rolledUpGTO = (rsWithGTOamount.containsKey(cpw.rs.Id))?rsWithGTOamount.get(cpw.rs.Id):0;
               //System.debug('rolledUpGTO-->'+rolledUpGTO);
               Decimal gtoAmt = (rolledUpGTO > 0)?((cpw.rs.Exchange_Rate__c > 0) ? rolledUpGTO / cpw.rs.Exchange_Rate__c : rolledUpGTO):0;
                /*//System.debug('gtoAmt-->'+gtoAmt);
                //System.debug('11cpw.rs.GTO_Amount_By_Lease__c->' + cpw.rs.GTO_Amount_By_Lease__c);*/
               if (!cpw.rs.Tiered__c && gtoAmt != null && leaseMap.get(cpw.rs.Lease_Charge__c).Charge_Rate__c != null) {
                    cpw.rs.GTO_Amount_By_Lease__c = gtoAmt * leaseMap.get(cpw.rs.Lease_Charge__c).Charge_Rate__c / 100.00;
                    //System.debug('111-->');
                } else {
                    if (cpw.rs.Cumulative__c) {
                        cpw.rs.GTO_Amount_By_Lease__c = cpw.rs.Calc_Cumulative_Tiered__c;
                        //System.debug('222-->');
                    } else {
                        cpw.rs.GTO_Amount_By_Lease__c = cpw.rs.Calc_NonCumulative_Tiered__c;
                        //System.debug('333-->');
                    }
                }
                //System.debug('cpw.rs.GTO_Amount_By_Lease__c->' + cpw.rs.GTO_Amount_By_Lease__c);
                if (cpw.rs.GTO_Amount_By_Lease__c == null) {
                    cpw.rs.GTO_Amount_By_Lease__c = 0;
                }
                decimal grossRent = 0;
                decimal grossRentCap = 0;
                decimal baseRentcal = 0;
                decimal capValue = 0;
                if (cpw.totalCapValue == null) {
                    capValue = 0;
                } else {
                    capValue = cpw.totalCapAmount * cpw.rs.Calc_No_of_Days_Pro_Rated_2__c / 100;
                    cpw.totalCapAmount = capValue;
                }
                if (cpw.totalBaseRent == null) {
                    baseRentcal = 0;
                } else {
                    baseRentcal = cpw.totalBaseRent;
                }
                //System.debug('baseRentcal-->'+baseRentcal);
                cpw.rs.Converted_Base_Rent_By_Lease__c = baseRentcal;
                //System.debug('cpw.rs.Converted_Base_Rent_By_Lease__c-->'+cpw.rs.Converted_Base_Rent_By_Lease__c);
                //System.debug('cpw.rs.Lease_Charge__c-->'+cpw.rs.Lease_Charge__c);
                //System.debug('leaseMap.containsKey(cpw.rs.Lease_Charge__c)-->'+leaseMap.containsKey(cpw.rs.Lease_Charge__c));
                if (leaseMap.get(cpw.rs.Lease_Charge__c).Type__c == 'GTO (Sum)') {
            
                    grossRent = cpw.rs.GTO_Amount_By_Lease__c + baseRentcal;
                    //System.debug('grossRent->' + grossRent);
                } else {
                    if (leaseMap.get(cpw.rs.Lease_Charge__c).Type__c == 'GTO (Higher)') {
                        if (cpw.rs.GTO_Amount_By_Lease__c>baseRentcal) {
                            grossRent = cpw.rs.GTO_Amount_By_Lease__c;
                        } else {
                            grossRent = baseRentcal;
                        }
                    } else {
                        if (leaseMap.get(cpw.rs.Lease_Charge__c).Type__c == 'GTO') {
                            grossRent = cpw.rs.GTO_Amount_By_Lease__c;
                        } else {
                            grossRent = 0;
                        }
                    }
                }
                //System.debug('grossRent-->' + grossRent);
                if (cpw.rs.Unit__c != null && unitMap.containsKey(cpw.rs.Unit__c)) {
                    if (grossRent <= capValue  || capValue <= 0) {
                        grossRentCap = grossRent;
                    } else {
                        grossRentCap = capValue;
                    } 
                }
                //System.debug('cpw.rs.Lease_Charge__c-->' + cpw.rs.Lease_Charge__c);
                if (cpw.rs.Lease_Charge__c != null) {
                    if (leaseMap.get(cpw.rs.Lease_Charge__c).Type__c == 'GTO (Higher)' || leaseMap.get(cpw.rs.Lease_Charge__c).Type__c == 'GTO (Sum)') {
                        /*//System.debug('Sum Higher case');
                        //System.debug('grossRentCap-->' + grossRentCap);
                        //System.debug('baseRentcal-->' + baseRentcal);
                        //System.debug('cpw.rs.Calc_No_of_Days_Pro_Rated_2__c-->' + cpw.rs.Calc_No_of_Days_Pro_Rated_2__c);
                        //System.debug('*****-->' + baseRentcal);*/
                        if (grossRentCap >= baseRentcal) {
                            cpw.rs.GTO_Rent_By_Lease__c = grossRentCap - baseRentcal;
                        } else {
                            cpw.rs.GTO_Rent_By_Lease__c = 0;
                        }
                    } else if (leaseMap.get(cpw.rs.Lease_Charge__c).Type__c == 'GTO') {
                        cpw.rs.GTO_Rent_By_Lease__c = grossRentCap;
                    }
                    //System.debug('grossRentCap-->' + grossRentCap);
                }
                
                if(!dupRSIds.contains(cpw.rs.Id) && cpw.rs.Id != null && !cpw.percentApplicable || (cpw.rs.Id != null && Test.isRunningTest())){
                    //System.debug('cpw.rs.Id-->'+cpw.rs.Id);
                    
                    cpw.rs.GTO_Amount_By_Lease__c= cpw.rs.GTO_Amount_By_Lease__c.setScale(2);
                    cpw.totalBaseRent = cpw.totalBaseRent.setScale(2);
                    cpw.totalCapValue = cpw.totalCapValue.setScale(2);
                    cpw.totalCapAmount = cpw.totalCapAmount.setScale(2);
                    cpw.totalNLASqft = cpw.totalNLASqft.setScale(2);
                    
                    cpw.rs.of_Converted_Base_Rent__c = 100;
                    cpw.rs.Converted_Base_Rent_By_Lease__c = cpw.totalBaseRent;
                    cpw.rs.Total_GTO_Rent_By_Lease__c =  cpw.rs.GTO_Rent_By_Lease__c;
                    cpw.rs.Cap_Value_By_Lease__c =  cpw.totalCapValue;
                    cpw.rs.Cap_Amount_By_Lease__c =  cpw.totalCapAmount;
                    cpw.rs.NLA_SQF_By_Lease__c = cpw.totalNLASqft;
                    if(cpw.percentApplicable)
                        cpw.rs.Transaction_Status__c = 'Applicable - Imported';
                    //totalCapValue
                    
                    rsToUpdate.add(cpw.rs);
                    dupRSIds.add(cpw.rs.Id);
                }
                if(cpw.percentApplicable){
                    for(LUwrap luwr:cpw.lulistwrap){
                        if(luwr.rsLU != null){
                            
                            luwr.rsLU.GTO_Amount_By_Lease__c  = cpw.rs.GTO_Amount_By_Lease__c;
                            luwr.percent = (cpw.totalBaseRent > 0)?(luwr.baseRent*100/cpw.totalBaseRent).setScale(2):0; 
                            luwr.rsLU.GTO_Rent_By_Lease__c = (cpw.rs.GTO_Rent_By_Lease__c*luwr.percent/100).setScale(2);
                            luwr.rsLU.of_Converted_Base_Rent__c = luwr.percent.setScale(2);
                            luwr.rsLU.Converted_Base_Rent_By_Lease__c = cpw.totalBaseRent.setScale(2);
                            luwr.rsLU.Cap_Value_By_Lease__c =  cpw.totalCapValue;
                            luwr.rsLU.Cap_Amount_By_Lease__c =  cpw.totalCapAmount.setScale(2);
                            luwr.rsLU.Total_GTO_Rent_By_Lease__c =  cpw.rs.GTO_Rent_By_Lease__c;
                            luwr.rsLU.NLA_SQF_By_Lease__c = cpw.totalNLASqft;
                            if(cpw.percentApplicable)
                                luwr.rsLU.Transaction_Status__c = 'Applicable - Imported';
                            
                            //System.debug('luwr.rsLU.Id-->'+luwr.rsLU.Id);
                            //System.debug(luwr.baseRent+' -- '+luwr.baseRent+'<-- luwr.baseRent ---cpw.totalBaseRent-->'+cpw.totalBaseRent);
                            //System.debug('luwr.percent-->'+luwr.percent);
                            /*//System.debug('cpw.rs.GTO_Rent_By_Lease__c-->'+cpw.rs.GTO_Rent_By_Lease__c);
                            //System.debug('luwr.rsLU.GTO_Rent_By_Lease__c-->'+luwr.rsLU.GTO_Rent_By_Lease__c);*/
                            if(!dupRSIds.contains(luwr.rsLU.Id) && luwr.rsLU.Id != null){
                                rsToUpdate.add(luwr.rsLU);
                                dupRSIds.add(luwr.rsLU.Id);
                            }
                        }
                    }
                }
        }   
        if(rsToUpdate.size()> 0){
            Utility.doGTO = false;
            update rsToUpdate;
        }
        try{
        
        }catch(Exception e){
            
        }                   
    }
    public class CalPercentageWrap {
        public Rent_Schedules__c rs{get;set;}
        public Lease__c lease{get;set;}
        public Decimal totalBaseRent{get;set;}
        public Decimal totalCapValue{get;set;}
        public Decimal totalCapAmount{get;set;}
        public Decimal totalNLASqft{get;set;}
        public list<LUwrap> lulistwrap{get;set;}
        public Boolean percentApplicable{get;set;}
        public CalPercentageWrap(){
            rs = new Rent_Schedules__c();
            lease = new Lease__c();
            lulistwrap = new list<LUwrap>();
            percentApplicable = false;
            totalBaseRent = 0;
            totalCapValue = 0;
            totalCapAmount = 0;
            totalNLASqft = 0;
            rs = new Rent_Schedules__c();
            lease = new Lease__c();
        }
    }
    public class LUwrap {
        public Lease_Unit__c leaseUnt{get;set;}
        public Rent_Schedules__c rsLU{get;set;}
        public Id rs1{get;set;}
        public Id rs2{get;set;}
        public Decimal baseRent{get;set;}
        public Decimal percent{get;set;}
        public LUwrap() {
            rsLU = new Rent_Schedules__c();
            leaseUnt = new Lease_Unit__c();
            baseRent = 0.00;
            percent = 0.00;
        }
    }
}