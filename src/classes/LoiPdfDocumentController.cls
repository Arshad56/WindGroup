public class LoiPdfDocumentController{
    public LOI__c loi{get;set;}
    public List<LOIChargesStructure> lOIChrgStr{get;set;}
    public List<Integer> yearList{get;set;}
    public List<Deposit__c> Dep { get; set; }
    public List<LOI_Charges__c> chargList{ get; set; }
    public List<Checklist_Item__c> chkList{get;set;}
    public List<Checklist_Item__c> diplayChecklist{get;set;}
    public String appliedCurrency{get;set;}
    public String tenureYear{get;set;}
    public String renewalYear{get;set;}
    public String depositMonths{get;set;}
    public List<LOI_Charges__c> chargesBaseRent{get;set;}
    public List<LOI_Charges__c> chargesGTO{get;set;}
    public Map<String, List<String>> handoverMapList{get;set;}
    public Map<Id, LOI_Charges__c> loiChrgeMap{get;set;}
    public string ChkMapKey{get;set;}
    public Map<String, String> depositCurrency{get;set;}
    public Map<String, String> depositMonthsString{get;set;}
    public Map<String, Checklist_Item__c> handOverCheckLst{get;set;}
    public Set<String> keyValues{get;set;}
    public List<DisplayLOIChargesWrap> higherGTOWrap{get;set;}
    public List<DisplayLOIChargesWrap> sumGTOWrap{get;set;}
    public List<DisplayLOIChargesWrap> tieredHigherGTOWrap{get;set;}
    public List<DisplayLOIChargesWrap> tieredSumGTOWrap{get;set;}
    public String burmeseTextUrl{get;set;}
    List<LOI_Charges__c> loiCharges = new List<LOI_Charges__c>();
    public String getYearfromMonth(decimal months){
       String tenureYear = '0';
       if(months > 0){
          Integer yearInt = Integer.valueOf(months/12);
          tenureYear = yearInt+'.'+ math.mod(Integer.valueof(months),12);
       }
       return tenureYear;
    }
    public String getFormatNumber(Decimal value){
        String[]  suffixes = new String[]{'k', 'm', 'b', 't', 'q'};
        for (Integer j = suffixes.size();  j > 0;  j--){
            double  unit = Math.Pow(1000, j);
            if (value >= unit)
                return LeasePlanDailyController.getCents((value / unit).setScale(2)) + suffixes[--j];
            }
        return LeasePlanDailyController.getCents(value.setScale(2));
    }
    public LoiPdfDocumentController(){    
        lOIChrgStr = new List<LOIChargesStructure>();
        handoverMapList = new Map<String, List<String>>();
        depositCurrency = new Map<String, String>();
        depositMonthsString = new Map<String, String>();
        id loiId=ApexPages.currentPage().getParameters().get('loiId');
        
        loi=[select id,Trade_Category__c,Contact__c,Contact__r.name,name,Handover_Date__c,LOI_Tenure_Mths__c,Option_to_Renew__c,LOI_Start_Date__c,LOI_End_Date__c,Original_End_Date__c,Generated_LOI__c,Financial_Contact__r.title,
            Financial_Contact__r.name,Tenant__r.name,Tenant__r.Trade_Category__c,Tenant__r.Sub_Trade_Category__c,Tenant__r.billingstreet,
            Tenant__r.billingCity,Tenant__r.billingState,Tenant__r.billingCountry,Tenant__r.Shop_Name_Printed__c,Property__r.name,
            Tenant__r.BillingPostalCode, property__r.Address__c,property__r.Logo__c,property__r.Website__c,property__r.Landlord__r.Name, property__r.Landlords_Authorized_Agent__r.name,
            LOI_Validity_Week__c, 
            Tenant_Name_Acceptance__c,Tenant_Position__c,Tenant_Address__c,Landlord_s_representative__c,Landlord_s_Position__c,Landlord_s_Address__c,
            Fit_Out_Period_Days__c,Fit_Out_Period_Months__c,
            (select Unit__r.name,Unit__r.NLA_SQM__c ,Unit__r.NLA_SQF__c,Unit__r.level__r.name,Rent_per_Sq_Feet__c from LOI_Units__r ),
            (select Deposit_Amount__c,Number_of_Months__c,Currency_Code__c,Deposit_Formula_Type__c,Deposit_Type__c from Deposits__r) from loi__c 
            where id=:loiId];
            
       chkList=[select FM_SN__c,Description__c,Condition__c from Checklist_Item__c where checklist__r.loi_unit__c=:loi.loi_units__r AND checkList__r.type__c='Handover'];
            
       integer sCount=0,rCount=0;
       Dep = new List<Deposit__c>();
       for(Deposit__c depo:loi.deposits__r){
          
           if(depositMonths == null ){
             depositMonths =  depo.Number_of_Months__c+'';
           }
           depo.Deposit_Amount__c = (depo.Deposit_Amount__c != null)? depo.Deposit_Amount__c : 0;
           string amo = ConvertCurrencyToWords.english_number(Integer.valueof(depo.Deposit_Amount__c));
       depositCurrency.put(depo.Id+'', amo.remove(','));
       
       //depo.Deposit_Amount__c = (depo.Number_of_Months__c != null)? depo.Number_of_Months__c : 0;
       
       amo = ConvertCurrencyToWords.english_number(Integer.valueof(depo.Number_of_Months__c));
       depositMonthsString.put(depo.Id+'', amo.remove(','));
        
           if(depo.Deposit_Type__c == 'Security' && sCount==0){
               sCount++;
               dep.add(depo);
           }
           else if(depo.Deposit_Type__c == 'Fit-Out' && rCount==0){
               rCount++;
               dep.add(depo);
           }
           
       }
       tenureYear = getYearfromMonth(loi.LOI_Tenure_Mths__c);
       renewalYear = getYearfromMonth(loi.Option_to_Renew__c);
       
       yearList = new List<Integer>();
       Integer yStrt=loi.LOI_Start_Date__c.year();
       while(yStrt <= loi.LOI_End_Date__c.year())
           yearList.add(yStrt++);
    
       
       loiCharges = [select id,name,Base_Rent__c,Currency_Code__c,start_date__c,End_Date__c,Charge_Rate__c,Charge_Type__c , Type__c,
            Tier_1_Upper_Limit__c,Tier_2_Upper_Limit__c,Tier_3_Upper_Limit__c,Tier_4_Upper_Limit__c,Tier_5_Upper_Limit__c,
          Tier_6_Upper_Limit__c,Tier_7_Upper_Limit__c,Tier_8_Upper_Limit__c,
          Tier_1_Rate__c,Tier_2_Rate__c,Tier_3_Rate__c,Tier_4_Rate__c,Tier_5_Rate__c,Tier_6_Rate__c,Tier_7_Rate__c,
          Tier_8_Rate__c,Tier_9_Rate__c,Tiered_Lower_Limit__c,Tiered_Limit__c,
          LOI_Unit__c,Base_Charge_Type__c
                    FROM Loi_charges__c 
                    WHERE LOI_Unit__r.LOI_Agreement_No__c=:loiId  ORDER BY start_date__c  desc];// AND (charge_type__c='Advance Rental' OR charge_type__c='Service')  
                    //ORDER BY start_date__c  desc ];
       sCount=0;rCount=0;
       chargList = new List<LOI_Charges__c>();        
       ChkMapKey = '';   
       loiChrgeMap = new Map<Id, LOI_Charges__c>();                    
       for(LOI_Charges__c loiChar : loiCharges){
           if(appliedCurrency == null ){
               appliedCurrency = loiChar.Currency_Code__c;
           }
           if(!loiChrgeMap.containsKey(loiChar.LOI_Unit__c) & loiChar.charge_Type__c == 'Advance Rental'){
              loiChrgeMap.put(loiChar.LOI_Unit__c , loiChar);
              ChkMapKey = string.valueof(loiChrgeMap.keyset()).replace('{', '').replace('{', '');
           }
            
           if(loiChar.charge_Type__c == 'Advance Rental' && rCount == 0){
               chargList.add(loiChar);
               rCount++;
           }
           if(loiChar.charge_Type__c == 'Service' && sCount == 0){
               chargList.add(loiChar);
               sCount++;
           }
           if(rCount > 0 && sCount > 0)
               break;
           else
               continue;
       }
       LOIChargesStructure serviceCharges = new LOIChargesStructure();
       LOIChargesStructure anpCharges = new LOIChargesStructure();
       LOIChargesStructure extraServiceCharges = new LOIChargesStructure();
       Boolean anpCount = false,extraSCount = false;
       sCount=0;rCount=0;
       
       Set<String> duplicateBRDates = new Set<String>();
       Set<String> duplicateGTODates = new Set<String>();
       
       chargesBaseRent = new List<LOI_Charges__c>();
       chargesGTO = new List<LOI_Charges__c>();
       
       Set<String> duplicateHigherGTODates = new Set<String>();
       Set<String> duplicateSumGTODates = new Set<String>();
       Set<String> duplicateTieredHGTODates = new Set<String>();
       Set<String> duplicateTieredSGTODates = new Set<String>();
       
       higherGTOWrap = new List<DisplayLOIChargesWrap>();
       sumGTOWrap = new List<DisplayLOIChargesWrap>();
       tieredHigherGTOWrap = new List<DisplayLOIChargesWrap>();
       tieredSumGTOWrap = new List<DisplayLOIChargesWrap>();
       
       Integer srNo = 1;
       for(LOI_Charges__c loiChar : loiCharges){
            String strtDt = loiChar.Start_Date__c.day()+'/'+loiChar.Start_Date__c.month()+'/'+loiChar.Start_Date__c.year();
            String endDt = loiChar.End_Date__c.day()+'/'+loiChar.End_Date__c.month()+'/'+loiChar.End_Date__c.year();
            
          DisplayLOIChargesWrap dlw = new DisplayLOIChargesWrap();
          if(loiChar.charge_Type__c == 'GTO Rent'){
            if(!duplicateHigherGTODates.contains(strtDt+'||'+endDt) && loiChar.Type__c == 'GTO (Higher)' && !loiChar.Tiered_Limit__c){
              dlw.gtoChrg = loiChar;
              dlw.sr = srNo;
              higherGTOWrap.add(dlw);
              duplicateHigherGTODates.add(strtDt+'||'+endDt);
            }
            if(!duplicateTieredHGTODates.contains(strtDt+'||'+endDt)   && loiChar.Type__c == 'GTO (Higher)' && loiChar.Tiered_Limit__c){
              dlw.gtoChrg = loiChar;
              dlw.sr = srNo;
              tieredHigherGTOWrap.add(dlw);
              duplicateTieredHGTODates.add(strtDt+'||'+endDt);
            }
            if(!duplicateSumGTODates.contains(strtDt+'||'+endDt)  && loiChar.Type__c == 'GTO (Sum)' && !loiChar.Tiered_Limit__c){
              dlw.gtoChrg = loiChar;
              dlw.sr = srNo;
              sumGTOWrap.add(dlw);
              duplicateSumGTODates.add(strtDt+'||'+endDt);
              System.debug('dlw-->'+dlw);
            }
            if(!duplicateTieredSGTODates.contains(strtDt+'||'+endDt)  && loiChar.Type__c == 'GTO (Sum)' && loiChar.Tiered_Limit__c){
              dlw.gtoChrg = loiChar;
              dlw.sr = srNo;
              tieredSumGTOWrap.add(dlw);
              duplicateTieredSGTODates.add(strtDt+'||'+endDt);
            }
            System.debug('dlw-->'+dlw);
            srNo++;
          }
       }
       System.debug(sumGTOWrap.size() +' sumGTOWrap-->'+sumGTOWrap);
       higherGTOWrap = (higherGTOWrap.size() > 0)?populateBaseRent(higherGTOWrap):new List<DisplayLOIChargesWrap>();
       tieredHigherGTOWrap = (tieredHigherGTOWrap.size() > 0)?populateBaseRent(tieredHigherGTOWrap):new List<DisplayLOIChargesWrap>();
       sumGTOWrap = (sumGTOWrap.size() > 0)?populateBaseRent(sumGTOWrap):new List<DisplayLOIChargesWrap>();
       tieredSumGTOWrap = (tieredSumGTOWrap.size() > 0)?populateBaseRent(tieredSumGTOWrap):new List<DisplayLOIChargesWrap>();
       Set<String> duplicateChargename = new Set<String>();
       for(LOI_Charges__c loiChar : loiCharges){
           String strtDt = loiChar.Start_Date__c.day()+'/'+loiChar.Start_Date__c.month()+'/'+loiChar.Start_Date__c.year();
           String endDt = loiChar.End_Date__c.day()+'/'+loiChar.End_Date__c.month()+'/'+loiChar.End_Date__c.year();
           if(!duplicateBRDates.contains(strtDt+'||'+endDt) && loiChar.charge_Type__c == 'Advance Rental'){
              chargesBaseRent.add(loiChar);
                duplicateBRDates.add(strtDt+'||'+endDt);
           }
           if(!duplicateGTODates.contains(strtDt+'||'+endDt)  && loiChar.charge_Type__c == 'GTO Rent'){
              chargesGTO.add(loiChar);
                duplicateGTODates.add(strtDt+'||'+endDt);
           }
           if(loiChar.charge_Type__c == 'Advance Rental' && rCount == 0){
               chargList.add(loiChar);
               rCount++;
           }
           //------//------ For 9 no point  //------//------
           Boolean checkCharges = (loiChar.charge_Type__c != 'Advance Rent' && loiChar.charge_Type__c != 'Advance Rental' && 
                  loiChar.charge_Type__c != 'Commercial Tax' && loiChar.charge_Type__c != 'Deposit' && 
                  loiChar.charge_Type__c != 'Discount' && loiChar.charge_Type__c != 'Gas'  && 
                  loiChar.charge_Type__c != 'Generator' && loiChar.charge_Type__c != 'Gov Meter' && 
                  loiChar.charge_Type__c != 'GTO Rent'  && loiChar.charge_Type__c != '  Late Charge' && 
                  loiChar.charge_Type__c != ' License Tax' && loiChar.charge_Type__c != 'Local' && 
                  loiChar.charge_Type__c != 'Payment Terms' && loiChar.charge_Type__c != 'Rebate' && 
                  loiChar.charge_Type__c != 'Sub Meter' && loiChar.charge_Type__c != 'Trunk' && 
                  loiChar.charge_Type__c != 'Water' && loiChar.charge_Type__c != 'Invoice Discount') 
                  ? true:false;
           if(!duplicateChargename.contains(loiChar.name.trim()) && checkCharges && loiChar.charge_Type__c != null){
             System.debug('duplicateChargename-->'+duplicateChargename);
             System.debug(loiChar.Id+'  loiChar.name.trim()-->'+loiChar.name.trim());
             serviceCharges = new LOIChargesStructure();
             serviceCharges.ChargeName = loiChar.name;
             if(loiChar.charge_Type__c == 'Service'){
                 chargList.add(loiChar);
              // serviceCharges.Description = loiChar.Charge_Rate__c.setScale(2) +' '+loiChar.Currency_Code__c+'  per Sq.ft (Including maintenance, security, cleaning, internal shop air con, common area utility fees)';
             } 
             if(loiChar.Charge_Rate__c == null ){
                loiChar.Charge_Rate__c = 0;
             }
             String tempBCT = (loiChar.Base_Charge_Type__c!=null)?loiChar.Base_Charge_Type__c:'';
             if(loiChar.Type__c == 'By Percent'){
                serviceCharges.Description = loiChar.Charge_Rate__c.setScale(2) +'% per one month '+tempBCT.toLowerCase() + ' fees';
             }else if(loiChar.Type__c == 'By Area'){
                serviceCharges.Description = loiChar.Charge_Rate__c.setScale(2) +' '+tempBCT.toLowerCase()+'  per sq.ft';
             }
             if(loiChar.charge_Type__c == 'Service'){
                  serviceCharges.Description += ' (Including maintenance, security, cleaning, internal shop air con, common area utility fees)';
             }
             lOIChrgStr.add(serviceCharges);
               duplicateChargename.add(loiChar.name.trim());
           }
           //------//------//------//------//------//------
       }
       
     
     
    /* if(serviceCharges.ChargeName != '')
        lOIChrgStr.add(serviceCharges);
     if(anpCharges.ChargeName != '')
        lOIChrgStr.add(anpCharges);
     if(extraServiceCharges.ChargeName != '')
        lOIChrgStr.add(extraServiceCharges);*/
        
       LOIChargesStructure loiChrages = new LOIChargesStructure();
       loiChrages.ChargeName = 'ELECTRICITY* (MEPE)';
       loiChrages.Description = 'According to private meter units (dual metering system)';
       lOIChrgStr.add(loiChrages);
       
       loiChrages = new LOIChargesStructure();
       loiChrages.ChargeName = 'WATER & GAS*';
       loiChrages.Description = 'According to usage (where applicable)';
       lOIChrgStr.add(loiChrages);
       
       loiChrages = new LOIChargesStructure();
       loiChrages.ChargeName = 'TELEPHONE & DATA LINE';
       loiChrages.Description = 'According to usage (where applicable)';
       lOIChrgStr.add(loiChrages);
       
       loiChrages = new LOIChargesStructure();
       loiChrages.ChargeName = 'COMMERCIAL TAX';
       loiChrages.Description = '5% of one month rental fees';
       lOIChrgStr.add(loiChrages);
       
       loiChrages = new LOIChargesStructure();
       loiChrages.ChargeName = 'PAYMENT';
       loiChrages.Description = 'Monthly payment';
       lOIChrgStr.add(loiChrages);
       
       List<Checklist_Item__c> checklistItm = [Select Id, Checklist__r.LOI_Unit__c, Checklist__c,FM_SN__c,Description__c,Condition__c From Checklist_Item__c where Checklist__r.LOI_Unit__r.LOI_Agreement_No__c =: loiId AND checkList__r.type__c='Handover'];
       Id loiUnit;
       handoverMapList = new Map<String, List<String>>();
       handOverCheckLst = new Map<String, Checklist_Item__c>();
       diplayChecklist  = new List<Checklist_Item__c>();
       for(Checklist_Item__c chk: checklistItm){
          if(loiUnit == null ){
            loiUnit = chk.Checklist__r.LOI_Unit__c;
          }
          if(loiUnit == chk.Checklist__r.LOI_Unit__c && chk.Checklist__r.LOI_Unit__c != null){
            List<String> tempStr = new List<String>();
            if(handoverMapList.containsKey(chk.Description__c)){
              tempStr = handoverMapList.get(chk.Description__c);
            }
            tempStr.add(chk.Condition__c);
            handoverMapList.put(chk.Description__c,tempStr);
            handOverCheckLst.put(chk.Description__c,chk);
            
            diplayChecklist.add(chk);
          }
       }
       keyValues = handoverMapList.keySet();
       
       
       List<Burmese_Text__c> btext = Burmese_Text__c.getall().values();
       for(Burmese_Text__c bt:btext){
          if(bt.Property_Name__c == loi.Property__r.Name){
            burmeseTextUrl = bt.Url__c;
            break;
          }
      if(bt.Property_Name__c == 'All'){
            burmeseTextUrl = bt.Url__c;
          }
       }
    }
    public List<DisplayLOIChargesWrap> populateBaseRent(List<DisplayLOIChargesWrap> gtoList){
      List<DisplayLOIChargesWrap> tempWrap = new List<DisplayLOIChargesWrap>();
      for(DisplayLOIChargesWrap hgw:gtoList){
          if(hgw.baseRentChrg == null)
            for(LOI_Charges__c loiChar : loiCharges){
              if(hgw.gtoChrg.LOI_Unit__c == loiChar.LOI_Unit__c && loiChar.charge_Type__c == 'Advance Rental'){
                System.debug('loiChar-->'+loiChar.Id);
                if(hgw.gtoChrg.Start_Date__c >= loiChar.Start_Date__c && hgw.gtoChrg.End_Date__c <= loiChar.End_Date__c){
                  hgw.baseRentChrg = new LOI_Charges__c();
                  hgw.baseRentChrg = loiChar;
                  System.debug('matched-->'+loiChar);
                  break;
                }else if(hgw.gtoChrg.Start_Date__c >= loiChar.Start_Date__c && hgw.gtoChrg.End_Date__c >= loiChar.End_Date__c){
                  hgw.baseRentChrg = new LOI_Charges__c();
                  hgw.baseRentChrg = loiChar;
                  DisplayLOIChargesWrap newWrap = new DisplayLOIChargesWrap();
                  newWrap.gtoChrg = hgw.gtoChrg;
                  newWrap.sr = hgw.sr;
                  for(LOI_Charges__c loiChar2 : loiCharges){
                    if(hgw.gtoChrg.LOI_Unit__c == loiChar2.LOI_Unit__c && loiChar2.charge_Type__c == 'Advance Rental')
                      if(hgw.gtoChrg.Start_Date__c <= loiChar2.Start_Date__c && hgw.gtoChrg.End_Date__c <= loiChar2.End_Date__c){
                        newWrap.baseRentChrg = new LOI_Charges__c();
                        newWrap.baseRentChrg = loiChar2;
                        tempWrap.add(newWrap);
                        break;
                      }
                  }
                  break;
                }
              }
            }
         }
         gtoList.addAll(tempWrap);
         return gtoList;
    }
    public Class DisplayLOIChargesWrap{
      public Integer sr{get;set;}
      public LOI_Charges__c baseRentChrg{get;set;}
      public LOI_Charges__c gtoChrg{get;set;}
      public DisplayLOIChargesWrap(){
        sr = 0;
        //baseRentChrg = new LOI_Charges__c();
        gtoChrg      = new LOI_Charges__c();
      }
    }
    public Class LOIChargesStructure{
      public String ChargeName{get;set;}
      public String Description{get;set;}
      public LOIChargesStructure(){
        ChargeName = '';
        Description = '';
      }
    }
   
}