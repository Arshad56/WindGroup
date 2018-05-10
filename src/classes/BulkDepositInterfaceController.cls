public class BulkDepositInterfaceController {
    public Set<String> leaseUnitIds{get;set;}
    public List<BulkLeaseUnitWrap> leaseUnitWrap{get;set;}
    public static Integer toAddRow {get;set;}
    public static Integer toDelRow {get;set;}
    public Boolean closePage {get;set;}
    public List<Deposit__c> existingDeposits{get;set;}
    public List<Deposit__c> insertDeposit;
    String fromPage{get;set;}
    Map<Id,Lease_Unit__c> mapOfLU = new Map<Id,Lease_Unit__c>();
    String LeaseName{get;set;}
    public String currencyError{get;set;}
    public String dpAmountError{get;set;}
    public String redirectId{get;set;}
    Set<String> units = new Set<String>();
    
    Id leaseId;
    Id leaseUnitId;
    Integer counter = 0 ;
    Map<String, Lease_Charges__c> mapLC = new Map<String, Lease_Charges__c>();
    
    public BulkDepositInterfaceController(){
        String selectedLeaseUnits = ApexPages.currentpage().getParameters().get('selectedLeaseUnits');
        fromPage = ApexPages.currentpage().getParameters().get('from');
        closePage = false;
        System.debug('fromPage-fromPage-->'+fromPage);
        if(fromPage == 'LeaseUnit'){
            redirectId = selectedLeaseUnits;
        }else{
            redirectId = ApexPages.currentpage().getParameters().get('leaseId');
        }
        
        
        leaseUnitIds = new Set<String>();
        if(selectedLeaseUnits!=null && selectedLeaseUnits!=''){
            List<String> strList = selectedLeaseUnits.split(',');
            for(String s : strList){
                leaseUnitIds.add(s);
            }
        }
        existingDeposits = [select id,Outstanding_Amount__c,Lease_Unit__c,Lease_Unit__r.Unit__r.name,Deposit_Formula_Type__c,Deposit_Type__c,Lease_Charge__r.Base_Rent_Calculation__c,Deposit_Amount__c,Lease_Unit__r.Lease_Start_Date__c, Lease_Unit__r.Lease_End_Date__c,Lease_Unit__r.Area_Sq_Ft__c from Deposit__c where Lease_Unit__c=: leaseUnitIds Order By Lease_Unit__c Asc];
        
        List<Lease_Charges__c> listLc = [select id,Currency_Code__c, Lease_Unit__c, Base_Rent_Calculation__c from Lease_Charges__c where Start_Date__c  != null and Lease_Unit__c =: leaseUnitIds and (Charge_Type__c = 'Rent' or Charge_Type__c = 'Advance Rental') Order By Start_Date__c Asc ];
        for(Lease_Charges__c li: listLc){
            if(!mapLC.containsKey(li.Lease_Unit__c)){
                mapLC.put(li.Lease_Unit__c, li);
            }
        }
        
        List<Lease_Unit__c> leaseUnits = [select Id ,Lease_Agreement_No__r.name, Area_Sq_Ft__c, Unit__r.name, Lease_Agreement_No__c, Lease_Start_Date__c, Lease_End_Date__c, Name from Lease_Unit__c where id =: leaseUnitIds];
        leaseUnitWrap = new List<BulkLeaseUnitWrap>();
        BulkLeaseUnitWrap bl;
        for(Lease_Unit__c l : leaseUnits){
            mapOfLU.put(l.Id,l);
            if(leaseUnitIds.size() == 1){
                bl = new BulkLeaseUnitWrap(new Deposit__c(), true);
            }else{
                bl = new BulkLeaseUnitWrap(new Deposit__c(), false);
            }
            
            units.add(l.Unit__r.Name);
            LeaseName = l.Lease_Agreement_No__r.name;
            leaseId = l.Lease_Agreement_No__c;
            if(fromPage == 'LeaseUnit'){
                leaseUnitId = l.id;
            }
            
            bl.dep.Name = '--SystemGenerated--';
            bl.dep.Lease_Unit__c = l.id;
            bl.dep.Lease__c = l.Lease_Agreement_No__c;
            
            bl.unit = l.Unit__r.name;
            bl.srNo = counter;
            bl.startDate = l.Lease_Start_Date__c;
            bl.endDate = l.Lease_End_Date__c;
            if(mapLC.containsKey(l.id)){
                if( mapLC.get(l.id).Currency_Code__c != null){
                    bl.dep.Currency_Code__c = mapLC.get(l.id).Currency_Code__c;
                }
                bl.baseRent =  mapLC.get(l.id).Base_Rent_Calculation__c;
                bl.lcCurrencyCode = mapLC.get(l.id).Currency_Code__c;
                bl.dep.Lease_Charge__c = mapLC.get(l.id).Id;
            }
            bl.areaSqFt = l.Area_Sq_Ft__c;
            leaseUnitWrap.add(bl);
            counter++;
        }
        System.debug('Con leaseUnitWrap--->'+leaseUnitWrap);
    }
    public void delRow(){
        Integer toDelPos = -1;
        toDelRow = Integer.valueOf(ApexPages.currentPage().getParameters().get('toDelRow'));
        toDelRow -= 1;
        for (Integer idx = 0; idx < leaseUnitWrap.size(); idx++) {
            leaseUnitWrap[idx].depositAmount = calDepositAmt(leaseUnitWrap[idx].areaSqFt,leaseUnitWrap[idx].dep.Deposit_Formula_Type__c,leaseUnitWrap[idx].depositRate,leaseUnitWrap[idx].noOfMonths);
            if (idx == toDelRow) {
                toDelPos = idx;
            }
        }
        if (-1 != toDelPos) {
            leaseUnitWrap.remove(toDelPos);
        }
    }
    public Decimal calDepositAmt(Decimal areaSqFt, String fType, Decimal depRate, Integer noOfMonths){
        if(fType == 'By Area'){
            return depRate * noOfMonths * areaSqFt;
        }else{
            return depRate * noOfMonths;
        }
    }
    public void addRow() {
        System.debug('leaseUnitWrap--->'+leaseUnitWrap);
      Integer tempCount = 0;
         toAddRow = Integer.valueOf(ApexPages.currentPage().getParameters().get('toAddRow'));
         System.debug('toAddRow--->'+toAddRow);
        BulkLeaseUnitWrap objWrapper = new BulkLeaseUnitWrap(new Deposit__c(), false);
        //lstWrapper.add(objWrapper);
        List<BulkLeaseUnitWrap> newList = new List<BulkLeaseUnitWrap>();
        for(Integer i = 0; i < toAddRow; i++) {
            newList.add(leaseUnitWrap[i]);
            leaseUnitWrap[i].depositAmount = calDepositAmt(leaseUnitWrap[i].areaSqFt,leaseUnitWrap[i].dep.Deposit_Formula_Type__c,leaseUnitWrap[i].depositRate,leaseUnitWrap[i].noOfMonths);
            //objWrapper = leaseUnitWrap[i];
            IF(i == (toAddRow - 1)){
            objWrapper.dep.Lease_Unit__c = leaseUnitWrap[i].dep.Lease_Unit__c;
            objWrapper.dep.Lease_Charge__c = leaseUnitWrap[i].dep.Lease_Charge__c;
            objWrapper.dep.Lease__c = leaseUnitWrap[i].dep.Lease__c;
            objWrapper.unit = leaseUnitWrap[i].unit;
            //objWrapper.dep.Currency_Code__c = leaseUnitWrap[i].dep.Currency_Code__c;
            objWrapper.startDate = leaseUnitWrap[i].startDate;
            objWrapper.endDate = leaseUnitWrap[i].endDate;
            objWrapper.baseRent = leaseUnitWrap[i].baseRent;
            objWrapper.lcCurrencyCode =  leaseUnitWrap[i].lcCurrencyCode;
            objWrapper.areaSqFt = leaseUnitWrap[i].areaSqFt;
            
                IF(leaseUnitWrap[i].dep.Deposit_Formula_Type__c == 'By Base Rent'){
                    objWrapper.dep.Deposit_Formula_Type__c = leaseUnitWrap[i].dep.Deposit_Formula_Type__c;
                    objWrapper.depositRate = leaseUnitWrap[i].depositRate;
                    objWrapper.depositAmount = leaseUnitWrap[i].depositRate;
                    objWrapper.dep.Currency_Code__c = leaseUnitWrap[i].dep.Currency_Code__c;
                }
            }
        }
        newList.add(objWrapper);
        for(Integer i = toAddRow; i < leaseUnitWrap.size(); i++) {
            newList.add(leaseUnitWrap[i]);
            leaseUnitWrap[i].depositAmount = calDepositAmt(leaseUnitWrap[i].areaSqFt,leaseUnitWrap[i].dep.Deposit_Formula_Type__c,leaseUnitWrap[i].depositRate,leaseUnitWrap[i].noOfMonths);
            
        }
        leaseUnitWrap = newList;
    }
    
    public void save(){
        currencyError = null;
        dpAmountError = null;
        insertDeposit = new List<Deposit__c>();
        
        Deposit__c dd;
        Boolean isBlank = false;
        set<Id> leaseUnitIds = new set<Id>();
        for(BulkLeaseUnitWrap wl : leaseUnitWrap){
            wl.dpTEmpty = false;
            wl.dpFTEmpty = false;
            wl.dpCCEmpty = false;
            if(wl.dep.Deposit_Formula_Type__c == null){
                wl.dpFTEmpty = true;
                isBlank = true;
            }
            if(wl.dep.Currency_Code__c == null){
                wl.dpCCEmpty = true;
                isBlank = true;
            }else{
                if(wl.lcCurrencyCode != wl.dep.Currency_Code__c && wl.dep.Deposit_Formula_Type__c == 'By Base Rent'){
                    wl.dpCCEmpty = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Currency Code should be in synch with Base Rent Currency.'));
                    isBlank = true;
                    currencyError = 'Currency Code should be in synch with Base Rent Currency.';
                } 
            }
            if(wl.dep.Deposit_Type__c == null){
                wl.dpTEmpty = true;
                isBlank = true;
            }
            
            wl.depositAmount = calDepositAmt(wl.areaSqFt,wl.dep.Deposit_Formula_Type__c,wl.depositRate,wl.noOfMonths);
            if(wl.depositAmount == 0){
                dpAmountError = 'Deposit amount cannot be zero.';
                isBlank = true;
            }
            dd = new Deposit__c();
            dd = wl.dep;
            
            dd.Deposit_Rate__c = wl.depositRate;
            dd.Number_of_Months__c = wl.noOfMonths;
            dd.Deposit_Date__c = System.today();
            dd.Deposit_Generated__c = true;
            dd.Deposit_Amount__c = wl.depositAmount;
            dd.Status__c = 'Outstanding';
            dd.Description__c = 'Refundable '+dd.Deposit_Type__c+' Deposit';
            insertDeposit.add(dd);
            if(dd.Lease_Unit__c != null){
                leaseUnitIds.add(dd.Lease_Unit__c);
            }
        }
        if(!isBlank){
            try{
                checkRecursive.runDepositOnce();
                System.debug(insertDeposit.size()+'insertDeposit-->'+insertDeposit);
                MainDepositTrigger_Helper.generateDPName(leaseUnitIds,insertDeposit);
                insert insertDeposit;
                closePage = true;
            }catch(Exception e){
                System.debug('Exception Occured--> '+ e);
            }
        }
        System.debug('closePageclosePageclosePage-->'+closePage);
    }
    public void generateDepositPDF(){ 
        if(closePage){
                 System.debug('generating PDF-->'+closePage);
                /*Datetime myDT = Datetime.now();
                String stdt = myDT.format('YYYYMM-ddHHmm');
                List<Attachment> listattach = new List<Attachment>();
                
                Set<Id> idsTest = new Set<Id>();
                String insertedIds='';
                for(Deposit__c ii : insertDeposit){
                    Attachment attInsertLease = new Attachment();
                    Attachment attInsertLeaseUnit = new Attachment();
                    Attachment attInsertDeposit = new Attachment();
                    attInsertLease.name= ii.Name+'-'+mapOfLU.get(ii.Lease_Unit__c).Unit__r.name+'-';
                    attInsertLease.name += ii.Deposit_Type__c; 
                    
                    //attInsertLease.name = attInsertLease.name.substring(0, attInsertLease.name.length()-1);
                    attInsertLease.name += '-'+stdt+'.PDF';
                    attInsertLease.ParentId = ii.Lease__c;
                    Blob body;
                    PageReference pdf = new PageReference('/apex/DepositPDF?depositId='+ii.Id);
                    if(Test.isRunningTest()){
                        body = blob.valueOf('Test');
                    }else{ 
                        body = pdf.getContentAsPDF();
                    }
                   attInsertLease.Body = body;
                   attInsertLease.IsPrivate = false;
                   attInsertLease.contentType = 'application/pdf';
                   listattach.add(attInsertLease);
                   
                   attInsertLeaseUnit.ParentId = ii.Lease_Unit__c;
                   attInsertLeaseUnit.Name = attInsertLease.Name;
                   attInsertLeaseUnit.Body = attInsertLease.Body;
                   attInsertLeaseUnit.IsPrivate = attInsertLease.IsPrivate;
                   attInsertLeaseUnit.contentType = attInsertLease.contentType ;
                   listattach.add(attInsertLeaseUnit);
                   
                   attInsertDeposit.ParentId = ii.id;
                   attInsertDeposit.Name = attInsertLease.Name;
                   attInsertDeposit.Body = attInsertLease.Body;
                   attInsertDeposit.IsPrivate = attInsertLease.IsPrivate;
                   attInsertDeposit.contentType = attInsertLease.contentType ;
                   listattach.add(attInsertDeposit);
                }
                System.debug('listattach size-->'+listattach.size());
                System.debug('listattach-->'+listattach);
               try{
                 insert listattach;
               }catch(Exception e){
                    System.debug('Exception Occured--> '+ e);
               }*/
               if(Test.isRunningTest()){
                    checkRecursive.runOnce();
                    checkRecursive.runAlready();
                    checkRecursive.makeRunTrue();
               }
        }
    }
     public class BulkLeaseUnitWrap {
        public Integer srNo{get;set;}
        public Deposit__c dep {get;set;}
        public Boolean defaultRec {get;set;}
        public String lcCurrencyCode{get;set;}
        public Decimal baseRent {get;set;}
        public Decimal areaSqFt {get;set;}
        public Decimal depositRate {get;set;}
        public Integer noOfMonths{get;set;}
        public Decimal depositAmount {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        public String unit{get;set;}
        public Boolean dpTEmpty{get;set;}
        public Boolean dpFTEmpty{get;set;}
        public Boolean dpCCEmpty{get;set;}
        public BulkLeaseUnitWrap(Deposit__c d, Boolean def) {
            dep = d;
            defaultRec = def;
            baseRent = 0.00;
            lcCurrencyCode = '';
            areaSqFt = 0.00;
            depositRate = 0.00;
            noOfMonths = 1;
            depositAmount = 0.00;
        }
    }
}