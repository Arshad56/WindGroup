public class ExtensionLuCmpController {
    @AuraEnabled
    public static String checkTermination(String recordId) {
        try{
            String msg = '';
            List<Lease_Unit__c> luList = [SELECT Id,Name,Pre_Termination__c FROM Lease_Unit__c 
                                          WHERE  Id =: recordId AND Pre_Termination__c = true];	
            
            if(luList.size() > 0)
                msg = 'Error: '+ 'This Lease Unit is Terminated.';
            else
                msg = 'Success';
            
            return msg;
        }catch(Exception e){
            return 'ERROR: '+e;
        }
    }
    
    @AuraEnabled
    public static string checkDate(String recordId, String extendedDate) {
        SavePoint sp = Database.setSavePoint();
        String msg = 'Success';
        try{
            
            Lease__c leaseForUI = new Lease__c();
            
            Lease_Unit__c leaseUnit = new Lease_Unit__c();
            for(Lease_Unit__c lu:[Select id,Lease_End_Date__c,Original_End_Date__c,Extension_Date__c,Extended__c,Unit__r.Start_Date__c,Unit__r.End_Date__c,Lease_Agreement_No__c from Lease_Unit__c where id=:recordId limit 1])
                leaseUnit = lu;
            
            if(String.isNotBlank(extendedDate)){
                String[] dts = extendedDate.split('-');    
                leaseForUI.Lease_Start_Date__c = Date.newInstance(Integer.valueOf(dts[0]),Integer.valueOf(dts[1]),Integer.valueOf(dts[2]));
            }
            
            if(leaseForUI.Lease_Start_Date__c == null){
                msg = 'Info: Please Select Extension Date.';
            }else if(leaseForUI.Lease_Start_Date__c <= leaseUnit.Lease_End_Date__c){
                msg = 'Info: Please Select Future Extension Date.';
            }else if(!(leaseForUI.Lease_Start_Date__c>=leaseUnit.Unit__r.Start_Date__c && leaseForUI.Lease_Start_Date__c<=leaseUnit.Unit__r.End_Date__c)){
                msg ='Info: Selected date should be within Unit Start and End Date.';
            }else{
                
                Date selectedDate = leaseForUI.Lease_Start_Date__c;
                if(selectedDate>leaseUnit.Lease_End_Date__c){
                    leaseUnit.Original_End_Date__c = leaseUnit.Lease_End_Date__c;
                    leaseUnit.Lease_End_Date__c = selectedDate;
                    leaseUnit.Extension_Date__c = selectedDate;
                    leaseUnit.Extended__c = true;
                    List<Lease_Charges__c> leaseChargeList = [Select id,End_Date__c,Lease_Unit__c,Generate_Rent_Schedule__c,Charge_Method__c,Due_Month_Formula__c,Base_Charge_Type__c,Billing_Terms__c,Name,Multiple_Rental_Schedule__c,Billing_Frequency__c,Frequency__c,Billing_Days__c,Base_included__c,Base_Value__c,GTO_Rate__c,Active__c,Charge__c,Charge_Operator__c,Formula_Description__c,Multiple_of_Parameter__c,Finance_Accounts_Code__c,Finance_Accounts_Desc__c,Cap_Applicable__c,GTO_Cap__c,Start_Date__c,Type__c,Commercial_Tax_Apply__c,Charge_Type__c,RecordTypeId,Currency_Code__c,Tiered_Limit__c,Cumulative_for_each_Tier__c,Tiered_Lower_Limit__c,Tier_1_Upper_Limit__c,Tier_2_Upper_Limit__c,Tier_3_Upper_Limit__c,Tier_4_Upper_Limit__c,Tier_5_Upper_Limit__c,Tier_6_Upper_Limit__c,Tier_7_Upper_Limit__c,Tier_8_Upper_Limit__c,Tier_1_Rate__c,Tier_2_Rate__c,Tier_3_Rate__c,Tier_4_Rate__c,Tier_5_Rate__c,Tier_6_Rate__c,Tier_7_Rate__c,Tier_8_Rate__c,Lease_Plan__c,Charge_Rate__c,Expected_GTO_Amount__c from Lease_Charges__c where Lease_Unit__c =:leaseUnit.Id and End_Date__c=:leaseUnit.Original_End_Date__c];
                    
                    List<Lease_Charges__c> newLcList = new List<Lease_Charges__c>();
                    Set<Id> dupCheckApplChg = new Set<Id>();
                    
                    for(Lease_Charges__c lc:leaseChargeList){
                        if(lc.Charge_Method__c!='Daily Rate'){
                            lc.End_Date__c = selectedDate;
                        }else{
                            if(!dupCheckApplChg.contains(lc.Charge__c)){
                                dupCheckApplChg.add(lc.Charge__c);                                    
                                for(Date dt=leaseUnit.Original_End_Date__c+1;dt<=leaseUnit.Lease_End_Date__c;dt=dt+1){
                                    Lease_Charges__c lc1 = new Lease_Charges__c();
                                    lc1.Due_Month_Formula__c = lc.Due_Month_Formula__c;
                                    lc1.Base_Charge_Type__c = lc.Base_Charge_Type__c;
                                    lc1.Billing_Terms__c = lc.Billing_Terms__c;
                                    lc1.Name =lc.Name;
                                    lc1.Multiple_Rental_Schedule__c = lc.Multiple_Rental_Schedule__c;
                                    lc1.Lease_Unit__c = lc.Lease_Unit__c;
                                    lc1.Billing_Frequency__c = lc.Billing_Frequency__c;
                                    lc1.Frequency__c = lc.Frequency__c;
                                    lc1.Billing_Days__c = lc.Billing_Days__c;
                                    lc1.Base_included__c = lc.Base_included__c;
                                    lc1.Base_Value__c = lc.Base_Value__c;                                        
                                    lc1.GTO_Rate__c = lc.GTO_Rate__c;
                                    lc1.Active__c = lc.Active__c;
                                    lc1.Charge__c = lc.Charge__c;
                                    lc1.Charge_Operator__c = lc.Charge_Operator__c;
                                    lc1.Formula_Description__c = lc.Formula_Description__c;
                                    lc1.Multiple_of_Parameter__c = lc.Multiple_of_Parameter__c;
                                    lc1.Finance_Accounts_Code__c = lc.Finance_Accounts_Code__c;
                                    lc1.Finance_Accounts_Desc__c = lc.Finance_Accounts_Desc__c;
                                    
                                    lc1.Cap_Applicable__c = lc.Cap_Applicable__c;
                                    lc1.GTO_Cap__c = lc.GTO_Cap__c;
                                    
                                    lc1.Start_Date__c = dt;
                                    lc1.End_Date__c = dt;
                                    
                                    lc1.Type__c = lc.Type__c;
                                    lc1.Commercial_Tax_Apply__c = lc.Commercial_Tax_Apply__c;
                                    lc1.Charge_Type__c = lc.Charge_Type__c;
                                    lc1.RecordTypeId = lc.RecordTypeId;
                                    
                                    lc.Currency_Code__c = lc.Currency_Code__c;
                                    
                                    lc1.Tiered_Limit__c = lc.Tiered_Limit__c;
                                    lc1.Cumulative_for_each_Tier__c = lc.Cumulative_for_each_Tier__c;
                                    lc1.Tiered_Lower_Limit__c = lc.Tiered_Lower_Limit__c;
                                    lc1.Tier_1_Upper_Limit__c = lc.Tier_1_Upper_Limit__c;
                                    lc1.Tier_2_Upper_Limit__c = lc.Tier_2_Upper_Limit__c;
                                    lc1.Tier_3_Upper_Limit__c = lc.Tier_3_Upper_Limit__c;
                                    lc1.Tier_4_Upper_Limit__c = lc.Tier_4_Upper_Limit__c;
                                    lc1.Tier_5_Upper_Limit__c = lc.Tier_5_Upper_Limit__c;
                                    lc1.Tier_6_Upper_Limit__c = lc.Tier_6_Upper_Limit__c;
                                    lc1.Tier_7_Upper_Limit__c = lc.Tier_7_Upper_Limit__c;
                                    lc1.Tier_8_Upper_Limit__c = lc.Tier_8_Upper_Limit__c;
                                    lc1.Tier_1_Rate__c = lc.Tier_1_Rate__c;
                                    lc1.Tier_2_Rate__c = lc.Tier_2_Rate__c;
                                    lc1.Tier_3_Rate__c = lc.Tier_3_Rate__c;
                                    lc1.Tier_4_Rate__c = lc.Tier_4_Rate__c;
                                    lc1.Tier_5_Rate__c = lc.Tier_5_Rate__c;
                                    lc1.Tier_6_Rate__c = lc.Tier_6_Rate__c;
                                    lc1.Tier_7_Rate__c = lc.Tier_7_Rate__c;
                                    lc1.Tier_8_Rate__c = lc.Tier_8_Rate__c;                                        
                                    lc1.Charge_Method__c = lc.Charge_Method__c;
                                    lc1.Lease_Plan__c = lc.Lease_Plan__c;
                                    lc1.Charge_Rate__c = lc.Charge_Rate__c;
                                    lc1.Expected_GTO_Amount__c = lc.Expected_GTO_Amount__c;
                                    
                                    newLcList.add(lc1);
                                }
                            }
                        }
                    }
                    
                    Lease__c lease = new Lease__c();
                    lease.Id = leaseUnit.Lease_Agreement_No__c;
                    lease.Original_End_Date__c = selectedDate;
                    lease.Extended__c = true;
                    //lease.Lease_Status__c = 'Extended';
                    update lease;
                    
                    update leaseChargeList;
                    update leaseUnit;
                    if(newLcList.size()>0){
                        insert newLcList;
                    }
                }
                msg = 'Success';
            }
        }catch(DMLException e){
           // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getDMlMessage(0)));
            Database.Rollback(sp);
            msg = 'Error: '+e.getDMlMessage(0);
        }catch(exception e){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            Database.Rollback(sp);
            msg = 'Error: '+e.getMessage();
        }
        
        
        return msg;
    }  
}