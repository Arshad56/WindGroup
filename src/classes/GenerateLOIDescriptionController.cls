public class GenerateLOIDescriptionController {
    public LOI__c loi{get;set;}
    public List<loiWrapper> loiWrap{get;set;}
    public String selectedLeasePlan{ get; set; }
    public String listType{get;set;}
    public Integer indexVal{get;set;}
    public Boolean act{get;set;}
    public List<LOI__c> searchlist{ get; set; }
    public id loiProp;
    public string urlUnit{get;set;}
    public String loiStatus;
    private Id masId;
    public List<LOI__c> selectedloi{ get; set; }
    
    //pagination information
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
    public string dataRow{get;set;}
    
    //Sorting
    public String sortOrderLOI{get;set;}
    public String sortOrderTenant{get;set;}
    public String sortOrderProperties{get;set;}
    public String sortOrderloiStartDate{get;set;}
    public String sortOrderOgEndDate{get;set;}
    public String sortField{get;set;}
    
    public void sortByLOI(){
    	sortField = 'Name';
    	sortOrderLOI = (sortOrderLOI == 'Asc')?'Desc':'Asc';
    	this.page = 1;
    	search();
    }
    public void sortByTenant(){
    	sortField = 'Tenant__r.Name';
    	sortOrderTenant = (sortOrderTenant == 'Asc')?'Desc':'Asc';
    	this.page = 1;
    	search();
    }
    public void sortByProperties(){
    	sortField = 'Property__r.Name';
    	sortOrderProperties = (sortOrderProperties == 'Asc')?'Desc':'Asc';
    	this.page = 1;
    	search();
    }
    public void sortByloiStartDate(){
    	sortField = 'LOI_Start_Date__c';
    	sortOrderloiStartDate = (sortOrderloiStartDate == 'Asc')?'Desc':'Asc';
    	this.page = 1;
    	search();
    }
    public void sortByOgEndDate(){
    	sortField = 'LOI_End_Date__c';
    	sortOrderOgEndDate = (sortOrderOgEndDate == 'Asc')?'Desc':'Asc';
    	this.page = 1;
    	search();
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
    
    //----------------------Constructor-------------------------------------- 
    public GenerateLOIDescriptionController(){
		searchList = new List<LOI__c>();
	    loi=new loi__c();
	    loiWrap=new list<loiWrapper>();
	    loi.loi_status__c = 'Draft';
	    try{
	        String str = ApexPages.currentPage().getParameters().get('opr');
	        loi.property__c = ApexPages.CurrentPage().getParameters().get('propid');
	        loi.tenant__c = ApexPages.CurrentPage().getParameters().get('tenantId');
	        urlUnit = ApexPages.CurrentPage().getParameters().get('unitId');
	        String strDate = ApexPages.CurrentPage().getParameters().get('sDate');
	        
	        if(strDate != null){
	            List<String> dList = strDate.split('-');
	            loi.LOI_Start_Date__c = date.newInstance(integer.valueof(dList[2]),integer.valueof(dList[1]),integer.valueof(dList[0]));
	        }
	        if(str != NULL){
	            selectedLeasePlan ='Add LOI Unit';
	            act=true;
	            search();
	            
	        } else{
	            selectedLeasePlan = 'New';
	            act=false;
	        }
	    }
	    catch(Exception e){
	        system.debug(e.getMessage());
	    }
    /*loi.loi_start_date__c=date.today();
    loi.origianl_end_date__c = date.today();*/
    //searchlist=[select id,name,Tenant__c,Property__c,LOI_Status__c,LOI_Start_Date__c,LOI_End_Date__c,(select Unit__r.name from LOI_Units__r) from LOI__c  order by LastModifiedDate desc];
    }
     //------------------------------ To generate the action values-----------------------------------
    /*public List<SelectOption> getActionSelectList(){
        List<SelectOption> options = new List<SelectOption>();
        for(Manage_LOI__c loiMan : Manage_LOI__c.getall().values()){
            if (loiMan.Action__c != null && loiMan.Action__c!='Cancel') 
               // options.add(new SelectOption(loiMan.Action__c, loiMan.Comments__c));
               options.add(new SelectOption(loiMan.Action__c, loiMan.Action__c));
        }
        return options;
    }*/
   
    public pageReference ContinueGenerateLOI(){
        if(selectedLeasePlan == 'New')
            return new pageReference('/apex/generateloi');
        else if(selectedLeasePlan == 'Add LOI Unit'){
            //getWrap();
            if(loi.id != NUll)
                return new pageReference('/apex/generateloi?loiId='+loi.id);
            
            else
               Apexpages.addMessage(new ApexPages.message(ApexPages.severity.info,'Select An LOI'));
        return NULL;
        }
        else
            return null;    
    }
    public void btnSearch(){
    	sortField = null;
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
        this.searchList.clear();
        this.loiWrap.clear();
        
        doSearch();
        
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
    
    public pageReference doSearch(){
        string str='select id,name,Tenant__c,Property__c,LOI_Status__c,LOI_Start_Date__c,LOI_End_Date__c,LOI_Validity_Week__c,(select Unit__r.name from LOI_Units__r) from LOI__c where CreatedDate != null ';
        system.debug('------------------'+loi.loi_start_date__c);
        if(loi.property__c != NULL){
            str+=' And property__c=\''+loi.property__c+'\'';
        }
        
        if(loi.Tenant__c != NULL){
            str+=' AND Tenant__c =\''+loi.Tenant__c+'\'';
        }
        
        if(loi.loi_status__c != NULL){ 
            str+=' AND loi_status__c =\''+loi.loi_status__c +'\'';
        }else{
        	str+=' AND loi_status__c =\'Draft\'';
        }
        
         Date dtStt = loi.loi_start_date__c;
         Date dtend = loi.Original_End_Date__c ;
        if(loi.loi_start_date__c != NULL && loi.Original_End_Date__c!= NULL){
           str+=' AND (loi_start_date__c >=: dtStt AND loi_start_date__c <=: dtend)';
        }
        else if(loi.loi_start_date__c != NULL){
           str+=' AND loi_start_date__c >=: dtStt ';
            system.debug(loi.loi_start_date__c);
        }

         else if(loi.Original_End_Date__c!= NULL){
           str+=' AND loi_start_date__c <=: dtend ';
            system.debug(loi.loi_start_date__c);
        }
		if(sortField == null){
			str+='  order by LastModifiedDate desc LIMIT 50000';
		}else if(sortField == 'Name'){
			str+='  order by '+sortField+' '+sortOrderLOI+' LIMIT 50000';
		}else if(sortField == 'Tenant__r.Name'){
			str+='  order by '+sortField+' '+sortOrderTenant+' LIMIT 50000';
		}else if(sortField == 'Property__r.Name'){
			str+='  order by '+sortField+' '+sortOrderProperties+' LIMIT 50000';
		}else if(sortField == 'LOI_End_Date__c'){
			str+='  order by '+sortField+' '+sortOrderOgEndDate+' LIMIT 50000';
		}else if(sortField == 'LOI_Start_Date__c'){
			str+='  order by '+sortField+' '+sortOrderloiStartDate+' LIMIT 50000';
		}
           // str+='  order by LastModifiedDate desc LIMIT 50000';
            List<LOI__c> searchListSelected = new List<LOI__c>();
            try{
	            system.debug('@@@@-->'+str);
	            searchList= new List<LOI__c>();
	            searchList=Database.query(str);
	            
	            String initDataRow = '100';
	            if(!String.isBlank(dataRow))
	                initDataRow = dataRow;
	            
	            for(LOI__c loi: searchlist){
		        	if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx){
		            	searchListSelected.add(loi);
		        	}
		        	this.totalRecords++;
		        } 
            }catch(Exception e){
                system.debug('@@@@-->'+e.getMessage());
            }
            if(searchListSelected.size()>0){
                loiWrap=new list<loiWrapper>();
                system.debug('ok'+searchListSelected);
                searchList.sort();
                for(LOI__c l: searchListSelected)
                    loiWrap.add(new loiWrapper(l));
            }
            else{
                loiWrap = new List<loiWrapper>();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'No records Found'));
            }
            
            return null;
       
    }
                
    public pageReference reload(){
   
        if(selectedLeasePlan =='New')
           act=false;
        else{
        	this.page = 1;
            dataRow = '50';
             loi = new LOI__c();
             loi.loi_status__c = (loi.loi_status__c == null)?'Draft':loi.loi_status__c;
             /*searchlist=[select id,name,Tenant__c,Property__c,LOI_Status__c,LOI_Start_Date__c,LOI_End_Date__c,(select Unit__r.name from LOI_Units__r) from LOI__c where LOI_Status__c = 'Draft' order by LastModifiedDate  limit 1000  ]; 
            
            if(searchlist.size()>0){
                loiWrap=new list<loiWrapper>();
                system.debug('ok'+searchlist);
                searchList.sort();
                for(LOI__c l: searchlist)
                    loiWrap.add(new loiWrapper(l));
            }
            else{
                loiWrap = new List<loiWrapper>();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'No records Found'));
            }*/
            btnSearch();
            system.debug(searchList);
            act=true;
            //table=true;
        } 
        system.debug('act-->'+act);
        return null;
    }
  //---------------------------------------------cancellation of loi -----------------------------------------------------------------------
  /*
      public void showLoi(){
             searchlist=[select id,name,Tenant__c,Property__c,LOI_Status__c,LOI_Start_Date__c,LOI_End_Date__c,Reason_for_Termination__c
              from LOI__c where id=:loiId];
              
        }
        public pageReference cancel(){
        loi=new LOI__c(id=loiId);
        loi.LOI_Status__c='Cancelled';
        loi.Reason_for_Termination__c=remarks;
        update loi;
        return new PageReference('/' + loiId);
        }
  
  */
  public void dataRowChange(){
    	this.page = 1;
    	search();
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
     //-----------------------------------LOI List Wrapper-----------------------------
    public class loiWrapper{
        public Boolean isSelected{ get; set; }
        public LOI__c selectloi{ get; set; }
        public loiWrapper(LOI__c loi){
             isSelected=false;
             selectloi=loi;
         }
    }
    
}