public class GenerateRentRollController{
	//http://sfdcsrini.blogspot.com/2014/12/custom-controller-pagination-with.html
    // static variable to indicate that a GTO RS is an estimated billing.
    private static final String GTORENTBYESTIMATION = 'Estimated GTO';
    public Rent_Roll__c rentRoll{get;set;}
    public Rent_Roll__c gtoRentRoll{get;set;}
    public string batch{get;set;}
    public string batchId{get;set;}
    public Integer month{get;set;}
    public Integer year{get;set;}
    public List<Rent_Schedules__c> rentScheduleList{get;set;}
    public Boolean selectAll{get;set;}
    public string chargeType{get;set;}
    public string bilingDate{get;set;}
    public string propertyName{get;set;}
    public string rentSchTypeId{get;set;}
    public string exRateName{get;set;}
    public Id exRateId{get;set;} 
    public decimal exRate{get;set;}
    public string chargeTypeWithoutGTO{get;set;}
    public string chargeMethod{get;set;}
    public string dataRow{get;set;}
    
    public List<Rent_Schedules__c> gtoRsList{get;set;}
    public string gtoDataRow{get;set;}
    public Integer gtoMonth{get;set;}
    public Integer gtoYear{get;set;}
    
    public String sortOrder{get;set;}
    public String sortField{get;set;}
    
    //pagination information
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
    
