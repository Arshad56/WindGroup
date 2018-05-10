trigger CreateLOIChargeTemplate on LOI_Unit_Template__c (after insert) {
    Set<Id> unitIds = new Set<Id>();
    Map<Id,Id> unitToPropertyMap = new Map<Id,Id>();
    Set<Id> propertyIds = new Set<Id>();
    Map<Id,Units__c> unitMap = new Map<Id,Units__c>();
    for(LOI_Unit_Template__c lut:Trigger.New){
        if(lut.Charge_Method__c!=null){
            if(lut.Property_Lookup__c!=null){
                propertyIds.add(lut.Property_Lookup__c);
            }
            if(lut.Unit__c!=null){
                unitIds.add(lut.Unit__c);
            }
        }
    }
    
    if(unitIds.size()>0){
        List<Units__c> unitList = [Select id,Property__c,Start_Date__c,End_Date__c from Units__c where id in:unitIds];
        for(Units__c un:unitList){
            unitToPropertyMap.put(un.Id,un.Property__c);
            propertyIds.add(un.Property__c);
            unitMap.put(un.Id,un);
        }
    }
    if(propertyIds.size()>0){
        List<Applicable_Charges__c> appChgList = [Select id,Charge_Start_Day__c,Tiered_Limit__c,Cumulative_for_each_Tier__c,Tiered_Lower_Limit__c,Tier_1_Upper_Limit__c,Tier_2_Upper_Limit__c,Tier_3_Upper_Limit__c,Tier_4_Upper_Limit__c,Tier_5_Upper_Limit__c,Tier_6_Upper_Limit__c,Tier_7_Upper_Limit__c,Tier_8_Upper_Limit__c,Tier_1_Rate__c,Tier_2_Rate__c,Tier_3_Rate__c,Tier_4_Rate__c,Tier_5_Rate__c,Tier_6_Rate__c,Tier_7_Rate__c,Tier_8_Rate__c,Tier_9_Rate__c,Cap_Value__c,Charge_Description__c,Currency_Code__c,Billing_Frequency__c,Base_Charge_Type__c,Due_Month_Formula__c,Billing_Terms__c,Lease_Type__c,RecordType.DeveloperName ,Name,Active__c,Property__c,Base_included__c,Base_Value__c,Billing_Days__c,Frequency__c,Charge_Operator__c,Charge_Rate__c,GTO_Percent__c,Charge_Rate_Description__c,Multiple_of_Parameter__c,Finance_Accounts_Code__c,Finance_Accounts_Desc__c,Type__c,Rate__c,Commercial_Tax_Apply__c,Charge_Type__c,Multiple_Rental_Schedule__c,Expected_GTO_Amount__c,Charge_Method__c from Applicable_Charges__c where Property__c in:propertyIds and Active__c=true and Charge_Type__c!='Miscellaneous'];
        Map<Id,List<Applicable_Charges__c>> propToAppChgMap = new Map<Id,List<Applicable_Charges__c>>();
        for(Applicable_Charges__c ac:appChgList){
            List<Applicable_Charges__c> tempList = new List<Applicable_Charges__c>();
            if(propToAppChgMap.containsKey(ac.Property__c)){
                tempList.addAll(propToAppChgMap.get(ac.Property__c));
            }
            tempList.add(ac);
            propToAppChgMap.put(ac.Property__c,tempList);
        }
        if(propToAppChgMap.size()>0){
            Map<string,Id> recordTypeMap = new Map<string,Id>();
            for(RecordType rt:[Select id,DeveloperName from RecordType where SobjectType='LOI_Charge_Template__c']){
                recordTypeMap.put(rt.DeveloperName,rt.Id);
            }
            List<LOI_Charge_Template__c> loiChargeTempList = new List<LOI_Charge_Template__c>();
            for(LOI_Unit_Template__c lut:Trigger.New){
                if((lut.Property_Lookup__c!=null && propToAppChgMap.containsKey(lut.Property_Lookup__c)) || (lut.Unit__c!=null && unitToPropertyMap.containsKey(lut.Unit__c) && propToAppChgMap.containsKey(unitToPropertyMap.get(lut.Unit__c)))){
                    for(Applicable_Charges__c ac: (lut.Property_Lookup__c!=null?propToAppChgMap.get(lut.Property_Lookup__c):propToAppChgMap.get(unitToPropertyMap.get(lut.Unit__c)))){
                        if(lut.Charge_Method__c!=null && ((lut.Charge_Method__c.contains('Monthly Rate - L') && (ac.Charge_Method__c=='Monthly Rate - L' ||  ac.Charge_Method__c=='Transaction Rate')) || (lut.Charge_Method__c.contains('Monthly Rate - CL') && ac.Charge_Method__c=='Monthly Rate - CL')  || (lut.Charge_Method__c.contains('Daily Rate') && ac.Charge_Method__c=='Daily Rate')  || (lut.Charge_Method__c.contains('Transaction Rate') && ac.Charge_Method__c=='Transaction Rate'))){
                            LOI_Charge_Template__c lct = new LOI_Charge_Template__c();
                            lct.Due_Month_Formula__c = ac.Due_Month_Formula__c;
                            lct.Base_Charge_Type__c = ac.Base_Charge_Type__c;
                            lct.Billing_Terms__c = ac.Billing_Terms__c;
                            lct.Name =ac.Name;
                            lct.Multiple_Rental_Schedule__c = ac.Multiple_Rental_Schedule__c;
                            
                            lct.LOI_Unit_Template__c = lut.Id;
                            
                            if(ac.Frequency__c!=null && ac.Frequency__c.trim().length()>0){
                                lct.Billing_Frequency__c = ac.Frequency__c;
                            }
                            if(ac.Billing_Frequency__c!=null && ac.Billing_Frequency__c.trim().length()>0){
                                lct.Frequency__c = Ac.Billing_Frequency__c;
                            }
                            
                            if(ac.Billing_Days__c!=null && ac.Billing_Days__c.trim().length()>0){
                                lct.Billing_Days__c = ac.Billing_Days__c;
                            }
                            lct.Base_included__c = ac.Base_included__c;
                            lct.Base_Value__c = ac.Base_Value__c;
                            lct.Charge_Rate__c = ac.Charge_Rate__c;
                            lct.GTO_Rate__c = ac.GTO_Percent__c;
                            lct.Active__c = ac.Active__c;
                            lct.Charge__c = ac.Id;
                            lct.Charge_Operator__c = ac.Charge_Operator__c;
                            lct.Formula_Description__c = ac.Charge_Rate_Description__c;
                            lct.Multiple_of_Parameter__c = ac.Multiple_of_Parameter__c;
                            lct.Finance_Accounts_Code__c = ac.Finance_Accounts_Code__c;
                            lct.Finance_Accounts_Desc__c = ac.Finance_Accounts_Desc__c;
                            
                            lct.Tiered_Limit__c = ac.Tiered_Limit__c;    
                            lct.Cumulative_for_each_Tier__c = ac.Cumulative_for_each_Tier__c;                        
                            lct.Tiered_Lower_Limit__c = ac.Tiered_Lower_Limit__c;
                            lct.Tier_1_Upper_Limit__c = ac.Tier_1_Upper_Limit__c;
                            lct.Tier_2_Upper_Limit__c = ac.Tier_2_Upper_Limit__c;
                            lct.Tier_3_Upper_Limit__c = ac.Tier_3_Upper_Limit__c;
                            lct.Tier_4_Upper_Limit__c = ac.Tier_4_Upper_Limit__c;
                            lct.Tier_5_Upper_Limit__c = ac.Tier_5_Upper_Limit__c;
                            lct.Tier_6_Upper_Limit__c = ac.Tier_6_Upper_Limit__c;
                            lct.Tier_7_Upper_Limit__c = ac.Tier_7_Upper_Limit__c;
                            lct.Tier_8_Upper_Limit__c = ac.Tier_8_Upper_Limit__c;
                            lct.Tier_1_Rate__c = ac.Tier_1_Rate__c;
                            lct.Tier_2_Rate__c = ac.Tier_2_Rate__c;
                            lct.Tier_3_Rate__c = ac.Tier_3_Rate__c;
                            lct.Tier_4_Rate__c = ac.Tier_4_Rate__c;
                            lct.Tier_5_Rate__c = ac.Tier_5_Rate__c;
                            lct.Tier_6_Rate__c = ac.Tier_6_Rate__c;
                            lct.Tier_7_Rate__c = ac.Tier_7_Rate__c;
                            lct.Tier_8_Rate__c = ac.Tier_8_Rate__c;
                            lct.Tier_9_Rate__c = ac.Tier_9_Rate__c;
                            
                            if(lut.Start_Date__c!=null){
                                lct.Start_Date__c = lut.Start_Date__c;
                            }else if(unitMap.containsKey(lut.Unit__c)){
                                lct.Start_Date__c = unitMap.get(lut.Unit__c).Start_Date__c;
                            }
                            
                            if(lut.End_Date__c!=null){
                                lct.End_Date__c = lut.End_Date__c;
                            }else if(unitMap.containsKey(lut.Unit__c)){
                                lct.End_Date__c = unitMap.get(lut.Unit__c).End_Date__c;
                            }
                            
                            lct.Type__c = ac.Type__c;
                            lct.Commercial_Tax_Apply__c = ac.Commercial_Tax_Apply__c;
                            lct.Charge_Type__c = ac.Charge_Type__c;
                            
                            lct.recordtypeId = recordTypeMap.get(ac.recordtype.developerName);
                            
                            lct.Expected_GTO_Amount__c = ac.Expected_GTO_Amount__c;
                            
                            lct.Currency_code__c = ac.Currency_Code__c;
                            lct.Charge_Description__c = ac.Charge_Description__c;
                            lct.Cap_Value__c = ac.Cap_Value__c;
                            
                           // if(ac.Charge_Start_Day__c != null)
                            //lct.Charge_Start_Day__c = (ac.Charge_Start_Day__c != null)?ac.Charge_Start_Day__c:'0';
                            if(ac.Charge_Start_Day__c != null)
                            lct.Charge_Start_Day__c = ac.Charge_Start_Day__c;
                            
                            System.debug(ac.Id+ ' ' +ac.name + ' '+ ac.Type__c +' ac.Charge_Start_Day__c -->'+ac.Charge_Start_Day__c);
                            loiChargeTempList.add(lct);
                        }
                    }
                }
            }
            Integer i = 0;
            for(LOI_Charge_Template__c loic:loiChargeTempList){
            	System.debug(++i + ' '+loic.Charge_Start_Day__c+' loic -->'+loic);
            }
            //System.debug(' loiChargeTempList -->'+loiChargeTempList);
            insert loiChargeTempList;
        }
    }
    
}