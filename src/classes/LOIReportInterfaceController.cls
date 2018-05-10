public class LOIReportInterfaceController {

    public Transient  List<MainWrapper> mainWrapper{get;set;}
    public Transient  List<MainWrapper> singleRecWrapper{get;set;}
    public List<LPStructure> lpWrapper{get;set;}
    public Boolean showInterface{get;set;}
    public Boolean showUnitDiv{get;set;}
    public String selectedUnit{get;set;} 
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
    Map<Id,List<Lease_Charges__c>> LeaseChargeWithIds;
    public Integer currentYear{get;set;}
    Map<Integer,String> monthMap;
    public Units__c unitUI{get;set;}
    public Lease_Plan__c leasePlanUI{get;set;}
    public String selectedYear{get;set;} 
    public List<SelectOption> getYearOptions(){
        List < SelectOption > options = new List < SelectOption > ();
        Integer tempYear = System.today().year() - 7;
        for(Integer i=0; i<=10;i++){
            options.add(new SelectOption(++tempYear+'', tempYear+''));
        }
        return options;
    }
    public String selectedTradeCat{get;set;} 
    public List<SelectOption> getTradeCatOptions(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =   Units__c.Trade_Category__c.getDescribe();
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
    public LOIReportInterfaceController(){
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
    }
    
    public void Generate(){
        
        singleRecWrapper = new List<MainWrapper>();
        mainWrapper = new List<MainWrapper>();
        lpWrapper = new List<LPStructure>();
        showInterface = false;
        showUnitDiv = false;
        if(unitUI.Property__c != null){
            currentYear = Integer.valueof(selectedYear);

            totalForecast1stAmount = 0;
            totalForecast2ndAmount = 0;
            mainWrapper = new List<MainWrapper>();
            lpWrapper = new List<LPStructure>();
            
            date myDate = date.newInstance(currentYear, 1, 1);
            date endDate = date.newInstance(currentYear+2, 1, 1);
            
            String  soqlQueryUnit = 'select Id,Name,Start_Date__c,End_Date__c,Property__r.Short_Code__c,'
                                    +'Sub_Trade_Category__c,Sub_Trade_Category_1__c,Sub_Trade_Category_2__c,Sub_Trade_Category_3__c,'
                                    +'Trade_Category__c,Trade_category_1__c,Trade_category_2__c,Trade_category_3__c,'
                                    +'Rent_Hurdle_1__c,Rent_Hurdle_2__c,Rent_Hurdle_3__c,Unique_Selling_Point__c'
                                    +' from Units__c where  CreatedDate != null And Active__c = true And Charge_Method__c INCLUDES (\'Monthly Rate - L\')';// (id = \'a03O000000IslYK\' Or Main_Unit__c = \'a03O000000IslYK\') And
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
            System.debug('soqlQueryUnit--> '+soqlQueryUnit);
            listUnit = database.query(soqlQueryUnit);
            if(listUnit.size() > 0){
                Set<Id> unitIdsSrch = new Set<Id>();
                for(Units__c luId:listUnit){
                    unitIdsSrch.add(luId.Id);
                }
                System.debug('unitIdsSrch.size()-->'+unitIdsSrch.size());
                String lpSOQL = 'select Id,Unit__c,Unit__r.name,Commited__c,Vacant__c,Status__c,LOI__c from Lease_Plan__c where  Start_Date__c != null And End_Date__c != null And Unit__c =: unitIdsSrch';
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
                unitIdsSrch = new Set<Id>();
                for(Lease_Plan__c lp:tempLPforUnitIds){
                    if(!unitIdsSrch.contains(lp.Unit__c)){
                        if(leasePlanUI.Status__c == 'All'){
                            unitIdsSrch.add(lp.Unit__c);
                        }else{
                            if(lp.Status__c == leasePlanUI.Status__c){
                                unitIdsSrch.add(lp.Unit__c);
                                System.debug(lp.Unit__c+' '+ lp.Unit__r.name+ ' lp Id--> '+lp.Id +' lp.Status__c-->'+lp.Status__c);
                            }else if(leasePlanUI.Status__c == 'Committed'){
                                if(lp.Vacant__c && lp.Commited__c && !lp.LOI__c){
                                    unitIdsSrch.add(lp.Unit__c);
                                    System.debug(lp.Unit__c + 'lp Id-->'+lp.Unit__c +'lp.Status__c-->'+lp.Status__c);
                                }
                            }
                        }
                    }
                } 
                System.debug('unitIdsSrch.size()-->'+unitIdsSrch.size());
                String  soqlQueryLP = 'select Name,Commited__c,Vacant__c,LOI__c,Fit_out__c,Status_1__c,Status_2__c,Status_3__c,Status_4__c,Status_5__c,Status_6__c,'
                                        +'Day_1__c,Day_2__c,Day_3__c,Day_4__c,Day_5__c,LOI_Monthly_Budget__c,Monthly_Committed_Budget__c,'
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
                                        +'LOI_Unit__c,LOI_Unit__r.LOI_Agreement_No__c,LOI_Unit__r.LOI_Agreement_No__r.Tenant_Name__c,LOI_Unit__r.LOI_Agreement_No__r.LOI_Status__c,'
                                        +'Lease_Unit__c,Lease_Unit__r.Lease_Agreement_No__c,Lease_Unit__r.Fit_Out_Date__c,Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c,'
                                        +'Rent_Hurdle__c,unit__r.Trade_Category__c,Lease_Unit__r.Lease_Start_Date__c,Lease_Unit__r.Lease_Agreement_No__r.Lease_Status__c from Lease_Plan__c where Start_Date__c != null And End_Date__c != null ';
                soqlQueryLP += ' And Unit__c  =: unitIdsSrch'; 

                soqlQueryLP += ' And Start_Date__c >= '+string.valueOf(myDate)+' And End_Date__c < '+string.valueOf( endDate)+' Order By Start_Date__c Asc';
                
                System.debug('soqlQueryLP--> '+soqlQueryLP);
                List<Lease_Plan__c> listLP = database.query(soqlQueryLP);
                unitIdsSrch = new Set<Id>();
                
                for(Integer i=1; i<=24 ; i++){
                    LPStructure lpr= new LPStructure();
                    date newDate = myDate;
                    lpr.headerMonth = newDate.Year()+'<br/>'+monthMap.get(newDate.Month());
                    myDate = myDate.addMonths(1);
                    lpWrapper.add(lpr);
                }
                
                Map<Id, List<Lease_Plan__c>> listOfMPLp= new Map<Id, List<Lease_Plan__c>>();
                Set<Id> leaseUnitIds = new Set<Id>();
                LeaseChargeWithIds = new Map<Id,List<Lease_Charges__c>>();
                for(Lease_Plan__c ls: listLP){
                    unitIdsSrch.add(ls.Unit__c);
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
                mainWrapper.add(mw1);
                for(Units__c lu:listUnit){
                    if((unitIdsSrch.contains(lu.Id) && leasePlanUI.Status__c != 'All') || leasePlanUI.Status__c == 'All'){
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
                            Boolean LOICancelled = false;
                        	Boolean LACancelled = false;
                            for(Lease_Plan__c lpp:listOfMPLp.get(lu.Id)){
                            	
                            	String strLOIStat = lpp.LOI_Unit__r.LOI_Agreement_No__r.LOI_Status__c;
								String strLAStat =  lpp.Lease_Unit__r.Lease_Agreement_No__r.Lease_Status__c;
								if( strLOIStat == 'Cancelled'){
									LOICancelled = true;
								} 
								if( strLAStat == 'Cancelled'){
									LACancelled = true;
								}
								
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
                                String currentStat = lpp.Status__c;
                                String tempStr = 'from '+stdt+' to1 '+endt + 'PPPPP Mthly Rent $ ' + ((currentStat == 'LOI')?lpp.LOI_Monthly_Budget__c:((currentStat== 'Committed')?lpp.Monthly_Committed_Budget__c:lpp.Monthly_Budget__c));
                                str.bgColor = (lpp.Status__c == 'Vacant' || LOICancelled || LACancelled) ? 'rgba(204, 0, 0, 0.57) !important' :( (lpp.Status__c == 'LOI') ? 'rgba(58, 102, 144, 0.78) !important' : ((lpp.Status__c == 'Committed') ? 'rgba(49, 148, 49, 0.75) !important' : 'rgba(229, 193, 48, 0) !important'));
                                 str.cellText = (lpp.Status__c == 'Vacant') ? '' : ((lpp.Status__c == 'LOI') ? 'LOI: PPPPP '+lpp.LOI_Unit__r.LOI_Agreement_No__r.Tenant_Name__c+' PPPPP '+tempStr : ((lpp.Status__c == 'Committed') ? 'Lease Commited: PPPPP '+lpp.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c+' PPPPP '+tempStr : ''));
                                 System.debug(lpp.Id+' lpp.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c-->'+lpp.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c);
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
                } 
                Integer mainWrapSize = mainWrapper.Size();
                MainWrapper mmw =new MainWrapper();
                mmw.endTab = 1;
                mmw.bgColor='rgba(153, 153, 153, 0.67)';
                mmw.rowHeader = 'Total NLA';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 1;
                mmw.hideRow = true;
                mmw.bgColor = 'rgba(204, 0, 0, 0.48) !important;';
                mmw.rowHeader = 'Vacant NLA';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 1;
                mmw.hideRow = true;
                mmw.bgColor = 'rgba(49, 148, 49, 0.66) !important';
                mmw.rowHeader = 'Leased NLA';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 1;
                mmw.hideRow = true;
                mmw.bgColor = 'rgba(58, 102, 144, 0.65) !important';
                mmw.rowHeader = 'LOI NLA';
                mainWrapper.add(mmw);
                
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mmw.bgColor='rgba(153, 153, 153, 0.67)';
                mmw.rowHeader = 'Total Budget';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mmw.hideRow = true;
                mmw.smallHeader = 'a';
                mmw.bgColor = 'rgba(49, 148, 49, 0.66) !important';
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
                mmw.bgColor = 'rgba(204, 0, 0, 0.48) !important;';
                mmw.rowHeader = 'Total Vacant Amount (Forecast)';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mmw.hideRow = true;
                mmw.smallHeader = 'd';
                mmw.bgColor = 'rgba(58, 102, 144, 0.65) !important';
                mmw.rowHeader = 'Total Pending LOI';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mmw.hideRow = true;
                mmw.smallHeader = 'e';
                mmw.bgColor = 'rgba(58, 102, 144, 0.65) !important';
                mmw.rowHeader = 'Total Over/Under LOI';
                mainWrapper.add(mmw);
                mmw =new MainWrapper();
                mmw.endTab = 2;
                mmw.hideRow = true;
                mmw.smallHeader = 'f';
                mmw.bgColor = 'rgba(58, 102, 144, 0.65) !important';
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
                            tradeCatString = 'PPPPP '+mw.unit.Sub_Trade_Category_1__c +' - '+ mw.unit.Rent_Hurdle_1__c;
                        }
                        if(mw.unit.Sub_Trade_Category_2__c != null){
                            if(mw.unit.Sub_Trade_Category_1__c != null){
                                tradeCatString += '; ';
                            }
                            tradeCatString += mw.unit.Sub_Trade_Category_2__c +' - '+ mw.unit.Rent_Hurdle_2__c;
                        }
                        if(mw.unit.Sub_Trade_Category_3__c != null){
                            if(mw.unit.Sub_Trade_Category_2__c != null || (mw.unit.Sub_Trade_Category_1__c != null && mw.unit.Trade_category_2__c == null)){
                                tradeCatString += '; ';
                            } 
                            tradeCatString += mw.unit.Sub_Trade_Category_3__c +' - '+ mw.unit.Rent_Hurdle_3__c;
                        }
                        if(mw.unit.Unique_Selling_Point__c != null){
                            tradeCatString += ' USP: '+mw.unit.Unique_Selling_Point__c;
                        }
                        if(mw.unit.Sub_Trade_Category__c == null){
                            mw.unit.Sub_Trade_Category__c = '';
                        }
                        Integer prevIndex;
                        String prevVal;
                        String prevLeaseUnit;
                        String prevLOIUnit;
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
                                    //Vacant NLA
                                    mainWrapper[mainWrapSize+1].lpstr[i].totalNLA += mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                                    //Total Vacant Amount (Forecast)
                                    mainWrapper[mainWrapSize+8].lpstr[i].totalBudget += mw.lpstr[i].leasePlan.Monthly_Budget__c* mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                                }
                                //Lease Committed
                                if(mw.lpstr[i].leasePlan.Status__c == 'Committed'){
                                    //Leased NLA
                                    mainWrapper[mainWrapSize+2].lpstr[i].totalNLA += mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                                    //Total Leased Amount
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
                                    //Leased NLA
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
                            String stdt = '';
                            String endt = '';
                            if(prevVal == null && prevLeaseUnit == null && prevLOIUnit == null){
                                prevIndex = i;
                                prevVal = mw.lpstr[i].status;
                                prevLeaseUnit = mw.lpstr[i].leasePlan.Lease_Unit__c;
                                prevLOIUnit = mw.lpstr[i].leasePlan.LOI_Unit__c;
                                mw.lpstr[i].colSpan = 1;
                                
                                //mw.lpstr[prevIndex].hurdleAmt += mw.lpstr[i].leasePlan.Rent_Hurdle__c;
                                //System.debug('hurdle on null-->'+mw.lpstr[prevIndex].hurdleAmt);
                            }else if(prevLOIUnit == mw.lpstr[i].leasePlan.LOI_Unit__c && prevLeaseUnit == mw.lpstr[i].leasePlan.Lease_Unit__c && prevVal == mw.lpstr[i].status && mw.lpstr[i].status != ''){
                                tempCount++;
                                mw.lpstr[prevIndex].colSpan = tempCount;
                                mw.lpstr[i].colSpan = 0;
                                
                                
                                if(i == mw.lpstr.size()-1){
                                    Date startDatte = mw.lpstr[prevIndex].leasePlan.Start_Date__c;
                                    Date endDatte = mw.lpstr[i].leasePlan.End_Date__c;
                                    
                                    stdt = startDatte.day() +'/'+startDatte.month()+'/'+startDatte.year();
                            	    endt = endDatte.day() +'/'+endDatte.month()+'/'+endDatte.year();
                            
                                    String currentStat = mw.lpstr[prevIndex].leasePlan.Status__c;
                                    
                                    String LOIStr =  'from '+stdt +' to '+ endt +' PPPPP Mthly Rent $ '+ ((mw.lpstr[prevIndex].leasePlan.Status__c == 'LOI')?mw.lpstr[prevIndex].leasePlan.LOI_Monthly_Budget__c:((mw.lpstr[prevIndex].leasePlan.Status__c == 'Committed')?mw.lpstr[prevIndex].leasePlan.Monthly_Committed_Budget__c:mw.lpstr[prevIndex].leasePlan.Monthly_Budget__c));
                                    String cellText = (currentStat == 'Vacant') ? 'Vacant: PPPPP ' : ((currentStat == 'LOI') ? 'LOI: PPPPP '+mw.lpstr[prevIndex].leasePlan.LOI_Unit__r.LOI_Agreement_No__r.Tenant_Name__c+' PPPPP '+LOIStr : ((currentStat == 'Committed') ? 'Lease committed: PPPPP '+mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c+' PPPPP '+LOIStr : ''));
                                    
                                    System.debug('cellText-->'+cellText); 

                                    System.debug('mw.lpstr[prevIndex].cellText111-->'+mw.lpstr[prevIndex].cellText);
                                    if(currentStat == 'LOI' || currentStat == 'Committed'){
                                    	String fitoutAdd  ='';
                                    	if(currentStat == 'Committed' && mw.lpstr[i].leasePlan.Fit_out__c && mw.lpstr[i].leasePlan.Lease_Unit__r.Fit_Out_Date__c != null){
                                    		Date fitoutStartDt = mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Fit_Out_Date__c;
                                    		Date fitoutEndDt = mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Lease_Start_Date__c;
                                		    fitoutAdd = 'Lease Fitout: PPPPP '+
                                					mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c+ ' PPPPP '+
                                					'from '+
													fitoutStartDt.day()+'/'+fitoutStartDt.month()+'/'+fitoutStartDt.Year()+
													' To ' + 
													fitoutEndDt.day()+'/'+fitoutEndDt.month()+'/'+fitoutEndDt.Year() +
													'  PPPPP PPPPP  ';	
		                                }
		                                
                                        mw.lpstr[prevIndex].cellText = fitoutAdd + cellText;
                                    }else if(currentStat == 'Vacant'){
                                        for(Integer l=prevIndex ; l< mw.lpstr[prevIndex].colSpan; l++){
                                            mw.lpstr[prevIndex].hurdleAmt += mw.lpstr[l].leasePlan.Rent_Hurdle__c; 
                                        }
                                        vacantTillText = ' to '+ endt +' PPPPP Rent Hurdle Rate-'+mw.lpstr[prevIndex].hurdleAmt+' '+tradeCatString;
                                        if(mw.lpstr[prevIndex].cellText.contains('from')){
                                            mw.lpstr[prevIndex].cellText += vacantTillText;
                                        }else{
                                            mw.lpstr[prevIndex].cellText = 'Vacant: PPPPP '+mw.unit.Sub_Trade_Category__c+' PPPPP from '+stdt+vacantTillText;
                                        }
                                        
                                    }
                                } 
                            }else{
                            	prevLeaseUnit = mw.lpstr[i].leasePlan.Lease_Unit__c;
                                prevVal = mw.lpstr[i].status;
                                mw.lpstr[prevIndex].colSpan = tempCount;
                                
                                mw.lpstr[i].colSpan = 1; 
                                
                                Date startDatte = mw.lpstr[prevIndex].leasePlan.Start_Date__c;
                                Date endDatte = mw.lpstr[i-1].leasePlan.End_Date__c; 
                                 
                                if(tempCount > 1 ){
                                    String currentStat = mw.lpstr[prevIndex].leasePlan.Status__c;
                                    stdt = startDatte.day() +'/'+startDatte.month()+'/'+startDatte.year();
                            	    endt = endDatte.day() +'/'+endDatte.month()+'/'+endDatte.year();
                                    
                                    vacantTillText = mw.lpstr[i-1].leasePlan.End_Date__c.day()+'/'+mw.lpstr[i-1].leasePlan.End_Date__c.month()+'/'+mw.lpstr[i-1].leasePlan.End_Date__c.year(); 
                                    String LOIStr =  'from '+stdt +' to '+ vacantTillText +' PPPPP Mthly Rent $ '+ ((currentStat == 'LOI')?mw.lpstr[prevIndex].leasePlan.LOI_Monthly_Budget__c:((currentStat== 'Committed')?mw.lpstr[prevIndex].leasePlan.Monthly_Committed_Budget__c:mw.lpstr[prevIndex].leasePlan.Monthly_Budget__c));
                                    vacantFromText = stdt;
                                    
                                    String cellText = (currentStat == 'Vacant') ? 'Vacant: PPPPP ' : ((currentStat == 'LOI') ? 'LOI: PPPPP '+mw.lpstr[prevIndex].leasePlan.LOI_Unit__r.LOI_Agreement_No__r.Tenant_Name__c+' PPPPP' : ((currentStat == 'Committed') ? 'Lease committed: PPPPP '+mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c+' PPPPP  ' : ''));
                                    //System.debug(mw.lpstr[i].leasePlan.Id +' mw.lpstr[i].leasePlan--> '+mw.lpstr[i].leasePlan.Lease_Unit__c+' Tenant--> '+ mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c);
                                    if(currentStat == 'LOI' || currentStat == 'Committed'){
                                    	String fitoutAdd  ='';
                                    	mw.lpstr[prevIndex].cellText= cellText + LOIStr;
                                    	if(currentStat == 'Committed' && mw.lpstr[prevIndex].leasePlan.Fit_out__c && mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Fit_Out_Date__c != null){
                                    		Date fitoutStartDt = mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Fit_Out_Date__c;
                                    		Date fitoutEndDt = mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Lease_Start_Date__c-1;
                                		    fitoutAdd = 'Lease Fitout: PPPPP '+
                                					mw.lpstr[prevIndex].leasePlan.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c+ ' PPPPP '+
                                					'from '+
													fitoutStartDt.day()+'/'+fitoutStartDt.month()+'/'+fitoutStartDt.Year()+
													' To ' + 
													fitoutEndDt.day()+'/'+fitoutEndDt.month()+'/'+fitoutEndDt.Year() +
													'  PPPPP PPPPP  ';	
											fitoutEndDt+=1;
											LOIStr =  'from '+fitoutEndDt.day()+'/'+fitoutEndDt.month()+'/'+fitoutEndDt.Year()  +' to '+ vacantTillText +' PPPPP Mthly Rent $ '+ ((currentStat == 'LOI')?mw.lpstr[prevIndex].leasePlan.LOI_Monthly_Budget__c:((currentStat== 'Committed')?mw.lpstr[prevIndex].leasePlan.Monthly_Committed_Budget__c:mw.lpstr[prevIndex].leasePlan.Monthly_Budget__c));
											mw.lpstr[prevIndex].cellText= fitoutAdd+cellText+LOIStr;
		                                }
                                    }
                                    
                                    if(((mw.lpstr[prevIndex].cellText =='' || (currentStat == 'Vacant' && !mw.lpstr[prevIndex].cellText.contains('from')))) && currentStat!='N/A'){
                                        if(mw.lpstr[prevIndex].cellText.contains('to')){
                                            mw.lpstr[prevIndex].cellText = 'Vacant: PPPPP '+mw.unit.Sub_Trade_Category__c+' PPPPP from '+vacantFromText + mw.lpstr[prevIndex].cellText;
                                        }else{
                                            mw.lpstr[prevIndex].cellText = 'Vacant: PPPPP '+mw.unit.Sub_Trade_Category__c+' PPPPP from '+vacantFromText;
                                        }
                                    }
                                    if((mw.lpstr[prevIndex].cellText =='' || (currentStat == 'Vacant' && !mw.lpstr[prevIndex].cellText.contains('to'))) && currentStat!='N/A'){
                                        for(Integer l=prevIndex ; l< mw.lpstr[prevIndex].colSpan; l++){
                                            mw.lpstr[prevIndex].hurdleAmt += mw.lpstr[l].leasePlan.Rent_Hurdle__c; 
                                        }
                                        mw.lpstr[prevIndex].cellText += ' to '+ vacantTillText +' PPPPP Rent Hurdle Rate-'+mw.lpstr[prevIndex].hurdleAmt+'  '+tradeCatString;
                                    }
                                    //System.debug('mw.lpstr[prevIndex].cellText222-->'+mw.lpstr[prevIndex].cellText);
                                }
                                
                                
                                tempCount = 1; 
                                prevIndex = i;
                            }  
                            System.debug('mw.lpstr[i].cellText-->'+mw.lpstr[i].cellText); 
                            if(mw.lpstr[i].status == 'N/A' ){
                            	mw.lpstr[i].bgColor = 'rgba(95, 84, 84, 0.57) !important';
                            	mw.lpstr[i].cellText = '';
                            	
                            } 
                            //Vacant From Hover text Logic For Overlapping cell
                            //Overlapping cell
                            Boolean isCommitted = (mw.lpstr[i].leasePlan.Status__c == 'Vacant' && mw.lpstr[i].leasePlan.Vacant__c && mw.lpstr[i].leasePlan.Commited__c) ? true : false;
                            Boolean isFitout =  (mw.lpstr[i].leasePlan.Status__c == 'Vacant' && mw.lpstr[i].leasePlan.Vacant__c && mw.lpstr[i].leasePlan.Fit_out__c) ? true : false;
                            Boolean isLOI  =  (mw.lpstr[i].leasePlan.Status__c == 'Vacant' && mw.lpstr[i].leasePlan.Vacant__c && mw.lpstr[i].leasePlan.LOI__c) ? true : false;
                            
                            System.debug(mw.lpstr[i].leasePlan.Name+' leasePlan.Id @@-->'+mw.lpstr[i].leasePlan.Id);
                            System.debug('111-->'+mw.lpstr[i].leasePlan.Status__c + ' '+mw.lpstr[i].leasePlan.Vacant__c);
                            System.debug('222-->'+mw.lpstr[i].leasePlan.Commited__c+' '+mw.lpstr[i].leasePlan.Fit_out__c+' '+mw.lpstr[i].leasePlan.LOI__c);
                            System.debug('isCommitted-->'+isCommitted+''+isFitout+''+isLOI);
                            //To Generate Message for Overlapping cell
                            if(isCommitted || isFitout || isLOI){
                            	String vancantStartDt;
                            	String commitStartDt;
                            	String fitoutStartDt;
                            	String loiStartDt;
                            	String vancantEndDt;
                            	String commitEndDt;
                            	String fitoutEndDt;
                            	String loiEndDt;
                            	for(Integer k = 1 ; k <= 31 ; k++){
                            		Date tempDate = Date.newInstance(mw.lpstr[i].leasePlan.Start_Date__c.year(),mw.lpstr[i].leasePlan.Start_Date__c.Month(),k);
                            		String currntStatus =(String) mw.lpstr[i].leasePlan.get('Status_'+k+'__c');
                                    if(currntStatus == 'Vacant'){
                                       if(vancantStartDt == null){
                                       		vancantStartDt = tempDate.day()+'/'+tempDate.month()+'/'+tempDate.Year();
                                       } else{
                                       	    vancantEndDt = tempDate.day()+'/'+tempDate.month()+'/'+tempDate.Year();
                                       }
                                    }
                                    if(currntStatus == 'Fitout'){
                                       if(fitoutStartDt == null){
                                       		fitoutStartDt = tempDate.day()+'/'+tempDate.month()+'/'+tempDate.Year();
                                       } else{
                                       	    fitoutEndDt = tempDate.day()+'/'+tempDate.month()+'/'+tempDate.Year();
                                       }
                                    }
                                    if(currntStatus == 'Committed'){
                                       if(commitStartDt == null){
                                       		commitStartDt = tempDate.day()+'/'+tempDate.month()+'/'+tempDate.Year();
                                       } else{
                                       	    commitEndDt = tempDate.day()+'/'+tempDate.month()+'/'+tempDate.Year();
                                       }
                                    }
                                    if(currntStatus == 'LOI'){
                                       if(loiStartDt == null){
                                       		loiStartDt = tempDate.day()+'/'+tempDate.month()+'/'+tempDate.Year();
                                       } else{
                                       	    loiEndDt = tempDate.day()+'/'+tempDate.month()+'/'+tempDate.Year();
                                       }
                                       System.debug(k+' '+currntStatus+' ' +loiStartDt+' loiEndDt-->'+loiEndDt);
                                    }
                                    
                                }
                                
                                String fullMessage = '';
                                if(vancantStartDt != null){
                                	fullMessage += 'Vacant: PPPPP'+mw.unit.Sub_Trade_Category__c+' PPPPP from '+ vancantStartDt +' To ' + vancantEndDt +
                                				' PPPPP Rent Hurdle Rate - '+mw.lpstr[prevIndex].hurdleAmt+
                                				tradeCatString+
                                				'PPPPP PPPPP';	
                                }
                                if(fitoutStartDt != null){
                                	fullMessage += 'Lease Fitout: PPPPP '+
                                					mw.lpstr[i].leasePlan.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c+ ' PPPPP '+
                                					'from '+fitoutStartDt+' To ' + fitoutEndDt +'  PPPPP PPPPP  ';	
                                }
                                if(commitStartDt != null){
                                	fullMessage += 'Lease Committed: PPPPP '+
                                	mw.lpstr[i].leasePlan.Lease_Unit__r.Lease_Agreement_No__r.Tenant_Name__c+ ' PPPPP '+
                                	'from '+commitStartDt+' To ' + commitEndDt +
									' PPPPP Mthly Rent $ '+mw.lpstr[i].leasePlan.Monthly_Committed_Budget__c+
									'PPPPP PPPPP';	
                                }
                                if(loiStartDt != null){
                                	fullMessage += 'LOI: PPPPP from '+loiStartDt+' To ' + loiEndDt +
									' PPPPP Mthly Rent $ '+mw.lpstr[i].leasePlan.LOI_Monthly_Budget__c+
									'PPPPP PPPPP';	
                                }
                                System.debug('fullMessage-->'+fullMessage);
                                
                                System.debug('mw.lpstr[i].leasePlan.get(\'Status_1__c\')-->'+mw.lpstr[i].leasePlan.get('Status_1__c'));
                                
                                if(mw.lpstr[i].leasePlan.get('Status_1__c')  == 'Committed' || mw.lpstr[i].leasePlan.get('Status_1__c')  == 'LOI'){
                                	mw.lpstr[prevIndex].vacantFrom = fullMessage;
                                }
                                 if(mw.lpstr[i].leasePlan.get('Status_1__c')  == 'Vacant'){
                                	mw.lpstr[prevIndex].committedFrom = fullMessage;
                                }
                                System.debug('mw.lpstr[prevIndex].vacantFrom-->'+mw.lpstr[prevIndex].vacantFrom);
                                System.debug('mw.lpstr[prevIndex].committedFrom-->'+mw.lpstr[prevIndex].committedFrom);
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
    public void showUnitPanel(){
        singleRecWrapper = new List<MainWrapper>();
       
        selectedUnit = Apexpages.currentPage().getParameters().get('selectedUnit');
        Generate();
         showUnitDiv = true;
        System.Debug('singleRecWrapper-->'+selectedUnit);
        
        System.Debug('mainWrapper11-->'+mainWrapper);
        System.Debug('mainWrapper-->'+mainWrapper.size());
        if(mainWrapper != null){
            for(MainWrapper mw:mainWrapper){
                System.Debug('mw.endTab-->'+mw.endTab);
                System.Debug('mw.unit.Id-->'+mw.endTab);
                if(mw.endTab == 0 && mw.unit.Id == selectedUnit){ 
                    System.Debug('mw-->'+mw);
                    MainWrapper mw1 = new MainWrapper();
                    mw1 = mw;
                    singleRecWrapper.add(mw1);
                }
            } 
        }
        
        System.Debug('singleRecWrapper-->'+singleRecWrapper);
        System.Debug('singleRecWrapper.size()-->'+singleRecWrapper.size());
        MainWrapper mmw =new MainWrapper();
        mmw.endTab = 1;
        singleRecWrapper.add(mmw);
        mmw =new MainWrapper();
        mmw.endTab = 2;
        mmw.bgColor='rgba(153, 153, 153, 0.67)';
        mmw.rowHeader = 'Unit Budget';
        singleRecWrapper.add(mmw);
        mmw =new MainWrapper();
        mmw.endTab = 2;
        mmw.hideRow = true;
        mmw.smallHeader = 'a';
        mmw.bgColor = 'rgba(49, 148, 49, 0.66) !important';
        mmw.rowHeader = 'Budget Leased Amount';
        singleRecWrapper.add(mmw);
        mmw =new MainWrapper();
        mmw.endTab = 2;
        mmw.hideRow = true;
        mmw.smallHeader = 'b';
        mmw.rowHeader = 'Budget Variance';
        singleRecWrapper.add(mmw);
        mmw =new MainWrapper();
        mmw.endTab = 2;
        mmw.hideRow = true;
        mmw.smallHeader = 'c';
        mmw.bgColor = 'rgba(204, 0, 0, 0.48) !important;';
        mmw.rowHeader = 'Budget Vacant Amount (Forecast)';
        singleRecWrapper.add(mmw);
        mmw =new MainWrapper();
        mmw.endTab = 2;
        mmw.hideRow = true;
        mmw.smallHeader = 'd';
        mmw.bgColor = 'rgba(58, 102, 144, 0.65) !important';
        mmw.rowHeader = 'Budget Pending LOI';
        singleRecWrapper.add(mmw);
        mmw =new MainWrapper();
        mmw.endTab = 2;
        mmw.hideRow = true;
        mmw.smallHeader = 'e';
        mmw.bgColor = 'rgba(58, 102, 144, 0.65) !important';
        mmw.rowHeader = 'Budget Over/Under LOI';
        singleRecWrapper.add(mmw);
        mmw =new MainWrapper();
        mmw.endTab = 2;
        mmw.hideRow = true;
        mmw.smallHeader = 'f';
        mmw.bgColor = 'rgba(58, 102, 144, 0.65) !important';
        mmw.rowHeader = 'Budget Over/Under Leased ';
        singleRecWrapper.add(mmw);
         System.Debug('singleRecWrapper.size()-->'+singleRecWrapper.size());
        //Generate Wrapper Lower Part in Table with Units and Empty LP
        for(MainWrapper mw:singleRecWrapper){
            if(mw.endTab != 0){
                for(Integer j=1; j<=24 ; j++){
                    LPStructure tt = new LPStructure();
                    tt.cellIndex = j;
                    tt.colSpan = 1;
                    mw.lpstr.add(tt);
                }
            }
        }
        if(mainWrapper != null){
        for(MainWrapper mw:singleRecWrapper){
            if(mw.endTab == 0){ 
                 for(Integer i=0; i < mw.lpstr.size(); i++){
                    //Budget And Rent Calculations
                    if(mw.lpstr[i].leasePlan != null && mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c > 0 ){
                        
                        //vacant
                        if(mw.lpstr[i].leasePlan.Status__c == 'Vacant'){
                            //  Budget Vacant Amount (Forecast)
                            singleRecWrapper[5].lpstr[i].totalBudget += mw.lpstr[i].leasePlan.Monthly_Budget__c* mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                        }
                        //Lease Committed
                        if(mw.lpstr[i].leasePlan.Status__c == 'Committed'){
                            
                            // Budget Leased Amount
                           // singleRecWrapper[3].lpstr[i].totalBudget += mw.lpstr[i].leasePlan.Monthly_Budget__c* mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                           if(LeaseChargeWithIds.containsKey(mw.lpstr[i].leasePlan.Lease_Unit__c)){
                                for(Lease_Charges__c lc: LeaseChargeWithIds.get(mw.lpstr[i].leasePlan.Lease_Unit__c)){
                                    if(mw.lpstr[i].leasePlan.Start_Date__c >= lc.Start_Date__c && mw.lpstr[i].leasePlan.Start_Date__c <= lc.End_Date__c){
                                        ///  Budget Leased Amount 
                                        singleRecWrapper[3].lpstr[i].totalBudget += lc.Base_Rent_Calculation__c;
                                        break;
                                    }
                                }
                            }
                            
                           if(LeaseChargeWithIds.containsKey(mw.lpstr[i].leasePlan.Lease_Unit__c)){
                                for(Lease_Charges__c lc: LeaseChargeWithIds.get(mw.lpstr[i].leasePlan.Lease_Unit__c)){
                                    if(mw.lpstr[i].leasePlan.Start_Date__c >= lc.Start_Date__c && mw.lpstr[i].leasePlan.Start_Date__c <= lc.End_Date__c){
                                        //  Budget Over/Under Leased
                                        singleRecWrapper[8].lpstr[i].totalBudget += lc.Base_Rent_Calculation__c - (mw.lpstr[i].leasePlan.Monthly_Budget__c*mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c);
                                        break;
                                    }
                                }
                            }
                        }
                        //LOI
                        if(mw.lpstr[i].leasePlan.Status__c == 'LOI'){
                            //   Budget Pending LOI
                            singleRecWrapper[6].lpstr[i].totalBudget += mw.lpstr[i].leasePlan.Monthly_Budget__c* mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c;
                              
                           if(LeaseChargeWithIds.containsKey(mw.lpstr[i].leasePlan.Lease_Unit__c)){
                                for(Lease_Charges__c lc: LeaseChargeWithIds.get(mw.lpstr[i].leasePlan.Lease_Unit__c)){
                                    if(mw.lpstr[i].leasePlan.Start_Date__c >= lc.Start_Date__c && mw.lpstr[i].leasePlan.Start_Date__c <= lc.End_Date__c){
                                        ///  Budget Over/Under Leased 
                                        singleRecWrapper[7].lpstr[i].totalBudget += lc.Base_Rent_Calculation__c - (mw.lpstr[i].leasePlan.Monthly_Budget__c*mw.lpstr[i].leasePlan.Unit__r.NLA_SQF__c);
                                        break;
                                    }
                                }
                            }
                        }
                        
                    }
                 }
            }
            if(mw.rowHeader == 'Budget Variance'){
                for(Integer i=0; i < mw.lpstr.size(); i++){
                    //   Unit Budget
                    singleRecWrapper[2].lpstr[i].totalBudget += singleRecWrapper[3].lpstr[i].totalBudget+singleRecWrapper[5].lpstr[i].totalBudget+singleRecWrapper[6].lpstr[i].totalBudget -(singleRecWrapper[7].lpstr[i].totalBudget + singleRecWrapper[8].lpstr[i].totalBudget);
                    
                    //   Budget Variance
                    singleRecWrapper[4].lpstr[i].totalBudget += singleRecWrapper[3].lpstr[i].totalBudget - singleRecWrapper[2].lpstr[i].totalBudget ;
                }
            }
        }
        
        for(MainWrapper mw:singleRecWrapper){
            if((mw.endTab == 1 || mw.endTab == 2) && mw.rowHeader != ''){
                for(Integer i=0; i < mw.lpstr.size(); i++){
                    if(mw.endTab == 2 && mw.lpstr[i].totalBudget != 0){
                        if(i < mw.lpstr.size()/2){
                            mw.totalAmountCrYr += mw.lpstr[i].totalBudget;
                        }else{
                            mw.totalAmountNtYr += mw.lpstr[i].totalBudget;
                        }
                    }  
                    mw.totalAmountCrYrSTR = LOIReportInterfaceController.FormatNumber(mw.totalAmountCrYr);
                    mw.totalAmountCrYrSTRformatted  = LOIReportInterfaceController.doFormatting(mw.totalAmountCrYr, 2, ',', '.');
                    
                    mw.totalAmountNtYrSTR = LOIReportInterfaceController.FormatNumber(mw.totalAmountNtYr);
                    mw.totalAmountNtYrSTRformatted  = LOIReportInterfaceController.doFormatting(mw.totalAmountNtYr, 2, ',', '.');
                    
                    mw.lpstr[i].totalNLASTR = LOIReportInterfaceController.FormatNumber(mw.lpstr[i].totalNLA);
                    mw.lpstr[i].totalNLASTRFormatted  = LOIReportInterfaceController.doFormatting(mw.lpstr[i].totalNLA, 2, ',', '.');
                    
                    mw.lpstr[i].totalBudgetSTR = LOIReportInterfaceController.FormatNumber(mw.lpstr[i].totalBudget);
                    mw.lpstr[i].totalBudgetSTRFormatted  = LOIReportInterfaceController.doFormatting(mw.lpstr[i].totalBudget, 2, ',', '.');
                }
            }
        }
       Integer op = 0;
       op+=1;
       Integer lm = 10;
       lm = lm+op;
       lm = lm+op;
       op = lm+op;
       lm = lm+op;
       op = lm+op;
       lm = lm+op;
       op = lm+op;

      totalForecast3rdAmount =  singleRecWrapper[3].totalAmountCrYr + singleRecWrapper[5].totalAmountCrYr +  singleRecWrapper[6].totalAmountCrYr - singleRecWrapper[7].totalAmountCrYr - singleRecWrapper[8].totalAmountCrYr;
      totalForecast4thAmount =  singleRecWrapper[3].totalAmountNtYr + singleRecWrapper[5].totalAmountNtYr +  singleRecWrapper[6].totalAmountNtYr - singleRecWrapper[7].totalAmountNtYr - singleRecWrapper[8].totalAmountNtYr;
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
            bgColor = 'rgba(229, 193, 48, 0) !important';
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
        
        public String totalNLASTR{get;set;}
        public String totalBudgetSTR{get;set;}
        
        public String totalNLASTRFormatted{get;set;}
        public String totalBudgetSTRFormatted{get;set;}
        
        public Decimal recBudget{get;set;}
        public String vacantFrom{get;set;}
        public String committedFrom{get;set;}
        public LPStructure(){
            leasePlan = new Lease_Plan__c();
            colSpan = 1;
            cellText = '';
            bgColor = 'rgba(229, 193, 48, 0) !important';
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