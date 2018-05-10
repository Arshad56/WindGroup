public with sharing class ResurveyController {
    public Boolean closePage{get;set;}
    public Boolean showDetail{get;set;}
    public Boolean showTable{get;set;}
    public decimal oldNLA{get;set;}
    public string billingType{get;set;}
    public Units__c unitOnUI{get;set;}
    public Units__c selectedunit{get;set;}
    public String unitId{get;set;}
    public Map<Id,List<ResurveyRSWrap>> maplistRsWrap{get;set;} 
    public Map<Id, Lease_Unit__c> mapLU{get;set;}
    public Set<Id> allIds{get;set;}
    public ResurveyController(){
        unitId = ApexPages.currentpage().getParameters().get('unitId');
        selectedunit = [select id,NLA_SQF__c,Start_Date__c,End_Date__c,Property__r.Comm_Tax__c from Units__c where id =: unitId];
        oldNLA = (selectedunit.NLA_SQF__c==null)?0:selectedunit.NLA_SQF__c;
        
        refresh();
        unitOnUI = new Units__c();
        //unitOnUI.NLA_SQF__c = 50;
        //unitOnUI.Start_Date__c =  date.newInstance(2017, 1, 1);
    }
    public void refresh(){
        
        maplistRsWrap = new Map<Id,List<ResurveyRSWrap>>();
        allIds = new Set<Id>();
        mapLU  = new Map<Id, Lease_Unit__c>();
        showTable = false;
        showDetail = true;
        billingType = '';
    }
    public void next(){
        showDetail = true;
        showTable = false;
    }
    public void back(){
        refresh();
    }
    public void addRow() {
        Integer toAddRow = Integer.valueOf(ApexPages.currentPage().getParameters().get('toAddRow'));
        String luId = ApexPages.currentPage().getParameters().get('luId');
        System.debug('toAddRow-->'+toAddRow+'  luId-->'+luId);
        
        ResurveyRSWrap tempWrap = new ResurveyRSWrap();
        System.debug('maplistRsWrap.get(luId)-->'+maplistRsWrap.containsKey(luId)+'  luId-->'+maplistRsWrap);
        tempWrap = maplistRsWrap.get(luId).get(toAddRow);
        
        ResurveyRSWrap addWrap = new ResurveyRSWrap();
        addWrap.rs = tempWrap.rs.clone(false);
        addWrap.remark = tempWrap.remark;
        addWrap.amount = tempWrap.amount;
        addWrap.commTax = tempWrap.commTax;
        addWrap.parentRSId = tempWrap.parentRSId;
        addWrap.isCloned = true;
        
        if(toAddRow == (maplistRsWrap.get(luId).size()-1)){
            maplistRsWrap.get(luId).add(addWrap);
        }else{
            maplistRsWrap.get(luId).add(toAddRow+1,addWrap);
        }
        
    }
    public void delRow(){
        String luId = ApexPages.currentPage().getParameters().get('luId');
        Integer toDelRow = Integer.valueOf(ApexPages.currentPage().getParameters().get('toDelRow'));
        
        maplistRsWrap.get(luId).remove(toDelRow);
    }
    public pageReference search(){
        
        if(unitOnUI.NLA_SQF__c == null || unitOnUI.NLA_SQF__c <= 0){
            unitOnUI.NLA_SQF__c.addError('Please Enter New NLA Sq ft.');  
            return null;
        }
        decimal diffArea = 0;
        diffArea = (oldNLA - unitOnUI.NLA_SQF__c);
        if((oldNLA - unitOnUI.NLA_SQF__c) >= 0 ){
            billingType ='Debit Note'; // +ve amount
        }else{
            billingType ='Credit Note'; // -ve amount
        }
        if(oldNLA == unitOnUI.NLA_SQF__c){
            unitOnUI.NLA_SQF__c.addError('Please donot enter same old different Area NLA sqft.');  
            return null;
        }
        if(unitOnUI.Start_Date__c == null){
            unitOnUI.Start_Date__c.addError('Please Enter Effective Date.');   
            return null;
        }
        Date effectiveDate = unitOnUI.Start_Date__c;
        
        if(effectiveDate < selectedunit.Start_Date__c || effectiveDate > selectedunit.End_Date__c){
            unitOnUI.Start_Date__c.addError('Please Enter Effective Date in between Unit start and end date.');   
            return null;
        }
        /* Updated Query Condition 
         mapLU = new Map<Id, Lease_Unit__c>([select id ,Name ,
                                    (Select Name,Type__c, Lease_Unit__r.Unit__c, Lease_Unit__c, Active__c,Charge_Rate__c ,Parent_Lease_Charge__r.Type__c
                                        From Lease_Charges__r 
                                            where  (Type__c ='By Area' Or Parent_Lease_Charge__r.Type__c = 'By Area' Or Type__c ='GTO (Higher)')  And (Start_Date__c >=: effectiveDate Or (Start_Date__c <: effectiveDate And End_Date__c >: effectiveDate And End_Date__c >: System.today())))  
                                                from Lease_Unit__c 
                                                    where Unit__c =: unitId]);
        */
        /*
        Date Modified -  26th March 2018
        By- Arshad Shaikh
        Reason- To Show A&P in RS list | To Remove inactive LC | To allow past and future date to process without todays check
        */
        mapLU = new Map<Id, Lease_Unit__c>([
        select id ,Name ,
            (Select Name,Type__c, Lease_Unit__r.Unit__c, Lease_Unit__c, Active__c,Charge_Rate__c ,Parent_Lease_Charge__r.Type__c
                From Lease_Charges__r 
                    where  (Type__c ='By Area' Or Parent_Lease_Charge__r.Type__c = 'By Area' Or Type__c ='GTO (Higher)' Or Base_Charge_Type__c ='Advance Rental' Or Base_Charge_Type__c ='Rent') And Active__c = true  And End_Date__c >=: effectiveDate)  
                        from Lease_Unit__c 
                            where Unit__c =: unitId And Lease_Unit_Status__c != 'Cancelled']);
        Map<Id, Lease_Charges__c> lcWithRSMap= new Map<Id, Lease_Charges__c>([Select Type__c,Charge_Rate__c, Lease_Unit__r.Unit__c, Lease_Unit__c, Active__c,Parent_Lease_Charge__r.Type__c, 
        (select Id, of_Converted_Base_Rent__c, Active__c, Amount__c, Amount_Foreign__c, Amount_Local__c, Approved__c, Area_ft__c, Base_Rent__c, Test_BaseRent__c, Base_Rent_LC__c, Base_Rent_RS_1__c, Base_Rent_RS_2__c, Billed_Month__c, Billing_Date__c, Billing_Month__c, Billing_Type__c, Calc_Cumulative_Tiered__c, Calc_NonCumulative_Tiered__c, Calc_No_of_Days_Pro_Rated__c, Calc_No_of_Days_Pro_Rated_2__c, Calculated_Amount__c, Calculated_Amount_Foreign__c, Calculated_Amount_Local__c, Calculated_Utility_Non_Tiered__c, Cap_Amount__c, Cap_Amount_By_Lease__c, Cap_Applicable__c, Cap_Value__c, Cap_Value_By_Lease__c, Charge_Type__c, check__c, Comm_Tax__c, Comm_Tax_LC__c, Comm_Tax_Amount__c, Comm_Tax_Amount_Foreign__c, Comm_Tax_Amount_Local__c, Converted_Base_Rent__c, Converted_Base_Rent_By_Lease__c, Cumulative__c, Currency_Code__c, Current_Base_Rent__c, days__c, Electric_Meter__c, Electric_Meter_Number__c, Ele_Transaction_Count__c, End_Date__c, Est_Calc_Cumulative_Tiered__c, Est_Calc_Non_Cumulative_Tiered__c, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Amount__c, Estimated_GTO_Rent__c, Exchange_Rate__c, Expected_Amount__c, Expected_Charge__c, first_RentalSchedule__c, Gas_Transaction_Count__c, Gross_Rent__c, Gross_Rent_By_Lease__c, Gross_Rent_Cap__c, Gross_Rent_Cap_By_Lease__c, Calculated_Amount_Higher_or_Sum__c, GTO_Rent_By_Lease__c, GTO_Rent_By__c, GTO_Amount1__c, GTO_Amount_By_Lease__c, Hold__c, Horse_Power__c, Invoice_Line_Item__c, last_RentalSchedule__c, Leap_Year__c, Lease_Agreement_No__c, Lease_Charge__c, Lease_Unit__c, Lease_Unit_Property__c, Level__c, Maintenance_Fee__c, NLA_SQF_By_Lease__c, Parent_Rent_Schedule__c, Phone_transaction_Count__c, POS_Transaction_Count__c, PropertyLU__c, Property_Short_Code__c, Comments__c, Remarks__c, Rent_Roll__c, rent_roll_casesafe__c, Rent_Roll_Detail__c, Rent_Schedules_Month_Year__c, RRD_Text__c, RR_Text__c, Start_Date__c, Status__c, Target_Rental__c, Temp_Cumulative_Cur__c, Temp_Calculated_Amount__c, Tenancy_Status__c, Tenant__c, TenantLU__c, Terminated_Month__c, Terminated_Month_cal__c, Tiered__c, Total_Amount__c, Total_Amount_Foreign__c, Total_Amount_Local__c, Total_Electric_Units__c, Total_Estimated_GTO__c, Total_Estimated_GTO_Converted__c, Total_Gas_Units__c, GTO_Monthly_Total__c, GTO_Monthly_Total_Converted__c, Total_GTO_Rent_By_Lease__c, Total_Phone_Units__c, Total_Units__c, Total_Units_p__c, Total_Water_Units__c, Trading_Day_s__c, Transaction_End_Date__c, Transaction_Start_Date__c, Transaction_Status__c, Transaction_Unit__c, Type__c, Unit__c, Property__c, Water_Transaction_Count__c, Withholding_Tax_Rate__c, Year__c, Lease_Charge__r.name, Lease_Charge__r.Charge_Rate__c , Lease_Charge__r.Commercial_Tax_Apply__c 
            from Rent_schedules__r 
                where (Start_Date__c >=: effectiveDate Or (Start_Date__c <: effectiveDate And End_Date__c >: effectiveDate)) 
                And Status__c ='Rent Roll Generated' And Billing_Type__c != 'Debit Note'  And Billing_Type__c != 'Credit Note'  And Billing_Type__c != 'Ad-Hoc Invoice' ) 
                    from Lease_Charges__c 
                        where Lease_Unit__r.Unit__c =: unitId and (Type__c ='By Area' Or Parent_Lease_Charge__r.Type__c = 'By Area' Or Type__c ='GTO (Higher)' Or Base_Charge_Type__c ='Advance Rental' Or Base_Charge_Type__c ='Rent') And Active__c = true
                        And End_Date__c >: effectiveDate]);
        System.debug('effectiveDate-->'+effectiveDate);
        System.debug('lcWithRSMap-->'+lcWithRSMap);
        Set<Id> baseRentIds = new set<Id>();
        for(Id lcId: lcWithRSMap.KeySet()){
            if(lcWithRSMap.get(lcId).Type__c =='GTO (Higher)')
                for(Rent_schedules__c rs: lcWithRSMap.get(lcId).Rent_schedules__r){
                    if(rs.Base_Rent_RS_1__c!=null){
                        baseRentIds.add(rs.Base_Rent_RS_1__c);
                    }
                    if(rs.Base_Rent_RS_2__c!=null){
                        baseRentIds.add(rs.Base_Rent_RS_2__c);
                    }
                }
        }
        
        Map<Id,Rent_Schedules__c> baseRentRsMap = new Map<Id,Rent_Schedules__c>([Select id,Start_Date__c,End_Date__c,Calculated_Amount__c,Calculated_Amount_Foreign__c,Calculated_Amount_Local__c,Amount__c,Amount_Local__c,Amount_Foreign__c from Rent_Schedules__c where id in:baseRentIds]);
        //map<id, List<>
        ResurveyRSWrap tempWrap;
        List<ResurveyRSWrap> tempWrapList = new List<ResurveyRSWrap>();
        Integer tempCount = 1;
        
        for(Id lu: mapLU.keyset()){
            tempCount = 1;
            tempWrapList = new List<ResurveyRSWrap>();
            if(mapLU.get(lu).Lease_Charges__r.size()>0){
                System.debug('LU-->'+lu);
                for(Lease_Charges__c lc: mapLU.get(lu).Lease_Charges__r){
                    System.debug(lc.id +'  '+ lc.name+'   lcWithRSMap-->'+lcWithRSMap.containsKey(lc.id));
                    if(lcWithRSMap.containsKey(lc.id)){
                        System.debug('   RS List -->'+lcWithRSMap.get(lc.id).Rent_schedules__r.size());
                        for(Rent_schedules__c rs:lcWithRSMap.get(lc.id).Rent_schedules__r){
                            System.debug('rs-->'+rs);
                            Rent_schedules__c rsCopy = rs.clone(false);
                            if(rsCopy.Start_Date__c < effectiveDate){
                                rsCopy.Start_Date__c = effectiveDate;
                            }
                            rsCopy.Billing_Type__c = billingType;
                            rsCopy.Remarks__c = 'Unit Resurvey';
                            rsCopy.Lease_Charge__r.Charge_Rate__c = (lc.Charge_Rate__c != null)?lc.Charge_Rate__c:0;
                            
                            System.debug('lc.Type__c -->'+lc.Type__c +' --rs.Lease_Charge__r.Type__c-->'+rs.Lease_Charge__r.Type__c);
                            
                            if(lc.Type__c == 'By Area' || lc.Parent_Lease_Charge__r.Type__c == 'By Area'){
                                rsCopy.Amount__c = getByArea( rs.Amount__c, unitOnUI.NLA_SQF__c ,rs.Lease_Charge__r.Charge_Rate__c) ;
                            }else if(lc.Type__c =='GTO (Higher)'){
                                decimal gtoRevenue = getGTOrevenue(rs,lcWithRSMap);
                                decimal baseRent = doBRcalculation(unitOnUI.NLA_SQF__c , rs, rs.Base_Rent_RS_1__c, rs.Base_Rent_RS_2__c,baseRentRsMap );
                                decimal grossRent = getGrossRent(gtoRevenue , baseRent);
                                decimal grossRentCap = getGrossRentCap(rs,grossRent,unitOnUI.NLA_SQF__c);
                                decimal gtoRent = getGTORent(grossRentCap,baseRent);
                                
                                rsCopy.Amount__c = gtoRent - rsCopy.Amount__c;
                            }
                            
                            
                            tempWrapList.add(new ResurveyRSWrap(rsCopy));
                            tempCount++;
                        }
                    }
                }
            }
            System.debug('maplistRsWrap-->'+maplistRsWrap);
            if(tempWrapList.size()>0){
                allIds.add(lu);
                maplistRsWrap.put(lu, tempWrapList);
                showTable = true;
            }
        }
        if(showTable){
            showDetail = false;
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is no Rent Schedule affected from '+ DateTime.newInstance(effectiveDate.year(),effectiveDate.month(),effectiveDate.day()).format('d/MM/YYYY')));
        }
        return null;
    }
    
    public pageReference generate(){
        List<Rent_schedules__c> insertRS = new List<Rent_schedules__c>();
        for(Id ids:maplistRsWrap.keySet()){
            for(ResurveyRSWrap rsWrap:maplistRsWrap.get(ids)){
                Rent_schedules__c tempRS = new Rent_schedules__c();
                tempRS = rsWrap.rs;
                
                tempRS.Remarks__c = rsWrap.remark; 
                tempRS.Amount__c = rsWrap.amount;
                if(rsWrap.commTax){
                    tempRS.Comm_Tax__c = selectedUnit.Property__r.Comm_Tax__c;
                }else{
                    tempRS.Comm_Tax__c = null;
                }
                //tempRS.Remarks__c = rsWrap.commTax;
                insertRS.add(tempRS);
            }
        }
        try{
            closePage = true;
            insert insertRS;
            
        }catch(Exception e){
            closePage = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Exception occured: ' +e));
        }
        return null;
    }
    
    // By Area Calculation
    public static decimal getByArea(decimal oldAmount, decimal newArea, decimal chargeRate){
        decimal newAmount = (newArea*chargeRate) - oldAmount;
        
        return oldAmount;
    }
    // GTO Revenue Calculation
    public static decimal getGTOrevenue(Rent_schedules__c rs, Map<Id, Lease_Charges__c> leaseMap){
        decimal gtoAmount = 0;
        if(!rs.Tiered__c && rs.GTO_Monthly_Total_Converted__c != null && leaseMap.get(rs.Lease_Charge__c).Charge_Rate__c != null) {
            gtoAmount = rs.GTO_Monthly_Total_Converted__c * leaseMap.get(rs.Lease_Charge__c).Charge_Rate__c / 100.00;
        }else{
            if(rs.Cumulative__c){
                gtoAmount = rs.Calc_Cumulative_Tiered__c;
            }else{
                gtoAmount = rs.Calc_NonCumulative_Tiered__c;
            }
        }
        return gtoAmount;
    }
    // Gross Rent Calculation
    public static decimal getGrossRent(decimal gtoAmount, decimal baseRentcal){
        decimal grossRent = 0;
        if(gtoAmount > baseRentcal){
            grossRent = gtoAmount;
        }else{
            grossRent = baseRentcal;
        }
        return grossRent;
    }
    // Gross Rent Cap Calculation
    public static decimal getGrossRentCap(Rent_schedules__c rs, decimal grossRent, decimal newArea){
        decimal grossRentCap = 0;
        decimal capValue = (rs.Cap_Value__c == null) ?0:rs.Cap_Value__c;

        if (grossRent <= (capValue * rs.Calc_No_of_Days_Pro_Rated_2__c * newArea) / 100 || capValue * newArea <= 0) {
            grossRentCap = grossRent;
        } else {
            grossRentCap = capValue * rs.Calc_No_of_Days_Pro_Rated_2__c * newArea / 100;
        }
        return grossRentCap;
    }
    // GTO Rent calculation
    public static decimal getGTORent(decimal grossRentCap, decimal baseRentcal){
        decimal gtoAmount;
        
         if (grossRentCap >= baseRentcal) {
            gtoAmount = grossRentCap - baseRentcal;
        } else {
            gtoAmount = 0;
        }
        
        return gtoAmount;
    }
    // Base Rent calculation with new Area
    public static decimal doBRcalculation(decimal newArea, Rent_Schedules__c rs, Id br1, Id br2,Map<Id,Rent_Schedules__c> baseRentRsMap){
        decimal br1CalculatedAmount;
        decimal br1CalculatedAmountLocal;
        decimal br1CalculatedAmountForeign;
        if(br2!=null){
            br1CalculatedAmount = newArea * baseRentRsMap.get(br1).Lease_Charge__r.Charge_Rate__c;
            if(rs.Exchange_Rate__c==1){
                if(br1CalculatedAmount !=null ){
                    br1CalculatedAmountLocal = br1CalculatedAmount;
                    decimal baseForeignCurrencyRate = baseRentRsMap.get(br1).Amount_Local__c/baseRentRsMap.get(br1).Amount_Foreign__c;
                    if(baseForeignCurrencyRate>0){
                        br1CalculatedAmountForeign = br1CalculatedAmount / baseForeignCurrencyRate;
                    }
                }
            }else{
                if(rs.Amount__c!=null){
                    br1CalculatedAmountForeign = br1CalculatedAmount;
                    br1CalculatedAmountLocal = br1CalculatedAmount * rs.Exchange_Rate__c;
                }
            }
        }
        decimal br2CalculatedAmount;
        decimal br2CalculatedAmountLocal;
        decimal br2CalculatedAmountForeign;
        if(br2!=null){
            br2CalculatedAmount = newArea * baseRentRsMap.get(br2).Lease_Charge__r.Charge_Rate__c;
            if(rs.Exchange_Rate__c==1){
                if(br2CalculatedAmount !=null ){
                    br2CalculatedAmountLocal = br2CalculatedAmount;
                    decimal baseForeignCurrencyRate = baseRentRsMap.get(br2).Amount_Local__c/baseRentRsMap.get(br2).Amount_Foreign__c;
                    if(baseForeignCurrencyRate>0){
                        br2CalculatedAmountForeign = br2CalculatedAmount / baseForeignCurrencyRate;
                    }
                }
            }else{
                if(rs.Amount__c!=null){
                    br2CalculatedAmountForeign = br2CalculatedAmount;
                    br2CalculatedAmountLocal = br2CalculatedAmount * rs.Exchange_Rate__c;
                }
            }
        }
        decimal convertedBR = 0;
        if(br1!=null && br2==null){
            System.debug('1*1');
            if(baseRentRsMap.containsKey(br1)){
                Integer daysGap = rs.Start_Date__c.daysBetween(rs.End_Date__c)+1;
                Integer daysInMonth = Date.DaysInMonth(rs.Start_Date__c.Year(),rs.Start_Date__c.Month());
                decimal proRateDays = 1.00*daysGap/daysInMonth;
                proRateDays = proRateDays.setScale(4);
                if(rs.Currency_Code__c!=label.Default_Currency){                    
                    if(br1CalculatedAmountForeign!=null){
                        convertedBR = proRateDays*br1CalculatedAmountForeign;
                    } 
                }else{
                    if(br1CalculatedAmountLocal!=null){
                        convertedBR = proRateDays*br1CalculatedAmountLocal;
                    }
                }
            }
        }else if(br1!=null && br2!=null){
            System.debug('2*2');
            if(baseRentRsMap.containsKey(br1) && baseRentRsMap.containsKey(br2)){
                decimal amount1 = 0;
                decimal amount2 = 0;
                decimal proRateDays1 = 1.00*(rs.Start_Date__c.daysBetween(baseRentRsMap.get(br1).End_Date__c) + 1)/Date.DaysInMonth(baseRentRsMap.get(br1).End_Date__c.year(),baseRentRsMap.get(br1).End_Date__c.Month());
                proRateDays1 = proRateDays1.setScale(4);
                decimal proRateDays2 = 1.00*(baseRentRsMap.get(br2).Start_Date__c.DaysBetween(rs.End_Date__c)+1)/Date.DaysInMonth(rs.End_Date__c.year(),rs.End_Date__c.Month());
                proRateDays2 = proRateDays2.setScale(4);
                if(rs.Currency_Code__c!=label.Default_Currency){
                    if(baseRentRsMap.get(br1).Calculated_Amount_Foreign__c!=null){
                        amount1 = proRateDays1*br1CalculatedAmountForeign;
                    }
                    if(baseRentRsMap.get(br2).Calculated_Amount_Foreign__c!=null){
                        amount2 = proRateDays2*br2CalculatedAmountForeign;
                    }

                }else{
                    if(baseRentRsMap.get(br1).Calculated_Amount_Local__c!=null){
                        amount1 = proRateDays1*br1CalculatedAmountLocal;
                    }
                    if(baseRentRsMap.get(br2).Calculated_Amount_Local__c!=null){
                        amount2 = proRateDays2*br2CalculatedAmountLocal;
                    }
                }
                convertedBR = amount1 + amount2;
            }
        }
        
        return convertedBR;
    }
    
    public class ResurveyRSWrap{
        public Boolean isSelected{get;set;}
        public Boolean isCloned{get;set;}
        public Integer index{get;set;}
        
        public String parentRSId{get;set;}
        public String remark{get;set;}
        public decimal amount{get;set;}
        public Boolean commTax{get;set;}
        public Rent_schedules__c rs{get;set;}
        public ResurveyRSWrap(){
            rs = new Rent_schedules__c();
        }
        public ResurveyRSWrap(Rent_schedules__c rsTemp){
            rs = new Rent_schedules__c();
            rs = rsTemp;
            remark = rsTemp.Remarks__c;
            amount = rsTemp.Amount__c;
            commTax = rsTemp.Lease_Charge__r.Commercial_Tax_Apply__c;
            parentRSId = rsTemp.Id;
            isCloned = false;
        }
    }
}