trigger createFitoutLC on Lease_Unit__c (after update){
    Set<Id> luIds = new Set<Id>();
    for(Lease_Unit__c lu:Trigger.New){
        if(lu.Generate_Fit_Out_LC__c && !Trigger.oldMap.get(lu.Id).Generate_Fit_Out_LC__c && lu.Fit_Out_Date__c!=null && lu.Lease_Start_Date__c!=null && lu.Fit_out_Date__c<lu.Lease_Start_Date__c){
            luIds.add(lu.Id);
        }
    }
    
    if(luIds.size()>0){
        List<Lease_Charges__c> leaseChargeList = [Select id,Active__c,Start_Date__c,Lease_Unit__c,Generate_Rent_Schedule__c,Charge__c,Due_Month_Formula__c,Base_Charge_Type__c,Billing_Terms__c,Name,Multiple_Rental_Schedule__c,Billing_Frequency__c,Frequency__c,Billing_Days__c,Base_included__c,Base_Value__c,Charge_Rate__c,GTO_Rate__c,Charge_Operator__c,Formula_Description__c,Multiple_of_Parameter__c,Finance_Accounts_Code__c,Finance_Accounts_Desc__c,Cap_Applicable__c,GTO_Cap__c,Type__c,Commercial_Tax_Apply__c,Charge_Type__c,RecordTypeId,Currency_Code__c,Tiered_Limit__c,Cumulative_for_each_Tier__c,Tiered_Lower_Limit__c,Tier_1_Upper_Limit__c,Tier_2_Upper_Limit__c,Tier_3_Upper_Limit__c,Tier_4_Upper_Limit__c,Tier_5_Upper_Limit__c,Tier_6_Upper_Limit__c,Tier_7_Upper_Limit__c,Tier_8_Upper_Limit__c,Tier_1_Rate__c,Tier_2_Rate__c,Tier_3_Rate__c,Tier_4_Rate__c,Tier_5_Rate__c,Tier_6_Rate__c,Tier_7_Rate__c,Tier_8_Rate__c,Tier_9_Rate__c,Charge_Method__c,Expected_GTO_Amount__c from Lease_Charges__c where Lease_Unit__c in:luIds and Charge__r.Applicable_For_Fit_out__c=true and Active__c=true];
        Map<Id,List<Lease_Charges__c>> luToLcMap = new Map<Id,List<Lease_Charges__c>>();
        for(Lease_Charges__c lc:leaseChargeList){
            List<Lease_Charges__c> tempList = new List<Lease_Charges__c>();
            if(luToLcMap.containsKey(lc.Lease_Unit__c)){
                tempList.addAll(luToLcMap.get(lc.Lease_Unit__c));
            }
            
            tempList.add(lc);
            luToLcMap.put(lc.Lease_Unit__c,tempList);
        }
        
        if(luToLcMap.size()>0){
            List<Lease_Charges__c> newLcList = new List<Lease_Charges__c>();
            for(Lease_Unit__c lu:Trigger.New){
                if(luToLcMap.containsKey(lu.Id)){
                    for(Lease_Charges__c lc:luToLcMap.get(lu.Id)){
                        Lease_Charges__c newLC = new Lease_Charges__c();
                        newLC.Due_Month_Formula__c = lc.Due_Month_Formula__c;
                        newLC.Base_Charge_Type__c = lc.Base_Charge_Type__c;
                        newLC.Billing_Terms__c = lc.Billing_Terms__c;
                        newLC.Name = lc.Name;
                        newLC.Multiple_Rental_Schedule__c = lc.Multiple_Rental_Schedule__c;
                        newLC.Lease_Unit__c = lu.Id;
                        newLC.Billing_Frequency__c = lc.Billing_Frequency__c;
                        newLC.Frequency__c = lc.Frequency__c;
                        newLC.Billing_Days__c = lc.Billing_Days__c;
                        newLC.Base_included__c = lc.Base_included__c;
                        newLC.Base_Value__c = lc.Base_Value__c;
                        newLC.Charge_Rate__c = lc.Charge_Rate__c;
                        newLC.GTO_Rate__c = lc.GTO_Rate__c;
                        newLC.Active__c = lc.Active__c;
                        newLC.Charge__c = lc.Charge__c;
                        newLC.Charge_Operator__c = lc.Charge_Operator__c;
                        newLC.Formula_Description__c = lc.Formula_Description__c;
                        newLC.Multiple_of_Parameter__c = lc.Multiple_of_Parameter__c;
                        newLC.Finance_Accounts_Code__c = lc.Finance_Accounts_Code__c;
                        newLC.Finance_Accounts_Desc__c = lc.Finance_Accounts_Desc__c;
                        newLC.Cap_Applicable__c = lc.Cap_Applicable__c;
                        newLC.GTO_Cap__c = lc.GTO_Cap__c;
                        newLC.Type__c = lc.Type__c;
                        newLC.Commercial_Tax_Apply__c = lc.Commercial_Tax_Apply__c;
                        newLC.Charge_Type__c = lc.Charge_Type__c;
                        newLC.RecordTypeId = lc.RecordTypeId;
                        newLC.Currency_Code__c = lc.Currency_Code__c;
                        newLC.Tiered_Limit__c = lc.Tiered_Limit__c;
                        newLC.Cumulative_for_each_Tier__c = lc.Cumulative_for_each_Tier__c;
                        newLC.Tiered_Lower_Limit__c = lc.Tiered_Lower_Limit__c;
                        newLC.Tier_1_Upper_Limit__c = lc.Tier_1_Upper_Limit__c;
                        newLC.Tier_2_Upper_Limit__c = lc.Tier_2_Upper_Limit__c;
                        newLC.Tier_3_Upper_Limit__c = lc.Tier_3_Upper_Limit__c;
                        newLC.Tier_4_Upper_Limit__c = lc.Tier_4_Upper_Limit__c;
                        newLC.Tier_5_Upper_Limit__c = lc.Tier_5_Upper_Limit__c;
                        newLC.Tier_6_Upper_Limit__c = lc.Tier_6_Upper_Limit__c;
                        newLC.Tier_7_Upper_Limit__c = lc.Tier_7_Upper_Limit__c;
                        newLC.Tier_8_Upper_Limit__c = lc.Tier_8_Upper_Limit__c;
                        newLC.Tier_1_Rate__c = lc.Tier_1_Rate__c;
                        newLC.Tier_2_Rate__c = lc.Tier_2_Rate__c;
                        newLC.Tier_3_Rate__c = lc.Tier_3_Rate__c;
                        newLC.Tier_4_Rate__c = lc.Tier_4_Rate__c;
                        newLC.Tier_5_Rate__c = lc.Tier_5_Rate__c;
                        newLC.Tier_6_Rate__c = lc.Tier_6_Rate__c;
                        newLC.Tier_7_Rate__c = lc.Tier_7_Rate__c;
                        newLC.Tier_8_Rate__c = lc.Tier_8_Rate__c;
                        newLC.Tier_9_Rate__c = lc.Tier_9_Rate__c;
                        
                        newLC.Charge_Method__c = lc.Charge_Method__c;
                        newLC.Expected_GTO_Amount__c = lc.Expected_GTO_Amount__c;
                        newLC.Generate_Rent_Schedule__c = true;
                        newLC.Start_Date__c = lu.Fit_out_Date__c;
                        newLC.End_Date__c = lu.Lease_Start_Date__c - 1;
                        newLC.Fit_out_Duration__c = true;
                        newLcList.add(newLC);
                    }
                }
            }
            
            if(newLcList.size()>0){
                insert newLcList;
            }
        }
    }
}