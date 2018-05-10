public class CashAdjustmentController{
    public Rent_Roll__c rentRoll{get;set;}
    public string billingType{get;set;}
    public Boolean showDetail{get;set;}
    public Rent_Schedules__c filter{get;set;}
    public string leaseUnit{get;set;}
    public List<string> leaseChargeIds{get;set;}
    public List<string> applChargeIds{get;set;}
    public List<adHocItemWrapper> adhocItemList{get;set;}
    public Integer month{get;set;}
    public Integer year{get;set;}
    public string invNumber{get;set;}
    public string leaseAgreementNo{get;set;}
    public List<DCWrapper> dcWrapList{get;set;}
    public List<MiscWrapper> miscWrapList{get;set;}
    public string LeaseChargeType{get;set;}
    public string currencyCode{get;set;}
    public integer selRecord{get;set;}
    Map<string,Id> rsRecordTypeMap = new Map<string,Id>();
    public CashAdjustmentController(){
        for(RecordType rt:[Select id,DeveloperName from RecordType where sObjectType='Rent_Schedules__c']){
            rsRecordTypeMap.put(rt.DeveloperName,rt.Id);
        }
        showDetail = false;
        currencyCode = Label.Default_Currency;
        rentRoll = new Rent_Roll__c();
        filter = new Rent_Schedules__c();
        miscWrapList = new List<MiscWrapper>();
        adhocItemList = new List<adHocItemWrapper>();
        leaseChargeIds = new List<string>();
        applChargeIds = new List<string>();
        rentRoll.Expected_Invoice_Date__c = Date.NewInstance(system.today().year(),system.today().month(),1).addMonths(1);
        dcWrapList = new List<dcWrapper>();
        month = system.today().month();
        year = system.today().year();
        LeaseChargeType = 'Rent';
    }
    
    public void next(){
        showDetail = true;
    }
    
    public void back(){
        showDetail = false;
        refresh();
    }
    
    public void addMoreMisc(){
        if(selRecord>=0 && miscWrapList.size()>0){
            for(Integer i=0;i<miscWrapList.size();i++){
                if(i==selRecord){
                    MiscWrapper mw = new MiscWrapper();
                    mw.applChargeName = miscWrapList[i].applChargeName;
                    mw.applChargeId = miscWrapList[i].applChargeId;
                    mw.tenantName = miscWrapList[i].tenantName;
                    mw.tenantId = miscWrapList[i].tenantId;
                    mw.addMore = false;
                    if(i+1<miscWrapList.size()){
                        miscWrapList.add(i+1,mw);
                    }else{
                        miscWrapList.add(mw);
                    }
                    break;
                }
            }
        }
    }
    
    public void deleteMisc(){
        if(selRecord>=0 && miscWrapList.size()>0){
            for(Integer i=0;i<miscWrapList.size();i++){
                if(i==selRecord){
                    miscWrapList.remove(i);
                    break;
                }
            }
        }
    }
    
    public void search(){
        miscWrapList = new List<MiscWrapper>();
        adhocItemList = new List<adHocItemWrapper>();
        dcWrapList = new List<dcWrapper>();
        if(billingType=='Miscellaneous'){
            if(filter.PropertyLU__c!=null){
                if(filter.TenantLU__c!=null){
                    if(applChargeIds!=null & applChargeIds.size()>0){
                        List<Account> accList = [Select name from Account where id=:filter.TenantLU__c];
                        for(Applicable_Charges__c ac:[Select id,name from Applicable_Charges__c where id in:applChargeIds]){
                            MiscWrapper mw = new MiscWrapper();
                            mw.applChargeName = ac.Name;
                            mw.applChargeId = ac.Id;
                            if(accList.size()>0){
                                mw.tenantName = accList[0].Name;
                                mw.tenantId = accList[0].Id;
                            }
                            mw.addMore = true;
                            miscWrapList.add(mw);
                        }
                    }else{
                        Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Applicable Charge.'));
                    }
                }else{
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Tenant.'));
                }
            }else{
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Property.'));
            }
        }else if(billingType=='Ad-Hoc Invoice'){
            if(filter.PropertyLU__c!=null){
                if(filter.TenantLU__c!=null){
                    if(leaseUnit!=null && leaseUnit.trim().length()>0){
                        if(leaseChargeIds!=null && leaseChargeIds.size()>0){
                            Lease_Unit__c lu = [Select id,Name,Unit__c,Unit__r.Name,Property__c,Tenant__c,Lease_Agreement_No__r.Property__c,Lease_Agreement_No__r.Tenant__c from Lease_Unit__c where id=:leaseUnit];
                            Map<Id,Lease_Charges__c> lsMap = new Map<Id,Lease_Charges__c>([Select id,Name,Expected_Charge__c,recordType.Name from Lease_Charges__c where id in:leaseChargeIds]);
                            for(string lsStr:leaseChargeIds){
                                adHocItemWrapper adi = new adHocItemWrapper();
                                adi.propName = lu.Property__c;
                                adi.propId = lu.Lease_Agreement_No__r.Property__c;
                                adi.tenantName = lu.Tenant__c;
                                adi.tenantId = lu.Lease_Agreement_No__r.Tenant__c;
                                adi.leaseUnitName = lu.Name;
                                adi.leaseUnitId = leaseUnit;
                                adi.unitNo = lu.unit__r.Name;
                                adi.unitId = lu.Unit__c;
                                adi.leaseChargeId = lsStr;
                                
                                if(lsMap.containsKey(lsStr)){
                                    adi.leaseChargeName = lsMap.get(lsStr).Name;
                                    adi.expectedCharge = lsMap.get(lsStr).Expected_Charge__c;
                                    adi.leaseChargeRecordType = lsMap.get(lsStr).recordType.Name;
                                }
                                adhocItemList.add(adi);
                            }
                        }else{
                            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Lease Charge.'));
                        }
                    }else{
                        Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Lease Unit.'));
                    }
                }else{
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Tenant.'));
                }
            }else{
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Property.'));
            }
        }else if(billingType=='Debit Note' || billingType=='Credit Note'){
            if((filter.PropertyLU__c!=null && filter.TenantLU__c!=null && month!=null && year!=null) || (invNumber!=null && invNumber.trim().length()>0)){
                List<Invoice__c> invList = new List<Invoice__c>();
                if(invNumber!=null && invNumber.trim().length()>0){
                    invList = [Select id,Name,Property__c,Tenant__c,Currency_Code__c,Exchange_Rate__c,(Select id,Charge_Name__c,Lease_Charge__r.Charge_Type__c,Amount__c from Invoice_Line_Items__r) from Invoice__c where name=:invNumber and Currency_Code__c=:currencyCode and (Billing_Type__c='Rent' or Billing_Type__c='Monthly'  or Billing_Type__c='GTO Rent')];
                    if(invList.size()>0){
                        filter.PropertyLU__c = invList[0].Property__c;
                        filter.TenantLU__c = invList[0].Tenant__c;
                    }
                }else{
                    string query = 'Select id,Name,Currency_Code__c,Exchange_Rate__c,(Select id,Charge_Name__c,Lease_Charge__r.Charge_Type__c,Amount__c from Invoice_Line_Items__r) from Invoice__c where Currency_Code__c=:currencyCode and Lease__r.Property__c=\''+filter.PropertyLU__c+'\' and Lease__r.Tenant__c=\''+filter.TenantLU__c+'\' and Calendar_Month(Invoice_Date__c)=:month and Calendar_Year(Invoice_Date__c)=:year and (Billing_Type__c=\'Rent\' or Billing_Type__c=\'Monthly\'  or Billing_Type__c=\'GTO Rent\')';
                    if(leaseAgreementNo!=null && leaseAgreementNo.trim().length()>0){
                        query += ' and Lease__c=:leaseAgreementNo';
                    }
                    invList = database.query(query);
                }
                if(invList.size()>0){
                    for(Invoice__c inv:invList){
                        for(Invoice_Line_Item__c ili:inv.Invoice_Line_Items__r){
                            DcWrapper dcw = new DcWrapper();
                            dcw.inv = inv;
                            dcw.invLinItm = ili;
                            dcWrapList.add(dcw);
                        }
                    }
                }
                if(dcWrapList.size()==0){
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'No records found.'));
                }
            }else{
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please either select Property,Tenant, Month and Year or Invoice Number.'));
            }
        }
    }
    
    public pageReference generate(){
        Decimal taxPercent = 0;
        Property__c prop = new Property__c();
        Account tenant = new Account();
        if(filter.PropertyLU__c!=null){
            prop = [Select id,Rent_Roll_Index__c,Short_Code__c,Comm_Tax__c,Billing_Due_Days__c,Invoice_Index__c from Property__c where id=:filter.PropertyLU__c];
        }
        
        if(prop.Comm_Tax__c!=null){
            taxPercent = prop.Comm_Tax__c;
        }
        
        decimal totalAmount = 0;
        List<Lease_Unit__c> leaseUnits = [Select id,Area_Sq_Ft__c,Unit__r.Property__c from Lease_Unit__c where Unit__r.Property__c=:filter.PropertyLU__c and Area_Sq_Ft__c!=null];
        decimal totalLeaseArea = 0;
        for(Lease_Unit__c lu:leaseUnits){
            totalLeaseArea += lu.Area_Sq_Ft__c;
        }
        
        Integer currentMonth = system.today().month();
        Integer currentYear = system.today().Year();
        if(billingType=='Miscellaneous' && miscWrapList.size()>0){
            for(MiscWrapper mw:miscWrapList){
                if(mw.startDate==null){
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Start/Billing Date.'));
                    return null;
                }
                if(mw.amount<1){
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please enter positive amount.'));
                    return null;
                }
                totalAmount+=mw.amount;
            }
            
            rentRoll.Property__c = prop.Id;
            rentRoll.Total_Leased_Area_Sq_Ft__c = totalLeaseArea;
            rentRoll.Total_Amount__c = totalAmount;
            rentRoll.Rent_Roll_YYYY__c = ''+currentYear;
            rentROll.Rent_Roll_MM__c = (currentMonth<10?'0'+currentMonth:''+currentMonth);
            
            Integer IntIndex = 1;
            if(prop.Rent_Roll_Index__c!=null && prop.Rent_Roll_Index__c>0){
                intIndex = Integer.valueOf(prop.Rent_Roll_Index__c);
            }
            
            Integer indexSize = string.valueOf(intIndex).length();
            
            string index = '';
            for(integer i =1;i<=6-indexSize;i++){
                index += '0';
            }
            index += string.valueOf(intIndex);
            rentRoll.Rent_Roll_Index__c = index;
            prop.Rent_Roll_Index__c = intIndex + 1;
            
            rentRoll.Name = prop.Short_Code__c+'-RO-'+currentYear+(currentMonth<10?'0'+currentMonth:''+currentMonth)+'-'+rentRoll.Rent_Roll_Index__c;
            rentRoll.Billing_Type__c = billingType;
            rentRoll.Currency_Code__c = currencyCode;
            rentRoll.Approved__c = true;
           
            // Added by AS on 21-02-2018
            // Fixed Actual_Invoice_Date__c is null for Misc RR.
            
            if(rentRoll.Actual_Invoice_Date__c == null)
            	rentRoll.Actual_Invoice_Date__c = rentRoll.Expected_Invoice_Date__c;
            	
            insert rentRoll;
            
            Invoice__c inv = new Invoice__c();
            inv.rent_Roll__c = rentRoll.Id;
            inv.Status__c = 'Ready';
            inv.Invoice_Type__c = 'System Generated Invoice';

            inv.Tenant_Name__c = filter.TenantLU__c;
            
            inv.Currency_Code__c = currencyCode;
                        
                        
            
            inv.Invoice_Date__c = rentRoll.Expected_Invoice_Date__c;
            if(prop.Id!=null && prop.Billing_Due_Days__c!=null){
                inv.Payment_Due_Date__c = inv.Invoice_Date__c.addDays(Integer.valueOf(prop.Billing_Due_Days__c));
            }
            
            if(prop.Id!=null){
                IntIndex = 1;
                if(prop.Invoice_Index__c!=null && prop.Invoice_Index__c>0){
                    intIndex = Integer.valueOf(prop.Invoice_Index__c);
                }
                
                indexSize = string.valueOf(intIndex).length();
                
                index = '';
                for(integer i =1;i<=6-indexSize;i++){
                    index += '0';
                }
                index += string.valueOf(intIndex);
                inv.Invoice_Index__c = index;
                prop.Invoice_Index__c = intIndex + 1;
            }
            
            string currentYr = ''+system.today().year();
            string currentMth;
            if(system.today().month()<10){
                currentMth = '0' + system.today().month();
            }else{
                currentMth = '' + system.today().month();
            }
            
            inv.Name = prop.Short_Code__c +'-RI-'+currentYr+currentMth+'-'+inv.Invoice_Index__c;
			
            if(billingType=='Credit Note' || billingType == 'Miscellaneous')
                inv.Late_Charge_Applicable__c = false;
            
            inv.Property_Name__c = prop.Id;
            insert inv;
                        
            update prop;
            
            List<Invoice_Line_Item__c> lineItemList = new List<Invoice_Line_Item__c>();
            for(MiscWrapper mw:miscWrapList){
                Invoice_Line_Item__c invLinItm = new Invoice_Line_Item__c();
                invLinItm.Amount__c = mw.amount;
                if(mw.applyCommTax){
                    invLinItm.Comm_Tax_Amount__c = mw.amount*taxpercent/100;
                }
                if(mw.remarks!=null && mw.remarks.trim().length()>0){
                    invLinItm.Description__c = mw.applChargeName + ' - ' +mw.remarks;
                }else{
                    invLinItm.Description__c = mw.applChargeName;
                }
                
                invLinItm.Start_Date__c = mw.startDate;
                invLinItm.End_Date__c = Date.newInstance(mw.startDate.Year(),mw.startDate.Month(),Date.DaysInMonth(mw.startDate.Year(),mw.startDate.Month()));
                invLinItm.Currency_Code__c = currencyCode;
                invLinItm.Invoice__c =inv.Id;
                lineItemList.add(invLinItm);
            }
            insert lineItemList;
            inv.Invoice_Generated__c = true;
            update inv;
            return new pageReference('/'+inv.Id);
            
        }else if(adhocItemList.size()>0 && billingType=='Ad-Hoc Invoice'){
            for(adHocItemWrapper adi:adhocItemList){
                if(adi.startDate==null){
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Start/Billing Date.'));
                    return null;
                }
                if(adi.adjustAmount<1){
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please enter positive amount.'));
                    return null;
                }
                totalAmount+=adi.adjustAmount;
            }
            
            rentRoll.Property__c = prop.Id;
            rentRoll.Total_Leased_Area_Sq_Ft__c = totalLeaseArea;
            rentRoll.Total_Amount__c = totalAmount;
            rentRoll.Rent_Roll_YYYY__c = ''+currentYear;
            rentROll.Rent_Roll_MM__c = (currentMonth<10?'0'+currentMonth:''+currentMonth);
            
            Integer IntIndex = 1;
            if(prop.Rent_Roll_Index__c!=null && prop.Rent_Roll_Index__c>0){
                intIndex = Integer.valueOf(prop.Rent_Roll_Index__c);
            }
            
            Integer indexSize = string.valueOf(intIndex).length();
            
            string index = '';
            for(integer i =1;i<=6-indexSize;i++){
                index += '0';
            }
            index += string.valueOf(intIndex);
            rentRoll.Rent_Roll_Index__c = index;
            prop.Rent_Roll_Index__c = intIndex + 1;
            
            rentRoll.Name = prop.Short_Code__c+'-RO-'+currentYear+(currentMonth<10?'0'+currentMonth:''+currentMonth)+'-'+rentRoll.Rent_Roll_Index__c;
            rentRoll.Billing_Type__c = billingType;
            rentRoll.Currency_Code__c = currencyCode;
            insert rentRoll;
            
            update prop;
            
            List<Rent_Schedules__c> rentSchList = new List<Rent_Schedules__c>();
            for(adHocItemWrapper adi:adhocItemList){
                Rent_Schedules__c rs = new Rent_Schedules__c();
                rs.Unit__c = adi.UnitId;
                rs.PropertyLU__c = adi.PropId;
                rs.TenantLU__c = adi.tenantId;
                rs.Status__c = 'Rent Roll Generated';
                rs.Approved__c = true;
                rs.Lease_Charge__c = adi.leaseChargeId;
                if(adi.leaseChargeRecordType!=null){
                    rs.recordTypeId = rsRecordTypeMap.get(adi.leaseChargeRecordType);
                }
                rs.Expected_Amount__c = adi.expectedCharge;
                rs.Lease_Unit__c = adi.leaseUnitId;
                rs.Billing_Date__c = adi.startDate;
                rs.Start_Date__c = adi.startDate;
                rs.End_Date__c = Date.newInstance(rs.Start_Date__c.Year(),rs.Start_Date__c.Month(),Date.DaysInMonth(rs.Start_Date__c.Year(),rs.Start_Date__c.Month()));
                rs.Amount__c = adi.adjustAmount;
                rs.Billing_Type__c = billingType;
                rs.Rent_Roll__c = rentRoll.Id;
                rs.Remarks__c = adi.remarks;
                if(adi.applyCommTax && taxPercent>0){
                    rs.Comm_Tax__c = taxPercent;
                }else{
                    rs.Comm_Tax__c = 0;
                }
                rs.Currency_Code__c = currencyCode;
                rentSchList.add(rs);
            }
            insert rentSchList;
            Set<Id> rentSchIds = new Set<Id>();
            for(Rent_Schedules__c rs:rentSchList){
                rentSchIds.add(rs.Id);
            }
            Map<Id,Rent_Schedules__c> rentSchMap = new Map<Id,Rent_Schedules__c>([Select id,Name,Comm_Tax_Amount__c,Charge_Type__c from Rent_Schedules__c where id in:rentSchIds]);
            List<Rent_Roll_Detail__c> rrDetailList = new List<Rent_Roll_Detail__c>();
            for(Rent_Schedules__c rs:rentSchList){
                Rent_Roll_Detail__c rrDet = new Rent_Roll_Detail__c();
                if(rentSchMap.containsKey(rs.Id)){
                    rrDet.Rs_Name__c = rentSchMap.get(rs.Id).Name;
                    rrDet.Comm_Tax_Amount__c = rentSchMap.get(rs.Id).Comm_Tax_Amount__c;
                    rrDet.Charge_Type__c = rentSchMap.get(rs.Id).Charge_Type__c;
                }
                rrDet.Active__c = rs.Active__c;
                rrDet.Amount__c = rs.Amount__c;
                rrDet.Billing_Date__c = rs.Billing_Date__c;
                rrDet.End_Date__c = rs.End_Date__c;
                rrDet.Lease_Charge__c = rs.Lease_Charge__c;
                rrDet.Lease_Unit__c = rs.Lease_Unit__c;
                rrDet.Rent_Roll__c = rs.Rent_Roll__c;
                rrDet.Start_Date__c = rs.Start_Date__c;
                rrDet.Status__c = 'Pending';
                rrDet.Unit__c = rs.Unit__c;
                rrDet.Billing_Type__c = rs.Billing_Type__c;
                rrDet.Remarks__c = rs.Remarks__c;
                rrDet.Currency_Code__c = currencyCode;
                rrDetailList.add(rrDet);
            }
            
            insert rrDetailList;
            
            for(Rent_Schedules__c rs:rentSchList){
                for(Rent_Roll_Detail__c rrd: rrDetailList){
                    if(rrd.Rs_Name__c==rentSchMap.get(rs.Id).Name && rrd.Lease_Charge__c==rs.Lease_Charge__c && rrd.Lease_Unit__c==rs.Lease_Unit__c && rrd.Rent_Roll__c==rs.Rent_Roll__c && rrd.Start_Date__c==rs.Start_Date__c  && rrd.End_Date__c==rs.End_Date__c){
                        rs.Rent_Roll_Detail__c = rrd.Id;
                        break;
                    }
                }
            }
            update rentSchList;
            
            return new pageReference('/'+rentRoll.Id);
            
        }else if((billingType=='Debit Note' || billingType=='Credit Note') && dcWrapList.size()>0){
            Set<Id> invLinItmIds = new Set<Id>();
            Set<decimal> dupExcRateCheck = new set<decimal>();
            for(DcWrapper dcw:dcWrapList){
                if(dcw.isSelected){
                    if(dcw.adjustAmount==null || dcw.adjustAmount<1){
                        Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please enter positive amount.'));                    
                        return null;
                    }
                    totalAmount+=dcw.adjustAmount;
                    invLinItmIds.add(dcw.invLinItm.Id);
                    dupExcRateCheck.add(dcw.inv.Exchange_Rate__c);
                }
            }
            
            if(invLinItmIds.size()==0){
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select atleast 1 Item.'));
                return null;
            }
            
            if(dupExcRateCheck.size()>1){
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Invoice Line Items with same Exchange Rate.'));
                return null;
            }
            
            rentRoll.Property__c = prop.Id;
            rentRoll.Total_Leased_Area_Sq_Ft__c = totalLeaseArea;
            rentRoll.Total_Amount__c = totalAmount;
            
            rentRoll.Rent_Roll_YYYY__c = ''+currentYear;
            rentROll.Rent_Roll_MM__c = (currentMonth<10?'0'+currentMonth:''+currentMonth);
            
            Integer IntIndex = 1;
            if(prop.Rent_Roll_Index__c!=null && prop.Rent_Roll_Index__c>0){
                intIndex = Integer.valueOf(prop.Rent_Roll_Index__c);
            }
            
            Integer indexSize = string.valueOf(intIndex).length();
            
            string index = '';
            for(integer i =1;i<=6-indexSize;i++){
                index += '0';
            }
            index += string.valueOf(intIndex);
            rentRoll.Rent_Roll_Index__c = index;
            prop.Rent_Roll_Index__c = intIndex + 1;
            
            rentRoll.Name = prop.Short_Code__c+'-RO-'+currentYear+(currentMonth<10?'0'+currentMonth:''+currentMonth)+'-'+rentRoll.Rent_Roll_Index__c;
            rentRoll.Billing_Type__c = billingType;
            
            rentRoll.Currency_Code__c = currencyCode;
            if(dupExcRateCheck.size()==1){
                for(decimal st:dupExcRateCheck){
                    rentRoll.Exchange_Rate__c = st;
                    break;
                }
                
            }
            insert rentRoll;
            
            update prop;
            
            Map<Id,Rent_Roll_Detail__c> rrdMap = new Map<Id,Rent_Roll_Detail__c>([Select id from Rent_Roll_Detail__c where Invoice_Line_Item__c in:invLinItmIds]);
            
            Map<Id,Rent_Schedules__c> rsMap = new Map<Id,Rent_Schedules__c>();
            for(Rent_Schedules__c rs :[Select id,Rent_Roll_Detail__r.Invoice_Line_Item__c,recordtypeId,Transaction_Start_Date__c,Transaction_End_Date__c,Name,Active__c,Area_ft__c,Billing_Date__c,End_Date__c,Expected_Amount__c,Hold__c,Lease_Unit__c,Rent_Roll__c,Start_Date__c,Status__c,Total_Units_p__c,Trading_Day_s__c,Unit__c,Approved__c,Tenant__c,Unit__r.Name,Lease_Charge__r.Name,Total_Units__c,Lease_Charge__r.Charge_Rate__c,Amount__c,Lease_Charge__c,recordType.Name,Property__c,Electric_Meter__c,Electric_Meter_Number__c,Comments__c,Comm_Tax_Amount__c,Total_Amount__c,unit__r.property__r.Name,PropertyLU__c,TenantLU__c from Rent_Schedules__c where Rent_Roll_Detail__c in:rrdMap.keyset()]){
                rsMap.put(rs.Rent_Roll_Detail__r.Invoice_Line_Item__c,rs);
            }
            
            
            List<Rent_Schedules__c> rentSchList = new List<Rent_Schedules__c>();
            for(DcWrapper dcw:dcWrapList){
                if(rsMap.containsKey(dcw.invLinItm.Id)){
                    Rent_Schedules__c oldRs = rsMap.get(dcw.invLinItm.Id);
                    Rent_Schedules__c rs = new Rent_Schedules__c();
                    rs.Unit__c = oldRs.Unit__c;
                    rs.PropertyLU__c = oldRs.PropertyLU__c;
                    rs.TenantLU__c = oldRs.TenantLU__c;
                    rs.Status__c = 'Rent Roll Generated';
                    rs.Approved__c = true;
                    rs.Lease_Charge__c = oldRs.Lease_Charge__c;
                    rs.Expected_Amount__c = oldRs.Expected_Amount__c;
                    rs.Lease_Unit__c = oldRs.Lease_Unit__c;
                    rs.Billing_Date__c = oldRs.Billing_Date__c;
                    rs.Start_Date__c = oldRs.Start_Date__c;
                    rs.End_Date__c = oldRs.End_Date__c;
                    rs.RecordTypeId = oldRs.RecordtypeId;
                    if(billingType == 'Debit Note'){
                        rs.Amount__c = dcw.adjustAmount;
                    }else{
                        rs.Amount__c = -dcw.adjustAmount;
                    }
                    
                    rs.Billing_Type__c = billingType;
                    rs.Rent_Roll__c = rentRoll.Id;
                    rs.Remarks__c = dcw.remarks;
                    if(dcw.applyCommTax && taxPercent>0){
                        rs.Comm_Tax__c = taxPercent;
                    }else{
                        rs.Comm_Tax__c = 0;
                    }
                    rs.Invoice_Line_Item__c = dcw.invLinItm.Id;
                    rs.Currency_Code__c = currencyCode;
                    rentSchList.add(rs);
                }
            }
            
            insert rentSchList;
            
            Set<Id> rentSchIds = new Set<Id>();
            for(Rent_Schedules__c rs:rentSchList){
                rentSchIds.add(rs.Id);
            }
            Map<Id,Rent_Schedules__c> rentSchMap = new Map<Id,Rent_Schedules__c>([Select id,Name,Comm_Tax_Amount__c,Charge_Type__c from Rent_Schedules__c where id in:rentSchIds]);
            List<Rent_Roll_Detail__c> rrDetailList = new List<Rent_Roll_Detail__c>();
            for(Rent_Schedules__c rs:rentSchList){
                Rent_Roll_Detail__c rrDet = new Rent_Roll_Detail__c();
                if(rentSchMap.containsKey(rs.Id)){
                    rrDet.Rs_Name__c = rentSchMap.get(rs.Id).Name;
                    rrDet.Comm_Tax_Amount__c = rentSchMap.get(rs.Id).Comm_Tax_Amount__c;
                    rrDet.Charge_Type__c = rentSchMap.get(rs.Id).Charge_Type__c;
                }
                rrDet.Active__c = rs.Active__c;
                rrDet.Amount__c = rs.Amount__c;
                rrDet.Billing_Date__c = rs.Billing_Date__c;
                rrDet.End_Date__c = rs.End_Date__c;
                rrDet.Lease_Charge__c = rs.Lease_Charge__c;
                rrDet.Lease_Unit__c = rs.Lease_Unit__c;
                rrDet.Rent_Roll__c = rs.Rent_Roll__c;
                rrDet.Start_Date__c = rs.Start_Date__c;
                rrDet.Status__c = 'Pending';
                rrDet.Unit__c = rs.Unit__c;
                rrDet.Billing_Type__c = rs.Billing_Type__c;
                rrDet.Remarks__c = rs.Remarks__c;
                rrDet.Currency_Code__c = currencyCode;
                rrDetailList.add(rrDet);
            }
            
            insert rrDetailList;
            
            for(Rent_Schedules__c rs:rentSchList){
                for(Rent_Roll_Detail__c rrd: rrDetailList){
                    if(rrd.Rs_Name__c==rentSchMap.get(rs.Id).Name && rrd.Lease_Charge__c==rs.Lease_Charge__c && rrd.Lease_Unit__c==rs.Lease_Unit__c && rrd.Rent_Roll__c==rs.Rent_Roll__c && rrd.Start_Date__c==rs.Start_Date__c  && rrd.End_Date__c==rs.End_Date__c){
                        rs.Rent_Roll_Detail__c = rrd.Id;
                        break;
                    }
                }
            }
            update rentSchList;
            
            return new pageReference('/'+rentRoll.Id);
        }
        return null;
    }
    
    public List<SelectOption> getLeaseUnitOptionList(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Select --'));
        if(filter.PropertyLU__c!=null && filter.TenantLU__c!=null){
            for(Lease_Unit__c lu:[Select id,Name,unit__r.Name from Lease_Unit__c where Lease_Agreement_No__r.Property__c=:filter.PropertyLU__c and Lease_Agreement_No__r.Tenant__c=:filter.TenantLu__c and Lease_End_Date__c>=:system.today().addMonths(-3)]){
                options.add(new SelectOption(lu.Id,lu.Name+' '+lu.unit__r.Name));
            }
        }
        return options;
    }
    
    public List<SelectOption> getCurrencyCodes(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Invoice__c.Currency_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }   
        return options;
    }
    
    public void refresh(){
        adhocItemList = new List<adHocItemWrapper>();
        dcWrapList = new List<DcWrapper>();
        miscWrapList = new List<MiscWrapper>();
    }
    
    public List<SelectOption> getMiscApplChargeList(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Select --'));
        if(filter.PropertyLU__c!=null){
            for(Applicable_Charges__c ac:[Select id,Name from Applicable_Charges__c where Property__c=:filter.PropertyLU__c and Charge_Type__c='Miscellaneous']){
                options.add(new SelectOption(ac.Id,ac.Name));
            }
        }
        return options;
    }
    
    public List<SelectOption> getLeaseChargeOptionList(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Select --'));
        if(leaseUnit!=null){
            for(Lease_Charges__c lc:[Select id,Name from Lease_Charges__c where Lease_Unit__c=:leaseUnit and recordtype.Name=:LeaseChargeType]){
                options.add(new SelectOption(lc.Id,lc.Name));
            }
        }
        return options;
    }
    
    public List<SelectOption> getLeaseOptionList(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Select --'));
        if(filter.PropertyLU__c!=null && filter.TenantLU__c!=null){
            for(Lease__c lu:[Select id,Name,Lease_Start_Date__c from Lease__c where Property__c=:filter.PropertyLU__c and Tenant__c=:filter.TenantLu__c and Lease_End_Date__c>=:system.today().addMonths(-3)]){
                options.add(new SelectOption(lu.Id,lu.Name+' '+lu.Lease_Start_Date__c.format()));
            }
        }
        return options;
    }
    
    public List<selectOption> getMonthList(){
        List<selectOption> tempList = new List<selectOption>();
        tempList.add(new selectOption('1','January'));
        tempList.add(new selectOption('2','February'));
        tempList.add(new selectOption('3','March'));
        tempList.add(new selectOption('4','April'));
        tempList.add(new selectOption('5','May'));
        tempList.add(new selectOption('6','June'));
        tempList.add(new selectOption('7','July'));
        tempList.add(new selectOption('8','August'));
        tempList.add(new selectOption('9','September'));
        tempList.add(new selectOption('10','October'));
        tempList.add(new selectOption('11','November'));
        tempList.add(new selectOption('12','December'));
        return tempList;
    }
    
    public List<selectOption> getYearList(){
        List<selectOption> tempList = new List<selectOption>();
        Integer currentyear = system.today().year();
        for(Integer i=currentYear-1;i<=currentYear+4;i++){
            tempList.add(new selectOption(''+i+'',''+i+''));
        }
        return tempList;
    }
    
    public class adHocItemWrapper{
        public string propName{get;set;}
        public string propId{get;set;}
        public string tenantName{get;set;}
        public string tenantId{get;set;}
        public string leaseUnitName{get;set;}
        public string leaseUnitId{get;set;}
        public string unitNo{get;set;}
        public string unitId{get;set;}
        public string leaseChargeName{get;set;}
        public string leaseChargeId{get;set;}
        public string leaseChargeRecordType{get;set;}
        public decimal expectedCharge{get;set;}
        public date startDate{get;set;}
        public string remarks{get;set;}
        public decimal adjustAmount{get;set;}
        Public Boolean applyCommTax{get;set;}
        public adHocItemWrapper(){
            startDate = system.today();
            applyCommTax = false;
        }
    }
    
    public class DCWrapper{
        public Boolean isSelected{get;set;}
        public Invoice__c inv{get;set;}
        public Invoice_Line_Item__c invLinItm{get;set;}
        public string remarks{get;set;}
        public decimal adjustAmount{get;set;}
        Public Boolean applyCommTax{get;set;}
        public DCWrapper(){
            isSelected = false;
            inv = new Invoice__c();
            invLinItm = new Invoice_Line_Item__c();
            applyCommTax = false;
        }
    }
    
    public class MiscWrapper{
        public string tenantName{get;set;}
        public string tenantId{get;set;}
        public string applChargeName{get;set;}
        public string applChargeId{get;set;}
        public date startDate{get;set;}
        public decimal amount{get;set;}
        Public Boolean applyCommTax{get;set;}
        public string remarks{get;set;}
        public Boolean addMore{get;set;}
        public MiscWrapper(){
            addMore = false;
            startDate = system.today();
            applyCommTax = false;
        }
    }
}