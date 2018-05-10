public class LaPDFController{
    public Lease__c lease{get;set;}
    public string landlordAddress{get;set;}
    public string tenantAddress{get;set;}
    public string unitNames{get;set;}
    public decimal termInYears{get;set;}
    public decimal totalUnitArea{get;set;}
    public date handoverDate{get;set;}
    public date fitoutDate{get;set;}
    public string curCode{get;set;}
    public decimal DepositAmount{get;set;}
    public List<Bank_Information__c> bankInfoList{get;set;}
    public Lease_Charges__c govMeterCharge{get;set;}
    public Lease_Charges__c generatorCharge{get;set;}
    public Lease_Charges__c gasCharge{get;set;}
    public Map<string,List<string>> handoverItemMap{get;set;}
    public Map<string,Map<string,string>> condToDescMap{get;set;}
    public Map<Id,string> levelToUnitMap{get;set;}
    public List<Level__c> floorPlanLevels{get;set;}
    public Integer handoverMapSize{get;set;}
    public Map<string,List<leaseChargeWrapper>> unitToFixedRentLcMap{get;set;}
    public Integer fixedRentMapSize{get;set;}
    public Map<string,List<Lease_Charges__c>> unitToRebateMap{get;set;}
    public Integer rebateMapSize{get;set;}
    public Integer lateChargeRate{get;set;}
    public Map<decimal,string> promoFundMap{get;set;}
    public Integer promoMapSize{get;set;}
    public Map<decimal,ServiceChargeWrapper> serviceChgMap{get;set;}
    public Map<decimal,ServiceChargeWrapper> xtraServiceChgMap{get;set;}
    public Integer serviceMapSize{get;set;}
    public Integer xtraServiceMapSize{get;set;}
    public Map<decimal,string> generatorMap{get;set;}
    public Map<decimal,string> gasMap{get;set;}
    public Map<decimal,string> govMeterMap{get;set;}
    public Map<decimal,string> subMeterMap{get;set;}
    public Integer govMeterMapSize{get;set;}
    public Integer subMeterMapSize{get;set;}
    public Integer generatorMapSize{get;set;}
    public Integer gasMapSize{get;set;}
    public string lateRateStr{get;set;}
    public LaPDFController(){
        gasMap = new Map<decimal,string>();
        generatorMap = new Map<decimal,string>();
        govMeterMap = new Map<decimal,string>();
        subMeterMap = new Map<decimal,string>();
        promoFundMap = new Map<decimal,string>();
        lateChargeRate = 0;
        unitToFixedRentLcMap = new Map<string,List<leaseChargeWrapper>>();
        unitToRebateMap = new Map<string,List<Lease_Charges__c>>();
        handoverItemMap = new Map<string,List<string>>();
        condToDescMap = new Map<string,Map<string,string>>();
        levelToUnitMap = new Map<Id,string>();
        serviceChgMap = new Map<decimal,ServiceChargeWrapper>();
        xtraServiceChgMap = new Map<decimal,ServiceChargeWrapper>();
        lease = new Lease__c();
        floorPlanLevels = new List<Level__c>();
        govMeterCharge = new Lease_Charges__c();
        generatorCharge = new Lease_Charges__c();
        gasCharge = new Lease_Charges__c();        
        landlordAddress = '';
        unitNames = '';
        totalUnitArea = 0;
        DepositAmount = 0;
        bankInfoList = new List<Bank_Information__c>();
        for(Lease__c ls:[Select id,Lease_Start_Date__c,Late_Payment_Interest__c,Property__r.Air_cond_operation_time__c,property__r.Address__c,property__r.Name,Lease_Tenure_Days__c,Lease_Tenure_Mths__c,Lease_End_Date__c,Property__r.Landlord__r.Name,Property__r.Landlord__r.BillingStreet,Property__r.Landlord__r.BillingCity,Property__r.Landlord__r.BillingState,Property__r.Landlord__r.BillingCountry,Property__r.Landlord__r.BillingPostalCode,tenant__r.Name,Tenant__r.BillingStreet,Tenant__r.BillingCity,Tenant__r.BillingState,Tenant__r.BillingCountry,Tenant__r.BillingPostalCode,Tenant__r.Trade_Category__c from Lease__c where id=:Apexpages.CurrentPage().getParameters().get('Id') limit 1]){
            lease = ls;
            
            if(ls.Late_Payment_Interest__c!=null){
                lateChargeRate = Integer.valueOf(ls.Late_Payment_Interest__c);
                string amo = ConvertCurrencyToWords.english_number(Integer.valueof(ls.Late_Payment_Interest__c));
                lateRateStr = amo.remove(',');
            }
            
            landlordAddress  = (ls.Property__r.Landlord__r.BillingStreet!=null?ls.Property__r.Landlord__r.BillingStreet+',':'');
            landlordAddress += (ls.Property__r.Landlord__r.BillingCity!=null?ls.Property__r.Landlord__r.BillingCity+',':'');
            landlordAddress += (ls.Property__r.Landlord__r.BillingState!=null?ls.Property__r.Landlord__r.BillingState+',':'');
            landlordAddress += (ls.Property__r.Landlord__r.BillingCountry!=null?ls.Property__r.Landlord__r.BillingCountry:'');
            
            tenantAddress  = (ls.Tenant__r.BillingStreet!=null?ls.Tenant__r.BillingStreet+',':'');
            tenantAddress += (ls.Tenant__r.BillingCity!=null?ls.Tenant__r.BillingCity+',':'');
            tenantAddress += (ls.Tenant__r.BillingState!=null?ls.Tenant__r.BillingState+',':'');
            tenantAddress += (ls.Tenant__r.BillingCountry!=null?ls.Tenant__r.BillingCountry:'');
            
            termInYears = (ls.Lease_Start_Date__c.daysBetween(ls.Lease_End_Date__c))/365.0;
            termInYears = termInYears.setScale(2);
            
        }
        
        Set<Id> luIds = new Set<Id>();
        List<Lease_Unit__c> lsUnitList = [Select id,Fit_Out_Date__c,HandOver_Date__c,Lease_Agreement_No__c,Unit__r.Level__c,Unit__r.Name,Area_Sq_Ft__c from Lease_Unit__c where Lease_Agreement_No__c=:lease.Id];
        for(Lease_Unit__c lu:lsUnitList){
            string tempstr;
            if(levelToUnitMap.containsKey(lu.Unit__r.Level__c)){
                tempStr = levelToUnitMap.get(lu.Unit__r.Level__c);
            }
            if(tempStr!=null){
                tempStr += ',' + lu.Unit__r.Name;
            }else{
                tempStr = lu.Unit__r.Name;
            }
            levelToUnitMap.put(lu.Unit__r.Level__c,tempStr);
            
            luIds.add(lu.Id);
            unitNames += lu.unit__r.Name+',';
            totalUnitArea += lu.Area_Sq_Ft__c;
            if(handoverDate==null && lu.HandOver_Date__c!=null){
                handoverDate = lu.HandOver_Date__c;
            }
            
            if(fitoutDate==null && lu.Fit_Out_Date__c!=null){
                fitoutDate = lu.Fit_Out_Date__c;
            }
        }
        
        if(unitNames!=null && unitNames.trim().length()>0){
            unitNames = unitNames.substring(0,unitNames.Length()-1);
        }
        
        bankInfoList = [Select id,Account_No__c,Bank_Address__c,Bank_Name__c,Beneficiary_Name__c,Branch_Name__c,Currency_Code__c,Swift_Code__c from Bank_Information__c where Property__c=:lease.Property__c];
        
        for(Deposit__c dp:[Select id,Currency_Code__c,Deposit_Amount__c from Deposit__c where Lease__c=:lease.Id]){
            curCode = dp.Currency_Code__c;
            DepositAmount += (dp.Deposit_Amount__c!=null?dp.Deposit_Amount__c:0);
        }
        
        List<Lease_Charges__c> leaseChargeList = [Select id,Tiered_Lower_Limit__c,Tier_1_Upper_Limit__c,Tier_1_Rate__c,Tier_2_Upper_Limit__c,Tier_2_Rate__c,Tier_3_Upper_Limit__c,Tier_3_Rate__c,Tier_4_Upper_Limit__c,Tier_4_Rate__c,Tier_5_Upper_Limit__c,Tier_5_Rate__c,Tier_6_Upper_Limit__c,Tier_6_Rate__c,Tier_7_Upper_Limit__c,Tier_7_Rate__c,Tier_8_Upper_Limit__c,Tier_8_Rate__c,Cumulative_for_each_Tier__c ,Currency_Code__c,Start_Date__c,End_Date__c,Lease_Unit__c,Lease_Unit__r.Unit__r.Name,Base_Charge_Type__c,Charge_Type__c,Tiered_Limit__c,Type__c,Charge_Rate__c,GTO_Cap__c from Lease_Charges__c where Lease_Unit__c in:luIds and Active__c=true and (Charge_Type__c='GTO Rent' or Charge_Type__c='Advance Rental' or Charge_Type__c='Rent') order by Charge_Type__c,Start_Date__c Asc];
        
        List<Lease_Charges__c> rentalLcList = new List<Lease_Charges__c>();
        List<Lease_Charges__c> gtoLcList = new List<Lease_Charges__c>();
        
        for(Lease_Charges__c lc:leaseChargeList){
            if(lc.Charge_Type__c=='Advance Rental' || lc.Charge_Type__c=='Rent'){
                rentalLcList.add(lc);
            }else{
                gtoLcList.add(lc);
            }
        }
        
        for(Lease_Charges__c rLC :rentalLcList){
            leaseChargeWrapper lcWrap = new leaseChargeWrapper();
            lcWrap.rentalCharge = rLC;
            for(Lease_Charges__c gLC :gtoLcList){
                if(rLc.Lease_Unit__r.Unit__r.Name==gLC.Lease_Unit__r.Unit__r.Name){
                    if(rLC.Start_Date__c>=gLC.Start_Date__c && rLC.Start_Date__c<=gLC.End_Date__c){
                        lcWrap.gtoCharge = gLC;
                        if(gLC.Tiered_Limit__c){
                            for(Integer i=1;i<=8;i++){                            
                                if(gLC.get('Tier_'+i+'_Upper_Limit__c')!=null || gLC.get('Tier_'+i+'_Rate__c')!=null){
                                    TieredWrapper tw = new TieredWrapper();
                                    if(i==1){
                                        if(glc.Tiered_Lower_Limit__c>0){
                                            tw.upperlimit = (gLC.get('Tier_'+i+'_Upper_Limit__c')!=null?(decimal)gLC.get('Tier_'+i+'_Upper_Limit__c'):0) - glc.Tiered_Lower_Limit__c;
                                        }else{
                                            tw.upperlimit = (decimal)gLC.get('Tier_'+i+'_Upper_Limit__c');
                                        }                                        
                                    }else{
                                        tw.upperlimit = (gLC.get('Tier_'+i+'_Upper_Limit__c')!=null?((decimal)gLC.get('Tier_'+i+'_Upper_Limit__c')):0) - (gLC.get('Tier_'+(i-1)+'_Upper_Limit__c')!=null?((decimal)gLC.get('Tier_'+(i-1)+'_Upper_Limit__c')):0);
                                    }
                                    //tw.upperlimit = (decimal)gLC.get('Tier_'+i+'_Upper_Limit__c');
                                    tw.rate = (decimal)gLC.get('Tier_'+i+'_Rate__c');
                                    
                                    if(tw.rate!=null){
                                        tw.rate = tw.rate.setScale(2);
                                    }
                                    
                                    lcWrap.tieredList.add(tw);
                                }
                            }
                        }
                        break;
                    }
                }
            }
            List<leaseChargeWrapper> tempList = new List<leaseChargeWrapper>();
            if(unitToFixedRentLcMap.containsKey(rLc.Lease_Unit__r.Unit__r.Name)){
                tempList.addAll(unitToFixedRentLcMap.get(rLc.Lease_Unit__r.Unit__r.Name));
            }
            tempList.add(lcWrap);
            unitToFixedRentLcMap.put(rLc.Lease_Unit__r.Unit__r.Name,tempList);
        }
        
        fixedRentMapSize = unitToFixedRentLcMap.size();
        
        List<Lease_Charges__c> AllLeaseCharges = [Select id,Name,Currency_Code__c,Start_Date__c,End_Date__c,Lease_Unit__c,Lease_Unit__r.Unit__r.Name,Base_Charge_Type__c,Charge_Type__c,Tiered_Limit__c,Type__c,Charge_Rate__c,GTO_Cap__c from Lease_Charges__c where Lease_Unit__c in:luIds and Active__c=true and Charge_Rate__c!=null];
        for(Lease_Charges__c lc: AllLeaseCharges){
            if(lc.Charge_Type__c=='Service'){
                if(lc.Name=='F&B Service Charge'){
                    ServiceChargeWrapper sw = new ServiceChargeWrapper();
                    if(xtraServiceChgMap.containsKey(lc.Charge_Rate__c)){
                        sw = xtraServiceChgMap.get(lc.Charge_Rate__c);
                    }
                    if(sw.unitNames!=null){
                        sw.UnitNames += ','+ lc.Lease_Unit__r.Unit__r.Name;
                    }else{
                        sw.UnitNames = lc.Lease_Unit__r.Unit__r.Name;                        
                        sw.ServiceCharge = lc;
                    }
                    xtraServiceChgMap.put(lc.Charge_Rate__c,sw);
                }else{
                    ServiceChargeWrapper sw = new ServiceChargeWrapper();
                    if(serviceChgMap.containsKey(lc.Charge_Rate__c)){
                        sw = serviceChgMap.get(lc.Charge_Rate__c);
                    }
                    if(sw.unitNames!=null){
                        sw.UnitNames += ','+ lc.Lease_Unit__r.Unit__r.Name;
                    }else{
                        sw.UnitNames = lc.Lease_Unit__r.Unit__r.Name;                        
                        sw.ServiceCharge = lc;
                    }
                    serviceChgMap.put(lc.Charge_Rate__c,sw);
                }
            }else if(lc.Charge_Type__c=='A&P'){
                string tempstr;
                if(promoFundMap.containsKey(lc.Charge_Rate__c)){
                    tempStr = promoFundMap.get(lc.Charge_Rate__c);
                }
                if(tempStr!=null){
                    if(!tempStr.contains(lc.Lease_Unit__r.Unit__r.Name)){
                        tempStr += ',' + lc.Lease_Unit__r.Unit__r.Name;                        
                    }
                }else{
                    tempStr = lc.Lease_Unit__r.Unit__r.Name;
                }
                promoFundMap.put(lc.Charge_Rate__c,tempStr);
                
            }else if(lc.Charge_Type__c=='Gov Meter'){
                string tempStr = '';
                if(govMeterMap.containsKey(lc.Charge_Rate__c)){
                    tempStr = govMeterMap.get(lc.Charge_Rate__c) + ',';
                }
                tempStr += lc.Lease_Unit__r.Unit__r.Name;
                govMeterMap.put(lc.Charge_Rate__c,tempStr);
            }else if(lc.Charge_Type__c=='Sub Meter'){
                string tempStr = '';
                if(subMeterMap.containsKey(lc.Charge_Rate__c)){
                    tempStr = subMeterMap.get(lc.Charge_Rate__c) + ',';
                }
                tempStr += lc.Lease_Unit__r.Unit__r.Name;
                subMeterMap.put(lc.Charge_Rate__c,tempStr);
            }else if(lc.Charge_Type__c=='Generator'){
                string tempStr = '';
                if(generatorMap.containsKey(lc.Charge_Rate__c)){
                    tempStr = generatorMap.get(lc.Charge_Rate__c) + ',';
                }
                tempStr += lc.Lease_Unit__r.Unit__r.Name;
                generatorMap.put(lc.Charge_Rate__c,tempStr);
            }else if(lc.Charge_Type__c=='Gas'){
                string tempStr = '';
                if(gasMap.containsKey(lc.Charge_Rate__c)){
                    tempStr = gasMap.get(lc.Charge_Rate__c) + ',';
                }
                tempStr += lc.Lease_Unit__r.Unit__r.Name;
                gasMap.put(lc.Charge_Rate__c,tempStr);
                
            }else if(lc.Charge_Type__c=='Rebate'){
                List<Lease_Charges__c> tempList = new List<Lease_Charges__c>();
                if(unitToRebateMap.containsKey(lc.Lease_Unit__r.Unit__r.Name)){
                    tempList.addAll(unitToRebateMap.get(lc.Lease_Unit__r.Unit__r.Name));
                }
                tempList.add(lc);
                unitToRebateMap.put(lc.Lease_Unit__r.Unit__r.Name,tempList);
            }
        }
        
        rebateMapSize = unitToRebateMap.size();
        promoMapSize = promoFundMap.size();
        serviceMapSize = serviceChgMap.size();
        xtraServiceMapSize = xtraServiceChgMap.size();
        govMeterMapSize = govMeterMap.size();
        subMeterMapSize = subMeterMap.size();
        generatorMapSize = generatorMap.size();
        gasMapSize = gasMap.size();
                
        List<CheckList__c> checkLists = [Select id,Lease_Unit__c,Lease_Unit__r.Unit__r.Name,(Select id,Description__c,Condition__c from Checklist_Items__r order by FM_SN__c ASC) from CheckList__c where Lease_Unit__c in:luIds and type__c='Handover'];
        if(checkLists.size()>0){
            for(CheckList__c ch:checkLists){
                List<string> descList = new List<string>();
                set<string> dupCheckSet = new Set<string>();
                for(Checklist_Item__c ci:ch.Checklist_Items__r){
                    if(!dupCheckSet.contains(ci.Description__c)){
                        descList.add(ci.Description__c);
                        dupCheckSet.add(ci.Description__c);
                    }
                    Map<string,string> tempMap = new Map<string,string>();
                    if(condToDescMap.containsKey(ch.Lease_Unit__r.Unit__r.Name)){
                        tempMap = condToDescMap.get(ch.Lease_Unit__r.Unit__r.Name);
                    }
                    string tempStr = '';
                    if(tempMap.size()>0){
                        if(tempMap.containsKey(ci.Description__c)){
                            tempStr = tempMap.get(ci.Description__c) + '<br/>';
                        }
                    }
                    tempStr += ci.Condition__c;
                    tempMap.put(ci.Description__c,tempStr);
                    condToDescMap.put(ch.Lease_Unit__r.Unit__r.Name,tempMap);
                }
                handoverItemMap.put(ch.Lease_Unit__r.Unit__r.Name,descList);
            }                
        }
        
        handoverMapSize = handoverItemMap.size();
        
        floorPlanLevels = [Select id,Floor_Plan__c from Level__c where id in:levelToUnitMap.keyset()];
    }
    
    public class leaseChargeWrapper{
        public Lease_Charges__c rentalCharge{get;set;}
        public Lease_Charges__c gtoCharge{get;set;}
        public List<TieredWrapper> tieredList{get;set;}
        public leaseChargeWrapper(){
            rentalCharge = new Lease_Charges__c();
            gtoCharge = new Lease_Charges__c();
            tieredList = new List<TieredWrapper>();
        }
    }
    
    public class TieredWrapper{
        public decimal upperlimit{get;set;}
        public decimal rate{get;set;}
    }
    
    public class ServiceChargeWrapper{
        public string unitNames{get;set;}
        public Lease_Charges__c serviceCharge{get;set;}
        public ServiceChargeWrapper(){
            serviceCharge = new Lease_Charges__c();
        }
    }
}