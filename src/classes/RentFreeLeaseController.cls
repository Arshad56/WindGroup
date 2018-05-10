public class RentFreeLeaseController{
    Public Lease__c lease{get;set;}
    public Boolean success{get;set;}
    public List<LcToRsWrapper> lcToRsWrapList{get;set;}
    public RentFreeLeaseController(){
        lcToRsWrapList = new List<LcToRsWrapper>();
        success = false;
        lease = new Lease__c();
        try{
            string leaseId = Apexpages.currentPage().getParameters().get('Id');
            for(Lease__c ls:[Select id,Rent_Free_Start_Date__c,Rent_Free_End_Date__c,Lease_Start_Date__c,Lease_End_Date__c from Lease__c where id=:leaseId limit 1]){
                lease = ls;
            }
        }catch(Exception e){}
    }
    
    public void proceed(){
        if(lease.Rent_Free_End_Date__c > lease.Rent_Free_Start_Date__c){
            if(lease.Rent_Free_Start_Date__c>=lease.Lease_Start_Date__c && lease.Rent_Free_End_Date__c<=lease.Lease_End_Date__c){
                update lease;
                List<Lease_Unit__c> leaseUnitList = [Select id,Rent_Free_Start_Date__c,Rent_Free_End_Date__c from Lease_Unit__c where Lease_Agreement_No__c=:lease.Id];
                Set<Id> leaseUnitIds = new Set<Id>();
                for(Lease_Unit__c lu:leaseUnitList){
                    lu.Rent_Free_Start_Date__c = lease.Rent_Free_Start_Date__c;
                    lu.Rent_Free_End_Date__c = lease.Rent_Free_End_Date__c;
                    leaseUnitIds.add(lu.Id);
                }
                update leaseUnitList;
                Map<string,Lease_Charges__c> rentFreeLsChgMap = new Map<string,Lease_Charges__c>();
                List<Lease_Charges__c> oldLeaseCharges = new List<Lease_Charges__c>();
                List<Rent_Schedules__c> oldRentSchedules = new List<Rent_Schedules__c>();
                List<Lease_Charges__c> leaseChargeList = [Select id,Due_Month_Formula__c,Base_Charge_Type__c,Billing_Terms__c,Name,Multiple_Rental_Schedule__c,Lease_Unit__c,Billing_Frequency__c,Frequency__c,Billing_Days__c,Base_included__c,Base_Value__c,Charge_Rate__c,GTO_Rate__c,Active__c,Charge__c,Charge_Operator__c,Formula_Description__c,Multiple_of_Parameter__c,Finance_Accounts_Code__c,Finance_Accounts_Desc__c,Start_Date__c,End_Date__c,Type__c,Commercial_Tax_Apply__c,Charge_Type__c,RecordTypeId,Currency_Code__c,(Select id,Start_Date__c,End_Date__c,Lease_Charge__c,Unit__c,PropertyLU__c,TenantLU__c,Status__c,Base_Rent_LC__c,Expected_Amount__c,Lease_Unit__c,recordTypeId,Electric_Meter__c,Electric_Meter_Number__c,Transaction_Status__c,Remarks__c,Comm_Tax__c,Billing_Date__c from Rent_Schedules__r) from Lease_Charges__c where Lease_Unit__c in:leaseUnitIds and (Charge_Type__c='Rent' or Charge_Type__c='Advance Rental')];
                for(Lease_Charges__c lc:leaseChargeList){
                    if(lease.Rent_Free_Start_Date__c <= lc.Start_Date__c && lc.End_Date__c>lease.Rent_Free_End_Date__c){
                        lc.End_Date__c = lease.Rent_Free_End_Date__c + 1;
                        oldLeaseCharges.add(lc);
                        Lease_Charges__c lc1 = new Lease_Charges__c();
                        if(rentFreeLsChgMap.containsKey(lc.Lease_Unit__c+'-'+lease.Rent_Free_Start_Date__c.format()+'-'+lease.Rent_Free_End_Date__c.format())){
                            lc1 = rentFreeLsChgMap.get(lc.Lease_Unit__c+'-'+lease.Rent_Free_Start_Date__c.format()+'-'+lease.Rent_Free_End_Date__c.format());
                        }else{
                            lc1.Due_Month_Formula__c = lc.Due_Month_Formula__c;
                            lc1.Base_Charge_Type__c = lc.Base_Charge_Type__c;
                            lc1.Billing_Terms__c = lc.Billing_Terms__c;
                            lc1.Name =lc.Name;
                            lc1.Multiple_Rental_Schedule__c = lc.Multiple_Rental_Schedule__c;
                            lc1.Lease_Unit__c = lc.Lease_Unit__c;                                            
                            
                            lc1.Billing_Frequency__c = lc.Frequency__c;                                                
                            lc1.Frequency__c = lc.Billing_Frequency__c;
                            
                            if(lc.Billing_Days__c!=null && lc.Billing_Days__c.trim().length()>0){
                                lc1.Billing_Days__c = lc.Billing_Days__c;
                            }
                            lc1.Base_included__c = lc.Base_included__c;
                            lc1.Base_Value__c = lc.Base_Value__c;
                            lc1.Charge_Rate__c = 0;
                            lc1.GTO_Rate__c = lc.GTO_Rate__c;
                            lc1.Active__c = lc.Active__c;
                            lc1.Charge__c = lc.Charge__c;
                            lc1.Charge_Operator__c = lc.Charge_Operator__c;
                            lc1.Formula_Description__c = lc.Formula_Description__c;
                            lc1.Multiple_of_Parameter__c = lc.Multiple_of_Parameter__c;
                            lc1.Finance_Accounts_Code__c = lc.Finance_Accounts_Code__c;
                            lc1.Finance_Accounts_Desc__c = lc.Finance_Accounts_Desc__c;
                            
                            
                            lc1.Type__c = lc.Type__c;
                            lc1.Commercial_Tax_Apply__c = lc.Commercial_Tax_Apply__c;
                            lc1.Charge_Type__c = lc.Charge_Type__c;
    
                            lc1.RecordTypeId = lc.recordTypeId;
                            
                            lc1.Currency_Code__c = lc.Currency_Code__c;
                            
                            lc1.Start_Date__c = lease.Rent_Free_Start_Date__c;
                            lc1.End_Date__c = lease.Rent_Free_End_Date__c;
                            
                            rentFreeLsChgMap.put(lc1.Lease_Unit__c+'-'+lc1.Start_Date__c.format()+'-'+lc1.End_Date__c.format(),lc1);
                        }
                        LcToRsWrapper lcToRsWrap = new LcToRsWrapper();
                        lcToRsWrap.leaseCharge = lc1;
                        
                        for(Rent_Schedules__c rs:lc.Rent_Schedules__r){
                            if(rs.Start_Date__c>=lc1.Start_Date__c && rs.End_Date__c<=lc1.End_Date__c){
                                lcToRsWrap.rentSchList.add(rs);
                            }else if(rs.Start_Date__c<lc1.Start_Date__c && rs.End_Date__c>lc1.Start_Date__c){
                                Rent_Schedules__c newRs = new Rent_Schedules__c();
                                newRs.Unit__c = rs.Unit__c;
                                newRs.PropertyLU__c = rs.PropertyLU__c;
                                newRs.TenantLU__c = rs.TenantLU__c;
                                newRs.Status__c = rs.Status__c;
                                newRs.Base_Rent_LC__c =rs.Base_Rent_LC__c;
                                newRs.Expected_Amount__c =rs.Expected_Amount__c;
                                newRs.Lease_Unit__c = rs.Lease_Unit__c;
                                newRs.recordTypeId = rs.recordTypeId;
                                newRs.Electric_Meter__c = rs.Electric_Meter__c;
                                newRs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c;
                                newRs.Transaction_Status__c = rs.Transaction_Status__c;
                                newRs.Remarks__c = rs.Remarks__c;
                                newRs.Comm_Tax__c =rs.Comm_Tax__c;
                                newRs.Billing_Date__c = rs.Billing_Date__c;
                                newRs.Start_Date__c = lc1.Start_Date__c;
                                newRs.End_Date__c = rs.End_Date__c;
                                lcToRsWrap.rentSchList.add(newRs);
                                rs.End_Date__c = lc1.Start_Date__c - 1;
                                oldRentSchedules.add(rs);
                            }else if(rs.Start_Date__c>=lc1.Start_Date__c && rs.Start_Date__c<=lc1.End_Date__c && rs.End_Date__c>lc1.End_Date__c){
                                Rent_Schedules__c newRs = new Rent_Schedules__c();
                                newRs.Unit__c = rs.Unit__c;
                                newRs.PropertyLU__c = rs.PropertyLU__c;
                                newRs.TenantLU__c = rs.TenantLU__c;
                                newRs.Status__c = rs.Status__c;
                                newRs.Base_Rent_LC__c =rs.Base_Rent_LC__c;
                                newRs.Expected_Amount__c =rs.Expected_Amount__c;
                                newRs.Lease_Unit__c = rs.Lease_Unit__c;
                                newRs.recordTypeId = rs.recordTypeId;
                                newRs.Electric_Meter__c = rs.Electric_Meter__c;
                                newRs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c;
                                newRs.Transaction_Status__c = rs.Transaction_Status__c;
                                newRs.Remarks__c = rs.Remarks__c;
                                newRs.Comm_Tax__c =rs.Comm_Tax__c;
                                newRs.Billing_Date__c = rs.Billing_Date__c;
                                newRs.Start_Date__c = rs.Start_Date__c;
                                newRs.End_Date__c = lc1.End_Date__c;
                                lcToRsWrap.rentSchList.add(newRs);
                                rs.Start_Date__c = lc1.End_Date__c + 1;
                                oldRentSchedules.add(rs);
                            }
                        }
                        lcToRsWrapList.add(lcToRsWrap);
                    }else if(lease.Rent_Free_Start_Date__c <= lc.Start_Date__c && lease.Rent_Free_End_Date__c>=lc.End_Date__c){
                        lc.Start_Date__c = lease.Rent_Free_Start_Date__c;
                        lc.End_Date__c = lease.Rent_Free_End_Date__c;
                        lc.Charge_Rate__c = 0;
                        rentFreeLsChgMap.put(lc.Lease_Unit__c+'-'+lc.Start_Date__c.format()+'-'+lc.End_Date__c.format(),lc);
                        
                    }else if(lease.Rent_Free_Start_Date__c > lc.Start_Date__c && lease.Rent_Free_Start_Date__c<=lc.End_Date__c && lease.Rent_Free_End_Date__c>=lc.End_Date__c){
                        lc.End_Date__c = lease.Rent_Free_Start_Date__c - 1;
                        oldLeaseCharges.add(lc);
                        
                        Lease_Charges__c lc1 = new Lease_Charges__c();
                        lc1.Due_Month_Formula__c = lc.Due_Month_Formula__c;
                        lc1.Base_Charge_Type__c = lc.Base_Charge_Type__c;
                        lc1.Billing_Terms__c = lc.Billing_Terms__c;
                        lc1.Name =lc.Name;
                        lc1.Multiple_Rental_Schedule__c = lc.Multiple_Rental_Schedule__c;
                        lc1.Lease_Unit__c = lc.Lease_Unit__c;                                            
                        
                        lc1.Billing_Frequency__c = lc.Frequency__c;                                                
                        lc1.Frequency__c = lc.Billing_Frequency__c;
                        
                        if(lc.Billing_Days__c!=null && lc.Billing_Days__c.trim().length()>0){
                            lc1.Billing_Days__c = lc.Billing_Days__c;
                        }
                        lc1.Base_included__c = lc.Base_included__c;
                        lc1.Base_Value__c = lc.Base_Value__c;
                        lc1.Charge_Rate__c = 0;
                        lc1.GTO_Rate__c = lc.GTO_Rate__c;
                        lc1.Active__c = lc.Active__c;
                        lc1.Charge__c = lc.Charge__c;
                        lc1.Charge_Operator__c = lc.Charge_Operator__c;
                        lc1.Formula_Description__c = lc.Formula_Description__c;
                        lc1.Multiple_of_Parameter__c = lc.Multiple_of_Parameter__c;
                        lc1.Finance_Accounts_Code__c = lc.Finance_Accounts_Code__c;
                        lc1.Finance_Accounts_Desc__c = lc.Finance_Accounts_Desc__c;
                        
                        
                        lc1.Type__c = lc.Type__c;
                        lc1.Commercial_Tax_Apply__c = lc.Commercial_Tax_Apply__c;
                        lc1.Charge_Type__c = lc.Charge_Type__c;

                        lc1.RecordTypeId = lc.recordTypeId;
                        
                        lc1.Currency_Code__c = lc.Currency_Code__c;
                        
                        lc1.Start_Date__c = lease.Rent_Free_Start_Date__c;
                        lc1.End_Date__c = lease.Rent_Free_End_Date__c;
                        
                        rentFreeLsChgMap.put(lc1.Lease_Unit__c+'-'+lc1.Start_Date__c.format()+'-'+lc1.End_Date__c.format(),lc1);
                        
                        LcToRsWrapper lcToRsWrap = new LcToRsWrapper();
                        lcToRsWrap.leaseCharge = lc1;
                        
                        for(Rent_Schedules__c rs:lc.Rent_Schedules__r){
                            if(rs.Start_Date__c>=lc1.Start_Date__c && rs.End_Date__c<=lc1.End_Date__c){
                                lcToRsWrap.rentSchList.add(rs);
                            }else if(rs.Start_Date__c<lc1.Start_Date__c && rs.End_Date__c>lc1.Start_Date__c){
                                Rent_Schedules__c newRs = new Rent_Schedules__c();
                                newRs.Unit__c = rs.Unit__c;
                                newRs.PropertyLU__c = rs.PropertyLU__c;
                                newRs.TenantLU__c = rs.TenantLU__c;
                                newRs.Status__c = rs.Status__c;
                                newRs.Base_Rent_LC__c =rs.Base_Rent_LC__c;
                                newRs.Expected_Amount__c =rs.Expected_Amount__c;
                                newRs.Lease_Unit__c = rs.Lease_Unit__c;
                                newRs.recordTypeId = rs.recordTypeId;
                                newRs.Electric_Meter__c = rs.Electric_Meter__c;
                                newRs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c;
                                newRs.Transaction_Status__c = rs.Transaction_Status__c;
                                newRs.Remarks__c = rs.Remarks__c;
                                newRs.Comm_Tax__c =rs.Comm_Tax__c;
                                newRs.Billing_Date__c = rs.Billing_Date__c;
                                newRs.Start_Date__c = lc1.Start_Date__c;
                                newRs.End_Date__c = rs.End_Date__c;
                                lcToRsWrap.rentSchList.add(newRs);
                                rs.End_Date__c = lc1.Start_Date__c - 1;
                                oldRentSchedules.add(rs);
                            }else if(rs.Start_Date__c>=lc1.Start_Date__c && rs.Start_Date__c<=lc1.End_Date__c && rs.End_Date__c>lc1.End_Date__c){
                                Rent_Schedules__c newRs = new Rent_Schedules__c();
                                newRs.Unit__c = rs.Unit__c;
                                newRs.PropertyLU__c = rs.PropertyLU__c;
                                newRs.TenantLU__c = rs.TenantLU__c;
                                newRs.Status__c = rs.Status__c;
                                newRs.Base_Rent_LC__c =rs.Base_Rent_LC__c;
                                newRs.Expected_Amount__c =rs.Expected_Amount__c;
                                newRs.Lease_Unit__c = rs.Lease_Unit__c;
                                newRs.recordTypeId = rs.recordTypeId;
                                newRs.Electric_Meter__c = rs.Electric_Meter__c;
                                newRs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c;
                                newRs.Transaction_Status__c = rs.Transaction_Status__c;
                                newRs.Remarks__c = rs.Remarks__c;
                                newRs.Comm_Tax__c =rs.Comm_Tax__c;
                                newRs.Billing_Date__c = rs.Billing_Date__c;
                                newRs.Start_Date__c = rs.Start_Date__c;
                                newRs.End_Date__c = lc1.End_Date__c;
                                lcToRsWrap.rentSchList.add(newRs);
                                rs.Start_Date__c = lc1.End_Date__c + 1;
                                oldRentSchedules.add(rs);
                            }
                        }
                        lcToRsWrapList.add(lcToRsWrap);
                    }else if(lease.Rent_Free_Start_Date__c > lc.Start_Date__c && lease.Rent_Free_End_Date__c<lc.End_Date__c){
                        Lease_Charges__c lc2 = new Lease_Charges__c();
                        lc2.Due_Month_Formula__c = lc.Due_Month_Formula__c;
                        lc2.Base_Charge_Type__c = lc.Base_Charge_Type__c;
                        lc2.Billing_Terms__c = lc.Billing_Terms__c;
                        lc2.Name =lc.Name;
                        lc2.Multiple_Rental_Schedule__c = lc.Multiple_Rental_Schedule__c;
                        lc2.Lease_Unit__c = lc.Lease_Unit__c;                                            
                        
                        lc2.Billing_Frequency__c = lc.Frequency__c;                                                
                        lc2.Frequency__c = lc.Billing_Frequency__c;
                        
                        if(lc.Billing_Days__c!=null && lc.Billing_Days__c.trim().length()>0){
                            lc2.Billing_Days__c = lc.Billing_Days__c;
                        }
                        lc2.Base_included__c = lc.Base_included__c;
                        lc2.Base_Value__c = lc.Base_Value__c;
                        lc2.Charge_Rate__c = lc.Charge_Rate__c;
                        lc2.GTO_Rate__c = lc.GTO_Rate__c;
                        lc2.Active__c = lc.Active__c;
                        lc2.Charge__c = lc.Charge__c;
                        lc2.Charge_Operator__c = lc.Charge_Operator__c;
                        lc2.Formula_Description__c = lc.Formula_Description__c;
                        lc2.Multiple_of_Parameter__c = lc.Multiple_of_Parameter__c;
                        lc2.Finance_Accounts_Code__c = lc.Finance_Accounts_Code__c;
                        lc2.Finance_Accounts_Desc__c = lc.Finance_Accounts_Desc__c;
                        
                        
                        lc2.Type__c = lc.Type__c;
                        lc2.Commercial_Tax_Apply__c = lc.Commercial_Tax_Apply__c;
                        lc2.Charge_Type__c = lc.Charge_Type__c;

                        lc2.RecordTypeId = lc.recordTypeId;
                        
                        lc2.Currency_Code__c = lc.Currency_Code__c;
                        
                        lc2.Start_Date__c = lease.Rent_Free_End_Date__c + 1;
                        lc2.End_Date__c = lc.End_Date__c;
                        
                        rentFreeLsChgMap.put(lc2.Lease_Unit__c+'-'+lc2.Start_Date__c.format()+'-'+lc2.End_Date__c.format(),lc2);
                        
                        Lease_Charges__c lc1 = new Lease_Charges__c();
                        lc1.Due_Month_Formula__c = lc.Due_Month_Formula__c;
                        lc1.Base_Charge_Type__c = lc.Base_Charge_Type__c;
                        lc1.Billing_Terms__c = lc.Billing_Terms__c;
                        lc1.Name =lc.Name;
                        lc1.Multiple_Rental_Schedule__c = lc.Multiple_Rental_Schedule__c;
                        lc1.Lease_Unit__c = lc.Lease_Unit__c;                                            
                        
                        lc1.Billing_Frequency__c = lc.Frequency__c;                                                
                        lc1.Frequency__c = lc.Billing_Frequency__c;
                        
                        if(lc.Billing_Days__c!=null && lc.Billing_Days__c.trim().length()>0){
                            lc1.Billing_Days__c = lc.Billing_Days__c;
                        }
                        lc1.Base_included__c = lc.Base_included__c;
                        lc1.Base_Value__c = lc.Base_Value__c;
                        lc1.Charge_Rate__c = 0;
                        lc1.GTO_Rate__c = lc.GTO_Rate__c;
                        lc1.Active__c = lc.Active__c;
                        lc1.Charge__c = lc.Charge__c;
                        lc1.Charge_Operator__c = lc.Charge_Operator__c;
                        lc1.Formula_Description__c = lc.Formula_Description__c;
                        lc1.Multiple_of_Parameter__c = lc.Multiple_of_Parameter__c;
                        lc1.Finance_Accounts_Code__c = lc.Finance_Accounts_Code__c;
                        lc1.Finance_Accounts_Desc__c = lc.Finance_Accounts_Desc__c;
                        
                        
                        lc1.Type__c = lc.Type__c;
                        lc1.Commercial_Tax_Apply__c = lc.Commercial_Tax_Apply__c;
                        lc1.Charge_Type__c = lc.Charge_Type__c;

                        lc1.RecordTypeId = lc.recordTypeId;
                        
                        lc1.Currency_Code__c = lc.Currency_Code__c;
                        
                        lc1.Start_Date__c = lease.Rent_Free_Start_Date__c;
                        lc1.End_Date__c = lease.Rent_Free_End_Date__c;
                        
                        rentFreeLsChgMap.put(lc1.Lease_Unit__c+'-'+lc1.Start_Date__c.format()+'-'+lc1.End_Date__c.format(),lc1);
                        
                        lc.End_Date__c = lease.Rent_Free_Start_Date__c - 1;
                        
                        oldLeaseCharges.add(lc);
                        
                        LcToRsWrapper lcToRsWrap1 = new LcToRsWrapper();
                        lcToRsWrap1.leaseCharge = lc1;
                        
                        LcToRsWrapper lcToRsWrap2 = new LcToRsWrapper();
                        lcToRsWrap2.leaseCharge = lc2;
                        
                        for(Rent_Schedules__c rs:lc.Rent_Schedules__r){
                            if(rs.Start_Date__c>=lc1.Start_Date__c && rs.End_Date__c<=lc1.End_Date__c){
                                lcToRsWrap1.rentSchList.add(rs);
                            }else if(rs.Start_Date__c<lc1.Start_Date__c && rs.End_Date__c>lc1.Start_Date__c){
                                Rent_Schedules__c newRs = new Rent_Schedules__c();
                                newRs.Unit__c = rs.Unit__c;
                                newRs.PropertyLU__c = rs.PropertyLU__c;
                                newRs.TenantLU__c = rs.TenantLU__c;
                                newRs.Status__c = rs.Status__c;
                                newRs.Base_Rent_LC__c =rs.Base_Rent_LC__c;
                                newRs.Expected_Amount__c =rs.Expected_Amount__c;
                                newRs.Lease_Unit__c = rs.Lease_Unit__c;
                                newRs.recordTypeId = rs.recordTypeId;
                                newRs.Electric_Meter__c = rs.Electric_Meter__c;
                                newRs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c;
                                newRs.Transaction_Status__c = rs.Transaction_Status__c;
                                newRs.Remarks__c = rs.Remarks__c;
                                newRs.Comm_Tax__c =rs.Comm_Tax__c;
                                newRs.Billing_Date__c = rs.Billing_Date__c;
                                newRs.Start_Date__c = lc1.Start_Date__c;
                                newRs.End_Date__c = rs.End_Date__c;
                                lcToRsWrap1.rentSchList.add(newRs);
                                rs.End_Date__c = lc1.Start_Date__c - 1;
                                oldRentSchedules.add(rs);
                            }else if(rs.Start_Date__c>=lc1.Start_Date__c && rs.Start_Date__c<=lc1.End_Date__c && rs.End_Date__c>lc1.End_Date__c){
                                Rent_Schedules__c newRs = new Rent_Schedules__c();
                                newRs.Unit__c = rs.Unit__c;
                                newRs.PropertyLU__c = rs.PropertyLU__c;
                                newRs.TenantLU__c = rs.TenantLU__c;
                                newRs.Status__c = rs.Status__c;
                                newRs.Base_Rent_LC__c =rs.Base_Rent_LC__c;
                                newRs.Expected_Amount__c =rs.Expected_Amount__c;
                                newRs.Lease_Unit__c = rs.Lease_Unit__c;
                                newRs.recordTypeId = rs.recordTypeId;
                                newRs.Electric_Meter__c = rs.Electric_Meter__c;
                                newRs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c;
                                newRs.Transaction_Status__c = rs.Transaction_Status__c;
                                newRs.Remarks__c = rs.Remarks__c;
                                newRs.Comm_Tax__c =rs.Comm_Tax__c;
                                newRs.Billing_Date__c = rs.Billing_Date__c;
                                newRs.Start_Date__c = rs.Start_Date__c;
                                newRs.End_Date__c = lc1.End_Date__c;
                                lcToRsWrap1.rentSchList.add(newRs);
                                rs.Start_Date__c = lc1.End_Date__c + 1;
                                lcToRsWrap2.rentSchList.add(rs);
                            }else if(rs.Start_Date__c > lc1.End_Date__c){
                                lcToRsWrap2.rentSchList.add(rs);
                            }
                        
                        }
                        
                        lcToRsWrapList.add(lcToRsWrap1);
                        lcToRsWrapList.add(lcToRsWrap2);
                    }
                }
                
                if(oldLeaseCharges.size()>0){
                    update oldLeaseCharges;                    
                }
                
                if(oldRentSchedules.size()>0){
                    update oldRentSchedules;
                }
                
                if(rentFreeLsChgMap.size()>0){
                    upsert rentFreeLsChgMap.values();
                }
                
                if(lcToRsWrapList.size()>0){
                    List<Rent_Schedules__c> rentScheduleList = new List<Rent_Schedules__c>();
                    for(LcToRsWrapper lw:lcToRsWrapList){
                        if(lw.leaseCharge.Id!=null){
                            for(Rent_Schedules__c rs:lw.rentSchList){
                                rs.Lease_Charge__c = lw.leaseCharge.Id;
                                rentScheduleList.add(rs);
                            }
                        }
                    }
                    
                    if(rentScheduleList.size()>0){
                        upsert rentScheduleList;
                    }
                }
                success = true;
            }else{
                Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,'Rent Free Start and End Date should be betweeen Lease Start and End Date.'));
            }
        }else{
            Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,'Please select End Date more than Start Date.'));
        }
    }
    
    public class LcToRsWrapper{
        public Lease_Charges__c leaseCharge{get;set;}
        public List<Rent_Schedules__c> rentSchList{get;set;}
        
        public LcToRsWrapper(){
            leaseCharge = new Lease_Charges__c();
            rentSchList = new List<Rent_Schedules__c>();
        }
    }
}