global class LeasePlanDailyController {
    public Map<Id,Boolean> unitChecked{get;set;}
    public Transient  List<MainWrapper> mainWrapper{get;set;}
    public Transient  List<MainWrapper> dailyWrapper{get;set;}
    public Transient  List<MainWrapper> monthlyLWrapper{get;set;}
    public List<LPStructure> lpWrapper{get;set;}
    public Boolean showInterface{get;set;}
    public Boolean showUnitDiv{get;set;}
    public String selectedUnit{get;set;} 
    List<Units__c> listUnit;
    Set<String> ids;
    Map<Id,List<Lease_Charges__c>> LeaseChargeWithIds;
    public Integer currentYear{get;set;}
    Map<Integer,String> monthMap{get;set;}
    public Units__c unitUI{get;set;}
    public Lease_Plan__c leasePlanUI{get;set;}
    Integer totalDays;
            
    public String selectedYear{get;set;} 
    
    
    @RemoteAction
    global static boolean checkUnit(string unitIds,string chargeMethod){        
        Boolean isError = false;
        if(unitIds!=null){
            unitIds = unitIds.replace('[','');
            unitIds = unitIds.replace(']','');
            unitIds = unitIds.replace(' ','');
            List<Id> unitIdList = unitIds.split(',');
            for(Units__c un:[Select id,Charge_Method__c from Units__c where id in:unitIdList]){
                if(un.Charge_Method__c==null || !un.Charge_Method__c.contains(chargeMethod)){
                    isError = true;
                    break;
                }
            }            
        }
        return isError;
    }
    
    public List<SelectOption> getYearOptions(){
        List < SelectOption > options = new List < SelectOption > ();
        Integer tempYear = System.today().year() - 7;
        for(Integer i=0; i<=10;i++){
            options.add(new SelectOption(++tempYear+'', tempYear+''));
        }
        return options;
    }
    public String selectedMonth{get;set;} 
    public List<SelectOption> getMonthOptions(){
        List < SelectOption > options = new List < SelectOption > ();
        System.debug('monthMap--> '+monthMap);
        for(Integer str:monthMap.KeySet()){
            options.add(new SelectOption(str+'',monthMap.get(str)));
        }
        return options;
    }
    public String selectedSpaceType{get;set;} 
    public List<SelectOption> getSpaceTypeOptions(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =   Units__c.Space_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('All','All'));     
        for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }
    public List<SelectOption> getStatusOptions(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =   Lease_Plan__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('All','All'));     
        for( Schema.PicklistEntry f : ple){
        	if(f.getValue() != 'N/A' && f.getValue() != 'Fitout')
        	  options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }
    public static String getCents(Decimal x){
        String y = String.valueOf(x);
        String z = '.';
        if(y.contains(',')) z = ',';
        y = y.substring(0, y.indexOf(z));
        if(x - Decimal.valueOf(y) == 0)
            return String.valueOf(x.format()) + z + '00';
        else return String.valueOf(x.format());
    }
    public static String FormatNumber(Decimal value){
        String[]  suffixes = new String[]{'k', 'm', 'b', 't', 'q'};
        for (Integer j = suffixes.size();  j > 0;  j--)
            {
            double  unit = Math.Pow(1000, j);
            if (value >= unit)
                return LeasePlanDailyController.getCents((value / unit).setScale(2)) + suffixes[--j];
            }
        return LeasePlanDailyController.getCents(value.setScale(2));
    }
    
    public static String doFormatting(Decimal val, integer dec, String tSep, String dSep) {
        String s, tmp;
        Integer i = 4 + dec;
        if(dec==0) i--;
        s = val.setScale(dec).toPlainString().replace(tSep, dSep);
        while(s.length() > i) {
            tmp = s.substring(0, s.length() - i) + tSep + s.substring(s.length() - i);
            s = tmp;
            i += 4;
        }
        // If the number is negative and has a number non-decimal digits divisible by 3, it prevents putting a comma before the 1st digit (ex -300,000.00  comes out -,300,000.00)
        if (s.substring(0,1) == '-') 
            if (s.substring(1,2) == tSep) 
                s = '-' + s.substring(2);
        return s;
    }
    public LeasePlanDailyController(){
        leasePlanUI= new Lease_Plan__c();
        unitUI = new Units__c();
        ids = new Set<String>();
        unitChecked = new Map<Id,Boolean>();
        
        mainWrapper = new List<MainWrapper>();
        lpWrapper = new List<LPStructure>();
        
        dailyWrapper = new List<MainWrapper>();
        monthlyLWrapper = new List<MainWrapper>();
        
        monthMap= new Map<Integer,String>();
        
        monthMap.put(1,'Jan'); 
        monthMap.put(2,'Feb');
        monthMap.put(3,'Mar');
        monthMap.put(4,'Apr');
        monthMap.put(5,'May');
        monthMap.put(6,'Jun');
        monthMap.put(7,'Jul');
        monthMap.put(8,'Aug');
        monthMap.put(9,'Sep');
        monthMap.put(10,'Oct');
        monthMap.put(11,'Nov');
        monthMap.put(12,'Dec');
        
        System.debug('monthMap11--> '+monthMap);
        selectedYear = System.Today().Year()+'';
        selectedMonth = System.Today().Month()+'';
        totalDays = 0; 
    }
    
    public void Generate(){
        Integer selectedMonth1cc = Integer.valueof(selectedMonth);
        Integer selectedYear1cc  = Integer.valueof(selectedYear);
        
        Integer selectedMonth2cc = Integer.valueof(selectedMonth);
        Integer selectedYear2cc  = Integer.valueof(selectedYear);
        if(selectedMonth1cc == 12){
            selectedYear2cc++;
            selectedMonth2cc =1;
        }else{
            selectedMonth2cc++;
        }
        
        System.debug('Selected Month--> '+selectedMonth);
        Integer total1stMonthDays = Date.daysInMonth(selectedMonth1cc , selectedMonth1cc);
        Integer total2ndMonthDays = Date.daysInMonth(selectedYear2cc , selectedMonth2cc);
        
        mainWrapper = new List<MainWrapper>();
        lpWrapper = new List<LPStructure>();
        
        dailyWrapper = new List<MainWrapper>();
        monthlyLWrapper = new List<MainWrapper>();
        
        showInterface = false;
        showUnitDiv = false;
        if(unitUI.Property__c != null){
            currentYear = Integer.valueof(selectedYear);

            mainWrapper = new List<MainWrapper>();
            lpWrapper = new List<LPStructure>();
            
            date myDate = date.newInstance(selectedYear1cc, selectedMonth1cc, 1);
            date endDate = date.newInstance(selectedYear2cc, selectedMonth2cc+1, 1);
            
            date startDateOfLP = date.newInstance(selectedYear1cc, selectedMonth1cc, 1);
            date endDateOfLP = date.newInstance(selectedYear2cc, selectedMonth2cc, Date.daysInMonth(selectedYear2cc, selectedMonth2cc));
            
            Set<Id> displayUnits = new Set<Id>();
            String  soqlQueryUnit = 'select Id,Name,Start_Date__c,End_Date__c,Property__r.Short_Code__c,'
                                    +'Space_Type__c,Charge_Method__c,'
                                    +'Rent_Hurdle_1__c,Rent_Hurdle_2__c,Rent_Hurdle_3__c,Unique_Selling_Point__c,'
                                    +'(Select Id, Tenant__c, Lease_Start_Date__c, Lease_End_Date__c From Lease_Units__r),'+
                                    +'(Select Id, Tenant__c, LOI_Start_Date__c, LOI_End_Date__c From LOI_Units__r),'+
                                    +'(Select Id, Name, Account_Name__r.Name, Commencement_Date__c, Expiry_Date__c,Enquiry_Date__c From Expression_of_Interest__r  Order By Enquiry_Date__c Desc )'                                    
                                    +' from Units__c where CreatedDate != null And Active__c = true And Charge_Method__c INCLUDES (\'Daily Rate\', \'Monthly Rate - CL\')';
            if(unitUI.Property__c != null){
                soqlQueryUnit += ' And Property__c = \''+unitUI.Property__c+'\'';
            }
            if(unitUI.Level__c != null){
                soqlQueryUnit += ' And Level__c =  \''+unitUI.Level__c+'\'';
            }
            if(selectedSpaceType != 'All'){
                soqlQueryUnit += ' And Space_Type__c =  \''+selectedSpaceType+'\'';
            }
            soqlQueryUnit += ' Order By Level__c,Name Asc';
            System.debug('soqlQueryUnit--> '+soqlQueryUnit);
            listUnit = database.query(soqlQueryUnit);
            if(listUnit.size() > 0){
                Set<Id> idUnits = new Set<Id>();
                for(Units__c lu:listUnit){
                    idUnits.add(lu.Id);
                }
                System.debug('idUnits.size()-->'+idUnits.size());
                String lpSOQL = 'select Id,Unit__c,Unit__r.name,Commited__c,Vacant__c,Status__c,LOI__c from Lease_Plan__c where  Start_Date__c != null And End_Date__c != null And Unit__c =: idUnits';
                if(leasePlanUI.Status__c != 'All'){
                    lpSOQL += ' And (Status__c  = \''+ leasePlanUI.Status__c +'\'';
                    if(leasePlanUI.Status__c == 'Committed'){
                    	lpSOQL += ' OR (Commited__c  =  true And LOI__c  =  false ) ) ';
                    }else if(leasePlanUI.Status__c == 'LOI'){
                    	lpSOQL += ' OR (Commited__c  =  false And LOI__c  =  true ) ) ';
                    }else{
                    	lpSOQL += ' ) ';
                    }
                }
                lpSOQL += ' And Start_Date__c >= '+string.valueOf(myDate)+' And End_Date__c < '+string.valueOf( endDate)+' Order By Start_Date__c Asc';
                System.debug('lpSOQL-->'+lpSOQL);
                List<Lease_Plan__c> tempLPforUnitIds = database.query(lpSOQL);
                System.debug(tempLPforUnitIds.size() +'  tempLPforUnitIds-->'+tempLPforUnitIds);
                idUnits = new Set<Id>();
                for(Lease_Plan__c lp:tempLPforUnitIds){
                	if(!idUnits.contains(lp.Unit__c)){
                		if(leasePlanUI.Status__c == 'All'){
                			idUnits.add(lp.Unit__c);
                		}else{
	                		if(lp.Status__c == leasePlanUI.Status__c){
			            		idUnits.add(lp.Unit__c);
			            		System.debug(lp.Unit__c+' '+ lp.Unit__r.name+ ' lp Id--> '+lp.Id +' lp.Status__c-->'+lp.Status__c);
			            	}else if(leasePlanUI.Status__c == 'Committed'){
			            		if(lp.Vacant__c && lp.Commited__c && !lp.LOI__c){
			            			idUnits.add(lp.Unit__c);
			            			System.debug(lp.Unit__c + 'lp Id-->'+lp.Unit__c +'lp.Status__c-->'+lp.Status__c);
			            		}
			            	}
                		}
                	}
                } 
                System.debug('idUnits.size()-->'+idUnits.size());
                String  soqlQueryLP = 'select Commited__c,Vacant__c,Status_1__c,Status_2__c,Status_3__c,Status_4__c,Status_5__c,Status_6__c,'
                                        +'Day_1__c,Day_2__c,Day_3__c,Day_4__c,Day_5__c,'
                                        +'Day_6__c,Day_7__c,Day_8__c,Day_9__c,Day_10__c,'
                                        +'Day_11__c,Day_12__c,Day_13__c,Day_14__c,Day_15__c,'
                                        +'Day_16__c,Day_17__c,Day_18__c,Day_19__c,Day_20__c,'
                                        +'Day_21__c,Day_22__c,Day_23__c,Day_24__c,Day_25__c,Day_26__c,'
                                        +'Day_27__c,Day_28__c,Day_29__c,Day_30__c,Day_31__c,'
                                        +'Status_7__c,Status_8__c,Status_9__c,Status_10__c,'
                                        +'Status_11__c,Status_12__c,Status_13__c,Status_14__c,Status_15__c,'
                                        +'Status_16__c,Status_17__c,Status_18__c,Status_19__c,Status_20__c,'
                                        +'Status_21__c,Status_22__c,Status_23__c,Status_24__c,Status_25__c,'
                                        +'Status_26__c,Status_27__c,Status_28__c,Status_29__c,Status_30__c,Status_31__c,'
                                        +'Daily_Rate_1__c,Daily_Rate_2__c,Daily_Rate_3__c,Daily_Rate_4__c,Daily_Rate_5__c,Daily_Rate_6__c,'
                                        +'Daily_Rate_7__c,Daily_Rate_8__c,Daily_Rate_9__c,Daily_Rate_10__c,'
                                        +'Daily_Rate_11__c,Daily_Rate_12__c,Daily_Rate_13__c,Daily_Rate_14__c,Daily_Rate_15__c,'
                                        +'Daily_Rate_16__c,Daily_Rate_17__c,Daily_Rate_18__c,Daily_Rate_19__c,Daily_Rate_20__c,'
                                        +'Daily_Rate_21__c,Daily_Rate_22__c,Daily_Rate_23__c,Daily_Rate_24__c,Daily_Rate_25__c,'
                                        +'Daily_Rate_26__c,Daily_Rate_27__c,Daily_Rate_28__c,Daily_Rate_29__c,Daily_Rate_30__c,Daily_Rate_31__c,'
                                        +'Daily_Committed_Rate_1__c,Daily_Committed_Rate_2__c,Daily_Committed_Rate_3__c,Daily_Committed_Rate_4__c,Daily_Committed_Rate_5__c,Daily_Committed_Rate_6__c,'
                                        +'Daily_Committed_Rate_7__c,Daily_Committed_Rate_8__c,Daily_Committed_Rate_9__c,Daily_Committed_Rate_10__c,'
                                        +'Daily_Committed_Rate_11__c,Daily_Committed_Rate_12__c,Daily_Committed_Rate_13__c,Daily_Committed_Rate_14__c,Daily_Committed_Rate_15__c,'
                                        +'Daily_Committed_Rate_16__c,Daily_Committed_Rate_17__c,Daily_Committed_Rate_18__c,Daily_Committed_Rate_19__c,Daily_Committed_Rate_20__c,'
                                        +'Daily_Committed_Rate_21__c,Daily_Committed_Rate_22__c,Daily_Committed_Rate_23__c,Daily_Committed_Rate_24__c,Daily_Committed_Rate_25__c,'
                                        +'Daily_Committed_Rate_26__c,Daily_Committed_Rate_27__c,Daily_Committed_Rate_28__c,Daily_Committed_Rate_29__c,Daily_Committed_Rate_30__c,Daily_Committed_Rate_31__c,'
                                        +'Daily_LOI_Rate_1__c,Daily_LOI_Rate_2__c,Daily_LOI_Rate_3__c,Daily_LOI_Rate_4__c,Daily_LOI_Rate_5__c,Daily_LOI_Rate_6__c,'
										+'Daily_LOI_Rate_7__c,Daily_LOI_Rate_8__c,Daily_LOI_Rate_9__c,Daily_LOI_Rate_10__c,'
										+'Daily_LOI_Rate_11__c,Daily_LOI_Rate_12__c,Daily_LOI_Rate_13__c,Daily_LOI_Rate_14__c,Daily_LOI_Rate_15__c,'
										+'Daily_LOI_Rate_16__c,Daily_LOI_Rate_17__c,Daily_LOI_Rate_18__c,Daily_LOI_Rate_19__c,Daily_LOI_Rate_20__c,'
										+'Daily_LOI_Rate_21__c,Daily_LOI_Rate_22__c,Daily_LOI_Rate_23__c,Daily_LOI_Rate_24__c,Daily_LOI_Rate_25__c,'
										+'Daily_LOI_Rate_26__c,Daily_LOI_Rate_27__c,Daily_LOI_Rate_28__c,Daily_LOI_Rate_29__c,Daily_LOI_Rate_30__c,Daily_LOI_Rate_31__c,'
                                        +'Start_Date__c, End_Date__c , Unit__c, Monthly_Budget__c,LOI_Monthly_Budget__c,Monthly_Committed_Budget__c, Status__c,Unit__r.NLA_SQF__c,'
                                        +'Lease_Unit__c,Lease_Unit__r.Lease_Agreement_No__c,Lease_Unit__r.Lease_Agreement_No__r.Lease_Status__c,'
                                        +'LOI_Unit__c,LOI_Unit__r.LOI_Agreement_No__c,LOI_Unit__r.LOI_Agreement_No__r.LOI_Status__c,'
                                        +'Rent_Hurdle__c from Lease_Plan__c where Start_Date__c != null And End_Date__c != null';
                soqlQueryLP += ' And Unit__c =: idUnits';
                soqlQueryLP += ' And Start_Date__c >= '+string.valueOf(myDate)+' And End_Date__c < '+string.valueOf( endDate)+' Order By Start_Date__c Asc';
                List<Lease_Plan__c> listLP = database.query(soqlQueryLP);
                System.debug('soqlQueryLP--> '+soqlQueryLP);
                System.debug('listLP--> '+listLP);
                
                for(Integer i=1; i<= total1stMonthDays ; i++){
                    LPStructure lpr= new LPStructure();
                    Datetime newDate = Datetime.newInstance(selectedYear1cc, selectedMonth1cc, i);
                    lpr.headerDaily = newDate.format('EEEE').substring(0,3)+'<br/>'+i+'-'+monthMap.get(newDate.Month());
                    lpWrapper.add(lpr);
                }
                for(Integer i=1; i<= total2ndMonthDays ; i++){
                    LPStructure lpr= new LPStructure();
                    Datetime newDate = Datetime.newInstance(selectedYear2cc, selectedMonth2cc, i);
                    lpr.headerDaily = newDate.format('EEEE').substring(0,3)+'<br/>'+i+'-'+monthMap.get(newDate.Month());
                    lpWrapper.add(lpr); 
                }
                
                Map<Id, List<Lease_Plan__c>> listOfMPLp= new Map<Id, List<Lease_Plan__c>>();
                Set<Id> leaseUnitIds = new Set<Id>();
                LeaseChargeWithIds = new Map<Id,List<Lease_Charges__c>>();
                for(Lease_Plan__c ls: listLP){
                	
                	if(ls.Unit__c != null){
                        displayUnits.add(ls.Unit__c);
                    }
                    if(ls.Lease_Unit__c != null){
                        leaseUnitIds.add(ls.Lease_Unit__c);
                    }
                    if(ls.Rent_Hurdle__c == null){
                        ls.Rent_Hurdle__c = 0;
                    }
                    if(ls.Unit__r.NLA_SQF__c == null){
                        ls.Unit__r.NLA_SQF__c = 0;
                    }
                    if(ls.Monthly_Budget__c == null){
                        ls.Monthly_Budget__c = 0;
                    }
                    if(ls.LOI_Monthly_Budget__c == null){
                        ls.LOI_Monthly_Budget__c = 0;
                    }
                    if(ls.Monthly_Committed_Budget__c == null){
                        ls.Monthly_Committed_Budget__c = 0;
                    }
                    
                    if(listOfMPLp.containsKey(ls.Unit__c)) {
                        List<Lease_Plan__c> tempLpList = listOfMPLp.get(ls.Unit__c);
                        tempLpList.add(ls);
                        listOfMPLp.put(ls.Unit__c, tempLpList);
                    } else {
                        listOfMPLp.put(ls.Unit__c, new List<Lease_Plan__c> { ls });
                    }
                }
                List<Lease_Charges__c> lcList = [select id,Currency_Code__c, Lease_Unit__c, Base_Rent_Calculation__c,Start_Date__c,End_Date__c from Lease_Charges__c where Start_Date__c  != null and Lease_Unit__c =: leaseUnitIds and (Charge_Type__c = 'Rent' or Charge_Type__c = 'Advance Rental') Order By Start_Date__c Asc ];
                System.debug('clcList-->'+lcList.size());
                System.debug('clcList-->'+lcList);
                for(Lease_Charges__c lc: lcList){
                    if(LeaseChargeWithIds.containsKey(lc.Lease_Unit__c)) {
                        List<Lease_Charges__c> templc = LeaseChargeWithIds.get(lc.Lease_Unit__c);
                        templc.add(lc);
                        LeaseChargeWithIds.put(lc.Lease_Unit__c, templc);
                    } else {
                        LeaseChargeWithIds.put(lc.Lease_Unit__c, new List<Lease_Charges__c> { lc });
                    }
                }
                Map<Id,List<Lease_Unit__c>> unitIdwithLUs = new Map<Id,List<Lease_Unit__c>>();
                for(Units__c lu:listUnit){
                    unitChecked.put(lu.Id, false);
                    
                    MainWrapper mw =new MainWrapper();
                    mw.unit = lu;
                   // Integer c = 0;
                    for(Expression_of_Interest__c eoi:lu.Expression_of_Interest__r){
                        if(eoi.Commencement_Date__c != null && eoi.Expiry_Date__c != null){
                            if(startDateOfLP <= eoi.Expiry_Date__c && eoi.Commencement_Date__c <= endDateOfLP){
                                mw.eoiCount++;
                                if(mw.eoiCount <=5 ){
	                                String stdt = DateTime.newInstance(eoi.Commencement_Date__c.year(),eoi.Commencement_Date__c.month(),eoi.Commencement_Date__c.day()).format('d/MM/YYYY');
	                                String endt = DateTime.newInstance(eoi.Expiry_Date__c.year(),eoi.Expiry_Date__c.month(),eoi.Expiry_Date__c.day()).format('d/MM/YYYY');
	                                if(mw.eoiAccInfo != '')
	                                	mw.eoiAccInfo += ' PPPPP '; 
	                                mw.eoiAccInfo += '<b>'+eoi.Account_Name__r.Name+'</b> PPPPP from '+stdt+' to '+endt+' PPPPP ';
                                }
                            }
                        }
                    }
                    //Generate Wrapper Upper Part in Table with Units and Empty LP
                    for(Integer i=1; i<= total1stMonthDays ; i++){
                        LPStructure tt = new LPStructure();
                        tt.cellIndex = i;
                        tt.colSpan = 1;
                        mw.lpstr.add(tt);
                    }
                    for(Integer i=1; i<= total2ndMonthDays ; i++){
                        LPStructure tt = new LPStructure();
                        tt.cellIndex = i;
                        tt.colSpan = 1;
                        mw.lpstr.add(tt);
                    }
                    
                    System.debug('listOfMPLp.containsKey(lu.Id)=='+listOfMPLp.containsKey(lu.Id));
                    if(listOfMPLp.containsKey(lu.Id)){
                        Decimal totalMnthBdgt=0;
                        Decimal totalNLA=0;
                        Integer preColSpan;
                        Boolean LOICancelled = false;
                        Boolean LACancelled = false;
                        Lease_Plan__c preLpp = new Lease_Plan__c();
                        Integer i = 0;
                        System.debug('lu.Id=='+lu.Id);
                        for(Lease_Plan__c lpp:listOfMPLp.get(lu.Id)){
                        	LOICancelled = false;
							LACancelled = false;
							
							String strLOIStat = lpp.LOI_Unit__r.LOI_Agreement_No__r.LOI_Status__c;
							String strLAStat =  lpp.Lease_Unit__r.Lease_Agreement_No__r.Lease_Status__c;
							if( strLOIStat == 'Cancelled'){
								LOICancelled = true;
							} 
							if( strLAStat == 'Cancelled'){
								LACancelled = true;
							}
							System.debug(lpp.id + ' LOICancelled ==> '+strLOIStat+' '+LOICancelled +' '+ LACancelled +' ' + strLAStat);
                            i++;
                            LPStructure str = new LPStructure();
                            if(lpp.Start_Date__c.month() == selectedMonth1cc){
                                for(Integer j=1; j<= total1stMonthDays ; j++){
                                    lpp.get('Day_'+j+'__c');
                                    str = new LPStructure();
                                    
                                    str.cellIndex = j-1;
                                    str.leasePlan = lpp;
                                    str.Status = (String) lpp.get('Status_'+j+'__c');
                                    
                                    str.dailyRate = (Decimal) lpp.get('Daily_Rate_'+j+'__c');
                                    str.dailyCommittedRate = (Decimal) lpp.get('Daily_Committed_Rate_'+j+'__c');
                                    str.dailyLOIRate = (Decimal) lpp.get('Daily_LOI_Rate_'+j+'__c');
                                    
                                    if(str.dailyRate == null)
                                        str.dailyRate = 0.00;
                                    if(str.dailyLOIRate == null)
                                    	str.dailyLOIRate = 0;
                                    if(str.dailyCommittedRate == null)
                                    	str.dailyCommittedRate = 0;
                                    	
                                    str.dailyCommittedRate = str.dailyCommittedRate.setScale(2);
                                    str.dailyCommittedRateSTR = LeasePlanDailyController.FormatNumber(str.dailyCommittedRate);
                                    str.dailyCommittedRateSTRformatted = LeasePlanDailyController.doFormatting(str.dailyCommittedRate, 2, ',', '.');
                                    
                                    str.dailyLOIRate = str.dailyLOIRate.setScale(2);
                                    str.dailyLOIRateSTR = LeasePlanDailyController.FormatNumber(str.dailyLOIRate);
                                    str.dailyLOIRateSTRformatted = LeasePlanDailyController.doFormatting(str.dailyLOIRate, 2, ',', '.');
                                    
                                    /* Assign Loi Monthly Budget and Monthly Committed budget
                                    */
                                    str.loiMonthlyBudget = (Decimal) lpp.get('LOI_Monthly_Budget__c');
                                    str.monthlyCommBudget = (Decimal) lpp.get('Monthly_Committed_Budget__c');
                                    str.monthlyBudget = (Decimal) lpp.get('Monthly_Budget__c');
                                    
                                    if(mw.unit.Charge_Method__c != null){
                                    	if(mw.unit.Charge_Method__c.contains('Daily Rate')){
                                    		if(str.Status == 'Committed'){
	                                    		mw.laRent += (str.dailyCommittedRate!=null)?str.dailyCommittedRate:0;
		                                    }
		                                    if(str.Status == 'LOI'){
		                                    	mw.loiRent += (str.dailyLOIRate!=null)?str.dailyLOIRate:0;
		                                    }
                                    	}else if(mw.unit.Charge_Method__c.contains('Monthly Rate - CL')){
                                    		if(str.Status == 'Committed'){
	                                    		mw.laRent = (lpp.Monthly_Committed_Budget__c!=null)?lpp.Monthly_Committed_Budget__c:0;
		                                    }
		                                    if(str.Status == 'LOI'){
		                                    	mw.loiRent = (lpp.LOI_Monthly_Budget__c!=null)?lpp.LOI_Monthly_Budget__c:0;
		                                    }
                                    	}
	                                    
	                                    mw.loiRent = mw.loiRent.SetScale(2);
				                        mw.loiRentSTRformatted = LeasePlanDailyController.doFormatting(mw.loiRent, 2, ',', '.');
										mw.loiRentSTR = LeasePlanDailyController.FormatNumber(mw.loiRent);
										
										mw.laRent = mw.laRent.SetScale(2);
										mw.laRentSTRformatted = LeasePlanDailyController.doFormatting(mw.laRent, 2, ',', '.');
										mw.laRentSTR = LeasePlanDailyController.FormatNumber(mw.laRent);
				                        
                                    }
			                        
                                    if(str.loiMonthlyBudget == null)
                                    	str.loiMonthlyBudget = 0;
                                    if(str.monthlyCommBudget == null)
                                    	str.monthlyCommBudget = 0;
                                    if(str.monthlyBudget == null)
                                    	str.monthlyBudget = 0;

									str.loiMonthlyBudgetSTRformatted = LeasePlanDailyController.FormatNumber(str.loiMonthlyBudget);
									str.loiMonthlyBudgetSTR= LeasePlanDailyController.doFormatting(str.loiMonthlyBudget, 2, ',', '.');
									
									str.monthlyCommBudgetSTRformatted = LeasePlanDailyController.FormatNumber(str.monthlyCommBudget);
									str.monthlyCommBudgetSTR= LeasePlanDailyController.doFormatting(str.monthlyCommBudget, 2, ',', '.');
									
									str.monthlyBudgetSTRformatted = LeasePlanDailyController.FormatNumber(str.monthlyBudget);
									str.monthlyBudgetSTR= LeasePlanDailyController.doFormatting(str.monthlyBudget, 2, ',', '.');
									
                                    str.dailyRate = str.dailyRate.setScale(2);
                                    str.dailyRateSTR = LeasePlanDailyController.FormatNumber(str.dailyRate);
                                    str.dailyRateSTRformatted = LeasePlanDailyController.doFormatting(str.dailyRate, 2, ',', '.');
                                    
                                    /* --------------------------------------------------------------
                                    */
                                    str.colSpan = 1;
                                    //String stdt = DateTime.newInstance(lpp.Start_Date__c.year(),lpp.Start_Date__c.month(),lpp.Start_Date__c.day()).format('d/MM/YYYY');
                                    //String endt = DateTime.newInstance(lpp.End_Date__c.year(),lpp.End_Date__c.month(),lpp.End_Date__c.day()).format('d/MM/YYYY');
                                    str.bgColor = (str.Status == 'Vacant' || (LOICancelled || LACancelled)) ? 'rgba(204, 0, 0, 0.57) !important' :( (str.Status == 'LOI') ? 'rgba(58, 102, 144, 0.78) !important' : ((str.Status == 'Committed') ? 'rgba(49, 148, 49, 0.75) !important' : (str.Status == 'Booking') ? 'rgba(2, 92, 255, 0.34) !important' : (str.Status == 'N/A')?'rgba(95, 84, 84, 0.57) !important':'rgba(229, 193, 48, 0) !important'));
                                    String tempStatus = '<b>'+(String) lpp.get('Status_'+j+'__c')+'</b>';
                                    if(str.Status == 'Booking'){
                                    	for(Expression_of_Interest__c eoi:lu.Expression_of_Interest__r){
			                            	Date dd =   date.newInstance(lpp.Start_Date__c.year(), lpp.Start_Date__c.month(), j);
			                                String stdt = DateTime.newInstance(eoi.Commencement_Date__c.year(),eoi.Commencement_Date__c.month(),eoi.Commencement_Date__c.day()).format('d/MM/YYYY');
			                                String endt = DateTime.newInstance(eoi.Expiry_Date__c.year(),eoi.Expiry_Date__c.month(),eoi.Expiry_Date__c.day()).format('d/MM/YYYY');
			                                if(dd >=eoi.Commencement_Date__c && dd <= eoi.Expiry_Date__c){
				                                str.cellText = tempStatus + ' PPPPP '
				                                				+eoi.Account_Name__r.Name
				                                				+' PPPPP from '+stdt+' to '+endt+' PPPPP ';
				                               	if(lu.Charge_Method__c.contains('Daily Rate')){
				                               		str.cellText += 'Daily Rate : ' + str.dailyRateSTRformatted;
				                               	}else if(lu.Charge_Method__c.contains('Monthly Rate - CL')){
				                               		str.cellText += 'Monthly Rate : ' + str.monthlyBudgetSTRformatted;
				                               	}
				                                break;
			                                }
					                    }
                                    }
                                                       
                                    if(str.Status == 'Vacant'){
                                        str.cellText = tempStatus + ' PPPPP ' ;
                                        if(lu.Charge_Method__c.contains('Daily Rate')){
		                               		str.cellText += 'Daily Rate : ' + str.dailyRateSTRformatted;
		                               	}else if(lu.Charge_Method__c.contains('Monthly Rate - CL')){
		                               		str.cellText += 'Monthly Rate : ' + str.monthlyBudgetSTRformatted;
		                               	}
                                    }   
                                    if(str.Status == 'Committed')
                                        for(Lease_Unit__c Lsu: lu.Lease_Units__r){
                                            Date dd =   date.newInstance(lpp.Start_Date__c.year(), lpp.Start_Date__c.month(), j);
                                            String strtDt = DateTime.newInstance(Lsu.Lease_Start_Date__c.year(),Lsu.Lease_Start_Date__c.month(),Lsu.Lease_Start_Date__c.day()).format('d/MM/YYYY');
                                            String endDt = DateTime.newInstance(Lsu.Lease_End_Date__c.year(),Lsu.Lease_End_Date__c.month(),Lsu.Lease_End_Date__c.day()).format('d/MM/YYYY');
                                            
                                            if(dd >=Lsu.Lease_Start_Date__c && dd <= Lsu.Lease_End_Date__c){
                                                str.cellText = tempStatus + ' PPPPP ' 
                                                               + Lsu.Tenant__c + ' PPPPP ' 
                                                               + 'From ' + strtDt +' To '+ endDt + ' PPPPP ' ;
                                                 if(lu.Charge_Method__c.contains('Daily Rate')){
				                               		str.cellText += 'Daily Rate: ' + str.dailyRateSTRformatted + ' PPPPP ' 
                                                           			+ 'Daily Committed Rate: ' + str.dailyCommittedRateSTRformatted;
				                               	}else if(lu.Charge_Method__c.contains('Monthly Rate - CL')){
				                               		str.cellText += 'Monthly Rate : ' + str.monthlyBudgetSTRformatted + ' PPPPP ' 
				                               						+ 'Monthly Committed Rate: ' + str.monthlyCommBudgetSTRformatted;
				                               	}
                                                break;
                                            }
                                        }
                                    if(str.Status == 'LOI')
                                        for(LOI_Unit__c Lsu: lu.LOI_Units__r){
                                            Date dd =   date.newInstance(lpp.Start_Date__c.year(), lpp.Start_Date__c.month(), j);
                                            String strtDt = DateTime.newInstance(Lsu.LOI_Start_Date__c.year(),Lsu.LOI_Start_Date__c.month(),Lsu.LOI_Start_Date__c.day()).format('d/MM/YYYY');
                                            String endDt = DateTime.newInstance(Lsu.LOI_End_Date__c.year(),Lsu.LOI_End_Date__c.month(),Lsu.LOI_End_Date__c.day()).format('d/MM/YYYY');
                                            
                                            if(dd >=Lsu.LOI_Start_Date__c && dd <= Lsu.LOI_End_Date__c){
                                                str.cellText = tempStatus + ' PPPPP ' 
                                                               + Lsu.Tenant__c + ' PPPPP ' 
                                                               + 'From ' + strtDt +' To '+ endDt + ' PPPPP ';
                                                if(lu.Charge_Method__c.contains('Daily Rate')){
				                               		str.cellText += 'Daily Rate : ' + str.dailyRateSTRformatted;
				                               	}else if(lu.Charge_Method__c.contains('Monthly Rate - CL')){
				                               		str.cellText += 'Monthly Rate : ' + str.loiMonthlyBudgetSTRformatted;
				                               	}
                                                break;
                                            }
                                        }
                                    mw.lpstr[str.cellIndex] = str;
                                }
                            }else if(lpp.Start_Date__c.month() == selectedMonth2cc){
                                for(Integer k=1; k<= total2ndMonthDays ; k++){
                                    str = new LPStructure(); 
                                    
                                    str.cellIndex = total1stMonthDays+k-1;
                                    str.leasePlan = lpp;
                                    str.Status = (String) lpp.get('Status_'+k+'__c');
                                    
                                    str.dailyRate = (Decimal) lpp.get('Daily_Rate_'+k+'__c');
                                    str.dailyCommittedRate = (Decimal) lpp.get('Daily_Committed_Rate_'+k+'__c');
                                    str.dailyLOIRate = (Decimal) lpp.get('Daily_LOI_Rate_'+k+'__c');
                                    
                                    if(str.dailyRate == null)
                                        str.dailyRate = 0.00;
                                    if(str.dailyLOIRate == null)
                                    	str.dailyLOIRate = 0;
                                    if(str.dailyCommittedRate == null)
                                    	str.dailyCommittedRate = 0;
                                    	
                                    str.dailyCommittedRate = str.dailyCommittedRate.setScale(2);
                                    str.dailyCommittedRateSTR = LeasePlanDailyController.FormatNumber(str.dailyCommittedRate);
                                    str.dailyCommittedRateSTRformatted = LeasePlanDailyController.doFormatting(str.dailyCommittedRate, 2, ',', '.');
                                    
                                    str.dailyLOIRate = str.dailyLOIRate.setScale(2);
                                    str.dailyLOIRateSTR = LeasePlanDailyController.FormatNumber(str.dailyLOIRate);
                                    str.dailyLOIRateSTRformatted = LeasePlanDailyController.doFormatting(str.dailyLOIRate, 2, ',', '.');
                                    
                                    /* Assign Loi Monthly Budget and Monthly Committed budget
                                    */
                                     str.loiMonthlyBudget = (Decimal) lpp.get('LOI_Monthly_Budget__c');
                                    str.monthlyCommBudget = (Decimal) lpp.get('Monthly_Committed_Budget__c');
                                    str.monthlyBudget = (Decimal) lpp.get('Monthly_Budget__c');
                                    if(str.loiMonthlyBudget == null)
                                    	str.loiMonthlyBudget = 0;
                                    if(str.monthlyCommBudget == null)
                                    	str.monthlyCommBudget = 0;
                                    if(str.monthlyBudget == null)
                                    	str.monthlyBudget = 0;

									str.loiMonthlyBudgetSTRformatted = LeasePlanDailyController.FormatNumber(str.loiMonthlyBudget);
									str.loiMonthlyBudgetSTR= LeasePlanDailyController.doFormatting(str.loiMonthlyBudget, 2, ',', '.');
									
									str.monthlyCommBudgetSTRformatted = LeasePlanDailyController.FormatNumber(str.monthlyCommBudget);
									str.monthlyCommBudgetSTR= LeasePlanDailyController.doFormatting(str.monthlyCommBudget, 2, ',', '.');
									
									str.monthlyBudgetSTRformatted = LeasePlanDailyController.FormatNumber(str.monthlyBudget);
									str.monthlyBudgetSTR= LeasePlanDailyController.doFormatting(str.monthlyBudget, 2, ',', '.');
									
                                    str.dailyRate = str.dailyRate.setScale(2);
                                    str.dailyRateSTR = LeasePlanDailyController.FormatNumber(str.dailyRate);
                                    str.dailyRateSTRformatted = LeasePlanDailyController.doFormatting(str.dailyRate, 2, ',', '.');
                                    
                                    /* --------------------------------------------------------------
                                    */
                                    
                                    str.colSpan = 1;
                                    //String stdt = DateTime.newInstance(lpp.Start_Date__c.year(),lpp.Start_Date__c.month(),lpp.Start_Date__c.day()).format('d/MM/YYYY');
                                    //String endt = DateTime.newInstance(lpp.End_Date__c.year(),lpp.End_Date__c.month(),lpp.End_Date__c.day()).format('d/MM/YYYY');
                                    str.bgColor = (str.Status == 'Vacant'  || (LOICancelled || LACancelled)) ? 'rgba(204, 0, 0, 0.57) !important' :( (str.Status == 'LOI') ? 'rgba(58, 102, 144, 0.78) !important' : ((str.Status == 'Committed') ? 'rgba(49, 148, 49, 0.75) !important' : (str.Status == 'Booking') ? 'rgba(2, 92, 255, 0.34) !important' : 'rgba(229, 193, 48, 0) !important'));
                                    String tempStatus = '<b>'+(String) lpp.get('Status_'+k+'__c')+'</b>';
                                    
                                    if(str.Status == 'Booking'){
                                    	for(Expression_of_Interest__c eoi:lu.Expression_of_Interest__r){
			                            	Date dd =   date.newInstance(lpp.Start_Date__c.year(), lpp.Start_Date__c.month(), k);
			                                String stdt = DateTime.newInstance(eoi.Commencement_Date__c.year(),eoi.Commencement_Date__c.month(),eoi.Commencement_Date__c.day()).format('d/MM/YYYY');
			                                String endt = DateTime.newInstance(eoi.Expiry_Date__c.year(),eoi.Expiry_Date__c.month(),eoi.Expiry_Date__c.day()).format('d/MM/YYYY');
			                                if(dd >=eoi.Commencement_Date__c && dd <= eoi.Expiry_Date__c){
				                                str.cellText = tempStatus + ' PPPPP '
				                                				+eoi.Account_Name__r.Name
				                                				+' PPPPP from '+stdt+' to '+endt+' PPPPP ';
				                               	if(lu.Charge_Method__c.contains('Daily Rate')){
				                               		str.cellText += 'Daily Rate : ' + str.dailyRateSTRformatted;
				                               	}else if(lu.Charge_Method__c.contains('Monthly Rate - CL')){
				                               		str.cellText += 'Monthly Rate : ' + str.monthlyBudgetSTRformatted;
				                               	}
				                                break;
			                                }
					                    }
                                    }
                                                       
                                    if(str.Status == 'Vacant'){
                                        str.cellText = tempStatus + ' PPPPP ' ;
                                        if(lu.Charge_Method__c.contains('Daily Rate')){
		                               		str.cellText += 'Daily Rate : ' + str.dailyRateSTRformatted;
		                               	}else if(lu.Charge_Method__c.contains('Monthly Rate - CL')){
		                               		str.cellText += 'Monthly Rate : ' + str.monthlyBudgetSTRformatted;
		                               	}
                                    }   
                                    if(str.Status == 'Committed')
                                        for(Lease_Unit__c Lsu: lu.Lease_Units__r){
                                            Date dd =   date.newInstance(lpp.Start_Date__c.year(), lpp.Start_Date__c.month(), k);
                                            String strtDt = DateTime.newInstance(Lsu.Lease_Start_Date__c.year(),Lsu.Lease_Start_Date__c.month(),Lsu.Lease_Start_Date__c.day()).format('d/MM/YYYY');
                                            String endDt = DateTime.newInstance(Lsu.Lease_End_Date__c.year(),Lsu.Lease_End_Date__c.month(),Lsu.Lease_End_Date__c.day()).format('d/MM/YYYY');
                                            
                                            if(dd >=Lsu.Lease_Start_Date__c && dd <= Lsu.Lease_End_Date__c){
                                                str.cellText = (String) lpp.get('Status_'+k+'__c') + ' PPPPP ' 
                                                               + Lsu.Tenant__c + ' PPPPP ' 
                                                               + 'From ' + strtDt +' To '+ endDt + ' PPPPP ' ;
                                                 if(lu.Charge_Method__c.contains('Daily Rate')){
				                               		str.cellText += 'Daily Rate: ' + str.dailyRateSTRformatted + ' PPPPP ' 
                                                           			+ 'Daily Committed Rate: ' + str.dailyCommittedRateSTRformatted;
				                               	}else if(lu.Charge_Method__c.contains('Monthly Rate - CL')){
				                               		str.cellText += 'Monthly Rate : ' + str.monthlyBudgetSTRformatted + ' PPPPP ' 
				                               						+ 'Monthly Committed Rate: ' + str.monthlyCommBudgetSTRformatted;
				                               	}
                                                break;
                                            }
                                        }
                                    if(str.Status == 'LOI')
                                        for(LOI_Unit__c Lsu: lu.LOI_Units__r){
                                            Date dd =   date.newInstance(lpp.Start_Date__c.year(), lpp.Start_Date__c.month(), k);
                                            String strtDt = DateTime.newInstance(Lsu.LOI_Start_Date__c.year(),Lsu.LOI_Start_Date__c.month(),Lsu.LOI_Start_Date__c.day()).format('d/MM/YYYY');
                                            String endDt = DateTime.newInstance(Lsu.LOI_End_Date__c.year(),Lsu.LOI_End_Date__c.month(),Lsu.LOI_End_Date__c.day()).format('d/MM/YYYY');
                                            
                                            if(dd >=Lsu.LOI_Start_Date__c && dd <= Lsu.LOI_End_Date__c){
                                                str.cellText = (String) lpp.get('Status_'+k+'__c') + ' PPPPP ' 
                                                               + Lsu.Tenant__c + ' PPPPP ' 
                                                               + 'From ' + strtDt +' To '+ endDt + ' PPPPP ';
                                                if(lu.Charge_Method__c.contains('Daily Rate')){
				                               		str.cellText += 'Daily Rate : ' + str.dailyRateSTRformatted;
				                               	}else if(lu.Charge_Method__c.contains('Monthly Rate - CL')){
				                               		str.cellText += 'Monthly Rate : ' + str.loiMonthlyBudgetSTRformatted;
				                               	}
                                                break;
                                            }
                                        }
                                            
                                    mw.lpstr[str.cellIndex] = str;
                                }
                            }
                        if(lpp.Unit__r.NLA_SQF__c != null){
                                totalNLA += lpp.Unit__r.NLA_SQF__c;
                            }   
                            if(lpp.Monthly_Budget__c != null){
                                totalMnthBdgt += lpp.Monthly_Budget__c;
                            }
                        }
                        
                        mw.avgNLA = (totalNLA/listOfMPLp.get(lu.Id).size()).setScale(2);
                        mw.avgNLASTR = LeasePlanDailyController.FormatNumber(mw.avgNLA);
                        mw.avgNLASTRformatted = LeasePlanDailyController.doFormatting(mw.avgNLA, 2, ',', '.');
                        
                        mw.avgMonthBudgt = (totalMnthBdgt/listOfMPLp.get(lu.Id).size()).setScale(2);
                        mw.avgMonthBudgtSTR = LeasePlanDailyController.FormatNumber(mw.avgMonthBudgt);
                        mw.avgMonthBudgtSTRformatted  = LeasePlanDailyController.doFormatting(mw.avgMonthBudgt, 2, ',', '.');
                        
                        mw.budgetRent = (mw.avgMonthBudgt*mw.avgNLA).setScale(2);
                        mw.budgetRentSTR = LeasePlanDailyController.FormatNumber(mw.budgetRent);
                        mw.budgetRentSTRformatted = LeasePlanDailyController.doFormatting(mw.budgetRent, 2, ',', '.');
                        
                    }
                    mainWrapper.add(mw);
                } 
                
                MainWrapper mw1 =new MainWrapper();
                mw1.firstRow = true;
                mw1.unit = new Units__c();
                for(Integer i=1; i<= total1stMonthDays ; i++){
                    LPStructure tt = new LPStructure();
                    tt.cellIndex = i;
                    tt.colSpan = 1;
                    mw1.lpstr.add(tt);
                }
                for(Integer i=1; i<= total2ndMonthDays ; i++){
                    LPStructure tt = new LPStructure();
                    tt.cellIndex = i;
                    tt.colSpan = 1;
                    mw1.lpstr.add(tt);
                }
                
                mainWrapper.add(mw1);
                for(MainWrapper mm: mainWrapper){
                	if(mm.unit.Charge_Method__c != null && (leasePlanUI.Status__c == 'All' || ( leasePlanUI.Status__c != 'All' && displayUnits.contains(mm.unit.Id))))
	                	if(mm.unit.Charge_Method__c.contains('Daily Rate') ){
	                		dailyWrapper.add(mm);
	                	}else if(mm.unit.Charge_Method__c.contains('Monthly Rate - CL')){
	                		monthlyLWrapper.add(mm);
	                	}
                }
                dailyWrapper.add(mw1);
                monthlyLWrapper.add(mw1);
                dailyWrapper.sort();
                monthlyLWrapper.sort();
                if(dailyWrapper.size() > 1 || monthlyLWrapper.size() > 1){
                	if(dailyWrapper.size() == 1){
                		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No records found for Daily Rate Units.'));
                	}
                	if(monthlyLWrapper.size() == 1){
                		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No records found for Monthly - CL Units.'));
                	}
                	showInterface = true;
                }else{
                	showInterface = false;
              	    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'No records found for selected Property.'));
                }
                
            }else{
                showInterface = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'No records found for selected Property.'));
            }
            
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select Property.'));
        }
        
    }
    
    public Class MainWrapper implements Comparable{
        public Units__c unit{get;set;} 
        public Decimal avgMonthBudgt{get;set;} 
        public String avgMonthBudgtSTRformatted{get;set;}
        public String avgMonthBudgtSTR{get;set;}
        public Decimal avgNLA{get;set;}
        public String avgNLASTRformatted{get;set;}
        public String avgNLASTR{get;set;}
        
        public Decimal loiRent{get;set;}
		public String loiRentSTRformatted{get;set;}
		public String loiRentSTR{get;set;}
		public Decimal laRent{get;set;}
		public String laRentSTRformatted{get;set;}
		public String laRentSTR{get;set;}

        public Decimal budgetRent{get;set;}
        public String budgetRentSTRformatted{get;set;}
        public String budgetRentSTR{get;set;}
        public String bgColor{get;set;}
        public Integer endTab{get;set;}
        public String rowHeader{get;set;}
        public List<LPStructure> lpstr{get;set;}
        public Boolean hideRow{get;set;} 
        public String smallHeader{get;set;}
        public Boolean firstRow{get;set;}
        public Integer eoiCount{get;set;}
        public String eoiAccInfo{get;set;}
        
        public Integer compareTo(Object compareTo){
	        MainWrapper mainWrapper = (MainWrapper) compareTo;
	        String thisName = (unit == null || String.isEmpty(unit.Name) ? '' : unit.Name);
	        String thatName = (mainWrapper == null || mainWrapper.unit == null || String.isEmpty(mainWrapper.unit.Name) ? '' : mainWrapper.unit.Name);
	        return thisName.compareTo(thatName);
	    }
	    
        public MainWrapper(){
            unit = new Units__c();
            avgMonthBudgt = 0;
            avgMonthBudgtSTRformatted = '';
            avgMonthBudgtSTR = '';
            avgNLA = 0;
            avgNLASTRformatted = '';
            avgNLASTR = '';
            budgetRent = 0;
            budgetRentSTRformatted = '';
            budgetRentSTR = '';
            loiRent = 0;
			loiRentSTRformatted = '';
			loiRentSTR = '';
			laRent = 0;
			laRentSTRformatted = '';
			laRentSTR = '';
            endTab = 0;
            hideRow = false;
            firstRow = false;
            lpstr = new List<LPStructure>();
            rowHeader ='';
            smallHeader='';
            bgColor = 'rgba(229, 193, 48, 0) !important';
            eoiCount = 0;
            eoiAccInfo = '';
        }
    }
    public Class LPStructure{
        public Lease_Plan__c leasePlan{get;set;}
        public String status{get;set;}
        public String headerDaily{get;set;}
        public Integer cellIndex{get;set;}
        public Integer colSpan{get;set;}
        public String bgColor{get;set;}
        public String cellText{get;set;}
        public Boolean removeCell{get;set;}
        public Decimal dailyRate{get;set;}
        public String dailyRateSTRformatted{get;set;}
        public String dailyRateSTR{get;set;}
        
        public Decimal dailyLOIRate{get;set;}
        public String dailyLOIRateSTRformatted{get;set;}
        public String dailyLOIRateSTR{get;set;}
        
        public Decimal dailyCommittedRate{get;set;}
        public String dailyCommittedRateSTRformatted{get;set;}
        public String dailyCommittedRateSTR{get;set;}
        
        public Decimal loiMonthlyBudget{get;set;}
        public String loiMonthlyBudgetSTRformatted{get;set;}
        public String loiMonthlyBudgetSTR{get;set;}
        
        public Decimal monthlyCommBudget{get;set;}
        public String monthlyCommBudgetSTRformatted{get;set;}
        public String monthlyCommBudgetSTR{get;set;}
        
        public Decimal monthlyBudget{get;set;}
        public String monthlyBudgetSTRformatted{get;set;}
        public String monthlyBudgetSTR{get;set;}
        
        public LPStructure(){
            leasePlan = new Lease_Plan__c();
            colSpan = 1;
            cellText = '';
            bgColor = 'rgba(229, 193, 48, 0) !important';
            status = '';
            dailyRate= 0;
            dailyRateSTRformatted = '';
            dailyRateSTR='';
            dailyCommittedRate= 0;
            dailyCommittedRateSTRformatted = '';
            dailyCommittedRateSTR='';
            dailyLOIRate= 0;
            dailyLOIRateSTRformatted = '';
            dailyLOIRateSTR='';
            loiMonthlyBudget= 0;
            loiMonthlyBudgetSTRformatted = '';
            loiMonthlyBudgetSTR='';
            monthlyCommBudget= 0;
            monthlyCommBudgetSTRformatted = '';
            monthlyCommBudgetSTR='';
            monthlyBudget= 0;
            monthlyBudgetSTRformatted = '';
            monthlyBudgetSTR='';
            
        }
    }
}