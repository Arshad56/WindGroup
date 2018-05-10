public class GenerateInvoiceController{
    public Rent_Roll__c rentRoll{get;set;}
    public List<Rent_Roll__c> rentRollList{get;set;}
    public string selRentRollId{get;set;}
    public Boolean showRentDetail{get;set;}
    public Boolean selectAll{get;set;}
    public List<Rent_Roll_Detail__c> rentRollDetailList{get;set;}
    Map<Id,List<Rent_Roll_Detail__c>> rentRollDetMap{get;set;}
    public GenerateInvoiceController(){
        rentRoll = new Rent_Roll__c();
        rentRollList = new List<Rent_Roll__c>();
        rentRollDetailList = new List<Rent_Roll_Detail__c>();
        rentRollDetMap = new Map<Id,List<Rent_Roll_Detail__c>>();
        showRentDetail = false;
        selectAll = false;
    }
    
    public void search(){
        rentRollDetMap = new Map<Id,List<Rent_Roll_Detail__c>>();
        rentRollList = new List<Rent_Roll__c>();
        if(rentRoll.Property__c!=null){
            string query = 'Select id,Rejected__c,Billing_Type__c,Name,Expected_Invoice_Date__c,Approved__c,Property__c,Approver__c,Total_Diesel_Rate__c,Total_Leased_Area_Sq_Ft__c,Total_Amount_Formula__c,Currency_Code__c from Rent_Roll__c where Approved__c=false and Property__c=\''+rentRoll.Property__c+'\' ';
            if(rentRoll.Billing_Type__c!=null){
                query += 'and Billing_Type__c=\''+rentRoll.Billing_Type__c+'\' order by createddate asc';
            }
            //query += ' limit 1000';
            List<Rent_Roll__c> tempRentRollList = database.query(query);
            Set<Id> rentRollIds = new Set<Id>();
            for(Rent_Roll__c rr:tempRentRollList){
                rentRollIds.add(rr.Id);
            }
            Set<Id> rrDetSet= new Set<Id>();
            for(Rent_Roll_Detail__c rrd:[Select id,Withholding_Tax_Rate__c,Comm_Tax_Amount__c,Name,Active__c,Billing_Date__c,End_Date__c,Expected_Amount__c,Hold__c,Lease_Unit__c,Rent_Roll__c,Start_Date__c,Status__c,Total_Units_p__c,Trading_Day_s__c,Unit__c,Tenant__c,Unit__r.Name,Lease_Charge__r.Name,Lease_Charge__r.Charge_Rate__c,Amount__c,Lease_Charge__c,Comments__c,Invoice__c,Invoice__r.Name,Invoice__r.Amount__c,Invoice__r.Lease__r.Tenant__r.Name,Charge_Type__c,Late_Percent_Rate__c,Default_Days__c,Outstanding_Amount__c,Lease_Unit__r.Lease_Agreement_No__c from Rent_Roll_Detail__c where Status__c='Pending' and Rent_Roll__c in:rentRollIds order by Tenant__c asc,Unit__r.Name asc,Start_Date__c asc,Lease_Charge__r.Name asc]){
                /*List<Rent_Roll_Detail__c> tempList = new List<Rent_Roll_Detail__c>();
                if(rentRollDetMap.containsKey(rrd.Rent_Roll__c)){
                    tempList.addAll(rentRollDetMap.get(rrd.Rent_Roll__c));
                }
                tempList.add(rrd);
                rentRollDetMap.put(rrd.Rent_Roll__c,tempList);*/
                rrDetSet.add(rrd.Rent_Roll__c);
            }
            
            for(Rent_Roll__c rr:tempRentRollList){
                if(rrDetSet.contains(rr.Id)){
                    rentRollList.add(rr);
                    if(rentRollList.size()==1000){
                        break;
                    }
                }
            }
            if(rentRollList.size()==0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No record found. Please filter your search criteria.'));
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select Property.'));
        }
    }
    
    public void selectRentRoll(){
        rentRollDetailList = new List<Rent_Roll_Detail__c>();
        if(selRentRollId!=null){
            for(rent_Roll__c rr:rentRollList){
                if(rr.Id==selRentRollId){
                    rentRoll = rr;
                    rentRoll.Actual_Invoice_Date__c = rr.Expected_Invoice_Date__c;
                    showRentDetail = true;
                    //rentRollDetailList = rentRollDetMap.get(rentRoll.Id);
                    //rentRollDetailList = [Select id,Rent_Schedule__c,Name,Active__c,Billing_Date__c,End_Date__c,Expected_Amount__c,Hold__c,Lease_Unit__c,Rent_Roll__c,Start_Date__c,Status__c,Total_Units_p__c,Trading_Day_s__c,Unit__c,Tenant__c,Unit__r.Name,Lease_Charge__r.Name,Lease_Charge__r.Charge_Rate__c,Amount__c,Lease_Charge__c,Comments__c from Rent_Roll_Detail__c where Rent_Roll__c=:rentRoll.Id and Status__c='Pending'];
                    break;
                }
            }
            rentRollDetailList = [Select id,Withholding_Tax_Rate__c,Comm_Tax_Amount__c,Name,Active__c,Billing_Date__c,End_Date__c,Expected_Amount__c,Hold__c,Lease_Unit__c,Rent_Roll__c,Start_Date__c,Status__c,Total_Units_p__c,Trading_Day_s__c,Unit__c,Tenant__c,Unit__r.Name,Lease_Charge__r.Name,Lease_Charge__r.Charge_Rate__c,Amount__c,Lease_Charge__c,Comments__c,Invoice__c,Invoice__r.Name,Invoice__r.Amount__c,Invoice__r.Lease__r.Tenant__r.Name,Charge_Type__c,Late_Percent_Rate__c,Default_Days__c,Outstanding_Amount__c,Lease_Unit__r.Lease_Agreement_No__c from Rent_Roll_Detail__c where Status__c='Pending' and Rent_Roll__c =:selRentRollId order by Tenant__c asc,Unit__r.Name asc,Start_Date__c asc,Lease_Charge__r.Name asc];
        }
    }
    
    public void back(){
        rentRollDetailList = new List<Rent_Roll_Detail__c>();
        //rentRoll = new Rent_Roll__c();
        showRentDetail = false;
    }
    
    public pageReference generateInvoice(){
        SavePoint sp = Database.setSAvePoint();
        try{
            if(rentRoll.Id!=null){
                if(rentRollDetailList.size()>0){
                    List<Rent_Roll_Detail__c> appRentRollDetails = new List<Rent_Roll_Detail__c>();
                    List<Rent_Roll_Detail__c> rejRentRollDetails = new List<Rent_Roll_Detail__c>();
                    Set<Id> rentRollDetIds = new Set<Id>();
                    Map<Id,List<Rent_Roll_Detail__c>> luToWithHoldingRRDMap = new Map<Id,List<Rent_Roll_Detail__c>>();
                    
                    for(Rent_Roll_Detail__c rd:rentRollDetailList){
                        string AprRej = Apexpages.currentPage().getParameters().get(rd.Id);
                        if(aprRej=='Approved'){
                            rd.Status__c = 'Approved';
                            appRentRollDetails.add(rd);
                            if(rd.Withholding_Tax_Rate__c>0 && rd.Amount__c!=null){
                                List<Rent_Roll_Detail__c> tempList = new List<Rent_Roll_Detail__c>();
                                System.debug('luToWithHoldingRRDMap-----@@@'+luToWithHoldingRRDMap);
                                if(luToWithHoldingRRDMap.containsKey(rd.Lease_Unit__c)){
                                    tempList.addAll(luToWithHoldingRRDMap.get(rd.Lease_Unit__c));
                                }
                                tempList.add(rd);
                                luToWithHoldingRRDMap.put(rd.Lease_Unit__c,tempList);
                            }
                        }else{
                            if(rd.Comments__c==null || rd.Comments__c.trim().length()==0){
                                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Comments are mandatory for rejected items.'));
                                return null;
                            }
                            rd.Status__c = 'Rejected';
                            rentRollDetIds.add(rd.Id);
                            rejRentRollDetails.add(rd);
                        }
                    }
                    
                    if(appRentRollDetails.size()>0){
                        update appRentRollDetails;
                        rentRoll.Approved__c = true;
                        
                        if(luToWithHoldingRRDMap.size()>0){
                            List<RecordType> rcdTypeList = [Select id,Name from RecordType where sobjectType='Rent_Schedules__c'];
                            Map<String,Id> rentRcdMap = new Map<String,Id>();
                            for(RecordType rcd:rcdTypeList){
                                rentRcdMap.put(rcd.Name,rcd.Id);
                            }
                            
                            Map<Id,Lease_Charges__c> luToInvDiscChgMap = new Map<Id,Lease_Charges__c>();
                            for(Lease_Charges__c lc:[Select id,Lease_Unit__c,Lease_Unit__r.Unit__c,Lease_Unit__r.Lease_Agreement_No__r.Property__c,Lease_Unit__r.Lease_Agreement_No__r.Tenant__c,Lease_Unit__r.Lease_Agreement_No__r.Property__r.Comm_Tax__c,Commercial_Tax_Apply__c from Lease_Charges__c where Lease_Unit__c in:luToWithHoldingRRDMap.keyset() and Charge_Type__c = 'Invoice Discount']){
                                luToInvDiscChgMap.put(lc.Lease_Unit__c,lc);
                            }
                            List<RsandRRDWrapper> rsRRdWrapList = new List<RsandRRDWrapper>();
                            for(Id luId:luToWithHoldingRRDMap.keyset()){
                                if(luToInvDiscChgMap.containsKey(luId)){
                                    decimal amount = 0;
                                    decimal taxRate = 0;
                                    Date minDate = null;
                                    Date maxDate = null;
                                    for(Rent_Roll_Detail__c rrd:luToWithHoldingRRDMap.get(luId)){
                                        amount += rrd.Amount__c;
                                        if(taxRate==null || taxRate==0){
                                            taxRate = rrd.Withholding_Tax_Rate__c;
                                        }
                                        if(minDate==null || rrd.Start_Date__c<minDate){
                                            minDate = rrd.Start_Date__c;
                                        }
                                        if(maxDate==null || rrd.End_Date__c>maxDate){
                                            maxDate = rrd.End_Date__c;
                                        }
                                    }
                                    if(amount>0){
                                        amount = amount*taxRate/100.00;
                                        Lease_Charges__c invDiscLeaseCharge = luToInvDiscChgMap.get(luId);
                                        Rent_Schedules__c rs = new Rent_Schedules__c();
                                        rs.Unit__c = invDiscLeaseCharge.Lease_Unit__r.Unit__c;
                                        rs.PropertyLU__c = invDiscLeaseCharge.Lease_Unit__r.Lease_Agreement_No__r.Property__c;
                                        rs.TenantLU__c = invDiscLeaseCharge.Lease_Unit__r.Lease_Agreement_No__r.Tenant__c;
                                        
                                        if(invDiscLeaseCharge.Commercial_Tax_Apply__c){
                                            rs.Comm_Tax__c = invDiscLeaseCharge.Lease_Unit__r.Lease_Agreement_No__r.Property__r.Comm_Tax__c;
                                        }else{
                                            rs.Comm_Tax__c = 0.00;
                                        }
                                        
                                        rs.Status__c = 'Rent Roll Generated';
                                        rs.Approved__c = true;
                                        rs.Lease_Charge__c = invDiscLeaseCharge.Id;
                                        rs.Lease_Unit__c  = invDiscLeaseCharge.Lease_Unit__c;
                                        rs.recordTypeId = rentRcdMap.get('Rent');
                                        rs.Currency_Code__c = rentRoll.Currency_Code__c;
                                        rs.Rent_Roll__c = rentRoll.Id;
                                        rs.Amount__c = amount;
                                        rs.Start_Date__c = minDate;
                                        rs.End_Date__c = maxDate;
                                        
                                        Rent_Roll_Detail__c rrd = new Rent_Roll_Detail__c();
                                        rrd.Unit__c = rs.Unit__c;
                                        rrd.Amount__c = rs.Amount__c;
                                        if(rs.Comm_Tax__c>0){
                                            rrd.Comm_Tax_Amount__c = rrd.Amount__c*rs.Comm_Tax__c/100.00;
                                        }
                                        rrd.Status__c = 'Approved';
                                        rrd.Approved__c = true;
                                        rrd.Lease_Charge__c = rs.Lease_Charge__c;
                                        rrd.Lease_Unit__c = rs.Lease_Unit__c;
                                        rrd.Currency_Code__c = rs.Currency_Code__c;
                                        rrd.Rent_Roll__c = rentRoll.Id;
                                        rrd.Charge_Type__c = 'Invoice Discount';
                                        rrd.Start_Date__c = rs.Start_Date__c;
                                        rrd.End_Date__c = rs.End_Date__c;
                                        
                                        RsandRRDWrapper rWrap = new RsandRRDWrapper();
                                        rWrap.rs = rs;
                                        rWrap.rrd = rrd;
                                        rsRRdWrapList.add(rWrap);
                                    }
                                }
                            }
                            if(rsRRdWrapList.size()>0){
                                List<Rent_Roll_Detail__c> rrdList = new List<Rent_Roll_Detail__c>();
                                for(RsandRRDWrapper rWrap:rsRRdWrapList){
                                    rrdList.add(rWrap.rrd);
                                }
                                insert rrdList;
                                List<Rent_Schedules__c> rsList = new List<Rent_Schedules__c>();
                                for(RsandRRDWrapper rWrap:rsRRdWrapList){
                                    if(rWrap.rrd.Id!=null){
                                        rWrap.rs.Rent_Roll_Detail__c = rWrap.rrd.Id;
                                        rsList.add(rWrap.rs);
                                    }
                                }
                                insert rsList;
                            }
                        }
                        update rentRoll;
                    }
                    if(rejRentRollDetails.size()>0){
                        if(appRentRollDetails.size()==0){
                            rentRoll.Rejected__c = true;
                            update rentRoll;
                        }
                        update rejRentRollDetails;
                        List<Rent_Schedules__c> rsList = [Select id,Approved__c,Rent_Roll__c,Comments__c,Rent_Roll_Detail__c,Rent_Roll_Detail__r.Comments__c from Rent_Schedules__c where Rent_Roll_Detail__c in:rentRollDetIds];
                        if(rsList.size()>0){
                            for(Rent_Schedules__c rs:rsList){
                                rs.Approved__c = false;
                                rs.Rent_Roll__c = null;
                                rs.Comments__c = rs.Rent_Roll_Detail__r.Comments__c;
                                rs.Rent_Roll_Detail__c = null;
                                if(rentRoll.Billing_Type__c=='Debit Note' || rentRoll.Billing_Type__c=='Credit Note' || rentRoll.Billing_Type__c=='Ad-Hoc Invoice'){
                                    rs.Status__c = 'Rejected';
                                }
                            }
                            update rsList;                            
                        }
                        
                    }
                    
                    Schema.DescribeSObjectResult r = Invoice__c.sObjectType.getDescribe();
                    String keyPrefix = r.getKeyPrefix();
                    
                    return new pageReference('/'+keyPrefix+'?fcf='+label.TodayInvoiceViewID);
                }else{
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Rent Roll Detail not found.'));
                }
            }else{
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Rent Roll not found.'));
            }
        }catch(exception e){
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,e.getMessage()));
        }
        database.rollback(sp);
        return null;
    }
    
    public class RsandRRDWrapper{
        public Rent_Schedules__c rs{get;set;}
        public Rent_Roll_Detail__c rrd{get;set;}
        public RsandRRDWrapper(){
            rs = new Rent_Schedules__c();
            rrd = new Rent_Roll_Detail__c();
        }
    }
    
    public List<selectOption> getBillingTypes(){
        List<selectOption> tempList = new List<selectOption>();
        Schema.DescribeFieldResult fieldResult = Rent_Roll__c.Billing_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        tempList.add(new SelectOption('','All'));
        for(Schema.PicklistEntry f : ple){
           tempList.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return tempList;
    }
}