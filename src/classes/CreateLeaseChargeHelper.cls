public with sharing class CreateLeaseChargeHelper {
    public static void assignValues(Lease_Charges__c lc, Applicable_Charges__c ac, Lease_Unit__c lu, Map<String, Id> typeMap,Map<Id, Lease__c> leaseMap){
        lc.Due_Month_Formula__c = ac.Due_Month_Formula__c;
        lc.Base_Charge_Type__c = ac.Base_Charge_Type__c;
        lc.Billing_Terms__c = ac.Billing_Terms__c;
        lc.Name = ac.Name;
        lc.Multiple_Rental_Schedule__c = ac.Multiple_Rental_Schedule__c;
        lc.Lease_Unit__c = lu.Id;

        if(ac.Frequency__c != null && ac.Frequency__c.trim().length()>0){
            lc.Billing_Frequency__c = ac.Frequency__c;
        }
        if(ac.Billing_Frequency__c != null && ac.Billing_Frequency__c.trim().length()>0){
            lc.Frequency__c = Ac.Billing_Frequency__c;
        }

        if(ac.Billing_Days__c != null && ac.Billing_Days__c.trim().length()>0){
            lc.Billing_Days__c = ac.Billing_Days__c;
        }
        lc.Base_included__c = ac.Base_included__c;
        lc.Base_Value__c = ac.Base_Value__c;

        lc.GTO_Rate__c = ac.GTO_Percent__c;
        lc.Active__c = ac.Active__c;
        lc.Charge__c = ac.Id;
        lc.Charge_Operator__c = ac.Charge_Operator__c;
        lc.Formula_Description__c = ac.Charge_Rate_Description__c;
        lc.Multiple_of_Parameter__c = ac.Multiple_of_Parameter__c;
        lc.Finance_Accounts_Code__c = ac.Finance_Accounts_Code__c;
        lc.Finance_Accounts_Desc__c = ac.Finance_Accounts_Desc__c;

        lc.Cap_Applicable__c = ac.Cap_Applicable__c;
        lc.GTO_Cap__c = ac.Cap_Value__c;

        lc.Type__c = ac.Type__c;
        lc.Commercial_Tax_Apply__c = ac.Commercial_Tax_Apply__c;
        lc.Charge_Type__c = ac.Charge_Type__c; //added by myat sep-25-2016

        if(!Test.isRunningTest()){
            lc.RecordTypeId = typeMap.get(ac.RecordType.DeveloperName); // added by myat 14-sep-2016
        }

        lc.Currency_Code__c = ac.Currency_Code__c;

        lc.Tiered_Limit__c = ac.Tiered_Limit__c;
        lc.Cumulative_for_each_Tier__c = ac.Cumulative_for_each_Tier__c;
        lc.Tiered_Lower_Limit__c = ac.Tiered_Lower_Limit__c;
        lc.Tier_1_Upper_Limit__c = ac.Tier_1_Upper_Limit__c;
        lc.Tier_2_Upper_Limit__c = ac.Tier_2_Upper_Limit__c;
        lc.Tier_3_Upper_Limit__c = ac.Tier_3_Upper_Limit__c;
        lc.Tier_4_Upper_Limit__c = ac.Tier_4_Upper_Limit__c;
        lc.Tier_5_Upper_Limit__c = ac.Tier_5_Upper_Limit__c;
        lc.Tier_6_Upper_Limit__c = ac.Tier_6_Upper_Limit__c;
        lc.Tier_7_Upper_Limit__c = ac.Tier_7_Upper_Limit__c;
        lc.Tier_8_Upper_Limit__c = ac.Tier_8_Upper_Limit__c;
        lc.Tier_1_Rate__c = ac.Tier_1_Rate__c;
        lc.Tier_2_Rate__c = ac.Tier_2_Rate__c;
        lc.Tier_3_Rate__c = ac.Tier_3_Rate__c;
        lc.Tier_4_Rate__c = ac.Tier_4_Rate__c;
        lc.Tier_5_Rate__c = ac.Tier_5_Rate__c;
        lc.Tier_6_Rate__c = ac.Tier_6_Rate__c;
        lc.Tier_7_Rate__c = ac.Tier_7_Rate__c;
        lc.Tier_8_Rate__c = ac.Tier_8_Rate__c;

        lc.Charge_Method__c = ac.Charge_Method__c;

        lc.Expected_GTO_Amount__c = ac.Expected_GTO_Amount__c;
        
        lc.Charge_Start_Day__c = ac.Charge_Start_Day__c;
         
       // return lc;                                   
    }
}