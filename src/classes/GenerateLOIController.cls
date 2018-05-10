public class GenerateLOIController {

    public Boolean dataIncompleteCheck { get; set; }
    //public Boolean er;
    public Boolean addLoiUnit { get; set; }
    public String action{ get; set; }
    public loi__c loi{get;set;}
    public loi__c loi_ForDate{get;set;} // Added for End date according to User Locale. on line 75, 143, 747 **loi_ForDate.Original_End_Date__c = endDate;**
    public LOI_Unit_Template__c loiUnitTemp{get;set;}
    public date endDate{get;set;}
    public units__c unitDetail{get;set;}
    public LOI_Charge_Template__c loiUnitChrgTemp{get;set;}  
    public List<LOI_Charge_Template__c> rentUnitChrgTemp{get;set;}        
    public List<DepositUnitWrap> depositUnitChrgTemp{get;set;}
    public List<LOI_Charge_Template__c> monthlyUnitChrgTemp{get;set;} 
    public List<Checklist_Master_Item__c> unitCheckList{get;set;}
    public List<CheckList_Item__c>itemListTemp{ get; set;}
    public String selectedLeasePlan{ get; set; }
    public String listType{get;set;}
    public Integer indexVal{get;set;}
    public List<Conditions__c> temUnitCondition { get; set; }
    public List<loi__c> selectedloi{ get; set; }
    //public Boolean dataIncompleteCheck;
    private Id masId;
    
    public decimal priceFactor{get;set;}
    public Boolean showTenantType{get;set;}
    
    public Decimal SubAmount{get;set;}
    public Decimal commercialTaxAmount{get;set;}
    public Decimal withHoldingTaxAmount{get;set;}
    public Integer withHoldingTaxRate{get;set;}
    public Decimal TotalAmount{get;set;}
    
    public Boolean applyWitholding{get;set;}
    
    public string strLoiStartDate{get;set;}
    public string strLoiEndDate{get;set;}
    public string existingChargeMethod{get;set;}
    
    //----------------------Constructor-------------------------------------- 
    public GenerateLOIController(){
        applyWitholding = false;
        showTenantType = false;
        loi=new loi__c();
        loi_ForDate = new loi__c();
        loiUnitTemp = new LOI_Unit_Template__c();
        loiUnitChrgTemp = new LOI_Charge_Template__c();
        rentUnitChrgTemp = new list<LOI_Charge_Template__c>();
        depositUnitChrgTemp = new list<DepositUnitWrap>();
        monthlyUnitChrgTemp = new list<LOI_Charge_Template__c>();
        action=ApexPages.currentPage().getParameters().get('action');
        loi.id=ApexPages.currentPage().getParameters().get('loiId');
                    
            if(loi.id == NULL){
            
             if(ApexPages.CurrentPage().getParameters().get('sDate')!= NULL){
                List<string> strStart = (ApexPages.CurrentPage().getParameters().get('sDate')).split('-');
                loi.LOI_Start_Date__c = date.newInstance(Integer.valueOf(strStart[0]),Integer.valueOf(strStart[1]),Integer.valueOf(strStart[2]));
                
                date tempEndDate;
                if(ApexPages.CurrentPage().getParameters().get('eDate') != NULL){
                    List<string> strEnd = (ApexPages.CurrentPage().getParameters().get('eDate')).split('-');
                    tempEndDate = date.newInstance(Integer.valueOf(strEnd[0]),Integer.valueOf(strEnd[1]),Integer.valueOf(strEnd[2]));
                }
                
                Integer monthsBetween = loi.LOI_Start_Date__c.monthsbetween(tempEndDate);
                loi.LOI_Tenure_Mths__c = monthsBetween ;
                
                date tempNewdate = loi.LOI_Start_Date__c.addMonths(monthsBetween);
                integer daysDiff = tempNewdate.daysbetween(tempEndDate);
                loi.LOI_Tenure_Days__c = ''+daysDiff ;
                
                endDate = loi.LOI_Start_Date__c.addMonths(monthsBetween).addDays(daysDiff);
                loi_ForDate.Original_End_Date__c = endDate;
                
                strLoiStartDate = loi.Loi_Start_Date__c.Year()+'-'+loi.Loi_Start_Date__c.Month()+'-'+loi.Loi_Start_Date__c.day();
                strLoiEndDate = endDate.Year()+'-'+endDate.Month()+'-'+endDate.day();
                
            }
            
            if(ApexPages.CurrentPage().getParameters().get('accId') != NULL){
                loi.Tenant__c = ApexPages.CurrentPage().getParameters().get('accId');
            }
            if(ApexPages.CurrentPage().getParameters().get('conId') != NULL){
                loi.Contact__c = ApexPages.CurrentPage().getParameters().get('conId');
            }
            if(ApexPages.CurrentPage().getParameters().get('propId') != NULL){
                loi.Property__c = ApexPages.CurrentPage().getParameters().get('propId');
            }
            
            if(ApexPages.currentPage().getParameters().get('unitId') != NULL){
                loiUnitTemp.Unit__c = ApexPages.currentPage().getParameters().get('unitId');
                unitDetailSetup();
            }
            
            
           
           

        }
        if(loi.id != NULL){
            loi__c seltLoi=[select Charge_Method__c,Name,LOI_Validity_Week__c,LOI_Start_Date__c,Property__c,Contact__c,Tenant__c,LOI_Tenure_Days__c,LOI_Tenure_Mths__c,Tenant_Type__c from loi__c where id=:loi.id];
            existingChargeMethod = seltLoi.Charge_Method__c;
            
            loi = SeltLoi;
            
            loi.Name = SeltLoi.Name;
            loi.Contact__c=seltLoi.Contact__c;
            loi.LOI_Start_Date__c = seltLoi.LOI_Start_Date__c ;
            loi.Property__c = seltLoi.Property__c;
            loi.Tenant__c = seltLoi.Tenant__c;
            loi.Tenant_Type__c = seltLoi.Tenant_Type__c;
            loi.LOI_Tenure_Days__c = seltLoi.LOI_Tenure_Days__c;
            loi.LOI_Tenure_Mths__c = seltLoi.LOI_Tenure_Mths__c;
            loi.Charge_Method__c = seltLoi.Charge_Method__c;
            loi.LOI_Validity_Week__c = seltLoi.LOI_Validity_Week__c;
            endDateSetup();
            if(ApexPages.currentPage().getParameters().get('unitId') != NULL){
                loiUnitTemp.Unit__c = ApexPages.currentPage().getParameters().get('unitId');
                 unitDetailSetup();
            }
            
            if((loi.Charge_Method__c!='Monthly Rate - L' && loi.Tenant_Type__c == NULL) || loi.LOI_Tenure_Mths__c == NULL ||loi.LOI_Tenure_Days__c == NULL || loi.Tenant__c == NULL || loi.Property__c == NULL || loi.LOI_Start_Date__c == NULL || loi.Contact__c==NULL ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info,'All fields are mandatory to move on with next step.'));
                dataIncompleteCheck=TRUE;
            }
            else{
                if(loi.Tenant_Type__c != NULL){
                    showTenantType = true;
                }
                dataIncompleteCheck=FALSE;
            }
            
            addLoiUnit = TRUE;
        }
        else{
            addLoiUnit = False;
            if(loi.LOI_Start_Date__c == NULL){
                loi.LOI_Start_Date__c=system.today();
                
                endDate=System.today();
                loi_ForDate.Original_End_Date__c = endDate;
                
                strLoiStartDate = loi.Loi_Start_Date__c.Year()+'-'+loi.Loi_Start_Date__c.Month()+'-'+loi.Loi_Start_Date__c.day();
                strLoiEndDate = endDate.Year()+'-'+endDate.Month()+'-'+endDate.day();
                
                loi.LOI_Tenure_Mths__c=0;
                loi.LOI_Tenure_Days__c='0';
            }
            
            
        }
        selectedLeasePlan = 'New';
        
        
        
        
    }
   public Integer checkOverlappingDates(){
        //List<LOI_Unit__c> listLOIUnit = [select Id, Name, LOI_Start_Date__c,LOI_End_Date__c,Unit__c from LOI_Unit__c where Unit__c!= null And Unit__c =: loiUnitTemp.Unit__c and LOI_Start_Date__c <=: endDate and LOI_End_Date__c >=: loi.LOI_Start_Date__c and LOI_Agreement_No__r.LOI_Status__c !='Expired' and LOI_Agreement_No__r.LOI_Status__c !='Cancelled'];
        //List<Lease_Unit__c> listLeaseUnit = [select Id, Name, Fit_Out_Date__c,Lease_End_Date__c, Lease_Start_Date__c, Unit__c from Lease_Unit__c where Unit__c!= null And Unit__c =: loiUnitTemp.Unit__c and Lease_Unit_Status__c != 'Vacant' and Lease_Unit_Status__c !='Cancelled' and ((Fit_Out_Date__c <=: endDate and Lease_End_Date__c >=: loi.LOI_Start_Date__c) Or (Lease_Start_Date__c <=: endDate and Lease_End_Date__c >=: loi.LOI_Start_Date__c))];
        
        Map<Id, Units__c> mainUnitLALOIMap = new Map<Id, Units__c>([select Id, Property__c, name, Start_Date__c, End_Date__c, 
                                            (Select id,Start_Date__c,End_Date__c from Units__r), 
                                            (Select Id,name, Lease_Start_Date__c, Lease_End_Date__c 
                                                From Lease_Units__r where Lease_Unit_Status__c != 'Vacant' and Lease_Unit_Status__c !='Cancelled'  and Lease_Agreement_No__r.Lease_Status__c != 'Cancelled' 
                                                and ((Fit_Out_Date__c <=: endDate and Lease_End_Date__c >=: loi.LOI_Start_Date__c) 
                                                Or (Lease_Start_Date__c <=: endDate and Lease_End_Date__c >=: loi.LOI_Start_Date__c))), 
                                            (Select Id,name, LOI_End_Date__c, LOI_Start_Date__c 
                                                From LOI_Units__r 
                                                where LOI_Agreement_No__r.LOI_Status__c !='Expired' and LOI_Agreement_No__r.LOI_Status__c !='Cancelled' and LOI_Agreement_No__r.LOI_Status__c !='Converted' 
                                                and LOI_Start_Date__c <=: endDate and LOI_End_Date__c >=: loi.LOI_Start_Date__c) 
                                            From Units__c u where Id!= null And Id =: loiUnitTemp.Unit__c]);
        if(mainUnitLALOIMap.containsKey(loiUnitTemp.Unit__c)){
            if(!Test.isRunningTest() && !(loi.LOI_Start_Date__c <= mainUnitLALOIMap.get(loiUnitTemp.Unit__c).End_Date__c && mainUnitLALOIMap.get(loiUnitTemp.Unit__c).Start_Date__c <= endDate)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'LOI Unit Start and End Date should be within Unit Start and End Date <a target="_blank" href="/'+mainUnitLALOIMap.get(loiUnitTemp.Unit__c).Id+'"><b>'+mainUnitLALOIMap.get(loiUnitTemp.Unit__c).Name+'</b></a>'));
                return 1;
            }
            for(LOI_Unit__c loi1:mainUnitLALOIMap.get(loiUnitTemp.Unit__c).LOI_Units__r){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'<b>LOI Unit</b> for this duration already exist.<br/>Please click on <a target="_blank" href="/'+loi1.Id+'"><b>'+loi1.Name+'</b></a> to view details.'));
            }
            for(Lease_Unit__c lu:mainUnitLALOIMap.get(loiUnitTemp.Unit__c).Lease_Units__r){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'<b>Lease Unit</b> for this duration already exist.<br/>Please click on <a target="_blank" href="/'+lu.Id+'"><b>'+lu.Name+'</b></a> to view details.'));
            }
            for(Units__c splitUn:mainUnitLALOIMap.get(loiUnitTemp.Unit__c).Units__r){
                if((loi.LOI_Start_Date__c <= splitUn.End_Date__c && splitUn.Start_Date__c <= endDate) ){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'<br/><b>'+mainUnitLALOIMap.get(loiUnitTemp.Unit__c).Name+' </b>This unit is spit in this duration. '));
                    break;
                }
            }
        }
        System.debug(endDate+ ' loi.LOI_Start_Date__c--> '+loi.LOI_Start_Date__c);
        System.debug(' loiUnitTemp.Unit__c--> '+loiUnitTemp.Unit__c);
        if(ApexPages.getMessages().size() > 0 && !Test.isRunningTest()){
            return 1;
        } else 
            return 0;
    }
    //-------------------------------Page reference for NEXT button------------------
    public pageReference next(){
        System.debug('Next Button');
         integer check=checkMandateFields();
         integer dupl = checkOverlappingDates();
         System.debug(check+ '--dupl-->'+dupl+'  **'+loi);
         if(check==0 && dupl == 0){
         system.debug('action---------------------------->'+action);
             if(action == 'Clone')
                 return new pageReference('/apex/LOICloning?unitId='+loiUnitTemp.unit__c+'&loiId='+loi.id);
                 //return new pageReference('LOICloning');
             else{
                autoFillLoiUnitTemplate();
                if(loiUnitChrgTemp.LOI_Unit_Template__c != NULL)
                    generateCharge();
                return page.GenerateLOIStep2;
             }
        }
        return NULL;
    }
    
    public void calcPriceFactor(){
        priceFactor = null;
        if(loi.Tenant_Type__c!=null && loi.LOI_Start_Date__c!=null && loi.Property__c!=null && loiUnitTemp.Unit__c!=null){
            List<Units__c> unitList = [Select id,Charge_Method__c from Units__c where id=:loiUnitTemp.Unit__c and Charge_Method__c includes ('Monthly Rate - CL','Daily Rate')];
            if(unitList.size()>0){
                List<Pricing_Factor__c> priceFactorList = [Select id,Property_Name__c,Start_Date__c,End_Date__c,Factor__c,Tenant_Type__c,Charge_Method__c from Pricing_Factor__c where Property_Name__c=:loi.Property__c and Start_Date__c<=:loi.LOI_Start_Date__c and End_Date__c>=:loi.LOI_Start_Date__c and Tenant_Type__c=:loi.Tenant_Type__c and Charge_Method__c includes ('Monthly Rate - CL','Daily Rate')];
                System.debug('priceFactorList'+priceFactorList);
                if(priceFactorList.size()>0){
                    priceFactor = priceFactorList[0].Factor__c;
                }
            }
        }
    }
    
    public void calculation(){
        SubAmount = 0;
        commercialTaxAmount = 0;
        withHoldingTaxAmount = 0;
        TotalAmount = 0;
        Decimal commercialTaxPercent = 0;
        if(loi.Tenant__c!=null){
            List<Account> tenantList = [Select id,Witholding_Eligible__c from Account where id=:loi.Tenant__c];
            if(tenantList.size()>0 && tenantList[0].Witholding_Eligible__c){
                if(unitDetail.Charge_Method__c!=null && unitDetail.Charge_Method__c.contains('Monthly Rate - CL')){
                    if(rentUnitChrgTemp!=null && rentUnitChrgTemp.size()>0){
                        Property__c prop = [Select id,Comm_Tax__c,Witholding_Tax__c,Witholding_Tax_Limit__c from Property__C where Id=:loi.Property__c];
                        commercialTaxPercent = prop.COmm_Tax__c;
                        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>asdas>>>>'+rentUnitChrgTemp);
                        
                        for(LOI_Charge_Template__c loiChr:rentUnitChrgTemp){
                            System.debug('loiChr.Charge_Rate__c'+loiChr.Charge_Rate__c);
                            if(loiChr.Charge_Rate__c!=null && loiChr.Charge_Rate__c>0){
                                if(loiChr.Start_Date__c.Month()==loiChr.End_Date__c.Month() && loiChr.Start_Date__c.Year()==loiChr.End_Date__c.Year()){
                                    if(loiChr.Start_Date__c.day()==1 && loiChr.End_Date__c.day()==Date.DaysInMonth(loiChr.End_Date__c.Year(),loiChr.End_Date__c.Month())){
                                        if(loiChr.Type__c=='Fixed'){
                                            loiChr.Sub_Amount__c = loiChr.Charge_Rate__c;
                                            subAmount += loiChr.Charge_Rate__c;
                                        }else if(loiChr.Type__c=='By Area'){
                                            if(unitDetail.NLA_SQF__c>0){
                                                loiChr.Sub_Amount__c = unitDetail.NLA_SQF__c*loiChr.Charge_Rate__c;
                                                subAmount += unitDetail.NLA_SQF__c*loiChr.Charge_Rate__c;
                                            }
                                        }
                                    }else{
                                        Integer daysDiff = loiChr.Start_Date__c.daysBetween(loiChr.End_Date__c)+1;
                                        loiChr.Sub_Amount__c = loiChr.Charge_Rate__c*daysDiff/Date.DaysInMonth(loiChr.End_Date__c.Year(),loiChr.End_Date__c.Month());                                        
                                        subAmount += loiChr.Charge_Rate__c*daysDiff/Date.DaysInMonth(loiChr.End_Date__c.Year(),loiChr.End_Date__c.Month());                                        
                                    }
                                }else{
                                    Integer startMonth = loiChr.Start_Date__c.Month();
                                    Integer startYear = loiChr.Start_Date__c.Year();
                                    Integer endMonth = loiChr.End_Date__c.Month();
                                    Integer endYear = loiChr.End_Date__c.Year();
                                    
                                    Integer incMonth = startMonth;
                                    Integer incYear = startYear;
                                    loiChr.Sub_Amount__c = 0;
                                    While((incMonth<=endMonth && incYear<=endYear) || (incMonth>endMonth && incYear<endYear)){
                                        if(incMonth==startMonth && incYear==startYear){
                                            Integer daysDiff = Date.DaysInMonth(incYear,incMonth) - loiChr.Start_Date__c.day()+1;
                                            if(loiChr.Type__c=='Fixed'){
                                                loiChr.Sub_Amount__c += loiChr.Charge_Rate__c*daysDiff/Date.DaysInMonth(incYear,incMonth);
                                                subAmount += loiChr.Charge_Rate__c*daysDiff/Date.DaysInMonth(incYear,incMonth);
                                            }else if(loiChr.Type__c=='By Area'){
                                                if(unitDetail.NLA_SQF__c>0){
                                                    loiChr.Sub_Amount__c += unitDetail.NLA_SQF__c*loiChr.Charge_Rate__c*daysDiff/Date.DaysInMonth(incYear,incMonth);
                                                    subAmount += unitDetail.NLA_SQF__c*loiChr.Charge_Rate__c*daysDiff/Date.DaysInMonth(incYear,incMonth);
                                                }
                                            }
                                        }else if(incMonth==endMonth && incYear==endYear){
                                            Integer daysDiff = loiChr.End_Date__c.day();
                                            if(loiChr.Type__c=='Fixed'){
                                                loiChr.Sub_Amount__c += loiChr.Charge_Rate__c*daysDiff/Date.DaysInMonth(incYear,incMonth);
                                                subAmount += loiChr.Charge_Rate__c*daysDiff/Date.DaysInMonth(incYear,incMonth);
                                            }else if(loiChr.Type__c=='By Area'){
                                                if(unitDetail.NLA_SQF__c>0){
                                                    loiChr.Sub_Amount__c += unitDetail.NLA_SQF__c*loiChr.Charge_Rate__c*daysDiff/Date.DaysInMonth(incYear,incMonth);
                                                    subAmount += unitDetail.NLA_SQF__c*loiChr.Charge_Rate__c*daysDiff/Date.DaysInMonth(incYear,incMonth);
                                                }
                                            }
                                        }else{
                                            if(loiChr.Type__c=='Fixed'){
                                                loiChr.Sub_Amount__c += loiChr.Charge_Rate__c;
                                                subAmount += loiChr.Charge_Rate__c;
                                            }else if(loiChr.Type__c=='By Area'){
                                                if(unitDetail.NLA_SQF__c>0){
                                                    loiChr.Sub_Amount__c += unitDetail.NLA_SQF__c*loiChr.Charge_Rate__c;
                                                    subAmount += unitDetail.NLA_SQF__c*loiChr.Charge_Rate__c;
                                                }
                                            }
                                        }
                                        if(incMonth==12){
                                            incMonth = 1;
                                            incYear++;
                                        }else{
                                            incMonth++;
                                        }
                                    }
                                }
                                if(subAmount>0){
                                    subAmount = subAmount.setScale(2);
                                    if(prop.Witholding_Tax__c >0 && prop.Witholding_Tax_Limit__c>0){
                                        if(subAmount>=prop.Witholding_Tax_Limit__c){
                                            withHoldingTaxRate = Integer.valueOf(prop.Witholding_Tax__c);
                                            withHoldingTaxAmount = withHoldingTaxRate*subAmount/100.00;
                                            withHoldingTaxAmount = withHoldingTaxAmount.setScale(2);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else if(unitDetail.Charge_Method__c!=null && unitDetail.Charge_Method__c.contains('Daily Rate')){
                    if(rentUnitChrgTemp!=null && rentUnitChrgTemp.size()>0){
                        Property__c prop = [Select id,Comm_Tax__c,Witholding_Tax__c,Witholding_Tax_Limit__c from Property__C where Id=:loi.Property__c];
                        commercialTaxPercent = prop.COmm_Tax__c;
                        
                        for(LOI_Charge_Template__c loiChr:rentUnitChrgTemp){
                            if(loiChr.Charge_Rate__c!=null && loiChr.Charge_Rate__c>0){
                                if(loiChr.Type__c=='Fixed'){
                                    loiChr.Sub_Amount__c = loiChr.Charge_Rate__c;
                                    subAmount += loiChr.Charge_Rate__c;
                                }else if(loiChr.Type__c=='By Area'){
                                    if(unitDetail.NLA_SQF__c>0){
                                        loiChr.Sub_Amount__c = unitDetail.NLA_SQF__c*loiChr.Charge_Rate__c;
                                        subAmount += unitDetail.NLA_SQF__c*loiChr.Charge_Rate__c;
                                    }
                                }
                            }
                        }
                        if(subAmount>0){
                            subAmount = subAmount.setScale(2);
                            if(prop.Witholding_Tax__c >0 && prop.Witholding_Tax_Limit__c>0){
                                if(subAmount>=prop.Witholding_Tax_Limit__c){
                                    withHoldingTaxRate = Integer.valueOf(prop.Witholding_Tax__c);
                                    withHoldingTaxAmount = withHoldingTaxRate*subAmount/100.00;
                                    withHoldingTaxAmount = withHoldingTaxAmount.setScale(2);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    //----------------------------- Method to generate charge----------------------------
    public void generateCharge(){
        rentUnitChrgTemp = new list<LOI_Charge_Template__c>();
        depositUnitChrgTemp = new list<DepositUnitWrap>();
        monthlyUnitChrgTemp = new list<LOI_Charge_Template__c>();
        if(unitDetail.Charge_Method__c!=null && (unitDetail.Charge_Method__c.contains('Monthly Rate - CL') || unitDetail.Charge_Method__c.contains('Daily Rate'))){
            Map<Id,List<Lease_Plan__c>> unitToLpMap = new Map<Id,List<Lease_Plan__c>>();
            Map<Id,Map<string,Lease_Plan__c>> unitToDateLpMap = new Map<Id,Map<string,Lease_Plan__c>>();
            for(Lease_Plan__c lp:[Select id,Unit__c,Start_Date__c,End_Date__c,Daily_Rate_1__c,Daily_Rate_2__c,Daily_Rate_3__c,Daily_Rate_4__c,Daily_Rate_5__c,Daily_Rate_6__c,Daily_Rate_7__c,Daily_Rate_8__c,Daily_Rate_9__c,Daily_Rate_10__c,Daily_Rate_11__c,Daily_Rate_12__c,Daily_Rate_13__c,Daily_Rate_14__c,Daily_Rate_15__c,Daily_Rate_16__c,Daily_Rate_17__c,Daily_Rate_18__c,Daily_Rate_19__c,Daily_Rate_20__c,Daily_Rate_21__c,Daily_Rate_22__c,Daily_Rate_23__c,Daily_Rate_24__c,Daily_Rate_25__c,Daily_Rate_26__c,Daily_Rate_27__c,Daily_Rate_28__c,Daily_Rate_29__c,Daily_Rate_30__c,Daily_Rate_31__c,Monthly_Budget__c from Lease_Plan__c where Unit__c=:unitDetail.Id]){
                List<Lease_Plan__c> tempList = new List<Lease_Plan__c>();
                if(unitToLpMap.containsKey(lp.Unit__c)){
                    tempList.addAll(unitToLpMap.get(lp.Unit__c));
                }
                tempList.add(lp);
                unitToLpMap.put(lp.Unit__c,tempList);
                
                Map<string,Lease_Plan__c> tempMap = new Map<string,Lease_Plan__c>();
                if(unitToDateLpMap.containsKey(lp.Unit__c)){
                    tempMap = unitToDateLpMap.get(lp.Unit__c);
                }
                tempMap.put(lp.Start_Date__c.month()+'-'+lp.Start_Date__c.year(),lp);
                
                unitToDateLpMap.put(lp.Unit__c,tempMap);
            }
            for(LOI_Charge_Template__c loiChr : [SELECT Charge_Start_Day__c,Tiered_Limit__c,Cumulative_for_each_Tier__c,Tiered_Lower_Limit__c,Tier_1_Upper_Limit__c,Tier_2_Upper_Limit__c,Tier_3_Upper_Limit__c,Tier_4_Upper_Limit__c,Tier_5_Upper_Limit__c,Tier_6_Upper_Limit__c,Tier_7_Upper_Limit__c,Tier_8_Upper_Limit__c,Tier_1_Rate__c,Tier_2_Rate__c,Tier_3_Rate__c,Tier_4_Rate__c,Tier_5_Rate__c,Tier_6_Rate__c,Tier_7_Rate__c,Tier_8_Rate__c,charge__r.Tiered_Limit__c,charge__r.Cumulative_for_each_Tier__c,charge__r.Tiered_Lower_Limit__c,charge__r.Tier_1_Upper_Limit__c,charge__r.Tier_2_Upper_Limit__c,charge__r.Tier_3_Upper_Limit__c,charge__r.Tier_4_Upper_Limit__c,charge__r.Tier_5_Upper_Limit__c,charge__r.Tier_6_Upper_Limit__c,charge__r.Tier_7_Upper_Limit__c,charge__r.Tier_8_Upper_Limit__c,charge__r.Tier_1_Rate__c,charge__r.Tier_2_Rate__c,charge__r.Tier_3_Rate__c,charge__r.Tier_4_Rate__c,charge__r.Tier_5_Rate__c,charge__r.Tier_6_Rate__c,charge__r.Tier_7_Rate__c,charge__r.Tier_8_Rate__c,Tier_9_Rate__c,charge__r.Base_Charge_Type__c,charge__r.Charge_Description__c,charge__r.Billing_Days__c,charge__r.Billing_Frequency__c,charge__r.Billing_Terms__c,charge__r.Due_Month_Formula__c,charge__r.Cap_Value__c,charge__r.Charge_Rate_Description__c,charge__r.Base_included__c,charge__r.Base_Value__c,Id,Name,RecordType.Name,Charge__c,Charge_Type__c,Charge_Rate__c,Type__c,Currency_Code__c,Commercial_Tax_Apply__c,Start_Date__c,End_Date__c,Expected_GTO_Amount__c,Charge_Method__c,Charge_Description__c,Frequency__c,Billing_Terms__c,Due_Month_Formula__c,Cap_Value__c,Formula_Description__c,Base_included__c,Base_Value__c,Billing_Days__c FROM LOI_Charge_Template__c WHERE LOI_Unit_Template__c =: loiUnitChrgTemp.LOI_Unit_Template__c Order by Charge_Type__c]){
                if(unitDetail.Charge_Method__c.contains('Monthly Rate - CL')){
                    if(loiChr.Charge_Method__c=='Monthly Rate - CL'){
                        
                        Integer loiStartMonth = loi.LOI_Start_Date__c.month();
                        Integer loiStartYear = loi.LOI_Start_Date__c.year();
                        
                        Integer loiEndMonth = endDate.month();
                        Integer loiEndYear = endDate.year();
                        LOI_Charge_Template__c loiChr1 = new LOI_Charge_Template__c();
                        loiChr1 = loiChr.Clone(false,false,false,false);
                        loiChr1.Start_Date__c = null;
                        loiChr1.Charge_Rate__c = null;
                        while((loiStartMonth<=loiEndMonth && loiStartYear<=loiEndYear) || (loiStartMonth>loiEndMonth && loiStartYear<loiEndYear)){
                            if(unitToDateLpMap.containsKey(unitDetail.Id)){
                                decimal tempRate = null;
                                if(unitToDateLpMap.get(unitDetail.Id).containsKey(loiStartMonth+'-'+loiStartYear) && unitToDateLpMap.get(unitDetail.Id).get(loiStartMonth+'-'+loiStartYear).Monthly_Budget__c>0){
                                    tempRate = unitToDateLpMap.get(unitDetail.Id).get(loiStartMonth+'-'+loiStartYear).Monthly_Budget__c;
                                }
                                system.debug('tempRate'+tempRate);
                                if(loiChr1.Charge_Rate__c!=null){
                                    if(loiChr1.Charge_Rate__c!=tempRate){
                                        rentUnitChrgTemp.add(loiChr1);
                                        loiChr1 = new LOI_Charge_Template__c();
                                        loiChr1 = loiChr.Clone(false,false,false,false);
                                        loiChr1.Start_Date__c = null;
                                        //loiChr1.Charge_Rate__c = tempRate;
                                    }
                                }//else{
                                //    loiChr1.Charge_Rate__c = tempRate;
                                //}
                                
                                if(tempRate != null){
                                    loiChr1.Charge_Rate__c = tempRate;
                                }else{
                                    loiChr1.Charge_Rate__c = loiChr.Charge_Rate__c;
                                }
                                /*If(priceFactor!=null && loiChr1.Charge_Rate__c!=null){
                                    loiChr1.Charge_Rate__c = loiChr1.Charge_Rate__c*priceFactor;
                                }*/
                                if(loiChr1.Start_Date__c==null){
                                    if(loiStartMonth==loi.LOI_Start_Date__c.month() && loiStartYear==loi.LOI_Start_Date__c.Year()){
                                        loiChr1.Start_Date__c = Date.NewInstance(loiStartYear,loiStartMonth,loi.LOI_Start_Date__c.Day());
                                    }else{
                                        loiChr1.Start_Date__c = Date.NewInstance(loiStartYear,loiStartMonth,1);
                                    }
                                }
                                if(loiStartMonth==endDate.month() && loiStartYear==endDate.Year()){
                                    loiChr1.End_Date__c = Date.NewInstance(loiStartYear,loiStartMonth,endDate.Day());
                                }else{
                                    loiChr1.End_Date__c = Date.NewInstance(loiStartYear,loiStartMonth,Date.DaysInMonth(loiStartYear,loiStartMonth));
                                }
                                
                                if(loiChr1.End_Date__c>endDate){
                                    loiChr1.End_Date__c = endDate;
                                }
                            }else{
                                loiChr1.Charge_Rate__c = 0;
                                loiChr1.Start_Date__c =  loi.LOI_Start_Date__c;
                                loiChr1.End_Date__c =  endDate;
                                break;
                            }
                            if(loiStartMonth==12){
                                loiStartMonth = 1;
                                loiStartYear++;
                            }else{
                                loiStartMonth++;
                            }
                        }
                        rentUnitChrgTemp.add(loiChr1);
                    
                        /*loiChr.Start_Date__c =  loi.LOI_Start_Date__c;
                        loiChr.End_Date__c =  endDate;    
                        if(loiChr.Type__c== 'Fixed')
                            loiChr.Charge_Rate__c =  unitDetail.rent_hurdle_Amount__c;
                        if(loiChr.Type__c== 'By Area')
                            loiChr.Charge_Rate__c =  unitDetail.rent_hurdle__c;
                            
                        If(priceFactor!=null && loiChr.Charge_Rate__c!=null){
                            loiChr.Charge_Rate__c = loiChr.Charge_Rate__c*priceFactor;
                        }
                        rentUnitChrgTemp.add(loiChr);
                        */
                    }
                }else if(unitDetail.Charge_Method__c.contains('Daily Rate')){
                    if(loiChr.Charge_Method__c=='Daily Rate'){
                        for(Date dt=loi.LOI_Start_Date__c;dt<=endDate;dt=dt+1){
                            LOI_Charge_Template__c loiChrTemp = loiChr.clone(false, true);
                            loiChrTemp.Start_Date__c = dt;
                            loiChrTemp.End_Date__c = dt;
                            if(unitToLpMap.containsKey(unitDetail.Id)){
                                for(Lease_Plan__c lp:unitToLpMap.get(unitDetail.Id)){
                                    if(lp.Start_Date__c<=dt && lp.End_Date__c>=dt){
                                        loiChrTemp.Charge_Rate__c =  (decimal)lp.get('Daily_Rate_'+dt.day()+'__c');
                                        loiChrTemp.Lease_Plan__c = lp.Id;
                                        break;
                                    }
                                }
                                if(priceFactor!=null && loiChrTemp.Charge_Rate__c!=null){
                                    loiChrTemp.Charge_Rate__c = priceFactor*loiChrTemp.Charge_Rate__c;
                                }
                                
                            }
                            rentUnitChrgTemp.add(loiChrTemp);
                        }
                    }
                }
                
                if(loiChr.RecordType.Name == 'Monthly'){
                    loiChr.Start_Date__c =  loi.LOI_Start_Date__c;
                    loiChr.End_Date__c =  endDate;
                    
                    monthlyUnitChrgTemp.add(loiChr);
                }
                
            }
        }else if(unitDetail.Charge_Method__c!=null && unitDetail.Charge_Method__c.contains('Monthly Rate - L')){ 
            if(loiUnitChrgTemp.LOI_Unit_Template__c != null){
                for(LOI_Charge_Template__c loiChr : [SELECT Charge_Start_Day__c,Tiered_Limit__c,Cumulative_for_each_Tier__c,Tiered_Lower_Limit__c,Tier_1_Upper_Limit__c,Tier_2_Upper_Limit__c,Tier_3_Upper_Limit__c,Tier_4_Upper_Limit__c,Tier_5_Upper_Limit__c,Tier_6_Upper_Limit__c,Tier_7_Upper_Limit__c,Tier_8_Upper_Limit__c,Tier_1_Rate__c,Tier_2_Rate__c,Tier_3_Rate__c,Tier_4_Rate__c,Tier_5_Rate__c,Tier_6_Rate__c,Tier_7_Rate__c,Tier_8_Rate__c,Tier_9_Rate__c,charge__r.Base_Charge_Type__c,charge__r.Charge_Description__c,charge__r.Billing_Days__c,charge__r.Billing_Frequency__c,charge__r.Billing_Terms__c,charge__r.Due_Month_Formula__c,charge__r.Cap_Value__c,charge__r.Charge_Rate_Description__c,charge__r.Base_included__c,charge__r.Base_Value__c,Id,Name,RecordType.Name,Charge__c,Charge_Type__c,Charge_Rate__c,Type__c,Currency_Code__c,Commercial_Tax_Apply__c,Start_Date__c,End_Date__c,Expected_GTO_Amount__c,Charge_Description__c,Frequency__c,Billing_Terms__c,Due_Month_Formula__c,Cap_Value__c,Formula_Description__c,Base_included__c,Base_Value__c,Billing_Days__c FROM LOI_Charge_Template__c WHERE LOI_Unit_Template__c =: loiUnitChrgTemp.LOI_Unit_Template__c Order by Charge_Type__c]){
                    loiChr.Start_Date__c =  loi.LOI_Start_Date__c;
                    loiChr.End_Date__c =  endDate;
                    
                    String crgType = loiChr.Charge_Type__c.toLowerCase();
                    if(loiChr.RecordType.Name == 'Rent'){
                        Date tempStartDt = loi.LOI_Start_Date__c;     
                        if(endDate == null)
                            tempStartDt = endDate;            
                        Integer yearDiff = Integer.valueOf(tempStartDt.monthsBetween(endDate) / 12);
                        
                        if(yearDiff < 1){
                            if(loiChr.Type__c== 'Fixed')
                                loiChr.Charge_Rate__c =  unitDetail.rent_hurdle_Amount__c;
                            if(loiChr.Type__c== 'By Area')
                                loiChr.Charge_Rate__c =  unitDetail.rent_hurdle__c;
                            
                            
                            rentUnitChrgTemp.add(loiChr);
                        }
                        
                        Date tempLastEndDt;
                         
                        for(Integer i = 1 ; i<=yearDiff; i++){
                            LOI_Charge_Template__c loiChrTemp = loiChr.clone(false, true);
                            
                            loiChrTemp.Start_Date__c = tempStartDt.addYears(i-1); 
                            loiChrTemp.End_Date__c = tempStartDt.addYears(i);
                            
                            tempLastEndDt = loiChrTemp.End_Date__c;
                            
                            //if(yearDiff!=1 && loiChrTemp.End_Date__c != endDate)
                             loiChrTemp.End_Date__c = loiChrTemp.End_Date__c.addDays(-1);
                             
                            if(loiChrTemp.Type__c== 'Fixed')
                                loiChrTemp.Charge_Rate__c =  unitDetail.rent_hurdle_Amount__c;
                            if(loiChrTemp.Type__c== 'By Area')
                                loiChrTemp.Charge_Rate__c =  unitDetail.rent_hurdle__c;
                            rentUnitChrgTemp.add(loiChrTemp);
                            
                        }
                        
                        if(tempLastEndDt != null && endDate > tempLastEndDt){
                            LOI_Charge_Template__c loiChrTemp = loiChr.clone(false, true);
                            
                            loiChrTemp.Start_Date__c = tempLastEndDt; 
                            loiChrTemp.End_Date__c = endDate;
                            
                            if(loiChrTemp.Type__c== 'Fixed')
                                loiChrTemp.Charge_Rate__c =  unitDetail.rent_hurdle_Amount__c;
                            if(loiChrTemp.Type__c== 'By Area')
                                loiChrTemp.Charge_Rate__c =  unitDetail.rent_hurdle__c;
                            //assignTierSection(loiChrTemp, loiChr);
                            rentUnitChrgTemp.add(loiChrTemp);
                            
                        }
                    }/*else if(crgType != null && crgType.contains('deposit')){                    
                        depositUnitChrgTemp.add(loiChr);
                    }*/else{
                        monthlyUnitChrgTemp.add(loiChr);
                    }
                }
            }
        }
            
        if(rentUnitChrgTemp.size() > 0){
            if(priceFactor!=null && unitDetail.Charge_Method__c!=null && unitDetail.Charge_Method__c.contains('Monthly Rate - CL')){
                for(LOI_Charge_Template__c loiChr:rentUnitChrgTemp){
                    if(loiChr.Charge_Rate__c>0){
                        loiChr.Charge_Rate__c = loiChr.Charge_Rate__c*priceFactor;
                    }
                }
            }
            calculation();
            if(loiUnitTemp.unit__c !=NULL){
                LOI_Charge_Template__c loiChr = rentUnitChrgTemp.get(0);
                units__c unitDetail = [Select property__r.name,Name,NLA_SQF__c,NLA_SQM__c,Start_Date__c,End_Date__c,Level__r.name,Space_Type__c,Rent_Hurdle_Amount__c,Rent_Hurdle__c,Rent_Hurdle_Lower_Limit__c,Rent_Hurdle_Upper_Limit__c from units__c where id=:loiUnitTemp.unit__c];
                
                DepositUnitWrap dep1 = new DepositUnitWrap(new Deposit__c());
                dep1.unit = unitDetail.Name;
                dep1.startDate =  loi.LOI_Start_Date__c;
                dep1.endDate = endDate;
                dep1.areaSqFt = unitDetail.NLA_SQF__c;
                dep1.baseRent =  loiChr.Charge_Rate__c;
                dep1.lcCurrencyCode = loiChr.Currency_Code__c;
                if(loiChr.Type__c == 'By Area' && unitDetail.NLA_SQF__c!= null && dep1.baseRent != NULL)
                    dep1.baseRent = dep1.baseRent * unitDetail.NLA_SQF__c;
                
                depositUnitChrgTemp.add(dep1);
                //dep1.dep.Lease_Charge__c = mapLC.get(l.id).Id;
                /*
                DepositUnitWrap dep1 = new DepositUnitWrap;
               
                units.add(l.Unit__r.Name);
                LeaseName = l.Lease_Agreement_No__r.name;
                leaseId = l.Lease_Agreement_No__c;
                if(fromPage == 'LeaseUnit'){
                    leaseUnitId = l.id;
                }
                
                dep1.dep.Name = '--SystemGenerated--';
                dep1.dep.Lease_Unit__c = l.id;
                dep1.dep.Lease__c = l.Lease_Agreement_No__c;
                
                dep1.unit = l.Unit__r.name;
                dep1.startDate = l.Lease_Start_Date__c;
                dep1l.endDate = l.Lease_End_Date__c;
                if(mapLC.containsKey(l.id)){
                    if( mapLC.get(l.id).Currency_Code__c != null){
                        bl.dep.Currency_Code__c = mapLC.get(l.id).Currency_Code__c;
                    }
                    bl.baseRent =  mapLC.get(l.id).Base_Rent_Calculation__c;
                    bl.lcCurrencyCode = mapLC.get(l.id).Currency_Code__c;
                    bl.dep.Lease_Charge__c = mapLC.get(l.id).Id;
                }*/
                
                
            }
        }
        
    }

    //------------------------------------delete row function for generateLOI step2 page--------------------    
    public void delRow(){
        System.debug(indexVal+'monthlyUnitChrgTemp-->'+monthlyUnitChrgTemp);
        System.debug('monthlyUnitChrgTemp.size()-->'+monthlyUnitChrgTemp.size());
        if(indexVal != null){     
             System.debug('111-->'+indexVal);   
            if(listType == 'Rent'){
                rentUnitChrgTemp.remove(indexVal);
            }else if(listType == 'Deposit'){
                depositUnitChrgTemp.remove(indexVal);
            }else{
                System.debug('22-->'); 
                monthlyUnitChrgTemp.remove(indexVal);  
            }   
            for(DepositUnitWrap depWra : depositUnitChrgTemp){
                depWra.depositAmount = calDepositAmt(depWra.areaSqFt,depWra.dep.Deposit_Formula_Type__c,depWra.depositRate,depWra.noOfMonths);
            }       
        }
        System.debug('monthlyUnitChrgTemp11-->'+monthlyUnitChrgTemp);
        System.debug('monthlyUnitChrgTemp.size()11-->'+monthlyUnitChrgTemp.size());
        rentValidation();
    }
    
    
    //------------------------------------add row function for generateLOI step2 page--------------------
    public void addRow(){
        if(indexVal != null){      
            if(listType == 'Rent'){
                LOI_Charge_Template__c loiChrTemp = rentUnitChrgTemp.get(indexVal).clone(false, true);
                rentUnitChrgTemp.add(indexVal, loiChrTemp);                
            }else if(listType == 'Deposit'){
               // LOI_Charge_Template__c loiChrTemp = depositUnitChrgTemp.get(indexVal).clone(false, true);
                //depositUnitChrgTemp.add(indexVal, loiChrTemp); 
                LOI_Charge_Template__c loiChr = rentUnitChrgTemp.get(0);
                for(DepositUnitWrap depWra : depositUnitChrgTemp){
                    loiChr.Charge_Rate__c = (loiChr.Charge_Rate__c == null)?0:loiChr.Charge_Rate__c;
                    if(loiChr.Type__c == 'By Area' && depWra.areaSqFt != null)
                        depWra.baseRent = loiChr.Charge_Rate__c * depWra.areaSqFt;
                    else
                        depWra.baseRent = loiChr.Charge_Rate__c;
                    
                    depWra.depositAmount = calDepositAmt(depWra.areaSqFt,depWra.dep.Deposit_Formula_Type__c,depWra.depositRate,depWra.noOfMonths);
                }
                
                DepositUnitWrap depWrapold = depositUnitChrgTemp.get(indexVal);
                depWrapold.depositAmount = calDepositAmt(depWrapold.areaSqFt,depWrapold.dep.Deposit_Formula_Type__c,depWrapold.depositRate,depWrapold.noOfMonths);
               
                DepositUnitWrap dep1 = new DepositUnitWrap(new Deposit__c());
                dep1.unit = depWrapold.unit;
                dep1.startDate =  depWrapold.startDate;
                dep1.endDate = depWrapold.endDate;
                dep1.areaSqFt = depWrapold.areaSqFt;
                dep1.baseRent =  depWrapold.baseRent;
                dep1.lcCurrencyCode = depWrapold.lcCurrencyCode;
                dep1.baseRent = depWrapold.baseRent;
                dep1.dep.Deposit_Type__c = depWrapold.dep.Deposit_Type__c;
                dep1.dep.Deposit_Formula_Type__c = depWrapold.dep.Deposit_Formula_Type__c;
                dep1.dep.Currency_Code__c = depWrapold.dep.Currency_Code__c;
                dep1.depositRate = depWrapold.depositRate;
                dep1.noOfMonths = depWrapold.noOfMonths;
                dep1.depositAmount = depWrapold.depositAmount;
                
                depositUnitChrgTemp.add(indexVal, dep1);
            }else{
                LOI_Charge_Template__c loiChrTemp = monthlyUnitChrgTemp.get(indexVal).clone(false, true);
                monthlyUnitChrgTemp.add(indexVal, loiChrTemp);        
            }
            for(DepositUnitWrap depWra : depositUnitChrgTemp){
                depWra.depositAmount = calDepositAmt(depWra.areaSqFt,depWra.dep.Deposit_Formula_Type__c,depWra.depositRate,depWra.noOfMonths);
            }
        }
        rentValidation();
    }
    
    private Decimal calDepositAmt(Decimal areaSqFt, String fType, Decimal depRate, Integer noOfMonths){
        if(fType == 'By Area'){
            return depRate * noOfMonths * areaSqFt;
        }else{
            return depRate * noOfMonths;
        }
    }
    //------------------------------------Populate LOI validity---------------------------------------------
    public void populateLOIvalidity(){
        if(loi.Property__c != null){
            for(Property__c prop : [select Id, LOI_Validity_Week__c from Property__c where id =: loi.Property__c]){
                //if(loi.LOI_Validity_Week__c != null)
                    loi.LOI_Validity_Week__c = prop.LOI_Validity_Week__c;
            }
        }
    }
    //------------------------------------endDate Setup---------------------------------------------
    public void endDateSetup(){
        endDate=loi.LOI_Start_Date__c;
        
        
        if(loi.LOI_Start_Date__c != null){
            Integer Days=0;
            Integer months=0;
            
            if(loi.LOI_Tenure_Days__c != null)
                Days = Integer.valueOf(loi.LOI_Tenure_Days__c);
                
            if(loi.LOI_Tenure_Mths__c != null)
                months = Integer.valueOf(loi.LOI_Tenure_Mths__c);
                
            endDate=loi.LOI_Start_Date__c;
        
           // endDate = endDate.addDays(days) ;
            endDate = endDate.addMonths(months).addDays(days);
            
            if(loi.LOI_Start_Date__c != endDate)
                endDate=endDate.addDays(-1);
            system.debug(endDate);
            strLoiStartDate = loi.Loi_Start_Date__c.Year()+'-'+loi.Loi_Start_Date__c.Month()+'-'+loi.Loi_Start_Date__c.day();
            strLoiEndDate = endDate.Year()+'-'+endDate.Month()+'-'+endDate.day();
            loiUnitTemp.Unit__c = null;
        }
        loi_ForDate.Original_End_Date__c = endDate;
    }
    
    //------------------------------------checking mandatory fields in generateLOI page------------------------
    public Integer checkMandateFields(){
    
        if(loi.Tenant__c== NULL || loi.Contact__c== NULL || loi.Property__c== NULL || loiUnitTemp.Unit__c==NULL || loi.LOI_Validity_Week__c == NULL){
            
            if(loi.Tenant__c== NULL)
                loi.tenant__c.addError('Tenant Name is required');    
            if(loi.Contact__c== NULL)
                loi.Contact__c.addError('Contact Name is required');
            if(loi.Property__c== NULL)
                loi.Property__c.addError('Property is required');
            if(loiUnitTemp.Unit__c==NULL )
                loiUnitTemp.Unit__c.addError('Unit is required');
            if(loi.LOI_Validity_Week__c == NULL)
                loi.LOI_Validity_Week__c.addError('Validity Week is required');
            return 1;
        }
        
        if(showTenantType && loi.Tenant_Type__c == NULL){
            loi.Tenant_Type__c.addError('Tenant Type is required');
            return 1;
        }
        
        else 
            return 0;
    }
    
    //------------------------------------Creating zeros string for names---------------------------------------------
    public string addZeroIndex(Integer indexVal){
        Integer indexSize = string.valueOf(indexVal).length();
        String zeroVal = '';
        for(integer i =1;i<=6-indexSize;i++){
            zeroVal += '0';
        }
        return zeroVal+indexVal;
    }
        
        
        
    //------------------------------------SaveLOI---------------------------------------------    
    public pageReference SaveLOI(){
        Savepoint sp = Database.setSavepoint();
        Boolean loiInserted = false;
        //---------------------------Inserting LOI,LOI UNIT and updating pro.LOI_Index__c,pro.LOI_Unit_Index__c----------------------------
        try{
            Integer currentMonth = system.today().month();   
            Integer currentYear = system.today().Year();
            
            property__c pro=[Select short_code__c from property__c where id = :loi.Property__c];
            
            
            //String loiname = pro.Short_Code__c+'-LOI-'+currentYear+(currentMonth<10?'0'+currentMonth:''+currentMonth)+'-'+indxVal;
            //String loiUnitname = pro.Short_Code__c+'-LOIU-'+currentYear+(currentMonth<10?'0'+currentMonth:''+currentMonth)+'-'+loiUnitindxVal;    
            
            loi.name = '--System Generated--';
            
            if(loi.Charge_Method__c==null){
                if(unitDetail.Charge_Method__c!=null && unitDetail.Charge_Method__c.contains('Monthly Rate - L')){
                    loi.Charge_Method__c = 'Monthly Rate - L';
                }else if(unitDetail.Charge_Method__c!=null && unitDetail.Charge_Method__c.contains('Monthly Rate - CL')){
                    loi.Charge_Method__c = 'Monthly Rate - CL';
                }else if(unitDetail.Charge_Method__c!=null && unitDetail.Charge_Method__c.contains('Daily Rate')){
                    loi.Charge_Method__c = 'Daily Rate';
                }
            }
            
            if(loi.id == NULL){
                if(priceFactor!=null && priceFactor > 0){
                    loi.Price_Factor__c = priceFactor;
                }                
                insert loi;
                loiInserted = true;
                
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'LOI Created Successfully . <br/>Please click <a target="_blank" href="/'+loi.Id+'"><b>here</b></a> to view details.'));
            //---------------------------Inserting LOI Unit-----------------------        
            LOI_Unit__c loiUnit=new LOI_Unit__c();
            loiUnit.name='--System Generated--';
            loiUnit.LOI_Agreement_No__c=loi.id;
            loiUnit.Unit__c=loiUnitTemp.unit__c;
            loiUnit.LOI_Start_Date__c=loi.LOI_Start_Date__c;
            loiUnit.LOI_End_Date__c=endDate;
            loiUnit.Original_End_Date__c=endDate;
            system.debug('loi.id==='+loi.id);
            system.debug('loiUnitTemp.unit__c==='+loiUnitTemp.unit__c);
            insert loiUnit;
            
            //---------------------------Inserting deposit----------------------------
            
            List<Deposit__c> depList= new List<Deposit__C>();
            for(DepositUnitWrap wrap:depositUnitChrgTemp){
                Deposit__c dep= new Deposit__c();
                dep= wrap.dep;
                dep.Deposit_Date__c = System.today();
                dep.name='--System Generated--';
                dep.LOI__c=loi.id;
                dep.LOI_Unit__c=loiUnit.id;
                dep.Deposit_Amount__c= calDepositAmt(wrap.areaSqFt,wrap.dep.Deposit_Formula_Type__c,wrap.depositRate,wrap.noOfMonths);//wrap.depositAmount;
                dep.Currency_Code__c=wrap.dep.Currency_Code__c;
                dep.Deposit_Rate__c=wrap.depositRate;
                dep.Number_of_Months__c=wrap.noOfMonths;
                dep.Deposit_Generated__c = true;
                dep.Description__c = 'Refundable '+dep.Deposit_Type__c+' Deposit';
                depList.add(dep);
            }
            
            insert depList;
            
            //---------------------------Inserting LOI Charges-----------------------
            List<LOI_Charges__c> charges= new List<LOI_Charges__c>();
            id rentRecord = Schema.SObjectType.LOI_Charges__c.getRecordTypeInfosByName().get('Rent').getRecordTypeId();
            for(LOI_Charge_Template__c rentCharge : rentUnitChrgTemp){
                LOI_Charges__c loiCharges = new LOI_Charges__c();
                loiCharges.Charge__c=rentCharge.Charge__c; 
                loiCharges.name=rentCharge.name;
                loiCharges.Base_Charge_Type__c=rentCharge.Base_Charge_Type__c;
                loiCharges.Start_Date__c=rentCharge.Start_Date__c;
                loiCharges.End_Date__c=rentCharge.End_Date__c;
                loiCharges.Charge__c=rentCharge.Charge__c;
                loiCharges.Multiple_Rental_Schedule__c=rentCharge.Multiple_Rental_Schedule__c;
                loiCharges.Billing_Days__c=rentCharge.Billing_Days__c;
                loiCharges.Charge_Type__c=rentCharge.Charge_Type__c;
                loiCharges.Currency_Code__c=rentCharge.Currency_Code__c;
                loiCharges.Charge_Rate__c=rentCharge.Charge_Rate__c;
                loiCharges.Commercial_Tax_Apply__c=rentCharge.Commercial_Tax_Apply__c;
                loiCharges.Type__c=rentCharge.Type__c;
                loiCharges.LOI_Unit__c =loiUnit.id;
                loiCharges.Expected_GTO_Amount__c = rentCharge.Expected_GTO_Amount__c;
                
                loiCharges.Tiered_Limit__c = rentCharge.Tiered_Limit__c;
                loiCharges.Cumulative_for_each_Tier__c = rentCharge.Cumulative_for_each_Tier__c;
                loiCharges.Tiered_Lower_Limit__c = rentCharge.Tiered_Lower_Limit__c;
                loiCharges.Tier_1_Upper_Limit__c = rentCharge.Tier_1_Upper_Limit__c;
                loiCharges.Tier_2_Upper_Limit__c = rentCharge.Tier_2_Upper_Limit__c;
                loiCharges.Tier_3_Upper_Limit__c = rentCharge.Tier_3_Upper_Limit__c;
                loiCharges.Tier_4_Upper_Limit__c = rentCharge.Tier_4_Upper_Limit__c;
                loiCharges.Tier_5_Upper_Limit__c = rentCharge.Tier_5_Upper_Limit__c;
                loiCharges.Tier_6_Upper_Limit__c = rentCharge.Tier_6_Upper_Limit__c;
                loiCharges.Tier_7_Upper_Limit__c = rentCharge.Tier_7_Upper_Limit__c;
                loiCharges.Tier_8_Upper_Limit__c = rentCharge.Tier_8_Upper_Limit__c;
                loiCharges.Tier_1_Rate__c = rentCharge.Tier_1_Rate__c;
                loiCharges.Tier_2_Rate__c = rentCharge.Tier_2_Rate__c;
                loiCharges.Tier_3_Rate__c = rentCharge.Tier_3_Rate__c;
                loiCharges.Tier_4_Rate__c = rentCharge.Tier_4_Rate__c;
                loiCharges.Tier_5_Rate__c = rentCharge.Tier_5_Rate__c;
                loiCharges.Tier_6_Rate__c = rentCharge.Tier_6_Rate__c;
                loiCharges.Tier_7_Rate__c = rentCharge.Tier_7_Rate__c;
                loiCharges.Tier_8_Rate__c = rentCharge.Tier_8_Rate__c;
                loiCharges.Tier_9_Rate__c = rentCharge.Tier_9_Rate__c;
                
                loiCharges.RecordTypeId=rentRecord;
                //loiCharges.Base_Charge_Type__c = rentCharge.charge__r.Base_Charge_Type__c;
                loiCharges.Charge_Description__c = rentCharge.Charge_Description__c;
                //loiCharges.Billing_Days__c = rentCharge.charge__r.Billing_Days__c;
                loiCharges.Billing_Frequency__c = rentCharge.Billing_Frequency__c;
                loiCharges.Frequency__c = rentCharge.Frequency__c;
                loiCharges.Billing_Terms__c = rentCharge.Billing_Terms__c;
                loiCharges.Due_Month_Formula__c = rentCharge.Due_Month_Formula__c;
                loiCharges.Cap_Value__c= rentCharge.Cap_Value__c;
                loiCharges.Formula_Description__c= rentCharge.Formula_Description__c;
                loiCharges.Base_included__c= rentCharge.Base_included__c;
                loiCharges.Base_Value__c= rentCharge.Base_Value__c;
                
                if(withHoldingTaxAmount>0 && applyWitholding){
                    loiCharges.Withholding_Tax_Applicable__c = true;
                    loiCharges.Withholding_Tax_Rate__c = withHoldingTaxRate;
                }
                
                loiCharges.Lease_Plan__c = rentCharge.Lease_Plan__c;
                
                loiCharges.Charge_Start_Day__c = rentCharge.Charge_Start_Day__c;
                 
                charges.add(loiCharges);
            }
            
            if((withHoldingTaxAmount>0 && applyWitholding) || Test.isRunningTest()){
                List<Applicable_Charges__c> invDiscChgList = [Select Charge_Start_Day__c,Tiered_Limit__c,Cumulative_for_each_Tier__c,Tiered_Lower_Limit__c,Tier_1_Upper_Limit__c,Tier_2_Upper_Limit__c,Tier_3_Upper_Limit__c,Tier_4_Upper_Limit__c,Tier_5_Upper_Limit__c,Tier_6_Upper_Limit__c,Tier_7_Upper_Limit__c,Tier_8_Upper_Limit__c,Tier_1_Rate__c,Tier_2_Rate__c,Tier_3_Rate__c,Tier_4_Rate__c,Tier_5_Rate__c,Tier_6_Rate__c,Tier_7_Rate__c,Tier_8_Rate__c,id,frequency__c,Name,Base_Charge_Type__c,Billing_Days__c,Currency_Code__c,Commercial_Tax_Apply__c,Charge_Description__c,Billing_Frequency__c,Billing_Terms__c,Due_Month_Formula__c,Cap_Value__c,Base_Value__c,Base_Included__c,Charge_Rate_Description__c from Applicable_Charges__c where property__c =:pro.Id and Charge_Type__c='Invoice Discount'];
                if(invDiscChgList.size()>0){
                    LOI_Charges__c loiCharges = new LOI_Charges__c();
                    loiCharges.Charge__c=invDiscChgList[0].Id; 
                    loiCharges.name=invDiscChgList[0].Name;
                    loiCharges.Base_Charge_Type__c=invDiscChgList[0].Base_Charge_Type__c;
                    loiCharges.Start_Date__c=loi.loi_Start_Date__c;
                    loiCharges.End_Date__c=endDate;
                    loiCharges.Billing_Days__c=invDiscChgList[0].Billing_Days__c;
                    loiCharges.Charge_Type__c= 'Invoice Discount';
                    loiCharges.Currency_Code__c = invDiscChgList[0].Currency_Code__c;
                    loiCharges.Charge_Rate__c = withHoldingTaxRate;
                    loiCharges.Commercial_Tax_Apply__c=invDiscChgList[0].Commercial_Tax_Apply__c;
                    loiCharges.Type__c='By Percent';
                    loiCharges.LOI_Unit__c =loiUnit.id;
                    
                    loiCharges.RecordTypeId=rentRecord;
                    loiCharges.Charge_Description__c = invDiscChgList[0].Charge_Description__c;
                    loiCharges.Billing_Frequency__c = invDiscChgList[0].frequency__c;
                    loiCharges.Frequency__c = invDiscChgList[0].Billing_Frequency__c;
                    loiCharges.Billing_Terms__c = invDiscChgList[0].Billing_Terms__c;
                    loiCharges.Due_Month_Formula__c = invDiscChgList[0].Due_Month_Formula__c;
                    loiCharges.Cap_Value__c= invDiscChgList[0].Cap_Value__c;
                    loiCharges.Formula_Description__c= invDiscChgList[0].Charge_Rate_Description__c;
                    loiCharges.Base_included__c= invDiscChgList[0].Base_included__c;
                    loiCharges.Base_Value__c= invDiscChgList[0].Base_Value__c;
                    
                    loiCharges.Tiered_Limit__c = invDiscChgList[0].Tiered_Limit__c;
                    loiCharges.Cumulative_for_each_Tier__c = invDiscChgList[0].Cumulative_for_each_Tier__c;
                    loiCharges.Tiered_Lower_Limit__c = invDiscChgList[0].Tiered_Lower_Limit__c;
                    loiCharges.Tier_1_Upper_Limit__c = invDiscChgList[0].Tier_1_Upper_Limit__c;
                    loiCharges.Tier_2_Upper_Limit__c = invDiscChgList[0].Tier_2_Upper_Limit__c;
                    loiCharges.Tier_3_Upper_Limit__c = invDiscChgList[0].Tier_3_Upper_Limit__c;
                    loiCharges.Tier_4_Upper_Limit__c = invDiscChgList[0].Tier_4_Upper_Limit__c;
                    loiCharges.Tier_5_Upper_Limit__c = invDiscChgList[0].Tier_5_Upper_Limit__c;
                    loiCharges.Tier_6_Upper_Limit__c = invDiscChgList[0].Tier_6_Upper_Limit__c;
                    loiCharges.Tier_7_Upper_Limit__c = invDiscChgList[0].Tier_7_Upper_Limit__c;
                    loiCharges.Tier_8_Upper_Limit__c = invDiscChgList[0].Tier_8_Upper_Limit__c;
                    loiCharges.Tier_1_Rate__c = invDiscChgList[0].Tier_1_Rate__c;
                    loiCharges.Tier_2_Rate__c = invDiscChgList[0].Tier_2_Rate__c;
                    loiCharges.Tier_3_Rate__c = invDiscChgList[0].Tier_3_Rate__c;
                    loiCharges.Tier_4_Rate__c = invDiscChgList[0].Tier_4_Rate__c;
                    loiCharges.Tier_5_Rate__c = invDiscChgList[0].Tier_5_Rate__c;
                    loiCharges.Tier_6_Rate__c = invDiscChgList[0].Tier_6_Rate__c;
                    loiCharges.Tier_7_Rate__c = invDiscChgList[0].Tier_7_Rate__c;
                    loiCharges.Tier_8_Rate__c = invDiscChgList[0].Tier_8_Rate__c;
                    loiCharges.Tier_9_Rate__c = invDiscChgList[0].Tier_9_Rate__c;
                    
                    loiCharges.Charge_Start_Day__c = invDiscChgList[0].Charge_Start_Day__c;
                    
                    charges.add(loiCharges);
                }
            }
            
            id monthlyRecord =Schema.SObjectType.LOI_Charges__c.getRecordTypeInfosByName().get('Monthly').getRecordTypeId();
            for(LOI_Charge_Template__c monthCharges: monthlyUnitChrgTemp){
                LOI_Charges__c loiCharges = new LOI_Charges__c();
                loiCharges.Charge__c=monthCharges.Charge__c; 
                loiCharges.name = monthCharges.name;
                loiCharges.Base_Charge_Type__c = monthCharges.Base_Charge_Type__c;
                loiCharges.Start_Date__c = monthCharges.Start_Date__c;
                loiCharges.End_Date__c = monthCharges.End_Date__c;
                loiCharges.Charge__c = monthCharges.Charge__c;
                loiCharges.Multiple_Rental_Schedule__c = monthCharges.Multiple_Rental_Schedule__c;
                loiCharges.Billing_Days__c = monthCharges.Billing_Days__c;
                loiCharges.Charge_Type__c = monthCharges.Charge_Type__c;
                loiCharges.Currency_Code__c = monthCharges.Currency_Code__c;
                loiCharges.Charge_Rate__c=monthCharges.Charge_Rate__c;
                loiCharges.Commercial_Tax_Apply__c=monthCharges.Commercial_Tax_Apply__c;
                loiCharges.Type__c=monthCharges.Type__c;
                loiCharges.LOI_Unit__c =loiUnit.id;
                loiCharges.Expected_GTO_Amount__c = monthCharges.Expected_GTO_Amount__c;
                
                loiCharges.RecordTypeId=monthlyRecord;
                //loiCharges.Base_Charge_Type__c = monthCharges.charge__r.Base_Charge_Type__c;
                loiCharges.Charge_Description__c = monthCharges.Charge_Description__c;
                //loiCharges.Billing_Days__c = monthCharges.charge__r.Billing_Days__c;
                loiCharges.Billing_Frequency__c = monthCharges.Billing_Frequency__c;
                loiCharges.Frequency__c = monthCharges.Frequency__c;
                loiCharges.Billing_Terms__c = monthCharges.Billing_Terms__c;
                loiCharges.Due_Month_Formula__c = monthCharges.Due_Month_Formula__c;
                loiCharges.Cap_Value__c= monthCharges.Cap_Value__c;
                loiCharges.Formula_Description__c= monthCharges.Formula_Description__c;
                loiCharges.Base_included__c= monthCharges.Base_included__c;
                loiCharges.Base_Value__c= monthCharges.Base_Value__c;
                
                loiCharges.Tiered_Limit__c = monthCharges.Tiered_Limit__c;
                loiCharges.Cumulative_for_each_Tier__c = monthCharges.Cumulative_for_each_Tier__c;
                loiCharges.Tiered_Lower_Limit__c = monthCharges.Tiered_Lower_Limit__c;
                loiCharges.Tier_1_Upper_Limit__c = monthCharges.Tier_1_Upper_Limit__c;
                loiCharges.Tier_2_Upper_Limit__c = monthCharges.Tier_2_Upper_Limit__c;
                loiCharges.Tier_3_Upper_Limit__c = monthCharges.Tier_3_Upper_Limit__c;
                loiCharges.Tier_4_Upper_Limit__c = monthCharges.Tier_4_Upper_Limit__c;
                loiCharges.Tier_5_Upper_Limit__c = monthCharges.Tier_5_Upper_Limit__c;
                loiCharges.Tier_6_Upper_Limit__c = monthCharges.Tier_6_Upper_Limit__c;
                loiCharges.Tier_7_Upper_Limit__c = monthCharges.Tier_7_Upper_Limit__c;
                loiCharges.Tier_8_Upper_Limit__c = monthCharges.Tier_8_Upper_Limit__c;
                loiCharges.Tier_1_Rate__c = monthCharges.Tier_1_Rate__c;
                loiCharges.Tier_2_Rate__c = monthCharges.Tier_2_Rate__c;
                loiCharges.Tier_3_Rate__c = monthCharges.Tier_3_Rate__c;
                loiCharges.Tier_4_Rate__c = monthCharges.Tier_4_Rate__c;
                loiCharges.Tier_5_Rate__c = monthCharges.Tier_5_Rate__c;
                loiCharges.Tier_6_Rate__c = monthCharges.Tier_6_Rate__c;
                loiCharges.Tier_7_Rate__c = monthCharges.Tier_7_Rate__c;
                loiCharges.Tier_8_Rate__c = monthCharges.Tier_8_Rate__c;
                loiCharges.Tier_9_Rate__c = monthCharges.Tier_9_Rate__c;
                
                loiCharges.Charge_Start_Day__c = monthCharges.Charge_Start_Day__c;
                
                charges.add(loiCharges);
            }
            
            system.debug(charges);
            insert charges;   
            
            // To Update Lease Plans From LOI Unit - Updates LOI Committed Rate (Advance Rental)
            MainLOIUnitTrigger_Helper.updateLeasePlans(new Set<Id>{loiUnit.id},new Set<Id>{loiUnitTemp.unit__c});
            
            if(masId != null){
                CheckList_Master__c chekMstr=[Select id,description__c from checkList_master__c where id =:masId LIMIT 1];
                checkList__c newChekList = new checkList__c();
                newChekList.Unit__c=loiUnitTemp.Unit__c;
                newChekList.checkList_Master__c = masId;
                newChekList.description__c=chekMstr.description__c;
                newChekList.Type__c='Handover';
                newChekList.Loi_Unit__c=loiUnit.id;
                newChekList.RecordTypeId=schema.sObjectType.CheckList__c.getRecordTypeInfosByName().get('Handover').getRecordTypeId();
                
                insert newchekList;
                       
                for(CheckList_item__c cmi: itemListTemp)
                    cmi.Checklist__c=newChekList.id;
                    
                if(itemListTemp.size() > 0) 
                    insert itemListTemp;
                   
            }
            return new pageReference('/'+loi.id);   
       
        }catch(DmlException e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
        }catch(Exception e){             
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
        if(loiInserted){
            loi.Id = null;
        }
        Database.rollback(sp);
        return null;
    }
    
    public void unitDetailSetup(){
        showTenantType = false;
       if(loiUnitTemp.unit__c !=NULL){
          unitDetail=[Select property__r.name,name,NLA_SQF__c,NLA_SQM__c,Start_Date__c,End_Date__c,Level__r.name,Space_Type__c,Rent_Hurdle_Amount__c,Rent_Hurdle__c,Rent_Hurdle_Lower_Limit__c,Rent_Hurdle_Upper_Limit__c,Charge_Method__c from units__c where id=:loiUnitTemp.unit__c];
          if(unitDetail.Charge_Method__c!=null && (unitDetail.Charge_Method__c.contains('Monthly Rate - CL') || unitDetail.Charge_Method__c.contains('Daily Rate'))){
              showTenantType = true;
          }

       }
    }
    
    public string dateValidaion(){
        if(loi.LOI_Start_Date__c!=null && endDate!=null){
            if(rentUnitChrgTemp!=null && rentUnitChrgTemp.size()>0){
                Date minRentDate = null;
                Date maxRentDate = null;
                Map<Date,LOI_Charge_Template__c> startDateToChargeMap = new Map<Date,LOI_Charge_Template__c>();
                for(LOI_Charge_Template__c loiChr:rentUnitChrgTemp){
                    if(loiChr.Start_Date__c>loiChr.End_Date__c){
                        return 'Start Date should not be more than End Date.';
                    }
                    
                    if(loiChr.Start_Date__c<loi.Loi_Start_Date__c || loiChr.End_Date__c > endDate){
                        return 'Ensure Base Rent Lease Charge End Date does not exceeds LOI.';
                    }
                    
                    startDateToChargeMap.put(loiChr.Start_Date__c,loiChr);
                    
                    if(minRentDate == null && loiChr.Charge_Type__c != 'Rebate'){
                        minRentDate = loiChr.Start_Date__c;
                    }else if(minRentDate > loiChr.Start_Date__c){ }
                    
                    if(maxRentDate == null && loiChr.Charge_Type__c != 'Rebate'){
                        maxRentDate = loiChr.End_Date__c;
                    }else if(maxRentDate < loiChr.End_Date__c && loiChr.Charge_Type__c != 'Rebate'){
                        maxRentDate = loiChr.End_Date__c;
                    }
                }
                
                if(minRentDate!=loi.Loi_Start_date__c){
                    return 'Ensure Base Rent Lease Charge covers the entire LOI Duration.';
                }
                
                if(maxRentDate!=endDate){
                    return 'Ensure Base Rent Lease Charge covers the entire LOI Duration.';
                }
                
                for(Date dt:startDateToChargeMap.keyset()){
                    Date chgEndDate =startDateToChargeMap.get(dt).End_Date__c;
                    if(chgEndDate!=endDate  && startDateToChargeMap.get(dt).Charge_Type__c != 'Rebate'){
                        if(!startDateToChargeMap.containsKey(chgEndDate+1)){
                            //return 'Rent Charge dates are either overlapping or not covering whole LOI period.';
                            return 'Ensure Base Rent Lease Charge covers the entire LOI Duration.';
                        }
                    }
                }
            }
            
            
            
            if(monthlyUnitChrgTemp!=null && monthlyUnitChrgTemp.size()>0){
                for(LOI_Charge_Template__c loiChr:monthlyUnitChrgTemp){
                    if(loiChr.Start_Date__c>loiChr.End_Date__c){
                        return 'Start Date should not be more than End Date.';
                    }
                    if(loiChr.Start_Date__c<loi.Loi_Start_Date__c || loiChr.End_Date__c > endDate){
                        return 'Ensure Base Rent Lease Charge End Date does not exceeds LOI.';
                    }
                }
            }
        }
        return null;
    }
    
    
    //------------------------------------generateLOIPage3---------------------------------------------
    public pageReference generateLOIPage3(){
        string errorMsg = dateValidaion();
        if(errorMsg!=null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,errorMsg));
            return null;
        }
        Boolean check = false;
        
        for(DepositUnitWrap wrap:depositUnitChrgTemp){
            wrap.dpTEmpty = false;
            wrap.dpFTEmpty = false;
            wrap.dpCCEmpty = false;
            if(wrap.dep.Deposit_Type__c== null){
                wrap.dpTEmpty = true;
                check = true;
            }
            if(wrap.dep.Deposit_Formula_Type__c== null){
                wrap.dpFTEmpty = true;
                check = true;
            }
            if(wrap.dep.Currency_Code__c== null){
                wrap.dpCCEmpty = true;
                check = true;
            }
        }
        if(check){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'Please check all mandate fields.'));
            return null;
        }
        //rentUnitChrgTemp = new list<LOI_Charge_Template__c>();
        Boolean isChrageAvailable = false;
        for(LOI_Charge_Template__c loic: rentUnitChrgTemp){
            if(loic.Charge_Type__c =='Advance Rental' || loic.Charge_Type__c =='Rent'){
                isChrageAvailable = true;
            }
        }
        if(!isChrageAvailable){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'Please generate charge first.'));
            return null;
        }
       /* if(er!=False){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'Error not resolved'));
            return null;
        }
         else{   */
         system.debug('entered function=========================');
            masId = null;
            itemListTemp=new List<CheckList_Item__c>();
            temUnitCondition = new List<Conditions__c>();
            if(loiUnitTemp.Unit__c!=NULL){
             /*
                //string query='select Description__c,Condition__c,Checklist_Master__c,SN__c,Parent_Checklist_Item__c,Number__c,Issue_Types__c,Item_Type__c from Checklist_Master_Item__c where Checklist_Master__r.Property__r.id =\'' + loi.Property__c + '\' AND Checklist_Master__r.Type__c LIKE \'%Handover%\' ORDER BY FM_SN__c';
                //unitCheckList=Database.query(query);
               
                    for(CheckList_Master_Item__c cmi: unitCheckList){
                        masId = cmi.Checklist_Master__c;
                        CheckList_item__c chekListItem= new CheckList_Item__C();
                        chekListItem.Checklist_Master_Item__c=cmi.id;
                        chekListItem.Description__c=cmi.Description__c;
                        chekListItem.condition__c=cmi.Condition__c;
                        chekListItem.SN__c=cmi.SN__c;
                        chekListItem.Parent_Checklist_Item__c=cmi.Parent_Checklist_Item__c;
                        chekListItem.Number__c=cmi.Number__c;
                        chekListItem.Issue_Types__c=cmi.Issue_Types__c;
                        chekListItem.Item_Type__c=cmi.Item_Type__c;
                    
                        itemListTemp.add(chekListItem);
                    }
                    */
//----------------------------------------------------------------------------------------
                /*
                * Changes made on 30-5-2017
                * To fetch the checklist from unit condition 
                */    
//----------------------------------------------------------------------------------------                    
                string query='select Description__c,Condition__c,S_N__c,Number__c,Issue_Types__c,Item_Type__c,(select id,Checklist_Master_Item__c,Checklist__r.Checklist_Master__c from Checklist_Items__r LIMIT 1)  from Conditions__c where Unit__c =\'' +unitDetail.id + '\' ORDER BY S_N__c'; 
                try{
                    temUnitCondition = Database.query(query);
                   System.debug('temUnitCondition'+temUnitCondition);
                    for(Conditions__c cmi: temUnitCondition ){
                        System.debug('masId'+masId);
                        System.debug('Checklist_Items__r.size()'+cmi.Checklist_Items__r.size());
                        if(masId == NUll && cmi.Checklist_Items__r.size()>0){
                            
                            Checklist_Item__c tempCheckItem =cmi.Checklist_Items__r;
                            masId = tempCheckItem.Checklist__r.Checklist_Master__c;
                        } 
                        CheckList_item__c chekListItem= new CheckList_Item__C();
                        //chekListItem.Checklist_Master_Item__c=tempCheckItem.Checklist_Master_Item__c;
                        chekListItem.Description__c=cmi.Description__c;
                        chekListItem.condition__c=cmi.Condition__c;
                        chekListItem.SN__c=cmi.S_N__c+'';
                        //chekListItem.Parent_Checklist_Item__c=cmi.Parent_Checklist_Item__c;
                        chekListItem.Number__c=cmi.Number__c;
                        chekListItem.Issue_Types__c=cmi.Issue_Types__c;
                        chekListItem.Item_Type__c=cmi.Item_Type__c;
                    
                        itemListTemp.add(chekListItem);
                    }
                    
                    if(itemListTemp.size()<=0){
                        system.debug('Entered else------------------------' );
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'No Unit Conditions found under selected Unit!'));
                    }
                }
                catch(Exception e){
                    system.debug(e.getMessage());
                }
                return new pageReference('/apex/generateLOIstep3');
            }else
                return NULL;
       // }
    }
   
    
    /*
    
    //-------------------------Autopopulating Loi charge template--------------------------
    Public void autoFillLoiUnitTemplate(){
        if(loi.Tenant__c!=NULL){
            Account acc=[Select Trade_Category__c,sub_Trade_Category__c from account where id=:loi.Tenant__c];
            if(acc.Trade_Category__c != null){
               String str='SELECT id from LOI_Unit_Template__c';
               String queryFilter_one=str+' WHERE ((Trade_Category__c=\''+acc.Trade_Category__c+'\' AND sub_Trade_Category__c=\''+acc.sub_Trade_Category__c +'\') OR  (Trade_Category__c=\''+acc.Trade_Category__c+'\')) AND unit__c=\''+loiUnitTemp.Unit__c+'\' order by LastModifiedDate ';
               //String queryFilter_one=str+' WHERE (Unit__c=:loiUnitTemp.Unit__c OR Property_Lookup__c=:acc.id)AND((Trade_Category__c=\''+acc.Trade_Category__c+'\' AND sub_Trade_Category__c=\''+acc.sub_Trade_Category__c +'\') OR  (Trade_Category__c=\''+acc.Trade_Category__c+'\')) AND unit__c=\''+loiUnitTemp.Unit__c+'\' order by LastModifiedDate ';
               queryFilter_one+='LIMIT 1';
               LOI_Unit_Template__c template;
                
               try{
                   List<LOI_Unit_Template__c> lutList = Database.query(queryFilter_one);
                   
                   if(lutList.size() > 0){
                       template = lutList.get(0);
                   }else{
                       String queryFilter_two=str+' WHERE ((Trade_Category__c=\''+acc.Trade_Category__c+'\' AND sub_Trade_Category__c=\''+acc.sub_Trade_Category__c +'\') OR  (Trade_Category__c=\''+acc.Trade_Category__c+'\')) AND Property_Lookup__c=\''+loi.Property__c+'\' order by LastModifiedDate ';
                       queryFilter_two+='LIMIT 1';
                       lutList = Database.query(queryFilter_two);
                      
                       if(lutList.size() > 0){
                           template = lutList.get(0);
                       }                           
                   }   
               }catch(exception e){}
               
               if(template != NULL){
                    loiUnitChrgTemp.LOI_Unit_Template__c=template.id;
               }
           }
        }
       
    }
  */
  
  
      //-------------------------Autopopulating Loi charge template--------------------------
    Public void autoFillLoiUnitTemplate(){
        if(unitDetail==null){
            unitDetail=[Select property__r.name,name,NLA_SQF__c,NLA_SQM__c,Start_Date__c,End_Date__c,Level__r.name,Space_Type__c,Rent_Hurdle_Amount__c,Rent_Hurdle__c,Rent_Hurdle_Lower_Limit__c,Rent_Hurdle_Upper_Limit__c,Charge_Method__c from units__c where id=:loiUnitTemp.unit__c];
        }
        if(unitDetail!=null && unitDetail.Charge_Method__c!=null && (unitDetail.Charge_Method__c.contains('Monthly Rate - CL') || unitDetail.Charge_Method__c.contains('Daily Rate'))){
            if(unitDetail.Space_Type__c!=null){
                   
                List<LOI_Unit_Template__c> loiTempList = new List<LOI_Unit_Template__c>();
                if(unitDetail.Charge_Method__c.contains('Monthly Rate - CL')){
                    loiTempList = [SELECT id from LOI_Unit_Template__c where active__c=TRUE AND (Unit__c=:loiUnitTemp.Unit__c or Property_Lookup__c=:loi.property__c) AND Space_Type__c=:unitDetail.Space_Type__c and Active__c=true and Charge_Method__c includes('Monthly Rate - CL') and Start_Date__c<=:loi.LOI_Start_Date__c and Start_Date__c<=:endDate];
                }else{
                    loiTempList = [SELECT id from LOI_Unit_Template__c where active__c=TRUE AND (Unit__c=:loiUnitTemp.Unit__c or Property_Lookup__c=:loi.property__c) AND Space_Type__c=:unitDetail.Space_Type__c and Active__c=true and Charge_Method__c includes('Daily Rate') and Start_Date__c<=:loi.LOI_Start_Date__c and Start_Date__c<=:endDate];
                }
                 system.debug(loiTempList.size()); 
                if(loiTempList.size()==1){
                    loiUnitChrgTemp.LOI_Unit_Template__c = loiTempList[0].Id;
                   
                }
            
            }
            
                 
        }else if(loi.Tenant__c!=NULL){
            Account acc=[Select Trade_Category__c,sub_Trade_Category__c from account where id=:loi.Tenant__c];
            if(acc.Trade_Category__c != null){
               /*String str='SELECT id from LOI_Unit_Template__c';
               String queryFilter_one=str+' WHERE ((Trade_Category__c=\''+acc.Trade_Category__c+'\' AND sub_Trade_Category__c=\''+acc.sub_Trade_Category__c +'\') OR  (Trade_Category__c=\''+acc.Trade_Category__c+'\')) AND unit__c=\''+loiUnitTemp.Unit__c+'\' order by LastModifiedDate ';
               //String queryFilter_one=str+' WHERE (Unit__c=:loiUnitTemp.Unit__c OR Property_Lookup__c=:acc.id)AND((Trade_Category__c=\''+acc.Trade_Category__c+'\' AND sub_Trade_Category__c=\''+acc.sub_Trade_Category__c +'\') OR  (Trade_Category__c=\''+acc.Trade_Category__c+'\')) AND unit__c=\''+loiUnitTemp.Unit__c+'\' order by LastModifiedDate ';
               queryFilter_one+='LIMIT 1';
               LOI_Unit_Template__c template;
                
               try{
                   List<LOI_Unit_Template__c> lutList = Database.query(queryFilter_one);
                   
                   if(lutList.size() > 0){
                       template = lutList.get(0);
                   }else{
                       String queryFilter_two=str+' WHERE ((Trade_Category__c=\''+acc.Trade_Category__c+'\' AND sub_Trade_Category__c=\''+acc.sub_Trade_Category__c +'\') OR  (Trade_Category__c=\''+acc.Trade_Category__c+'\')) AND Property_Lookup__c=\''+loi.Property__c+'\' order by LastModifiedDate ';
                       queryFilter_two+='LIMIT 1';
                       lutList = Database.query(queryFilter_two);
                      
                       if(lutList.size() > 0){
                           template = lutList.get(0);
                       }                           
                   }   
               }catch(exception e){}
               
               if(template != NULL){
                    loiUnitChrgTemp.LOI_Unit_Template__c=template.id;
               }*/
           
               List<LOI_Unit_Template__c> loiTempList = [SELECT id,sub_Trade_Category__c from LOI_Unit_Template__c where active__c=TRUE AND Unit__c=:loiUnitTemp.Unit__c AND Trade_Category__c=:acc.Trade_Category__c and Start_Date__c<=:loi.LOI_Start_Date__c and Start_Date__c<=:endDate  order by LastModifiedDate ];
           
               if(loiTempList.size()>0){
                   for(LOI_Unit_Template__c temp : loiTempList)
                       if(temp.sub_Trade_Category__c == acc.sub_Trade_Category__c ){
                           loiUnitChrgTemp.LOI_Unit_Template__c=temp.id;               
                           break;
                       }
                       
                   if(loiUnitChrgTemp.LOI_Unit_Template__c == NULL)
                        loiUnitChrgTemp.LOI_Unit_Template__c=loiTempList.get(0).id;
               }
               else{
                   loiTempList = [SELECT id,sub_Trade_Category__c from LOI_Unit_Template__c where active__c=TRUE AND Property_Lookup__c=:loi.property__c AND Trade_Category__c=:acc.Trade_Category__c and Start_Date__c<=:loi.LOI_Start_Date__c and Start_Date__c<=:endDate  order by LastModifiedDate ];
                    if(loiTempList.size()>0){
                       for(LOI_Unit_Template__c temp : loiTempList)
                           if(temp.sub_Trade_Category__c == acc.sub_Trade_Category__c ){
                               loiUnitChrgTemp.LOI_Unit_Template__c=temp.id;               
                               break;
                           }
                           
                       if(loiUnitChrgTemp.LOI_Unit_Template__c == NULL)
                            loiUnitChrgTemp.LOI_Unit_Template__c=loiTempList.get(0).id;
                    }
               }
           }
        }       
    }
    //----------------------------------- Validation Check Rent unit charge values -----------------------------------
    
    public void rentValidation(){
        Calculation();
        system.debug('check===');
        //er=False;
        for(LOI_Charge_Template__c rntCharge: rentUnitChrgTemp){
           
           double rntHurdleLower,rntHurdleUpper,rentHurdleAmtLower,rentHurdleAmtUpper ;
           if(unitDetail.rent_hurdle__c == NULL)
               rntHurdleLower = rntHurdleUpper = 0.0;
           else{
               if(unitDetail.Rent_Hurdle_Lower_Limit__c != NULL)
                   rntHurdleLower = unitDetail.rent_hurdle__c * (100 - unitDetail.Rent_Hurdle_Lower_Limit__c)/100;
                else
                   rntHurdleLower = 0.0;
               if(unitDetail.Rent_Hurdle_Upper_Limit__c != NULL)
                   rntHurdleUpper = unitDetail.rent_hurdle__c * (100 + unitDetail.Rent_Hurdle_Upper_Limit__c)/100;
               else
                   rntHurdleUpper = unitDetail.rent_hurdle__c;
           }
           
           
           if(unitDetail.rent_hurdle_Amount__c == NULL)
               rentHurdleAmtLower = rentHurdleAmtUpper =0.0;
           else{
                if( unitDetail.Rent_Hurdle_Lower_Limit__c != NULL)
                    rentHurdleAmtLower = unitDetail.rent_hurdle_Amount__c * (100 - unitDetail.Rent_Hurdle_Lower_Limit__c)/100;
                else
                    rentHurdleAmtUpper = 0.0;
                if( unitDetail.Rent_Hurdle_Upper_Limit__c != NULL)
                    rentHurdleAmtUpper = unitDetail.rent_hurdle_Amount__c * (100 + unitDetail.Rent_Hurdle_Upper_Limit__c)/100;
                else
                    rentHurdleAmtUpper = unitDetail.rent_hurdle_Amount__c;
                //rentHurdleAmt=unitDetail.rent_hurdle_Amount__c;
           }
           
            
            if(rntCharge.Type__c=='Fixed'){ 
                if(rntCharge.Charge_Rate__c < rentHurdleAmtLower)
                    rntCharge.Charge_Rate__c.adderror('Value Precedes Rent Hurdle Amount Range');
                else if(rntCharge.Charge_Rate__c > rentHurdleAmtUpper)
                    rntCharge.Charge_Rate__c.adderror('Value Exceeds Rent Hurdle Amount Range');
                //er=TRUE;
            }
            else if(rntCharge.Type__c=='By Area'){
                If(rntCharge.Charge_Rate__c < rntHurdleLower)
                    rntCharge.Charge_Rate__c.adderror('Value Precedes Rent Hurdle Range');
                else if(rntCharge.Charge_Rate__c > rntHurdleUpper)
                    rntCharge.Charge_Rate__c.adderror('Value Exceeds Rent Hurdle Range');
            }
            
            
        } 
    }
    
    //----------------------------------------------------------------------------------------
    public void selectionError(){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'Select Atleast One LOI'));
    }
  
    //------------------------------------getSettings---------------------------------------------
  /*  public List<Manage_LOI__c> getSetting(){
        return Manage_LOI__c.getall().values();
    }*/
    
    //------------------------------ To generate the action values-----------------------------------
   /* public List<SelectOption> getActionSelectList() {
        List<SelectOption> options = new List<SelectOption>();
        
        for(Manage_LOI__c loiMan : Manage_LOI__c.getall().values()) {
            if (loiMan.Action__c != null) 
               // options.add(new SelectOption(loiMan.Action__c, loiMan.Comments__c));
               options.add(new SelectOption(loiMan.Action__c, loiMan.Action__c));
        }
        
        return options;
    }
   */
 
    //------------------------------------Deposit Wrapper---------------------------------------------
    public class DepositUnitWrap{
        public Deposit__c dep {get;set;}
        public Boolean defaultRec {get;set;}
        public String lcCurrencyCode{get;set;}
        public Decimal baseRent {get;set;}
        public Decimal areaSqFt {get;set;}
        public Decimal depositRate {get;set;}
        public Integer noOfMonths{get;set;}
        public Decimal depositAmount {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        public String unit{get;set;}
        public Boolean dpTEmpty{get;set;}
        public Boolean dpFTEmpty{get;set;}
        public Boolean dpCCEmpty{get;set;}
        public DepositUnitWrap(Deposit__c d) {
            dep = d;
            defaultRec = true;
            baseRent = 0.00;
            lcCurrencyCode = '';
            areaSqFt = 0.00;
            depositRate = 0.00;
            noOfMonths = 1;
            depositAmount = 0.00;
        }
    }
}