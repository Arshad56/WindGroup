public class LeaseExtensionController{
    public Lease__c lease{get;set;}
    public Lease__c leaseForUI{get;set;}
    public Boolean error{get;set;}
    public date selectedDate{get;set;}
    public boolean success{get;set;}
    public LeaseExtensionController(){
        lease = new Lease__c();
        leaseForUI = new Lease__c();
        error = false;
        success = false;
        selectedDate =  System.today();
        leaseForUI.Lease_Start_Date__c =  System.today();
        string leaseId = Apexpages.currentPage().getParameters().get('Id');
        
         for(Lease__c ls:[Select id,Lease_End_Date__c,Original_End_Date__c,Extended__c,Lease_Status__c from Lease__c where id=:leaseId limit 1]){
            lease = ls;
        }
    }
    
    public void  extend() {
        SavePoint sp = Database.setSavePoint();
         try{
            error = false;
            if(leaseForUI.Lease_Start_Date__c == null){
                error = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select Extension Date.'));
            }else if(leaseForUI.Lease_Start_Date__c <= lease.Original_End_Date__c){
                error = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Extension Date must be after Lease End Date.'));
            }else{
                Date tempDate = lease.Lease_End_Date__c.addMonths(3);
                if(leaseForUI.Lease_Start_Date__c>tempDate){
                    error = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Extension Date can\'t be more than 3 months from Current End Date. Kindly create a Renewal Lease in this case.'));
                }else{
                    error = false;
                    selectedDate = leaseForUI.Lease_Start_Date__c;
                    lease.Original_End_Date__c = selectedDate;
                    lease.Extended__c = true;
                    //lease.Lease_Status__c = 'Extended';
            
                    List<Lease_Charges__c> leaseChargeList = new List<Lease_Charges__c>();
                    List<Lease_Unit__c> leaseUnitList = [Select id,Original_End_Date__c,Lease_End_Date__c,Extended__c,Extension_Date__c,Unit__c,unit__r.Name,Unit__r.Start_Date__c,Unit__r.End_Date__c,(Select id,End_Date__c,Lease_Unit__c,Generate_Rent_Schedule__c,Charge_Method__c,Due_Month_Formula__c,Base_Charge_Type__c,Billing_Terms__c,Name,Multiple_Rental_Schedule__c,Billing_Frequency__c,Frequency__c,Billing_Days__c,Base_included__c,Base_Value__c,GTO_Rate__c,Active__c,Charge__c,Charge_Operator__c,Formula_Description__c,Multiple_of_Parameter__c,Finance_Accounts_Code__c,Finance_Accounts_Desc__c,Cap_Applicable__c,GTO_Cap__c,Start_Date__c,Type__c,Commercial_Tax_Apply__c,Charge_Type__c,RecordTypeId,Currency_Code__c,Tiered_Limit__c,Cumulative_for_each_Tier__c,Tiered_Lower_Limit__c,Tier_1_Upper_Limit__c,Tier_2_Upper_Limit__c,Tier_3_Upper_Limit__c,Tier_4_Upper_Limit__c,Tier_5_Upper_Limit__c,Tier_6_Upper_Limit__c,Tier_7_Upper_Limit__c,Tier_8_Upper_Limit__c,Tier_1_Rate__c,Tier_2_Rate__c,Tier_3_Rate__c,Tier_4_Rate__c,Tier_5_Rate__c,Tier_6_Rate__c,Tier_7_Rate__c,Tier_8_Rate__c,Tier_9_Rate__c,Lease_Plan__c,Charge_Rate__c,Expected_GTO_Amount__c from Lease_Charges__r) from Lease_Unit__c where Lease_Agreement_No__c=:lease.Id];
                    List<Lease_Charges__c> newLcList = new List<Lease_Charges__c>();
                    for(Lease_Unit__c lu:leaseUnitList){
                        Set<Id> dupCheckApplChg = new Set<Id>();
                        if(!(selectedDate>=lu.Unit__r.Start_Date__c && selectedDate<=lu.Unit__r.End_Date__c)){
                            error = true;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Selected date should be within Unit Start and End Date. Please click on<a target="_blank" href="/'+lu.Unit__c+'">'+lu.unit__r.Name+'</a>to view details.'));
                            return;
                        }
                        if(selectedDate>lu.Lease_End_Date__c){
                            lu.Original_End_Date__c = lu.Lease_End_Date__c;
                            lu.Lease_End_Date__c = selectedDate;
                            lu.Extension_Date__c = selectedDate;
                            lu.Extended__c = true;
                            for(Lease_Charges__c lc:lu.Lease_Charges__r){
                                if(lc.Charge_Method__c!='Daily Rate'){
                                    if(lc.End_Date__c==lu.Original_End_Date__c){
                                        lc.End_Date__c = selectedDate;
                                        leaseChargeList.add(lc);
                                    }
                                }else{
                                    if(!dupCheckApplChg.contains(lc.Charge__c)){
                                        dupCheckApplChg.add(lc.Charge__c);                                    
                                        for(Date dt=lu.Original_End_Date__c+1;dt<=lu.Lease_End_Date__c;dt=dt+1){
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
                                            lc1.Tier_9_Rate__c = lc.Tier_9_Rate__c; 
                                                                                   
                                            lc1.Charge_Method__c = lc.Charge_Method__c;
                                            lc1.Lease_Plan__c = lc.Lease_Plan__c;
                                            lc1.Charge_Rate__c = lc.Charge_Rate__c;
                                            lc1.Expected_GTO_Amount__c = lc.Expected_GTO_Amount__c;
                                            
                                            newLcList.add(lc1);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    update lease;
                    update leaseUnitList;
                    update leaseChargeList;
                    if(newLcList.size()>0){
                        insert newLcList;
                    }
                    success = true;
                }
            }
        }catch(DMLException e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getDMlMessage(0)));
            Database.Rollback(sp);
            error = true;
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            Database.Rollback(sp);
            error = true;
        }
    }
}