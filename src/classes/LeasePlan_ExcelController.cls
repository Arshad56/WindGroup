public with sharing class LeasePlan_ExcelController {
	public String XML_HEADER {get; set;}
    public String WORKBOOK_END {get; set;}
    
	public List<MainWrapper> mainWrapper{get;set;}
	public List<LPStructure> lpWrapper{get;set;}
	public List<Lease_Plan__c> listLP{get;set;} 
	public Boolean showInterface{get;set;}
	    public String selectedTradeCat{get;set;} 
	public String propName {get; set;}
	public Integer currentYear{get;set;}
	
	public Decimal totalForecast1stAmount{get;set;}
    public Decimal totalForecast2ndAmount{get;set;}
    public Decimal totalForecast3rdAmount{get;set;}
    public Decimal totalForecast4thAmount{get;set;}
    
    public String totalForecast1stAmountSTR{get;set;}
    public String totalForecast2ndAmountSTR{get;set;}
    public String totalForecast3rdAmountSTR{get;set;}
    public String totalForecast4thAmountSTR{get;set;}
    
    public String totalForecast1stAmountSTRformatted{get;set;}
    public String totalForecast2ndAmountSTRformatted{get;set;}
    public String totalForecast3rdAmountSTRformatted{get;set;}
    public String totalForecast4thAmountSTRformatted{get;set;}
    
	List<Units__c> listUnit;
	Set<String> ids;
	Map<Integer,String> monthMap;
	public Units__c unitUI{get;set;}
	public Lease_Plan__c leasePlanUI{get;set;}
	public String selectedYear{get;set;} 
	public String displayYear{get;set;} 
	public String PropertyName{get;set;} 
	public List<SelectOption> getYearOptions(){
		List < SelectOption > options = new List < SelectOption > ();
		Integer tempYear = 2009;
		for(Integer i=0; i<=10;i++){
			options.add(new SelectOption(++tempYear+'', tempYear+''));
		}
        return options;
	}
	public List<SelectOption> getStatusOptions(){
		List<SelectOption> options = new List<SelectOption>();
	    Schema.DescribeFieldResult fieldResult =   Lease_Plan__c.Status__c.getDescribe();
	    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	    options.add(new SelectOption('All','All'));     
	    for( Schema.PicklistEntry f : ple){
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	    }     
        return options;
	}
	public static String getCents(Decimal x){
    	Boolean isNeg = false;
    	if(x < 0){
    		isNeg = true;
    		x *= (-1);
    	}
	    String y = String.valueOf(x);
	    String z = '.';
	    if(y.contains(',')) z = ',';
	    y = y.substring(0, y.indexOf(z));
	    String temp='';
	    if(isNeg)
	    	temp = '-';
	    if(x - Decimal.valueOf(y) == 0)
	        return temp+String.valueOf(x.format()) + z + '00';
	    else return temp+String.valueOf(x.format());
	}
    public static String FormatNumber(Decimal value){
    	Boolean isNeg = false;
    	if(value < 0){
    		isNeg = true;
    		value *= (-1);
    	}
	    String[]  suffixes = new String[]{'k', 'm', 'b', 't', 'q'};
	    for (Integer j = suffixes.size();  j > 0;  j--){
	        double  unit = Math.Pow(1000, j);
	        String temp = '';
	        if(isNeg)
	        temp = '-';
	        temp += LOIReportInterfaceController.getCents((value / unit).setScale(2));
	        if (value >= unit)
	            return  temp + suffixes[--j];
        }
        String tempval = '';
	        if(isNeg)
	        tempval = '-';
	        tempval += LOIReportInterfaceController.getCents(value.setScale(2));
	    return tempval;
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
    public LeasePlan_ExcelController(){
    	
    	XML_HEADER = '';
            XML_HEADER += '<?xml version="1.0"?>';
            XML_HEADER += '<?mso-application progid="Excel.Sheet"?>';
		WORKBOOK_END = '</Workbook>';
        
    	leasePlanUI= new Lease_Plan__c();
    	unitUI = new Units__c();
    	ids = new Set<String>();
    	
    	mainWrapper = new List<MainWrapper>();
    	lpWrapper = new List<LPStructure>();
    	
    	monthMap= new Map<Integer,String>();
    	monthMap.put(1,'JAN'); 
    	monthMap.put(2,'FEB');
    	monthMap.put(3,'MAR');
    	monthMap.put(4,'APR');
    	monthMap.put(5,'MAY');
    	monthMap.put(6,'JUN');
    	monthMap.put(7,'JUL');
    	monthMap.put(8,'AUG');
    	monthMap.put(9,'SEP');
    	monthMap.put(10,'OCT');
    	monthMap.put(11,'NOV');
    	monthMap.put(12,'DEC');
    	
    	selectedYear = System.Today().Year()+'';
    	String urlProperty = ApexPages.currentpage().getParameters().get('Property');
    	String urlLevel = ApexPages.currentpage().getParameters().get('Level');
    	String urlStatus = ApexPages.currentpage().getParameters().get('Status');
    	
    	selectedYear = ApexPages.currentpage().getParameters().get('SelectedYear');
    	selectedTradeCat = ApexPages.currentpage().getParameters().get('selectedTradeCat');
    	
    	displayYear = selectedYear +'-' + (Integer.valueOf(selectedYear.substring(2,4))+1);
    	unitUI.Property__c = Id.valueOf(urlProperty);
    	if(urlLevel != null && urlLevel != '')
    	unitUI.Level__c    = Id.valueOf(urlLevel);
    	leasePlanUI.Status__c = urlStatus;
    	
    	this.Generate();
    }
    
    public void Generate(){
    	
        mainWrapper = new List<MainWrapper>();
        lpWrapper = new List<LPStructure>();
        showInterface = false;
        if(unitUI.Property__c != null){
            currentYear = Integer.valueof(selectedYear);
            
            //System.debug('unitUI.Property__c==>'+unitUI.Property__c);
            //System.debug('selectedYear==>'+selectedYear);
            //System.debug('leasePlanUI.Status__c==>'+leasePlanUI.Status__c);
            
            //System.debug('unitUI==>'+unitUI);
            totalForecast1stAmount = 0;
            totalForecast2ndAmount = 0;
            mainWrapper = new List<MainWrapper>();
            lpWrapper = new List<LPStructure>();
            
            date myDate = date.newInstance(currentYear, 1, 1);
            date endDate = date.newInstance(currentYear+2, 1, 1);
            //System.debug('currentYear==>'+currentYear);
            //System.debug('myDate==>'+myDate);
            //System.debug('endDate==>'+endDate);
            
            String  soqlQueryUnit = 'select Id,Name,Start_Date__c,End_Date__c,Property__r.Short_Code__c,Property__r.Name,'
                                    +'Sub_Trade_Category__c,Sub_Trade_Category_1__c,Sub_Trade_Category_2__c,Sub_Trade_Category_3__c,'
                                    +'Trade_Category__c,Trade_category_1__c,Trade_category_2__c,Trade_category_3__c,'
                                    +'Rent_Hurdle_1__c,Rent_Hurdle_2__c,Rent_Hurdle_3__c,Unique_Selling_Point__c'
                                    +' from Units__c where CreatedDate != null And Active__c = true And Charge_Method__c INCLUDES (\'Monthly Rate - L\')';// And id = \'a03O000000IBXWaIAP\'
            if(unitUI.Property__c != null){
                soqlQueryUnit += ' And Property__c = \''+unitUI.Property__c+'\'';
            }
            if(unitUI.Level__c != null){
                soqlQueryUnit += ' And Level__c =  \''+unitUI.Level__c+'\'';
            }
            if(selectedTradeCat != 'All'){
                soqlQueryUnit += ' And Trade_Category__c =  \''+selectedTradeCat+'\'';
            }
            soqlQueryUnit += ' Order By Level__c,Name Asc';
            System.debug('Excel soqlQueryUnit--> '+soqlQueryUnit);
            listUnit = database.query(soqlQueryUnit);
            if(listUnit.size() > 0){
                Set<Id> idString = new Set<Id>();
                for(Units__c lu:listUnit){
                	propName = lu.Property__r.Name;
                    idString.add(lu.Id);
                }
        
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
                                        +'Start_Date__c, End_Date__c , Unit__c, Monthly_Budget__c, Status__c,Unit__r.NLA_SQF__c,'
                                        +'LOI_Unit__c,LOI_Unit__r.LOI_Agreement_No__c,LOI_Unit__r.LOI_Agreement_No__r.Tenant_Name__c,'
                                        +'Lease_Unit__c,Lease_Unit__r.Lease_Agreement_No__c,Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c,Rent_Hurdle__c,unit__r.Trade_Category__c from Lease_Plan__c where Start_Date__c != null And End_Date__c != null ';
                soqlQueryLP += ' And Unit__c =: idString ';
                
                if(leasePlanUI.Status__c != 'All'){
                    soqlQueryLP += ' And Status__c  =: leasePlanUI.Status__c ';
                }
                
                soqlQueryLP += ' And Start_Date__c >= '+string.valueOf(myDate)+' And End_Date__c < '+string.valueOf( endDate)+' Order By Start_Date__c Asc';
                
                System.debug('soqlQueryLP--> '+soqlQueryLP);
                
                List<Lease_Plan__c> listLP = database.query(soqlQueryLP);
                
                for(Integer i=1; i<=24 ; i++){
                    LPStructure lpr= new LPStructure();
                    date newDate = myDate;
                    lpr.headerMonth = newDate.Year()+' '+monthMap.get(newDate.Month());
                    myDate = myDate.addMonths(1);
                    lpWrapper.add(lpr);
                }
                
                Map<Id, List<Lease_Plan__c>> listOfMPLp= new Map<Id, List<Lease_Plan__c>>();
                Set<Id> leaseUnitIds = new Set<Id>();
                Map<Id,List<Lease_Charges__c>> LeaseChargeWithIds = new Map<Id,List<Lease_Charges__c>>();
                for(Lease_Plan__c ls: listLP){
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
                    /*if(!LeaseChargeWithIds.containsKey(lc.Lease_Unit__c)){
                        LeaseChargeWithIds.put(lc.Lease_Unit__c,lc);
                        System.debug('LeaseChargeWithIds-->'+LeaseChargeWithIds);
                    }else{
                    
                    }*/
                    if(LeaseChargeWithIds.containsKey(lc.Lease_Unit__c)) {
						List<Lease_Charges__c> templc = LeaseChargeWithIds.get(lc.Lease_Unit__c);
						templc.add(lc);
						LeaseChargeWithIds.put(lc.Lease_Unit__c, templc);
					} else {
						LeaseChargeWithIds.put(lc.Lease_Unit__c, new List<Lease_Charges__c> { lc });
					}
                }
                MainWrapper mw1 =new MainWrapper();
                mw1.firstRow = true;
                mw1.unit = new Units__c();
				 for(Integer i=1; i<=24 ; i++){
				    LPStructure tt = new LPStructure();
				    tt.cellIndex = i;
				    tt.colSpan = 1;
				    mw1.lpstr.add(tt);
				}
                //mainWrapper.add(mw1);
                for(Units__c lu:listUnit){
                    MainWrapper mw =new MainWrapper();
                    mw.unit = lu;
                    //Generate Wrapper Upper Part in Table with Units and Empty LP
                    for(Integer i=1; i<=24 ; i++){
                        LPStructure tt = new LPStructure();
                        tt.cellIndex = i;
                        tt.colSpan = 1;
                        mw.lpstr.add(tt);
                    }
                    if(listOfMPLp.containsKey(lu.Id)){
                        Decimal totalMnthBdgt=0;
                        Decimal totalNLA=0;
                        Integer preColSpan;
                        Lease_Plan__c preLpp = new Lease_Plan__c();
                        Integer i = 0;
                        for(Lease_Plan__c lpp:listOfMPLp.get(lu.Id)){
                            i++;
                            LPStructure str = new LPStructure();
                            
                            str.cellIndex = lpp.Start_Date__c.Month() ;
                            if(lpp.Start_Date__c.year() != currentYear){
                                str.cellIndex += 12;
                            }
                            str.leasePlan = lpp;
                            str.Status = lpp.Status__c;
                            str.colSpan = 1;
                            String stdt = DateTime.newInstance(lpp.Start_Date__c.year(),lpp.Start_Date__c.month(),lpp.Start_Date__c.day()).format('d/MM/YYYY');
                            String endt = DateTime.newInstance(lpp.End_Date__c.year(),lpp.End_Date__c.month(),lpp.End_Date__c.day()).format('d/MM/YYYY');
                             String tempStr = stdt+' to '+endt + ' Mnthly Rent $ ' + lpp.Monthly_Budget__c;
                            str.bgColor = (lpp.Status__c == 'Vacant') ? 'rgba(204, 0, 0, 0.57) !important' :( (lpp.Status__c == 'LOI') ? 'rgba(58, 102, 144, 0.78) !important' : ((lpp.Status__c == 'Committed') ? 'rgba(49, 148, 49, 0.75) !important' : 'rgba(229, 193, 48, 0) !important'));
                             str.cellText = (lpp.Status__c == 'Vacant') ? '' : ((lpp.Status__c == 'LOI') ? 'LOI: &#13; '+lpp.LOI_Unit__r.LOI_Agreement_No__r.Tenant_Name__c+' &#13; '+tempStr : ((lpp.Status__c == 'Committed') ? 'Lease Commited: &#13; '+lpp.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c+' &#13; '+tempStr : ''));
                             System.debug(lpp.Id+' lpp.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c-->'+lpp.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c);
                            
                        	
                        	if(lpp.Status__c == 'Vacant' && !lpp.Commited__c && !lpp.LOI__c){
                        		str.cellStyle= 'vacant';
                        	}else if(lpp.Status__c == 'Vacant' && lpp.Commited__c){
                        		str.cellStyle= 'crossCommPattern';
                        	}else if(lpp.Status__c == 'Vacant' && lpp.LOI__c){
                        		str.cellStyle= 'crossLOIPattern';
                        	}else if(lpp.Status__c == 'LOI' ){
                        		str.cellStyle= 'loi';
                        	}else if(lpp.Status__c == 'Committed'){
                        		str.cellStyle= 'committed';
                        	}else {
                        		str.cellStyle= 'white';
                        	}
                        	mw.lpstr[str.cellIndex-1] = str;
                            if(lpp.Unit__r.NLA_SQF__c != null){
                                totalNLA += lpp.Unit__r.NLA_SQF__c;
                            }   
                            if(lpp.Monthly_Budget__c != null){
                                totalMnthBdgt += lpp.Monthly_Budget__c;
                            }
                        }
                        mw.avgNLA = (totalNLA/listOfMPLp.get(lu.Id).size()).setScale(2);
                        mw.avgNLASTR = LOIReportInterfaceController.FormatNumber(mw.avgNLA);
                        mw.avgNLASTRformatted = LOIReportInterfaceController.doFormatting(mw.avgNLA, 2, ',', '.');
                        
                        mw.avgMonthBudgt = (totalMnthBdgt/listOfMPLp.get(lu.Id).size()).setScale(2);
                        mw.avgMonthBudgtSTR = LOIReportInterfaceController.FormatNumber(mw.avgMonthBudgt);
                        mw.avgMonthBudgtSTRformatted = LOIReportInterfaceController.doFormatting(mw.avgMonthBudgt, 2, ',', '.');
                        
                        mw.budgetRent = (mw.avgMonthBudgt*mw.avgNLA).setScale(2);
                        mw.budgetRentSTR = LOIReportInterfaceController.FormatNumber(mw.budgetRent);
                        mw.budgetRentSTRformatted = LOIReportInterfaceController.doFormatting(mw.budgetRent, 2, ',', '.');
                    }
                    mainWrapper.add(mw);
                } 
                Integer mainWrapSize = mainWrapper.Size();
                MainWrapper mmw =new MainWrapper();
                mmw.endTab = 1;
                mmw.bgColor='Gray';
                mmw.rowHeader = 'Total NLA';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 1;
                mmw.hideRow = true;
                mmw.bgColor = 'Vacant';
                mmw.rowHeader = 'Vacant NLA';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 1;
                mmw.hideRow = true;
                mmw.bgColor = 'Committed';
                mmw.rowHeader = 'Leased NLA';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 1;
                mmw.hideRow = true;
                mmw.bgColor = 'LOI';
                mmw.rowHeader = 'LOI NLA';
                mainWrapper.add(mmw);
                
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mmw.bgColor='Gray';
                mmw.rowHeader = 'Total Budget';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mmw.hideRow = true;
                mmw.smallHeader = 'a';
                mmw.bgColor = 'Committed';
                mmw.rowHeader = 'Total Leased Amount';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mmw.hideRow = true;
                mmw.smallHeader = 'b';
                mmw.rowHeader = 'Total Variance';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mmw.hideRow = true;
                mmw.smallHeader = 'c';
                mmw.bgColor = 'Vacant';
                mmw.rowHeader = 'Total Vacant Amount (Forecast)';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mmw.hideRow = true;
                mmw.smallHeader = 'd';
                mmw.bgColor = 'LOI';
                mmw.rowHeader = 'Total Pending LOI';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mmw.hideRow = true;
                mmw.smallHeader = 'e';
                mmw.bgColor = 'LOI';
                mmw.rowHeader = 'Total Over/Under LOI';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mmw.hideRow = true;
                mmw.smallHeader = 'f';
                mmw.bgColor = 'LOI';
                mmw.rowHeader = 'Total Over/Under Leased ';
                mainWrapper.add(mmw);
                
                //Generate Wrapper Lower Part in Table with Units and Empty LP
                for(MainWrapper mw:mainWrapper){
                    if(mw.endTab != 0){
                        for(Integer j=1; j<=24 ; j++){
                            LPStructure tt = new LPStructure();
                            tt.cellIndex = j;
                            tt.colSpan = 1;
                            mw.lpstr.add(tt);
                        }
                    }
                }
                //Update Wrapper
                Integer counterTemp = 0;
                String vacantFromText = '';
                String vacantTillText = '';
                for(MainWrapper mw:mainWrapper){
                    if(mw.endTab == 0){ 
                        System.debug('11<----->'+mw.unit.Name);
                        String tradeCatString = '';
                        if(mw.unit.Sub_Trade_Category_1__c != null){
                            tradeCatString = '&#13; '+mw.unit.Sub_Trade_Category_1__c +'-'+ mw.unit.Rent_Hurdle_1__c;
                        }
                        if(mw.unit.Sub_Trade_Category_2__c != null){
                            if(mw.unit.Sub_Trade_Category_1__c != null){
                                tradeCatString += '; ';
                            }
                            tradeCatString += mw.unit.Sub_Trade_Category_2__c +'-'+ mw.unit.Rent_Hurdle_2__c;
                        }
                        if(mw.unit.Sub_Trade_Category_3__c != null){
                            if(mw.unit.Sub_Trade_Category_2__c != null || (mw.unit.Sub_Trade_Category_1__c != null && mw.unit.Trade_category_2__c == null)){
                                tradeCatString += '; ';
                            } 
                            tradeCatString += mw.unit.Sub_Trade_Category_3__c +'-'+ mw.unit.Rent_Hurdle_3__c;
                        }
                        if(mw.unit.Unique_Selling_Point__c != null){
                        	tradeCatString += ' USP: '+mw.unit.Unique_Selling_Point__c;
                        }
                        if(mw.unit.Sub_Trade_Category__c == null){
                        	mw.unit.Sub_Trade_Category__c = '';
                        }
                        Integer prevIndex;
                        String prevVal;
                        Integer tempCount=1;
                        vacantFromText = '';
                        vacantTillText = '';
                        Integer tempHurdleAmy=0;
                        for(Integer i=0; i < mw.lpstr.size(); i++){
                            
                            mainWrapper[mainWrapSize+1].lpstr[i].bgColor = 'rgba(204, 0, 0, 0.48) !important';
                            mainWrapper[mainWrapSize+2].lpstr[i].bgColor = 'rgba(49, 148, 49, 0.66) !important';
                            mainWrapper[mainWrapSize+3].lpstr[i].bgColor = 'rgba(58, 102, 144, 0.65) !important';
                            
                            //Budget And Rent Calculations
                            if(mw.lpstr[i].leasePlan != null && mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c > 0 ){
                                //    Total NLA
                                mainWrapper[mainWrapSize].lpstr[i].totalNLA += mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                                
                                //mainWrapper[mainWrapSize+5].lpstr[i].totalBudget += mw.avgMonthBudgt* mw.avgNLA;
                                
                                //vacant
                                if(mw.lpstr[i].leasePlan.Status__c == 'Vacant'){
                                	//     Vacant NLA
                                    mainWrapper[mainWrapSize+1].lpstr[i].totalNLA += mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                                    //     Total Vacant Amount (Forecast)
                                    mainWrapper[mainWrapSize+8].lpstr[i].totalBudget += mw.lpstr[i].leasePlan.Monthly_Budget__c* mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                                }
                                //Lease Committed
                                if(mw.lpstr[i].leasePlan.Status__c == 'Committed'){
                                	//     Leased NLA
                                    mainWrapper[mainWrapSize+2].lpstr[i].totalNLA += mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                                    //     Total Leased Amount
                                    //mainWrapper[mainWrapSize+6].lpstr[i].totalBudget += mw.lpstr[i].leasePlan.Monthly_Budget__c* mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                                     if(LeaseChargeWithIds.containsKey(mw.lpstr[i].leasePlan.Lease_Unit__c)){
                                    	for(Lease_Charges__c lc: LeaseChargeWithIds.get(mw.lpstr[i].leasePlan.Lease_Unit__c)){
                                    		if(mw.lpstr[i].leasePlan.Start_Date__c >= lc.Start_Date__c && mw.lpstr[i].leasePlan.Start_Date__c <= lc.End_Date__c){
                                    			//    Total Over/Under LOI
                                    			mainWrapper[mainWrapSize+6].lpstr[i].totalBudget += lc.Base_Rent_Calculation__c;
                                    			break;
                                    		}
                                    	}
                                    } 
                                    //mainWrapper[mainWrapSize+6].lpstr[i].totalBudget += 1;
                                    if(LeaseChargeWithIds.containsKey(mw.lpstr[i].leasePlan.Lease_Unit__c)){
                                    	for(Lease_Charges__c lc: LeaseChargeWithIds.get(mw.lpstr[i].leasePlan.Lease_Unit__c)){
                                    		if(mw.lpstr[i].leasePlan.Start_Date__c >= lc.Start_Date__c && mw.lpstr[i].leasePlan.Start_Date__c <= lc.End_Date__c){
                                    			//    Total Over/Under Leased 
                                    			mainWrapper[mainWrapSize+11].lpstr[i].totalBudget += lc.Base_Rent_Calculation__c - (mw.lpstr[i].leasePlan.Monthly_Budget__c*mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c);
                                    			break;
                                    		}
                                    	}
                                    }
                                }
                                //LOI
                                if(mw.lpstr[i].leasePlan.Status__c == 'LOI'){
                                	//    Leased NLA
                                    mainWrapper[mainWrapSize+3].lpstr[i].totalNLA += mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                                    //    Total Pending LOI
                                    mainWrapper[mainWrapSize+9].lpstr[i].totalBudget += mw.lpstr[i].leasePlan.Monthly_Budget__c* mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                                    System.debug('contains Lease_Unit__c-->'+LeaseChargeWithIds.containsKey(mw.lpstr[i].leasePlan.Lease_Unit__c));
                                    if(LeaseChargeWithIds.containsKey(mw.lpstr[i].leasePlan.Lease_Unit__c)){
                                    	for(Lease_Charges__c lc: LeaseChargeWithIds.get(mw.lpstr[i].leasePlan.Lease_Unit__c)){
                                    		if(mw.lpstr[i].leasePlan.Start_Date__c >= lc.Start_Date__c && mw.lpstr[i].leasePlan.Start_Date__c <= lc.End_Date__c){
                                    			//    Total Over/Under LOI
                                    			mainWrapper[mainWrapSize+10].lpstr[i].totalBudget += lc.Base_Rent_Calculation__c - (mw.lpstr[i].leasePlan.Monthly_Budget__c*mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c);
                                    			break;
                                    		}
                                    	}
                                    } 
                                }
                                //mainWrapper[mainWrapSize+5].lpstr[i].totalBudget += mainWrapper[mainWrapSize+6].lpstr[i].totalBudget+mainWrapper[mainWrapSize+8].lpstr[i].totalBudget+mainWrapper[mainWrapSize+9].lpstr[i].totalBudget -(mainWrapper[mainWrapSize+10].lpstr[i].totalBudget + mainWrapper[mainWrapSize+11].lpstr[i].totalBudget);
                            }
                            //Colspan Logic 
                            
                            System.debug('mw.lpstr[i].leasePlan.Id-->'+mw.lpstr[i].leasePlan.Id);
                            System.debug('mw.lpstr[i].leasePlan.End_Date__c-->'+mw.lpstr[i].leasePlan.End_Date__c);
                            
                            if(mw.lpstr[i].leasePlan.Rent_Hurdle__c == null){
                                mw.lpstr[i].leasePlan.Rent_Hurdle__c =0;
                            }
                            if(prevVal == null){
                                prevIndex = i;
                                prevVal = mw.lpstr[i].status;
                                mw.lpstr[i].colSpan = 1;
                                
                               // mw.lpstr[prevIndex].hurdleAmt += mw.lpstr[i].leasePlan.Rent_Hurdle__c;
                                //System.debug('hurdle on null-->'+mw.lpstr[prevIndex].hurdleAmt);
                            }else if(prevVal == mw.lpstr[i].status && mw.lpstr[i].status != ''){
                                tempCount++;
                                mw.lpstr[prevIndex].colSpan = tempCount;
                                mw.lpstr[i].colSpan = 0;
                                
                               // mw.lpstr[prevIndex].hurdleAmt += mw.lpstr[i].leasePlan.Rent_Hurdle__c;
                                //System.debug('hurdle on same-->'+mw.lpstr[prevIndex].hurdleAmt);
                                if(i == mw.lpstr.size()-1){
                                    Date startDatte = mw.lpstr[prevIndex].leasePlan.Start_Date__c;
                                    Date endDatte = mw.lpstr[i].leasePlan.End_Date__c;
                                  //  Date endDatte = system.today();
                                    
                                    String currentStat = mw.lpstr[prevIndex].leasePlan.Status__c;
                                    String stdt = DateTime.newInstance(startDatte.year(),startDatte.month(),startDatte.day()).format('d/MM/YYYY');
                                    String endt = DateTime.newInstance(endDatte.year()-1,endDatte.month(),endDatte.day()).format('d/MM/YYYY');
                                    
                                    String LOIStr =  stdt +' to '+ endt +' &#13; Mthly Rent $ '+ mw.lpstr[prevIndex].leasePlan.Monthly_Budget__c;
                                    String cellText = (currentStat == 'Vacant') ? 'Vacant: &#13; ' : ((currentStat == 'LOI') ? 'LOI: &#13; '+mw.lpstr[prevIndex].leasePlan.LOI_Unit__r.LOI_Agreement_No__r.Tenant_Name__c+' &#13; '+LOIStr : ((currentStat == 'Committed') ? 'Lease committed: &#13; '+mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c+' &#13; from '+LOIStr : ''));
                                    System.debug('cellText-->'+cellText);
                                   // System.debug('mw.lpstr[prevIndex].cellText-->'+mw.lpstr[prevIndex].cellText);
                                    System.debug('mw.lpstr[prevIndex].cellText111-->'+mw.lpstr[prevIndex].cellText);
                                    if(currentStat == 'LOI' || currentStat == 'Committed'){
                                        mw.lpstr[prevIndex].cellText= cellText;
                                    }else if(currentStat == 'Vacant'){
                                    	for(Integer l=prevIndex ; l< mw.lpstr[prevIndex].colSpan; l++){
                                    		mw.lpstr[prevIndex].hurdleAmt += mw.lpstr[l].leasePlan.Rent_Hurdle__c; 
                                    	}
                                        vacantTillText = ' to '+ endt +' &#13; Rent Hurdle Rate-'+mw.lpstr[prevIndex].hurdleAmt+' '+tradeCatString;
                                        if(mw.lpstr[prevIndex].cellText.contains('from')){
                                            mw.lpstr[prevIndex].cellText += vacantTillText;
                                        }else{
                                            mw.lpstr[prevIndex].cellText = 'Vacant: &#13; '+mw.unit.Sub_Trade_Category__c+' &#13; from '+stdt+vacantTillText;
                                        }
                                        
                                    }
                                } 
                            }else{
                                prevVal = mw.lpstr[i].status;
                                mw.lpstr[prevIndex].colSpan = tempCount;
                                
                                mw.lpstr[i].colSpan = 1; 
                                
                                Date startDatte = mw.lpstr[prevIndex].leasePlan.Start_Date__c;
                                Date endDatte = mw.lpstr[i-1].leasePlan.End_Date__c; 
                                System.debug(i+ ' endDatte-->'+ endDatte);
                                 
                              //  mw.lpstr[prevIndex].hurdleAmt += mw.lpstr[i-1].leasePlan.Rent_Hurdle__c;
                                //System.debug('hurdle on change-->'+mw.lpstr[prevIndex].hurdleAmt);
                                if(tempCount > 1 ){
                                    String currentStat = mw.lpstr[prevIndex].leasePlan.Status__c;
                                    String stdt = DateTime.newInstance(startDatte.year(),startDatte.month(),startDatte.day()).format('d/MM/YYYY');
                                    String endt = DateTime.newInstance(endDatte.year(),endDatte.month(),endDatte.day()).format('d/MM/YYYY');
                                    
                                     System.debug(i+ ' endt-->'+ endt);
                                    
                                    vacantTillText = mw.lpstr[i-1].leasePlan.End_Date__c.day()+'/'+mw.lpstr[i-1].leasePlan.End_Date__c.month()+'/'+mw.lpstr[i-1].leasePlan.End_Date__c.year(); 
                                    String LOIStr =  stdt +' to '+ vacantTillText +' &#13; Mthly Rent $ '+ mw.lpstr[prevIndex].leasePlan.Monthly_Budget__c;
                                    vacantFromText = stdt;
                                    
                                    String cellText = (currentStat == 'Vacant') ? 'Vacant: &#13; ' : ((currentStat == 'LOI') ? 'LOI: &#13; '+mw.lpstr[prevIndex].leasePlan.LOI_Unit__r.LOI_Agreement_No__r.Tenant_Name__c+' &#13;'+LOIStr : ((currentStat == 'Committed') ? 'Lease committed: &#13; '+mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c+' &#13; from '+LOIStr : ''));
                                   // System.debug(mw.lpstr[i].leasePlan.Id +' mw.lpstr[i].leasePlan--> '+mw.lpstr[i].leasePlan.Lease_Unit__c+' Tenant--> '+ mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c);
                                    if(currentStat == 'LOI' || currentStat == 'Committed'){
                                        mw.lpstr[prevIndex].cellText= cellText;
                                    }
                                    
                                    if(mw.lpstr[prevIndex].cellText =='' || (currentStat == 'Vacant' && !mw.lpstr[prevIndex].cellText.contains('from'))){
                                        if(mw.lpstr[prevIndex].cellText.contains('to')){
                                            mw.lpstr[prevIndex].cellText = 'Vacant: &#13; '+mw.unit.Sub_Trade_Category__c+' &#13; from '+vacantFromText + mw.lpstr[prevIndex].cellText;
                                        }else{
                                            mw.lpstr[prevIndex].cellText = 'Vacant: &#13; '+mw.unit.Sub_Trade_Category__c+' &#13; from '+vacantFromText;
                                        }
                                    }
                                    if(mw.lpstr[prevIndex].cellText =='' || (currentStat == 'Vacant' && !mw.lpstr[prevIndex].cellText.contains('to'))){
                                    	for(Integer l=prevIndex ; l< mw.lpstr[prevIndex].colSpan; l++){
                                    		mw.lpstr[prevIndex].hurdleAmt += mw.lpstr[l].leasePlan.Rent_Hurdle__c; 
                                    	}
                                        mw.lpstr[prevIndex].cellText += ' to '+ vacantTillText +' &#13; Rent Hurdle Rate-'+mw.lpstr[prevIndex].hurdleAmt+'  '+tradeCatString;
                                    }
                                    //System.debug('mw.lpstr[prevIndex].cellText222-->'+mw.lpstr[prevIndex].cellText);
                                }
                                
                                
                                tempCount = 1; 
                                prevIndex = i;
                            }  
                            
                            //Vacant From Hover text Logic
                            if(mw.lpstr[i].leasePlan.get('Status_1__c') == 'Committed' && mw.lpstr[i].leasePlan.Status__c == 'Vacant' && mw.lpstr[i].leasePlan.Vacant__c && mw.lpstr[i].leasePlan.Commited__c){
                                String tempVacantFrom;
                                for(Integer k = 1 ; k <= 31 ; k++){
                                    if(mw.lpstr[i].leasePlan.get('Status_'+k+'__c') == 'Vacant'){
                                        --k; 
                                        Date tempDate =(Date) mw.lpstr[i].leasePlan.get('Day_'+k+'__c');
                                        if(tempDate != null){
                                            tempVacantFrom = tempDate.day()+'/'+tempDate.month()+'/'+tempDate.Year();
                                            vacantFromText = tempDate.day()+1+'/'+tempDate.month()+'/'+tempDate.Year();
                                        }
                                        break;
                                    }
                                }
                                mw.lpstr[prevIndex].cellText = 'Vacant: &#13; '+mw.unit.Sub_Trade_Category__c+' from '+vacantFromText;
                                //System.debug('33 @@@@@@@@@mw.lpstr[prevIndex].cellText-->'+mw.lpstr[prevIndex].cellText);
                                mw.lpstr[prevIndex].vacantFrom = 'Commited End Date '+ tempVacantFrom;
                            }else if(mw.lpstr[i].leasePlan.get('Status_1__c') == 'Vacant' && mw.lpstr[i].leasePlan.Status__c == 'Vacant' && mw.lpstr[i].leasePlan.Vacant__c && mw.lpstr[i].leasePlan.Commited__c){
                                String tempVacantFrom;
                                for(Integer k = 1 ; k <= 31 ; k++){
                                    if(mw.lpstr[i].leasePlan.get('Status_'+k+'__c') == 'Committed'){
                                        Date tempDate =(Date) mw.lpstr[i].leasePlan.get('Day_'+k+'__c');
                                        if(tempDate != null){
                                            tempVacantFrom = tempDate.day()+'/'+tempDate.month()+'/'+tempDate.Year();
                                            vacantTillText = tempDate.day()-1+'/'+tempDate.month()+'/'+tempDate.Year();
                                        }
                                        break;
                                    }
                                }
                                for(Integer l=prevIndex ; l< mw.lpstr[prevIndex].colSpan; l++){
                            		mw.lpstr[prevIndex].hurdleAmt += mw.lpstr[l].leasePlan.Rent_Hurdle__c; 
                            	}
                                mw.lpstr[prevIndex].cellText += ' to '+ vacantTillText +' &#13; Rent Hurdle Rate-'+mw.lpstr[prevIndex].hurdleAmt+' ZZZ '+tradeCatString;
                                mw.lpstr[prevIndex].committedFrom = 'Committed Start Date '+ tempVacantFrom;
                            } 
                        }
                        counterTemp++;
                        System.debug('<----->');
                    }
                    if(mw.rowHeader == 'Total Variance'){
                        for(Integer i=0; i < mw.lpstr.size(); i++){
                        	//    Total Budget
                        	mainWrapper[mainWrapSize+5].lpstr[i].totalBudget += mainWrapper[mainWrapSize+6].lpstr[i].totalBudget+mainWrapper[mainWrapSize+8].lpstr[i].totalBudget+mainWrapper[mainWrapSize+9].lpstr[i].totalBudget -(mainWrapper[mainWrapSize+10].lpstr[i].totalBudget + mainWrapper[mainWrapSize+11].lpstr[i].totalBudget);
                        	//    Total Variance
                            mainWrapper[mainWrapSize+7].lpstr[i].totalBudget +=  mainWrapper[mainWrapSize+6].lpstr[i].totalBudget - mainWrapper[mainWrapSize+5].lpstr[i].totalBudget;
                        }
                    }
                    
                }
                for(MainWrapper mw:mainWrapper){
                    if((mw.endTab == 1 || mw.endTab == 2) && mw.rowHeader != ''){
                        for(Integer i=0; i < mw.lpstr.size(); i++){
                            if(mw.endTab == 1 && mw.lpstr[i].totalNLA != 0){
                                if(i < mw.lpstr.size()/2){
                                    mw.totalAmountCrYr += mw.lpstr[i].totalNLA;
                                }else{
                                    mw.totalAmountNtYr += mw.lpstr[i].totalNLA;
                                }
                            }
                            if(mw.endTab == 2 && mw.lpstr[i].totalBudget != 0){
                                if(i < mw.lpstr.size()/2){
                                    mw.totalAmountCrYr += mw.lpstr[i].totalBudget;
                                }else{
                                    mw.totalAmountNtYr += mw.lpstr[i].totalBudget;
                                }
                            }
                            
                            mw.lpstr[i].totalNLASTR = LOIReportInterfaceController.FormatNumber(mw.lpstr[i].totalNLA);
			                mw.lpstr[i].totalNLASTRFormatted  = LOIReportInterfaceController.doFormatting(mw.lpstr[i].totalNLA, 2, ',', '.');
			                
			                
			                mw.lpstr[i].totalBudgetSTR = LOIReportInterfaceController.FormatNumber(mw.lpstr[i].totalBudget);
			                mw.lpstr[i].totalBudgetSTRFormatted  = LOIReportInterfaceController.doFormatting(mw.lpstr[i].totalBudget, 2, ',', '.');
			                
			                
                            mw.totalAmountCrYrSTR = LOIReportInterfaceController.FormatNumber(mw.totalAmountCrYr);
			                mw.totalAmountCrYrSTRFormatted  = LOIReportInterfaceController.doFormatting(mw.totalAmountCrYr, 2, ',', '.');
			                
			                mw.totalAmountNtYrSTR = LOIReportInterfaceController.FormatNumber(mw.totalAmountNtYr);
	                        mw.totalAmountNtYrSTRFormatted  = LOIReportInterfaceController.doFormatting(mw.totalAmountNtYr, 2, ',', '.');
                        }
                    }
                }
              
                totalForecast1stAmount =  mainWrapper[mainWrapSize+6].totalAmountCrYr + mainWrapper[mainWrapSize+8].totalAmountCrYr +  mainWrapper[mainWrapSize+9].totalAmountCrYr - mainWrapper[mainWrapSize+10].totalAmountCrYr - mainWrapper[mainWrapSize+11].totalAmountCrYr;
                totalForecast2ndAmount =  mainWrapper[mainWrapSize+6].totalAmountNtYr + mainWrapper[mainWrapSize+8].totalAmountNtYr +  mainWrapper[mainWrapSize+9].totalAmountNtYr - mainWrapper[mainWrapSize+10].totalAmountNtYr - mainWrapper[mainWrapSize+11].totalAmountNtYr;
                
                totalForecast1stAmountSTR = LOIReportInterfaceController.FormatNumber(totalForecast1stAmount);
                totalForecast1stAmountSTRformatted  = LOIReportInterfaceController.doFormatting(totalForecast1stAmount, 2, ',', '.');
                
                totalForecast2ndAmountSTR = LOIReportInterfaceController.FormatNumber(totalForecast2ndAmount);
                totalForecast2ndAmountSTRformatted  = LOIReportInterfaceController.doFormatting(totalForecast2ndAmount, 2, ',', '.');
                showInterface = true;
            }else{
                showInterface = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'No records found for selected Property.'));
            }
            
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select Property.'));
        }
        
    }
    public Class MainWrapper{
        public Units__c unit{get;set;}
        public Decimal avgMonthBudgt{get;set;}
        public String avgMonthBudgtSTR{get;set;}
        public String avgMonthBudgtSTRformatted{get;set;}
        public Decimal avgNLA{get;set;}
        public String avgNLASTR{get;set;}
        public String avgNLASTRformatted{get;set;}
        public Decimal budgetRent{get;set;}
        public String budgetRentSTR{get;set;}
        public String budgetRentSTRformatted{get;set;}
        public Decimal totalAmountCrYr{get;set;}
        public Decimal totalAmountNtYr{get;set;}
        public String totalAmountCrYrSTR{get;set;}
        public String totalAmountNtYrSTR{get;set;}
        public String totalAmountCrYrSTRFormatted{get;set;}
        public String totalAmountNtYrSTRFormatted{get;set;}
        public String bgColor{get;set;}
        public Integer endTab{get;set;}
        public String rowHeader{get;set;}
        public List<LPStructure> lpstr{get;set;}
        public Boolean hideRow{get;set;}
        public String smallHeader{get;set;}
        public Boolean firstRow{get;set;}
        
        
        public MainWrapper(){
            unit = new Units__c();
            avgMonthBudgt = 0;
            avgMonthBudgtSTR ='';
            avgMonthBudgtSTRformatted ='';
            avgNLA = 0;
            avgNLASTR = '';
            avgNLASTRformatted = '';
            budgetRent = 0;
            budgetRentSTR = '';
            budgetRentSTRformatted = '';
            endTab = 0;
            hideRow = false;
            firstRow = false;
            lpstr = new List<LPStructure>();
            rowHeader ='';
            smallHeader='';
            totalAmountCrYr = 0;
            totalAmountNtYr = 0;
            totalAmountCrYrSTR = '';
            totalAmountNtYrSTR = '';
            totalAmountCrYrSTRFormatted = '';
            totalAmountNtYrSTRFormatted = '';
            bgColor = '';
        }
    }
    public Class LPStructure{
        public Lease_Plan__c leasePlan{get;set;}
        public String status{get;set;}
        public String headerMonth{get;set;}
        public Integer cellIndex{get;set;}
        public Integer colSpan{get;set;}
        public String bgColor{get;set;}
        public String cellText{get;set;}
        public Boolean removeCell{get;set;}
        public Decimal hurdleAmt{get;set;}
        public Decimal totalNLA{get;set;}
        public Decimal totalBudget{get;set;}
        public String cellStyle{get;set;}
        
        public String totalNLASTR{get;set;}
        public String totalBudgetSTR{get;set;}
        
        public String totalNLASTRFormatted{get;set;}
        public String totalBudgetSTRFormatted{get;set;}
        
        public Decimal recBudget{get;set;}
        public String vacantFrom{get;set;}
        public String committedFrom{get;set;}
        public LPStructure(){
            leasePlan = new Lease_Plan__c();
            cellStyle ='white';
            colSpan = 1;
            cellText = '';
            bgColor = '';
            status = '';
            totalNLA= 0;
            hurdleAmt = 0;
            totalBudget = 0;
            totalNLASTR= '';
            totalBudgetSTR = '';
            totalNLASTRFormatted= '';
            totalBudgetSTRFormatted = '';
            committedFrom ='';
            vacantFrom ='';
        }
    }
}