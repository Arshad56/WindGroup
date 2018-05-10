global class LOIConversionController{
    static Set<Id> luIds = new Set<Id>();
    static Set<Id> unIds = new Set<Id>();
    webservice static string convert(string loiId,String precedentLease){
        SavePoint sp = Database.SetSavePoint();
        try{
            List<leaseUnitChargeWrapper> leaseUnitChargeWrapList = new List<leaseUnitChargeWrapper>();
            List<LOI__c> loiList = [Select id,Fit_Out_Period_Days__c,Fit_Out_Period_Months__c,Charge_Method__c,Tenant_Type__c,Price_Factor__c,Billing_Term__c,Business_Type__c,Deposit_Fixed_Amount__c,Deposit_Pdf__c,Deposits__c,Extended__c,Financial_Contact__c,Handover_Client_Contact__c,Handover_Operation_In_Charge__c,Late_Payment_Interest__c,LOI_Signed_off_Date__c,LOI_Start_Date__c,LOI_Status__c,LOI_Tenure_Days__c,LOI_Tenure_Mths__c,Option_to_Renew__c,Permitted_Use__c,Property__c,Reason_for_Termination__c,Renovation_Rebates__c,Renovation_Rebates_Terms__c,Rent_Free_End_Date__c,Rent_Free_Start_Date__c,Rent_Roll__c,Original_End_Date__c,Stage__c,Staggered_Rent__c,Tenant__c,Terms_Conditions__c,(Select id,Actual_Trading_Date__c,Authorised_Person__c,Fit_Out_Date__c,Generate_CheckList__c,Handover_Date__c,Handover_Signed_off__c,Level__c,LOI_End_Date__c,LOI_Start_Date__c,Original_End_Date__c,Person_In_Charge__c,Rent_Free_End_Date__c,Rent_Free_Start_Date__c,Target_Trading_Date__c,Unit__c,Update_LOI_Plans__c from LOI_Units__r) from LOI__c where Id=:loiId limit 1];
            if(loiList.size()>0){
                Lease__c lease = new Lease__c();
                lease.Name = '-- System Generated --';
                if(precedentLease != null)
                    lease.Precedent_Lease__c = precedentLease;
                lease.Billing_Term__c = loiList[0].Billing_Term__c;
                lease.Business_Type__c = loiList[0].Business_Type__c;
                lease.Deposit_Fixed_Amount__c = loiList[0].Deposit_Fixed_Amount__c;
                lease.Deposit_Pdf__c = loiList[0].Deposit_Pdf__c;
                lease.Deposits__c = loiList[0].Deposits__c;
                lease.Extended__c = loiList[0].Extended__c;
                lease.Financial_Contact__c = loiList[0].Financial_Contact__c;
                lease.Handover_Client_Contact__c = loiList[0].Handover_Client_Contact__c;
                lease.Handover_Operation_In_Charge__c = loiList[0].Handover_Operation_In_Charge__c;
                lease.Late_Payment_Interest__c = loiList[0].Late_Payment_Interest__c;
                lease.Fit_Out_Period_Days__c = loiList[0].Fit_Out_Period_Days__c;
                lease.Fit_Out_Period_Months__c = loiList[0].Fit_Out_Period_Months__c;
               // lease.Lease_Signed_Date__c = loiList[0].LOI_Signed_Date__c;  This field LOI_Signed_Date__c removed from LOI
                lease.LOI_Signed_off_Date__c = loiList[0].LOI_Signed_off_Date__c;
                lease.Lease_Start_Date__c = loiList[0].LOI_Start_Date__c;
                lease.Lease_Status__c = 'New';
                lease.Lease_Tenure_Days__c = loiList[0].LOI_Tenure_Days__c;
                lease.Lease_Tenure_Mths__c = loiList[0].LOI_Tenure_Mths__c;
                lease.Option_to_Renew__c = loiList[0].Option_to_Renew__c;
                lease.Permitted_Use__c = loiList[0].Permitted_Use__c;
                lease.Property__c = loiList[0].Property__c;
                lease.Reason_for_Termination__c = loiList[0].Reason_for_Termination__c;
                lease.Renovation_Rebates__c = loiList[0].Renovation_Rebates__c;
                lease.Renovation_Rebates_Terms__c = loiList[0].Renovation_Rebates_Terms__c;
                lease.Rent_Free_End_Date__c = loiList[0].Rent_Free_End_Date__c;
                lease.Rent_Free_Start_Date__c = loiList[0].Rent_Free_Start_Date__c;
                lease.Rent_Roll__c = loiList[0].Rent_Roll__c;
                lease.Original_End_Date__c = loiList[0].Original_End_Date__c;
                lease.Stage__c = 'LA Draft';
                lease.Staggered_Rent__c = loiList[0].Staggered_Rent__c;
                lease.Tenant__c = loiList[0].Tenant__c;
                lease.Terms_Conditions__c = loiList[0].Terms_Conditions__c;
                lease.LOI__c = loiList[0].Id;
                lease.Tenant_Type__c = loiList[0].Tenant_Type__c;
                lease.Price_Factor__c = loiList[0].Price_Factor__c;
                lease.Charge_Method__c = loiList[0].Charge_Method__c;
                insert lease;            
                
                if(loiList[0].LOI_Units__r.size()>0){
                    Set<Id> loiUntIds = new Set<Id>();
                    for(LOI_Unit__c loiUnit:loiList[0].LOI_Units__r){
                        loiUntIds.add(loiUnit.Id);
                    }
                    Map<Id,List<Deposit__c>> loiDepositMap = new Map<Id,List<Deposit__c>>();
                    for(Deposit__c dp:[Select id,LOI_Unit__c from Deposit__c where LOI_Unit__c in:loiUntIds]){
                        List<Deposit__c> tempList = new List<Deposit__c>();
                        if(loiDepositMap.containsKey(dp.LOI_Unit__c)){
                            tempList.addAll(loiDepositMap.get(dp.LOI_Unit__c));
                        }
                        tempList.add(dp);
                        loiDepositMap.put(dp.LOI_Unit__c,tempList);
                    }
                    
                    Map<Id,List<Checklist__c>> loiChecklistMap = new Map<Id,List<Checklist__c>>();
                    for(Checklist__c dp:[Select id,LOI_Unit__c from Checklist__c where LOI_Unit__c in:loiUntIds]){
                        List<Checklist__c> tempList = new List<Checklist__c>();
                        if(loiChecklistMap.containsKey(dp.LOI_Unit__c)){
                            tempList.addAll(loiChecklistMap.get(dp.LOI_Unit__c));
                        }
                        tempList.add(dp);
                        loiChecklistMap.put(dp.LOI_Unit__c,tempList);
                    }
                    
                    Map<Id,List<LOI_Charges__c>> loiUnitToChargeMap = new Map<Id,List<LOI_Charges__c>>();
                    for(LOI_Charges__c loiChg:[Select id,Charge_Start_Day__c,LOI_Unit__c,Name,Active__c,Charge__c,Base_Charge_Type__c,Base_included__c,Base_Rent__c,Base_Value__c,Billing_Days__c,Frequency__c,Billing_Terms__c,Charge_Amount_Applicable__c,Charge_Description__c,Charge_Operator__c,Charge_Rate__c,Charge_Rate_Input_Required__c,Charge_Type__c,Commercial_Tax_Apply__c,Cumulative_for_each_Tier__c,Currency_Code__c,Default_Charge__c,Due_Month_Formula__c,End_Date__c,Exchange_Rate__c,Expected_Amount__c,Expected_GTO__c,Expected_GTO_Amount__c,Finance_Accounts_Code__c,Finance_Accounts_Desc__c,First_Month_Pro_rated_Rent__c,Formula_Description__c,GTO_Rate__c,Multiple_of_Parameter__c,Multiple_Rental_Schedule__c,No_of_Months__c,Billing_Frequency__c,Start_Date__c,Type__c,recordtype.DeveloperName,Charge__r.Tiered_Limit__c,Charge__r.Tier_1_Rate__c,Charge__r.Tier_1_Upper_Limit__c,Charge__r.Tier_2_Rate__c,Charge__r.Tier_2_Upper_Limit__c,Charge__r.Tier_3_Rate__c,Charge__r.Tier_3_Upper_Limit__c,Charge__r.Tier_4_Rate__c,Charge__r.Tier_4_Upper_Limit__c,Charge__r.Tier_5_Rate__c,Charge__r.Tier_5_Upper_Limit__c,Charge__r.Tier_6_Rate__c,Charge__r.Tier_6_Upper_Limit__c,Charge__r.Tier_7_Rate__c,Charge__r.Tier_7_Upper_Limit__c,Charge__r.Tier_8_Rate__c,Charge__r.Tier_8_Upper_Limit__c,Charge__r.Tiered_Lower_Limit__c,Charge__r.Charge_Method__c,Withholding_Tax_Applicable__c,Withholding_Tax_Rate__c,Lease_Plan__c,Tiered_Limit__c,Tiered_Lower_Limit__c,Tier_1_Rate__c,Tier_1_Upper_Limit__c, Tier_2_Rate__c,Tier_2_Upper_Limit__c,Tier_3_Rate__c,Tier_3_Upper_Limit__c,Tier_4_Rate__c,Tier_4_Upper_Limit__c,Tier_5_Rate__c,Tier_5_Upper_Limit__c, Tier_6_Rate__c, Tier_6_Upper_Limit__c,Tier_7_Rate__c, Tier_7_Upper_Limit__c, Tier_8_Rate__c,Tier_8_Upper_Limit__c,Tier_9_Rate__c  from LOI_Charges__c where LOI_Unit__c in:loiUntIds]){
                        List<LOI_Charges__c> tempList = new List<LOI_Charges__c>();
                        if(loiUnitToChargeMap.containsKey(loiChg.Loi_Unit__c)){
                            tempList.addAll(loiUnitToChargeMap.get(loiChg.Loi_Unit__c));
                        }
                        tempList.add(loiChg);
                        loiUnitToChargeMap.put(loiChg.Loi_Unit__c,tempList);
                    }
                    Map<String, Id> typeMap = New Map<String, Id>();
        
                    for(RecordType rt: [Select ID, DeveloperName From RecordType Where sObjectType = 'Lease_Charges__c']) {
                        typeMap.put(rt.DeveloperName, rt.id);
                    }
                    for(LOI_Unit__c loiUnit:loiList[0].LOI_Units__r){
                        Lease_Unit__c lu = new Lease_Unit__c();
                        lu.Actual_Trading_Date__c = loiUnit.Actual_Trading_Date__c;
                        lu.Authorised_Person__c = loiUnit.Authorised_Person__c;
                        //lu.CT_Meter_No__c = loiUnit.CT_Meter_No__c; // Removed unused fields
                        lu.Fit_Out_Date__c = loiUnit.Fit_Out_Date__c;
                        //lu.Gas_Meter_No__c = loiUnit.Gas_Meter_No__c;
                        lu.Generate_CheckList__c = loiUnit.Generate_CheckList__c;
                        lu.Handover_Date__c = loiUnit.Handover_Date__c;
                        lu.Handover_Signed_off__c = loiUnit.Handover_Signed_off__c;
                        //lu.Horse_Power__c = loiUnit.Horse_Power__c;//commented by myat at apr-05-2018 as it's not using any more.
                        //lu.Line_Loss__c = loiUnit.Line_Loss__c;//commented by myat at apr-05-2018 as it's not using any more.
                        lu.Lease_Agreement_No__c = lease.Id;
                        lu.Lease_End_Date__c = loiUnit.LOI_End_Date__c;
                        lu.Lease_Start_Date__c = loiUnit.LOI_Start_Date__c;
                        lu.Original_End_Date__c = loiUnit.Original_End_Date__c;
                        lu.Person_In_Charge__c = loiUnit.Person_In_Charge__c;
                        //lu.Phone_Extension_No__c = loiUnit.Phone_Extension_No__c; // Removed unused fields
                        //lu.Power_Factor__c = loiUnit.Power_Factor__c;             // Removed unused fields
                        lu.Rent_Free_End_Date__c = loiUnit.Rent_Free_End_Date__c;
                        lu.Rent_Free_Start_Date__c = loiUnit.Rent_Free_Start_Date__c;
                        //lu.Sub_Meter_No__c = loiUnit.Sub_Meter_No__c;     // Removed unused fields
                        lu.Target_Trading_Date__c = loiUnit.Target_Trading_Date__c;
                        lu.Unit__c = loiUnit.Unit__c;
                        lu.Update_Lease_Plans__c = loiUnit.Update_LOI_Plans__c;
                        //lu.Water_Meter_No__c = loiUnit.Water_Meter_No__c; // Removed unused fields
                        lu.Converted_From_LOI__c = true;
                        leaseUnitChargeWrapper lucw = new leaseUnitChargeWrapper();
                        lucw.leaseUnit = lu;
                        
                        if(loiDepositMap.containsKey(loiUnit.Id)){
                            lucw.depositList = loiDepositMap.get(loiUnit.Id);
                        }
                        if(loiCheckListMap.containsKey(loiUnit.Id)){
                            lucw.checkLists = loiCheckListMap.get(loiUnit.Id);
                        }
                        
                        if(loiUnitToChargeMap.containsKey(loiUnit.Id)){
                            for(LOI_Charges__c loiChg:loiUnitToChargeMap.get(loiUnit.Id)){
                                Lease_Charges__c lc = new Lease_Charges__c();
                                lc.Name = loiChg.Name;
                                lc.Charge_Start_Day__c = loiChg.Charge_Start_Day__c;
                                lc.Active__c = loiChg.Active__c;
                                lc.Charge__c = loiChg.Charge__c;
                                lc.Base_Charge_Type__c = loiChg.Base_Charge_Type__c;
                                lc.Base_included__c = loiChg.Base_included__c;
                                lc.Base_Rent__c = loiChg.Base_Rent__c;
                                lc.Base_Value__c = loiChg.Base_Value__c;
                                lc.Billing_Days__c = loiChg.Billing_Days__c;
                                lc.Billing_Terms__c = loiChg.Billing_Terms__c;
                                lc.Frequency__c = loiChg.Frequency__c;
                                lc.Charge_Amount_Applicable__c = loiChg.Charge_Amount_Applicable__c;
                                lc.Charge_Description__c = loiChg.Charge_Description__c;
                                lc.Charge_Operator__c = loiChg.Charge_Operator__c;
                                lc.Charge_Rate__c = loiChg.Charge_Rate__c;
                                lc.Charge_Rate_Input_Required__c = loiChg.Charge_Rate_Input_Required__c;
                                lc.Charge_Type__c = loiChg.Charge_Type__c;
                                lc.Commercial_Tax_Apply__c = loiChg.Commercial_Tax_Apply__c;
                                lc.Cumulative_for_each_Tier__c = loiChg.Cumulative_for_each_Tier__c;
                                lc.Currency_Code__c = loiChg.Currency_Code__c;
                                lc.Default_Charge__c = loiChg.Default_Charge__c;
                                lc.Due_Month_Formula__c = loiChg.Due_Month_Formula__c;
                                lc.End_Date__c = loiChg.End_Date__c;
                                lc.Exchange_Rate__c = loiChg.Exchange_Rate__c;
                                lc.Expected_Amount__c = loiChg.Expected_Amount__c;
                                lc.Expected_GTO__c = loiChg.Expected_GTO__c;
                                lc.Expected_GTO_Amount__c = loiChg.Expected_GTO_Amount__c;
                                lc.Finance_Accounts_Code__c = loiChg.Finance_Accounts_Code__c;
                                lc.Finance_Accounts_Desc__c = loiChg.Finance_Accounts_Desc__c;
                                lc.First_Month_Pro_rated_Rent__c = loiChg.First_Month_Pro_rated_Rent__c;
                                lc.Formula_Description__c = loiChg.Formula_Description__c;
                                lc.GTO_Rate__c = loiChg.GTO_Rate__c;
                                lc.Multiple_of_Parameter__c = loiChg.Multiple_of_Parameter__c;
                                lc.Multiple_Rental_Schedule__c = loiChg.Multiple_Rental_Schedule__c;
                                lc.No_of_Months__c = loiChg.No_of_Months__c;
                                lc.Billing_Frequency__c = loiChg.Billing_Frequency__c;
                                lc.Start_Date__c = loiChg.Start_Date__c;
                                lc.Type__c = loiChg.Type__c;
                                lc.RecordTypeId = typeMap.get(loiChg.RecordType.DeveloperName);
                                
                                lc.Tiered_Limit__c = loiChg.Tiered_Limit__c;    
                                lc.Cumulative_for_each_Tier__c = loiChg.Cumulative_for_each_Tier__c;                        
                                lc.Tiered_Lower_Limit__c = loiChg.Tiered_Lower_Limit__c;
                                lc.Tier_1_Upper_Limit__c = loiChg.Tier_1_Upper_Limit__c;
                                lc.Tier_2_Upper_Limit__c = loiChg.Tier_2_Upper_Limit__c;
                                lc.Tier_3_Upper_Limit__c = loiChg.Tier_3_Upper_Limit__c;
                                lc.Tier_4_Upper_Limit__c = loiChg.Tier_4_Upper_Limit__c;
                                lc.Tier_5_Upper_Limit__c = loiChg.Tier_5_Upper_Limit__c;
                                lc.Tier_6_Upper_Limit__c = loiChg.Tier_6_Upper_Limit__c;
                                lc.Tier_7_Upper_Limit__c = loiChg.Tier_7_Upper_Limit__c;
                                lc.Tier_8_Upper_Limit__c = loiChg.Tier_8_Upper_Limit__c;
                                lc.Tier_1_Rate__c = loiChg.Tier_1_Rate__c;
                                lc.Tier_2_Rate__c = loiChg.Tier_2_Rate__c;
                                lc.Tier_3_Rate__c = loiChg.Tier_3_Rate__c;
                                lc.Tier_4_Rate__c = loiChg.Tier_4_Rate__c;
                                lc.Tier_5_Rate__c = loiChg.Tier_5_Rate__c;
                                lc.Tier_6_Rate__c = loiChg.Tier_6_Rate__c;
                                lc.Tier_7_Rate__c = loiChg.Tier_7_Rate__c;
                                lc.Tier_8_Rate__c = loiChg.Tier_8_Rate__c;
                                lc.Tier_9_Rate__c = loiChg.Tier_9_Rate__c;
                                
                                lc.Charge_Method__c = loiChg.Charge__r.Charge_Method__c;
                                
                                lc.Withholding_Tax_Applicable__c = loiChg.Withholding_Tax_Applicable__c;
                                lc.Withholding_Tax_Rate__c = loiChg.Withholding_Tax_Rate__c;
                                
                                lc.Lease_Plan__c = loiChg.Lease_Plan__c;
                                
                                lucw.leaseChargeList.add(lc);
                            }
                        }
                        leaseUnitChargeWrapList.add(lucw);
                    }
                    if(leaseUnitChargeWrapList.size()>0){
                        List<Lease_Unit__c> leaseUnitList = new List<Lease_Unit__c>();
                        for(leaseUnitChargeWrapper lucw:leaseUnitChargeWrapList){
                            leaseUnitList.add(lucw.leaseUnit);
                        }
                        insert leaseUnitList;
                        List<Lease_Charges__c> leaseChargeList = new List<Lease_Charges__c>();
                        List<Deposit__c> depositList = new List<Deposit__c>();
                        List<CheckList__c> checkLists = new List<CheckList__c>();
                        for(leaseUnitChargeWrapper lucw:leaseUnitChargeWrapList){
                            if(lucw.leaseUnit.Id!=null){
                                for(Deposit__c dp:lucw.depositList){
                                    dp.Lease_Unit__c = lucw.leaseUnit.Id;
                                    dp.Lease__c = lucw.leaseUnit.Lease_Agreement_No__c;
                                    depositList.add(dp);
                                }
                                for(CheckList__c ch:lucw.checkLists){
                                    ch.Lease_Unit__c = lucw.leaseUnit.Id;
                                    ch.Unit__c = lucw.leaseUnit.Unit__c;
                                    checkLists.add(ch);
                                }
                                for(Lease_Charges__c lc:lucw.leaseChargeList){
                                    lc.Lease_Unit__c = lucw.leaseUnit.Id;
                                    leaseChargeList.add(lc);
                                }
                                luIds.add(lucw.leaseUnit.Id);
                                unIds.add(lucw.leaseUnit.Unit__c);
                            }
                        }
                        if(depositList.size()>0){
                            update depositList;
                        }
                        if(checkLists.size()>0){
                            update checkLists;
                        }
                        insert leaseChargeList;
                        /* Added By Arshad on 20th June
                         */
                        MainLeaseUnitTrigger_Helper.updateLeasePlans(luIds,unIds);
                        /* ----- */
                    }
                }
                
                loiList[0].LOI_Status__c = 'Converted';
                loiList[0].Stage__c = 'LA Converted';
                update loiList[0];
            }
        }catch(exception e){
            database.rollBack(sp);
            return e.getMessage();
        }
        return 'Lease Agreement successfully created.';
    }
    
    public class leaseUnitChargeWrapper{
        public Lease_Unit__c leaseUnit{get;set;}
        public List<Deposit__c> depositList{get;set;}
        public List<CheckList__c> checkLists{get;set;}
        public List<Lease_Charges__c> leaseChargeList{get;set;}
        public leaseUnitChargeWrapper(){
            leaseUnit = new Lease_Unit__c();
            leaseChargeList = new List<Lease_Charges__c>();
            depositList = new List<Deposit__c>();
            checkLists = new List<CheckList__c>();
        }
    }
}