    public GenerateRentRollController(){
        rentScheduleList = new List<Rent_Schedules__c>();
        
        gtoRsList = new List<Rent_Schedules__c>();
        rentRoll = new Rent_Roll__c();
        gtoRentRoll = new Rent_Roll__c();
        gtoRentRoll.Currency_Code__c = label.Default_Currency;
        rentRoll.Currency_Code__c = label.Default_Currency;
        month = system.today().month();
        year = system.today().year();
        
        gtomonth = system.today().month();
        gtoyear = system.today().year();
        
        rentRoll.Expected_Invoice_Date__c = Date.NewInstance(year,month,1).addMonths(1);
        rentRoll.Comm_Tax_Applicable__c = 'Yes';
        
        sortOrder = 'Asc';
        sortField = 'Tenant';
        
        //set initial page
        this.page = 1;
        dataRow = '50';
    }
    public void resort(){
    	//sortOrder = newSortOrder;
    	sortOrder = (sortOrder == 'Asc')?'Desc':'Asc';
    	System.debug('sortOrder-->'+sortOrder);
    	
    	this.page = 1;
    	search();
    }
    public void dataRowChange(){
    	this.page = 1;
    	search();
    }
    public void search(){
        Integer PAGE_SIZE = Integer.valueof(dataRow);
        //calculate range of records for capture
        this.startIdx = (this.page-1)*PAGE_SIZE;
        this.endIdx = this.page*PAGE_SIZE;
        this.totalRecords = 0;
        
        //clear container for records displayed
        this.rentScheduleList.clear();
        
        searchRS();
        
        //calculate total pages
        Decimal pages = Decimal.valueOf(this.totalRecords);
        pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        
        //adjust start index e.g. 1, 11, 21, 31
        this.startIdx++;
        
        
        //adjust end index
        if(this.endIdx>this.totalRecords){
            this.endIdx = this.totalRecords;
        }
     
        
        //display resource usage
        System.Debug(LoggingLevel.WARN,'****** LIMIT query rows: '+Limits.getQueryRows()+' / '+Limits.getLimitQueryRows());
        System.Debug(LoggingLevel.WARN,'****** LIMIT heap size: '+Limits.getHeapSize()+' / '+Limits.getLimitHeapSize());
        System.Debug(LoggingLevel.WARN,'****** LIMIT cpu time: '+Limits.getCpuTime()+' / '+Limits.getLimitCpuTime());
       // System.Debug(LoggingLevel.WARN,'****** LIMIT script statements: '+Limits.getScriptStatements()+' / '+Limits.getLimitScriptStatements());
    }
    public void searchRS(){
        string temp = batch;
        if(temp=='GTO Rent'){
            temp = 'Monthly';
        }
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Rent_Schedules__c' AND DeveloperName =: temp];
        if(recType <> null && recType.size()>0)
        batchId = String.valueOf(recType[0].Id).substring(0,String.valueOf(recType[0].Id).length()-3);
        
        selectAll = false;
        rentScheduleList = new List<Rent_Schedules__c>();
        if(rentRoll.Property__c!=null){
            
            if(rentRoll.Currency_Code__c!=label.Default_Currency && (exRateName==null || exRateName.trim().length()==0 || exRateId==null)){
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Exchange Rate.'));
                return;
            }
            
            bilingDate = month+'/'+Date.daysInMonth(year,Month)+'/'+year;
            
            string query = 'Select id,Withholding_Tax_Rate__c,Charge_Type__c,Remarks__c,recordtypeId,Transaction_Start_Date__c,Transaction_End_Date__c,Name,Active__c,Area_ft__c,Billing_Date__c,End_Date__c,Expected_Amount__c,Hold__c,Lease_Unit__c,Rent_Roll__c,Start_Date__c,Status__c,Total_Units_p__c,Trading_Day_s__c,Unit__c,Approved__c,Tenant__c,Unit__r.Name,Lease_Charge__r.Name,Total_Units__c,Lease_Charge__r.Charge_Rate__c,Amount__c,Lease_Charge__c,recordType.Name,Property__c,Electric_Meter__c,Electric_Meter_Number__c,Comments__c,Comm_Tax_Amount__c,Total_Amount__c,unit__r.property__r.Name,Currency_Code__c,Exchange_Rate__c,Amount_Local__c,Amount_Foreign__c,Comm_Tax_Amount_Local__c,Comm_Tax_Amount_Foreign__c,GTO_Amount1__c,GTO_Monthly_Total__c,GTO_Rent_By__c,(Select id,Withholding_Tax_Rate__c,Charge_Type__c,Remarks__c,recordtypeId,Transaction_Start_Date__c,Transaction_End_Date__c,Name,Active__c,Area_ft__c,Billing_Date__c,End_Date__c,Expected_Amount__c,Hold__c,Lease_Unit__c,Rent_Roll__c,Start_Date__c,Status__c,Total_Units_p__c,Trading_Day_s__c,Unit__c,Approved__c,Tenant__c,Unit__r.Name,Lease_Charge__r.Name,Total_Units__c,Lease_Charge__r.Charge_Rate__c,Amount__c,Lease_Charge__c,recordType.Name,Parent_Rent_Schedule__r.recordType.Name,Property__c,Electric_Meter__c,Electric_Meter_Number__c,Comments__c,Comm_Tax_Amount__c,Total_Amount__c,unit__r.property__r.Name,Currency_Code__c,Exchange_Rate__c,Amount_Local__c,Amount_Foreign__c,Comm_Tax_Amount_Local__c,Comm_Tax_Amount_Foreign__c,GTO_Amount1__c,GTO_Rent_By__c,GTO_Monthly_Total__c from Rent_Schedules__r) from Rent_Schedules__c where unit__r.property__c=\''+rentroll.property__c+ '\' and Rent_Roll__c=null and Approved__c=false and Status__c!=\'Terminated\' and Status__c!=\'Cancelled\' and Status__c!=\'Rent Free\'';
            Date tempBillDate = Date.newInstance(year,month,Date.daysInMonth(year,Month));
            query += ' and Billing_Date__c<=:tempBillDate';
            query += ' and Lease_Charge__c <> NULL';
            
            query += ' and (Billing_Type__c!=\'Credit Note\' and Billing_Type__c!=\'Debit Note\' and Billing_Type__c!=\'Ad-Hoc Invoice\')';
            
            if(rentRoll.Currency_Code__c!=null){
                query += ' and Currency_Code__c=\''+rentRoll.Currency_Code__c+'\'';
            }
            
            if(chargeMethod=='Monthly Rate - L'){
                query += 'and (Lease_Unit__r.Lease_Agreement_No__r.Charge_Method__c=null or Lease_Unit__r.Lease_Agreement_No__r.Charge_Method__c=:chargeMethod)';
            }else if(chargeMethod=='Monthly Rate - CL'|| chargeMethod=='Daily Rate'){
                query += 'and Lease_Unit__r.Lease_Agreement_No__r.Charge_Method__c=:chargeMethod';
            }
            
            if(rentRoll.Comm_Tax_Applicable__c=='Yes'){
                query += ' and  Lease_Charge__r.Commercial_Tax_Apply__c =true';
            }else{
                query += ' and Lease_Charge__r.Commercial_Tax_Apply__c =false';
            }
            
            if(batch!='GTO Rent'){
                if(chargeType!=null && chargeType.trim().length()>0){
                    query += ' and Charge_Type__c=:chargeType';
                }else {
                    query += ' and Charge_Type__c!=\'GTO Rent\'';
                }
                
                query += ' and ((lease_Charge__r.Type__c!=\'Meter Units\') or (lease_Charge__r.Type__c=\'Meter Units\' and Transaction_Status__c=\'Applicable - Imported\'))';
            }else{
                query += ' and Charge_Type__c=\'GTO Rent\' and (Transaction_Status__c=\'Applicable - Imported\' OR GTO_Rent_By__c=:GTORENTBYESTIMATION)';
            }
            
            system.debug('batch-->'+batch);
            if(batch==Label.RentScheduleRentRecordType){
                query += ' and recordType.Name=\''+Label.RentScheduleRentRecordType+'\'';
            }else if(batch==Label.RentScheduleMonthlyRecordType){
                query += ' and recordType.Name=\''+Label.RentScheduleMonthlyRecordType+'\'';
            }
            if(sortOrder == 'Desc'){
            	query+= ' order by Tenant__c Desc,Unit__r.Name, Start_Date__c,Lease_Charge__r.Name asc LIMIT 50000';
            }else{
            	query+= ' order by Tenant__c Asc,Unit__r.Name, Start_Date__c,Lease_Charge__r.Name asc LIMIT 50000';
            }
            
            String initDataRow = '100';
            
            if(!String.isBlank(dataRow))
                initDataRow = dataRow;
            
            //query+= initDataRow;
            System.debug('query-->'+query);
            
            List<Rent_Schedules__c> tempList = new List<Rent_Schedules__c>();
            tempList = database.query(query);
            if(tempList.size()==0){
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'No Rent Schedules present for this property.'));
            }else{
                for(Rent_Schedules__c rs:tempList){
                	
                	if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx){
                    	rentScheduleList.add(rs);
                	}
                	this.totalRecords++;
                	
                	for(Rent_Schedules__c rsChild:rs.rent_Schedules__r){
                		if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx){
                			rentScheduleList.add(rsChild);
                		}
    		            this.totalRecords++;
                	}
                }
                propertyName = rentScheduleList[0].Unit__r.Property__r.Name;
                rentSchTypeId = rentScheduleList[0].recordtypeId;
            }
        }else{
             Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Property.'));
        }
    }
    
    /*
    *   advance to next page
    */
    public void doNext(){
        
        if(getHasNext()){
            this.page++;
            search();
        }

    }
    
    
    /*
    *   advance to previous page
    */
    public void doPrevious(){
        
        if(getHasPrevious()){
            this.page--;
            search();
        }
                
    }
    
    /*
    *   returns whether the previous page exists
    */
    public Boolean getHasPrevious(){
        if(this.page>1){
            return true;
        }
        else{
            return false;
        }
    }
    
    /*
    *   returns whether the next page exists
    */
    public Boolean getHasNext(){
        if(this.page<this.totalPages){
            return true;
        }
        else{
            return false;
        }
    }
    /*
    *   returns whether the next page exists
    */
    public virtual void moveLast() {
        if(getHasLast()){
	        this.page = this.totalPages; 
	        search();
        }
    }
	/*
    *   returns whether the next page exists
    */
    public virtual void moveFirst() {
        if(getHasFirst()){
	        this.page = 1;
	        search();
        }
    }
     /*
    *   returns whether the previous page exists
    */
    public Boolean getHasFirst(){
        if(this.page>1){
            return true;
        }
        else{
            return false;
        }
    }
    
    /*
    *   returns whether the next page exists
    */
    public Boolean getHasLast(){
        if(this.page<this.totalPages){
            return true;
        }
        else{
            return false;
        }
    }
    
    public void searchGTO(){
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Rent_Schedules__c' AND DeveloperName ='Monthly'];
        if(recType <> null && recType.size()>0)
        batchId = String.valueOf(recType[0].Id).substring(0,String.valueOf(recType[0].Id).length()-3);
        
        selectAll = false;
        gtoRsList = new List<Rent_Schedules__c>();
        if(gtoRentRoll.Property__c!=null){
            
            if(gtorentRoll.Currency_Code__c!=label.Default_Currency && (exRateName==null || exRateName.trim().length()==0 || exRateId==null)){
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Exchange Rate.'));
                return;
            }
            
            bilingDate = gtomonth+'/'+Date.daysInMonth(gtoyear,gtoMonth)+'/'+gtoyear;
            
            string query = 'Select id,Estimated_GTO_Rent__c,Calculated_Amount_Higher_or_Sum__c,GTO_Rent_By_Lease__c,Total_Estimated_GTO__c,Withholding_Tax_Rate__c,Charge_Type__c,Remarks__c,recordtypeId,Transaction_Start_Date__c,Transaction_End_Date__c,Name,Active__c,Area_ft__c,Billing_Date__c,End_Date__c,Expected_Amount__c,Hold__c,Lease_Unit__c,Rent_Roll__c,Start_Date__c,Status__c,Total_Units_p__c,Trading_Day_s__c,Unit__c,Approved__c,Tenant__c,Unit__r.Name,Lease_Charge__r.Name,Total_Units__c,Lease_Charge__r.Charge_Rate__c,Amount__c,Lease_Charge__c,recordType.Name,Property__c,Electric_Meter__c,Electric_Meter_Number__c,Comments__c,Comm_Tax_Amount__c,Total_Amount__c,unit__r.property__r.Name,Currency_Code__c,Exchange_Rate__c,Amount_Local__c,Amount_Foreign__c,Comm_Tax_Amount_Local__c,Comm_Tax_Amount_Foreign__c,GTO_Amount1__c,GTO_Monthly_Total__c,GTO_Rent_By__c,Lease_Unit__r.Lease_Agreement_No__r.GTO_Billed__c,(Select id,GTO_Rent_By__c,Lease_Unit__r.Lease_Agreement_No__r.GTO_Billed__c,Estimated_GTO_Rent__c,Total_Estimated_GTO__c,Calculated_Amount_Higher_or_Sum__c,GTO_Rent_By_Lease__c,Withholding_Tax_Rate__c,Charge_Type__c,Remarks__c,recordtypeId,Transaction_Start_Date__c,Transaction_End_Date__c,Name,Active__c,Area_ft__c,Billing_Date__c,End_Date__c,Expected_Amount__c,Hold__c,Lease_Unit__c,Rent_Roll__c,Start_Date__c,Status__c,Total_Units_p__c,Trading_Day_s__c,Unit__c,Approved__c,Tenant__c,Unit__r.Name,Lease_Charge__r.Name,Total_Units__c,Lease_Charge__r.Charge_Rate__c,Amount__c,Lease_Charge__c,recordType.Name,Parent_Rent_Schedule__r.recordType.Name,Property__c,Electric_Meter__c,Electric_Meter_Number__c,Comments__c,Comm_Tax_Amount__c,Total_Amount__c,unit__r.property__r.Name,Currency_Code__c,Exchange_Rate__c,Amount_Local__c,Amount_Foreign__c,Comm_Tax_Amount_Local__c,Comm_Tax_Amount_Foreign__c,GTO_Amount1__c,GTO_Monthly_Total__c from Rent_Schedules__r) from Rent_Schedules__c where unit__r.property__c=\''+gtorentroll.property__c+ '\' and Rent_Roll__c=null and Approved__c=false and Status__c!=\'Terminated\' and Status__c!=\'Cancelled\' and Status__c!=\'Rent Free\'';
            Date tempBillDate = Date.newInstance(gtoyear,gtomonth,Date.daysInMonth(gtoyear,gtoMonth));
            query += ' and Billing_Date__c<=:tempBillDate';
            query += ' and Lease_Charge__c <> NULL';
            
            if(gtorentRoll.Currency_Code__c!=null){
                query += ' and Currency_Code__c=\''+gtorentRoll.Currency_Code__c+'\'';
            }
            
            //query += ' and Charge_Type__c=\'GTO Rent\' and (Transaction_Status__c=\'Applicable - Imported\' OR GTO_Rent_By__c=:GTORENTBYESTIMATION)';
            
            /* Change by AS -  Req by Myat on Jan 31st */
            /* To be able to key in the estimated GTO before POS data uploaded */
            //query += ' and Charge_Type__c=\'GTO Rent\' and (GTO_Monthly_Total_Converted__c>0 OR Total_Estimated_GTO_Converted__c>0)';
            query += ' and Charge_Type__c=\'GTO Rent\' ';
            
            query+= ' order by Tenant__c asc,Unit__r.Name, Start_Date__c,Lease_Charge__r.Name asc LIMIT ';
            
            
            String initDataRow = '20';
            
            if(!String.isBlank(gtoDataRow))
                initDataRow = gtoDataRow;
            
            query+= initDataRow;
            
            System.debug('Estimated GTO Query --> ' + query);
            
            List<Rent_Schedules__c> tempList = new List<Rent_Schedules__c>();
            tempList = database.query(query);
            if(tempList.size()==0){
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'No Rent Schedules present for this property.'));
            }else{
                for(Rent_Schedules__c rs:tempList){
                    gtoRSList.add(rs);
                    if(rs.rent_Schedules__r.size()>0){
                        gtoRSList.addAll(rs.rent_Schedules__r);
                    }
                }
                propertyName = gtoRSList[0].Unit__r.Property__r.Name;
                rentSchTypeId = gtoRSList[0].recordtypeId;
            }
        }else{
             Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Property.'));
        }
    }        
    
    public void refresh(){
        try{
            List<Rent_Schedules__c> updRentSchList = new List<Rent_Schedules__c>();
            for(Rent_Schedules__c rs:rentScheduleList){
                if(rs.Approved__c){
                    rs.Approved__c = false;
                    updRentSchList.add(rs);
                }
            }
            update updRentSchList;
            search();
        }catch(exception e){
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,e.getMessage()));
        }
    }
    
    public void refreshExRate(){
        if(exRateName!=null && exRateName.trim().length()>0 && exRateId!=null){
            Exchange_Rate__c exchangeRate = [Select id,Conversion_Rate__c,Start_Date_Time__c from Exchange_Rate__c where id=:exRateId And Applicable_Function__c = 'Operations'];
            Boolean apprCheck = false;
            for(Rent_Schedules__c rs:rentScheduleList){
                if(rs.Approved__c){
                    apprCheck = true;
                    rs.Approved__c = false;
                    rs.Exchange_Rate__c = exchangeRate.Conversion_Rate__c;
                }
            }
            
            if(!apprCheck){
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please check atleast 1 Rent Schedule.'));
                return;
            }
            update rentScheduleList;
            search();
            
        }else{
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Exchange Rate.'));
        }
    }
    
    public void refreshExRateGTO(){
        if(exRateName!=null && exRateName.trim().length()>0 && exRateId!=null){
            Exchange_Rate__c exchangeRate = [Select id,Conversion_Rate__c,Start_Date_Time__c from Exchange_Rate__c where id=:exRateId And Applicable_Function__c = 'Operations'];
            Boolean apprCheck = false;
            for(Rent_Schedules__c rs:gtoRsList){
                if(rs.Approved__c){
                    apprCheck = true;
                    rs.Approved__c = false;
                    rs.Exchange_Rate__c = exchangeRate.Conversion_Rate__c;
                }
            }
            
            if(!apprCheck){
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please check atleast 1 Rent Schedule.'));
                return;
            }
            update gtoRsList;
            searchGTO();
            
        }else{
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Exchange Rate.'));
        }
    }
    
    public void RentByChange(){
        for(Rent_Schedules__c rs:gtoRSList){
            if(rs.GTO_Rent_By__c=='POS GTO'){
                rs.Amount__c = rs.GTO_Monthly_Total__c;
            }else if(rs.GTO_Rent_By__c=='Estimated GTO'){
                rs.Amount__c = rs.Total_Estimated_GTO__c;
            }
        }
    }
    
    public void gtoRefreshExRate(){
        if(exRateName!=null && exRateName.trim().length()>0 && exRateId!=null){
            Exchange_Rate__c exchangeRate = [Select id,Conversion_Rate__c,Start_Date_Time__c from Exchange_Rate__c where id=:exRateId And Applicable_Function__c = 'Operations'];
            Boolean apprCheck = false;
            for(Rent_Schedules__c rs:gtoRSList){
                if(rs.Approved__c){
                    apprCheck = true;
                    rs.Approved__c = false;
                    rs.Exchange_Rate__c = exchangeRate.Conversion_Rate__c;
                }
            }
            
            if(!apprCheck){
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please check atleast 1 Rent Schedule.'));
                return;
            }
            update gtoRsList;
            searchGTO();
            
        }else{
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Exchange Rate.'));
        }
    }
    
    public pageReference reCalcGtoAmount(){
        Boolean apprCheck = false;
        for(Rent_Schedules__c rs:gtoRSList){
            if(rs.Approved__c){
                apprCheck = true;
                rs.Approved__c = false;
            }
        }
        
        if(!apprCheck){
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please check atleast 1 Rent Schedule.'));
            return null;
        }
        update gtoRsList;
        searchGTO();
        return null;
    }
    
    public void currencyCodeChange(){
        exRateName = null;
        exRateId = null;
        if(rentRoll.Currency_Code__c!=null && rentRoll.Currency_Code__c!=label.Default_Currency){
            for(Exchange_Rate__c er:[Select id,Name,Conversion_Rate__c,Start_Date_Time__c from Exchange_Rate__c where Currency_Code__c=:rentRoll.Currency_Code__c and  Start_Date_Time__c<=:system.now() And Applicable_Function__c = 'Operations' order by Start_Date_Time__c desc limit 1]){
                exRateName = er.Name;
                exRateId = er.Id;
                exRate = er.Conversion_Rate__c;
            }
        }else if(gtoRentRoll.Currency_Code__c!=null && gtoRentRoll.Currency_Code__c!=label.Default_Currency){
            for(Exchange_Rate__c er:[Select id,Name,Conversion_Rate__c,Start_Date_Time__c from Exchange_Rate__c where Currency_Code__c=:gtoRentRoll.Currency_Code__c and  Start_Date_Time__c<=:system.now() And Applicable_Function__c = 'Operations' order by Start_Date_Time__c desc limit 1]){
                exRateName = er.Name;
                exRateId = er.Id;
                exRate = er.Conversion_Rate__c;
            }
        }
        if(rentRoll.Property__c!=null){
            search();
        }
        if(gtoRentRoll.Property__c!=null){
            searchGTO();
        }
    }
    
    public void updateConversionRate(){
        exRate = 0;
        if(exRateId!=null && rentRoll.Currency_Code__c!=label.Default_Currency){
            for(Exchange_Rate__c er:[Select id,Name,Conversion_Rate__c,Start_Date_Time__c from Exchange_Rate__c where id=:exRateId And Applicable_Function__c = 'Operations' limit 1]){
                exRate = er.Conversion_Rate__c;
            }
        }
    }
    
    public pageReference approve(){
        Boolean apprCheck = false;
        List<Rent_Schedules__c> rentTypeSchedules = new List<Rent_Schedules__c>();
        List<Rent_Schedules__c> monthlyTypeSchedules = new List<Rent_Schedules__c>();
        Map<Id,Rent_Schedules__c> onholdSchedules = new Map<Id,Rent_Schedules__c>();
        List<Rent_Schedules__c> gtoRentSchedules = new List<Rent_Schedules__c>();
        Decimal rentTypeTotalAmount = 0;
        Decimal MonthlyTypeTotalAmount = 0;
        Decimal gtoRentTotalAmount = 0;
        if(rentRoll.Currency_Code__c!=label.Default_Currency && (exRateName==null || exRateName.trim().length()==0 || exRateId==null)){
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please select Exchange Rate.'));
            return null;
        }
        for(Rent_Schedules__c rs:rentScheduleList){
            if(rs.Approved__c){
                apprCheck = true;
                rs.Hold__c = false;
                if(batch!='GTO Rent'){
                    if(rs.recordType.Name==label.RentScheduleRentRecordType || rs.Parent_Rent_Schedule__r.recordType.Name==label.RentScheduleRentRecordType){
                        if(rs.Amount__c!=null){
                            rentTypeTotalAmount += rs.Amount__c;
                        }
                        rentTypeSchedules.add(rs);
                    }else if(rs.recordType.Name==label.RentScheduleMonthlyRecordType || rs.Parent_Rent_Schedule__r.recordType.Name==label.RentScheduleMonthlyRecordType){
                        if(rs.Amount__c!=null){
                            monthlyTypeTotalAmount += rs.Amount__c;
                        }
                        monthlyTypeSchedules.add(rs);
                    }
                }else{
                    if(rs.Amount__c!=null){
                        gtoRentTotalAmount += rs.Amount__c;
                    }
                    gtoRentSchedules.add(rs);
                }
            }else{
                rs.Hold__c = true;
                onholdSchedules.put(rs.Id,rs);
            }
           
        }
        if(!apprCheck){
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error,'Please check atleast 1 Rent Schedule.'));
            return null;
        }
        
        Exchange_Rate__c exchangeRate = new Exchange_Rate__c();
        if(exRateId!=null){
            exchangeRate = [Select id,Conversion_Rate__c,Start_Date_Time__c from Exchange_Rate__c where id=:exRateId And Applicable_Function__c = 'Operations'];
        }
        
        List<Lease_Unit__c> leaseUnits = [Select id,Area_Sq_Ft__c,Unit__r.Property__c from Lease_Unit__c where Unit__r.Property__c=:rentRoll.Property__c and Area_Sq_Ft__c!=null];
        decimal totalLeaseArea = 0;
        for(Lease_Unit__c lu:leaseUnits){
            totalLeaseArea += lu.Area_Sq_Ft__c;
        }
        List<Rent_Roll_Detail__c> rrDetailList = new List<Rent_Roll_Detail__c>();
        Property__c prop = [Select id,Rent_Roll_Index__c,Short_Code__c from Property__c where id=:rentRoll.Property__c];
        Integer currentMonth = system.today().month();
        Integer currentYear = system.today().Year();
        string rrId;
        if(rentTypeSchedules.size()>0){
            Rent_Roll__c rrRent = new Rent_Roll__c();
            rrRent.Property__c = rentRoll.property__c;
            rrRent.Currency_Code__c = rentRoll.Currency_Code__c;
            rrRent.Total_Leased_Area_Sq_Ft__c = totalLeaseArea;
            rrRent.Total_Amount__c = rentTypeTotalAmount ;
            rrRent.Rent_Roll_YYYY__c = ''+year;
            rrRent.Rent_Roll_MM__c = (month<10?'0'+month:''+month);
            //rrRent.Name = rentTypeSchedules[0].Property__c + '-' + rentTypeSchedules[0].Billing_Date__c.format() + '-'+label.RentScheduleRentRecordType;
            rrRent.Expected_Invoice_Date__c = rentRoll.Expected_Invoice_Date__c;
            
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
            rrRent.Rent_Roll_Index__c = index;
            prop.Rent_Roll_Index__c = intIndex + 1;
            
            rrRent.Name = prop.Short_Code__c+'-RO-'+currentYear+(currentMonth<10?'0'+currentMonth:''+currentMonth)+'-'+rrRent.Rent_Roll_Index__c;
            rrRent.Billing_Type__c = 'Rent';
            
            if(rentRoll.Currency_Code__c!=label.Default_Currency){
                rrRent.Exchange_Rate__c = exchangeRate.Conversion_Rate__c;
                if(exchangeRate.Start_Date_Time__c!=null){
                    rrRent.Ex_Rate_Date__c = exchangeRate.Start_Date_Time__c.date();
                }
            }else{
                rrRent.Exchange_Rate__c = 1;
            }
            rrRent.Comm_Tax_Applicable__c = rentRoll.Comm_Tax_Applicable__c;
            insert rrRent;
            
            rrId = rrRent.Id;
            
            update prop;
            
            for(Rent_Schedules__c rs:rentTypeSchedules){
                rs.Rent_Roll__c = rrRent.Id;
                rs.Status__c = 'Rent Roll Generated';
                if(rentRoll.Currency_Code__c!=label.Default_Currency){
                    rs.Exchange_Rate__c = rrRent.Exchange_Rate__c;
                }
                Rent_Roll_Detail__c rrDet = new Rent_Roll_Detail__c();
                rrDet.Rs_Name__c = rs.Name;
                rrDet.Active__c = rs.Active__c;
                rrDet.Amount__c = rs.Amount__c;
                rrDet.Comm_Tax_Amount__c = rs.Comm_Tax_Amount__c;
                rrDet.Billing_Date__c = rs.Billing_Date__c;
                rrDet.End_Date__c = rs.End_Date__c;
                rrDet.Lease_Charge__c = rs.Lease_Charge__c;
                rrDet.Lease_Unit__c = rs.Lease_Unit__c;
                rrDet.Rent_Roll__c = rs.Rent_Roll__c;
                rrDet.Start_Date__c = rs.Start_Date__c;
                //rrDet.Status__c = rs.Status__c;
                rrDet.Status__c = 'Pending';
                rrDet.Total_Units_p__c = rs.Total_Units__c;
                rrDet.Trading_Day_s__c = rs.Trading_Day_s__c;
                rrDet.Unit__c = rs.Unit__c;
                rrDet.Electric_Meter_Number__c = rs.Electric_Meter_Number__c;
                rrDet.Electric_Meter__c = rs.Electric_Meter__c;
                rrDet.Transaction_Start_Date__c = rs.Transaction_Start_Date__c;
                rrDet.Transaction_End_Date__c = rs.Transaction_End_Date__c;
                rrDet.Remarks__c = rs.Remarks__c;
                rrDet.Charge_Type__c = rs.Charge_Type__c;
                rrDet.Currency_Code__c = rs.Currency_Code__c;
                rrDet.Exchange_Rate__c = rs.Exchange_Rate__c;
                /*rrDet.Amount_Local__c = rs.Amount_Local__c;
                rrDet.Amount_Foreign__c = rs.Amount_Foreign__c;
                rrDet.Comm_Tax_Amount_Local__c = rs.Comm_Tax_Amount_Local__c;
                rrDet.Comm_Tax_Amount_Foreign__c = rs.Comm_Tax_Amount_Foreign__c;*/
                rrDet.POS_Sales_Amount__c =  rs.GTO_Monthly_Total__c;
                rrDet.GTO_Amount__c = rs.GTO_Amount1__c;
                rrDet.Withholding_Tax_Rate__c = rs.Withholding_Tax_Rate__c;
                rrDetailList.add(rrDet);
            }
        }
        if(monthlyTypeSchedules.size()>0){
            Rent_Roll__c rrMonthly = new Rent_Roll__c();
            rrMonthly.Property__c = rentRoll.property__c;
            rrMonthly.Currency_Code__c = rentRoll.Currency_Code__c;
            //rrMonthly.Rent_Roll_Date__c = monthlyTypeSchedules[0].Billing_Date__c;
            rrMonthly.Total_Leased_Area_Sq_Ft__c = totalLeaseArea;
            rrMonthly.Total_Amount__c = monthlyTypeTotalAmount;
            rrMonthly.Rent_Roll_YYYY__c = ''+year;
            rrMonthly.Rent_Roll_MM__c = (month<10?'0'+month:''+month);
            rrMonthly.Expected_Invoice_Date__c = rentRoll.Expected_Invoice_Date__c;
            
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
            rrMonthly.Rent_Roll_Index__c = index;
            prop.Rent_Roll_Index__c = intIndex + 1;
            rrMonthly.Name = prop.Short_Code__c+'-RO-'+currentYear+(currentMonth<10?'0'+currentMonth:''+currentMonth)+'-'+rrMonthly.Rent_Roll_Index__c;
            rrMonthly.Billing_Type__c = 'Monthly';            
            
            if(rentRoll.Currency_Code__c!=label.Default_Currency){
                rrMonthly.Exchange_Rate__c =exchangeRate.Conversion_Rate__c;
                if(exchangeRate.Start_Date_Time__c!=null){
                    rrMonthly.Ex_Rate_Date__c = exchangeRate.Start_Date_Time__c.date();
                }
            }else{
                rrMonthly.Exchange_Rate__c = 1;
            }
            
            rrMonthly.Comm_Tax_Applicable__c = rentRoll.Comm_Tax_Applicable__c;
            insert rrMonthly;
            
            rrId = rrMonthly.Id;
            
            update prop;
            
            for(Rent_Schedules__c rs:monthlyTypeSchedules){
                rs.Rent_Roll__c = rrMonthly.Id;
                rs.Status__c = 'Rent Roll Generated';
                if(rentRoll.Currency_Code__c!=label.Default_Currency){
                    rs.Exchange_Rate__c = rrMonthly.Exchange_Rate__c;
                }
                Rent_Roll_Detail__c rrDet = new Rent_Roll_Detail__c();
                rrDet.Rs_Name__c = rs.Name;
                rrDet.Active__c = rs.Active__c;
                rrDet.Amount__c = rs.Amount__c;
                rrDet.Comm_Tax_Amount__c = rs.Comm_Tax_Amount__c;
                rrDet.Billing_Date__c = rs.Billing_Date__c;
                rrDet.End_Date__c = rs.End_Date__c;
                rrDet.Lease_Charge__c = rs.Lease_Charge__c;
                rrDet.Lease_Unit__c = rs.Lease_Unit__c;
                rrDet.Rent_Roll__c = rs.Rent_Roll__c;
                rrDet.Start_Date__c = rs.Start_Date__c;
                //rrDet.Status__c = rs.Status__c;
                rrDet.Status__c = 'Pending';
                rrDet.Total_Units_p__c = rs.Total_Units_p__c;
                rrDet.Trading_Day_s__c = rs.Trading_Day_s__c;
                rrDet.Unit__c = rs.Unit__c;
                rrDet.Electric_Meter_Number__c = rs.Electric_Meter_Number__c;
                rrDet.Electric_Meter__c = rs.Electric_Meter__c;
                rrDet.Transaction_Start_Date__c = rs.Transaction_Start_Date__c;
                rrDet.Transaction_End_Date__c = rs.Transaction_End_Date__c;
                rrDet.Remarks__c = rs.Remarks__c;
                rrDet.Charge_Type__c = rs.Charge_Type__c;
                rrDet.Currency_Code__c = rs.Currency_Code__c;
                rrDet.Exchange_Rate__c = rs.Exchange_Rate__c;
                /*rrDet.Amount_Local__c = rs.Amount_Local__c;
                rrDet.Amount_Foreign__c = rs.Amount_Foreign__c;
                rrDet.Comm_Tax_Amount_Local__c = rs.Comm_Tax_Amount_Local__c;
                rrDet.Comm_Tax_Amount_Foreign__c = rs.Comm_Tax_Amount_Foreign__c;*/
                rrDet.POS_Sales_Amount__c =  rs.GTO_Monthly_Total__c;
                rrDet.GTO_Amount__c = rs.GTO_Amount1__c;
                rrDet.Withholding_Tax_Rate__c = rs.Withholding_Tax_Rate__c;
                rrDetailList.add(rrDet);
            }
        }
        
        if(gtoRentSchedules.size()>0){
            Rent_Roll__c rrgto = new Rent_Roll__c();
            rrgto.Property__c = rentRoll.property__c;
            rrgto.Currency_Code__c = rentRoll.Currency_Code__c;
            rrgto.Total_Leased_Area_Sq_Ft__c = totalLeaseArea;
            rrgto.Total_Amount__c = gtoRentTotalAmount;
            rrgto.Rent_Roll_YYYY__c = ''+year;
            rrgto.Rent_Roll_MM__c = (month<10?'0'+month:''+month);
            rrgto.Expected_Invoice_Date__c = rentRoll.Expected_Invoice_Date__c;
            
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
            rrgto.Rent_Roll_Index__c = index;
            prop.Rent_Roll_Index__c = intIndex + 1;
            rrgto.Name = prop.Short_Code__c+'-RO-'+currentYear+(currentMonth<10?'0'+currentMonth:''+currentMonth)+'-'+rrgto.Rent_Roll_Index__c;
            rrgto.Billing_Type__c = 'GTO Rent';
            
            if(rentRoll.Currency_Code__c!=label.Default_Currency){
                rrgto.Exchange_Rate__c =exchangeRate.Conversion_Rate__c;
                if(exchangeRate.Start_Date_Time__c!=null){
                    rrgto.Ex_Rate_Date__c = exchangeRate.Start_Date_Time__c.date();
                }
            }else{
                rrgto.Exchange_Rate__c = 1;
            }
            
            rrgto.Comm_Tax_Applicable__c = rentRoll.Comm_Tax_Applicable__c;
            
            insert rrgto;
            
            rrId = rrgto.Id;
            
            update prop;
            
            for(Rent_Schedules__c rs:gtoRentSchedules){
                rs.Rent_Roll__c = rrgto.Id;
                rs.Status__c = 'Rent Roll Generated';
                if(rentRoll.Currency_Code__c!=label.Default_Currency){
                    rs.Exchange_Rate__c = rrgto.Exchange_Rate__c;
                }
                Rent_Roll_Detail__c rrDet = new Rent_Roll_Detail__c();
                rrDet.Rs_Name__c = rs.Name;
                rrDet.Active__c = rs.Active__c;
                rrDet.Amount__c = rs.Amount__c;
                rrDet.Comm_Tax_Amount__c = rs.Comm_Tax_Amount__c;
                rrDet.Billing_Date__c = rs.Billing_Date__c;
                rrDet.End_Date__c = rs.End_Date__c;
                rrDet.Lease_Charge__c = rs.Lease_Charge__c;
                rrDet.Lease_Unit__c = rs.Lease_Unit__c;
                rrDet.Rent_Roll__c = rs.Rent_Roll__c;
                rrDet.Start_Date__c = rs.Start_Date__c;
                rrDet.Status__c = 'Pending';
                rrDet.Total_Units_p__c = rs.Total_Units_p__c;
                rrDet.Trading_Day_s__c = rs.Trading_Day_s__c;
                rrDet.Unit__c = rs.Unit__c;
                rrDet.Electric_Meter_Number__c = rs.Electric_Meter_Number__c;
                rrDet.Electric_Meter__c = rs.Electric_Meter__c;
                rrDet.Transaction_Start_Date__c = rs.Transaction_Start_Date__c;
                rrDet.Transaction_End_Date__c = rs.Transaction_End_Date__c;
                rrDet.Remarks__c = rs.Remarks__c;
                rrDet.Charge_Type__c = rs.Charge_Type__c;
                rrDet.Currency_Code__c = rs.Currency_Code__c;
                rrDet.Exchange_Rate__c = rs.Exchange_Rate__c;
                /*rrDet.Amount_Local__c = rs.Amount_Local__c;
                rrDet.Amount_Foreign__c = rs.Amount_Foreign__c;
                rrDet.Comm_Tax_Amount_Local__c = rs.Comm_Tax_Amount_Local__c;
                rrDet.Comm_Tax_Amount_Foreign__c = rs.Comm_Tax_Amount_Foreign__c;*/
                rrDet.POS_Sales_Amount__c =  rs.GTO_Monthly_Total__c;
                rrDet.GTO_Amount__c = rs.GTO_Amount1__c;
                rrDet.Withholding_Tax_Rate__c = rs.Withholding_Tax_Rate__c;
                if(rs.GTO_Rent_By__c != null){
                    rrDet.GTO_Rent_By__c = rs.GTO_Rent_By__c;
                }
                rrDetailList.add(rrDet);    
            }
        }
        
        if(rrDetailList.size()>0){
            insert rrDetailList;
        }
        if(onholdSchedules.size()>0){
            update onholdSchedules.values();
        }
        if(rentTypeSchedules.size()>0){
            for(Rent_Schedules__c rs:rentTypeSchedules){
                for(Rent_Roll_Detail__c rrDet:rrDetailList){
                    if(rrDet.Rs_Name__c==rs.Name && rrDet.Lease_Charge__c==rs.Lease_Charge__c && rrDet.Lease_Unit__c==rs.Lease_Unit__c && rrDet.Rent_Roll__c==rs.Rent_Roll__c && rrDet.Start_Date__c==rs.Start_Date__c  && rrDet.End_Date__c==rs.End_Date__c){
                        rs.Rent_Roll_Detail__c = rrDet.Id;
                        break;
                    }
                }
            }
            update rentTypeSchedules;
        }
        if(monthlyTypeSchedules.size()>0){
            for(Rent_Schedules__c rs:monthlyTypeSchedules){
                for(Rent_Roll_Detail__c rrDet:rrDetailList){
                    if(rrDet.Rs_Name__c==rs.Name && rrDet.Lease_Charge__c==rs.Lease_Charge__c && rrDet.Lease_Unit__c==rs.Lease_Unit__c && rrDet.Rent_Roll__c==rs.Rent_Roll__c && rrDet.Start_Date__c==rs.Start_Date__c  && rrDet.End_Date__c==rs.End_Date__c){
                        rs.Rent_Roll_Detail__c = rrDet.Id;
                        break;
                    }
                }
            }
            update monthlyTypeSchedules;
        }
        
        if(gtoRentSchedules.size()>0){
            for(Rent_Schedules__c rs:gtoRentSchedules){
                for(Rent_Roll_Detail__c rrDet:rrDetailList){
                    if(rrDet.Rs_Name__c==rs.Name && rrDet.Lease_Charge__c==rs.Lease_Charge__c && rrDet.Lease_Unit__c==rs.Lease_Unit__c && rrDet.Rent_Roll__c==rs.Rent_Roll__c && rrDet.Start_Date__c==rs.Start_Date__c  && rrDet.End_Date__c==rs.End_Date__c){
                        rs.Rent_Roll_Detail__c = rrDet.Id;
                        break;
                    }
                }
            }
            update gtoRentSchedules;
        }
       
        return new pageReference('/'+rrId);
         
    }
    
    public void selectAllToApprove(){
        for(Rent_Schedules__c rs:rentScheduleList){
            rs.Approved__c = selectAll;
        }
    }
    
    public List<selectOption> getbatchList(){
        List<selectOption> tempList = new List<selectOption>();
        //tempList.add(new selectOption('All','All'));
        tempList.add(new selectOption(Label.RentScheduleRentRecordType,Label.RentScheduleRentRecordType));
        tempList.add(new selectOption(Label.RentScheduleMonthlyRecordType,'Monthly/Transactions'));
        tempList.add(new selectOption('GTO Rent','GTO Rent'));
        return tempList;
    }
    
    public List<SelectOption> getChargeMethodList(){
        List<selectOption> tempList = new List<selectOption>();
        tempList.add(new selectOption('Monthly Rate - L','Monthly Rate - L'));
        tempList.add(new selectOption('Monthly Rate - CL','Monthly Rate - CL'));
        tempList.add(new selectOption('Daily Rate','Daily Rate'));
        return tempList;
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
    
    public List<selectOption> getDataRowList(){
        List<selectOption> tempList = new List<selectOption>();
       // tempList.add(new selectOption('2','2'));
        //tempList.add(new selectOption('3','3'));
        tempList.add(new selectOption('50','50'));
        tempList.add(new selectOption('100','100'));
        tempList.add(new selectOption('200','200'));
        tempList.add(new selectOption('300','300'));
        tempList.add(new selectOption('400','400'));
        tempList.add(new selectOption('500','500'));
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
    
    public List<selectOption> getchargeTypeList(){
        List<selectOption> tempList = new List<selectOption>();
        Schema.DescribeFieldResult fieldResult = Lease_Charges__c.Charge_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        tempList.add(new SelectOption('','All'));
        chargeTypeWithoutGTO = '';
        for(Schema.PicklistEntry f : ple){
           if(f.getLabel()!='GTO Rent'){
               tempList.add(new SelectOption(f.getLabel(), f.getValue()));
               chargeTypeWithoutGTO += f.getValue() + ',';
           }
        }
        if(chargeTypeWithoutGTO!=null && chargeTypeWithoutGTO.endsWith(',')){
            chargeTypeWithoutGTO = chargeTypeWithoutGTO.substring(0,chargeTypeWithoutGTO.length()-1);
        }
        chargeTypeWithoutGTO = EncodingUtil.urlEncode(chargeTypeWithoutGTO, 'UTF-8');

        return tempList;
    }
}