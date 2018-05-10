global class RentRollPdfController{
    public Rent_Roll__c rentRoll{get;set;}
    public map<Id,Decimal> usageUnitMap{get;set;}
    public List<InvoiceWrapper> invWrapList{get;set;}
    public map<Id,Boolean> baseRentLCPresentMap{get;set;}
    public map<Id,decimal> baseRentLCChargeRateMap{get;set;}
    public map<Id,Boolean> tieredCheckMap{get;set;}
    public map<Id,decimal> rrdInvAmountMap{get;set;}
    public map<Id,decimal> latePaymentRateMap{get;set;}
    public map<Id,string> DNCNoldInvoiceMap{get;set;}
    public map<Id,string> remarksMap{get;set;}
    public map<Id,Decimal> tierPercent{get;set;}
    map<String,Bank_Information__c> bankInfoMap{get;set;}
    public map<Id,decimal> baseRentAnPRateMap{get;set;}
    Set<Id> anpChargeIds = new Set<Id>();
    map<Integer, String> monthMap= new Map<Integer, String>();
    public static String getDayOfMonthSuffix(Integer n) {
	    if (n == null) {
	        return '';
	    }
	
	    if (n >= 11 && n <= 13) {
	        return 'th';
	    }
	
	    Integer modResult = Math.mod(n, 10);        
	    if (modResult == 1) { 
	        return 'st'; 
	    } else if (modResult == 2) { 
	        return 'nd'; 
	    } else if (modResult == 3) { 
	        return 'rd'; 
	    } else { 
	        return 'th';
	    }
	}
    public RentRollPdfController(){
    	monthMap.put(1, 'JANUARY');
		monthMap.put(2, 'FEBRUARY');
		monthMap.put(3, 'MARCH');
		monthMap.put(4, 'APRIL');
		monthMap.put(5, 'MAY');
		monthMap.put(6, 'JUNE');
		monthMap.put(7, 'JULY');
		monthMap.put(8, 'AUGUST');
		monthMap.put(9, 'SEPTEMBER');
		monthMap.put(10, 'OCTOBER');
		monthMap.put(11, 'NOVEMBER');
		monthMap.put(12, 'DECEMBER');
		
        baseRentAnPRateMap = new map<Id,decimal>();
        latePaymentRateMap = new map<Id,decimal>();
        rrdInvAmountMap = new map<Id,decimal>();
        tierPercent = new map<Id,Decimal>();
        invWrapList = new List<InvoiceWrapper>();
        rentRoll = new Rent_Roll__c();
        usageUnitMap = new Map<Id,Decimal>();
        baseRentLCPresentMap = new map<Id,Boolean>();
        baseRentLCChargeRateMap = new Map<Id,decimal>();
        DNCNoldInvoiceMap = new map<Id,string>();
        remarksMap = new map<Id,string>();
        tieredCheckMap = new map<Id,Boolean>();
        string rentRollId = Apexpages.currentPage().getParameters().get('Id');
        List<Rent_Roll__c> rentRollList = [Select id,Property__c,Property__r.Logo__c,Property__r.Name,Property__r.Address__c from Rent_Roll__C where id=:rentRollId limit 1];
        if(rentRollList.size()>0){
            rentRoll = rentRollList[0];
            
            //List<Invoice__c> invList = [Select id,Rent_Roll__r.Ex_Rate_Date__c,Exchange_Rate__c,Currency_Code__c,Rent_Roll__r.Billing_Type__c,Amount__c,Name,Account__c,Lease__r.Name,Lease__r.Tenant__r.Phone,Lease__r.Tenant__r.BillingStreet,Lease__r.Tenant__r.BillingCity,Lease__r.Tenant__r.BillingCountry,Lease__r.Tenant__r.BillingState,Lease__r.Tenant__r.BillingPostalCode,Invoice_Date__c,Payment_Due_Date__c,Lease__c,Lease__r.Property__r.Comm_Tax__c,Lease__r.Property__c,Lease__r.Property__r.Name,Lease__r.Property__r.Utility_Usage_Remarks__c ,Lease__r.Property__r.Logo__c,Lease__r.Property__r.Address__c,Lease__r.Property__r.Remarks__c,Lease__r.Property__r.Remarks_Other_Invoices__c,Lease__r.Property__r.Bank_Account_Number__c,Lease__r.Property__r.Bank_Address__c,Lease__r.Property__r.Bank_Name__c,Lease__r.Property__r.Beneficiary_Name__c,Lease__r.Property__r.Branch_Code__c,Lease__r.Property__r.Branch_Name__c,Lease__r.Property__r.Bank_Address_Local__c,Lease__r.Property__r.Bank_Name_Local__c,Lease__r.Property__r.Beneficiary_Name_Local__c,Lease__r.Property__r.Branch_Name_Local__c,Lease__r.Property__r.Swift_Code_Local__c,Lease__r.Property__r.Account_No_Local__c,(Select id,Due_Days__c,Invoice_old__c,Late_Rate__c,Outstanding_Amount__c,Amount__c,Charge_Name__c,Start_Date__c,End_Date__c,Lease_Charge__r.Charge_Type__c,Lease_Charge__r.Type__c,Lease_Charge__r.Frequency__c,Lease_Charge__r.Commercial_Tax_Apply__c,Lease_Charge__r.Charge_Rate__c,Lease_Charge__r.Lease_Unit__c,Lease_Charge__r.Lease_Unit__r.Unit__r.Name,Lease_Charge__r.Lease_Unit__r.Area_Sq_Ft__c,Lease_Charge__r.Lease_Unit__r.Rent_per_Sq_Feet__c,Comm_Tax_Amount__c,Transaction_Start_Date__c,Transaction_End_Date__c,Description__c,Lease_Charge__c from Invoice_Line_Items__r ORDER BY Lease_Charge__r.Lease_Unit__r.Unit__r.Name ASC,Lease_Charge__r.Name ASC,Period_Start_Date__c ASC),Comm_Tax_Amount__c from Invoice__c where Rent_Roll__c=:rentRoll.Id order by Lease__r.Tenant__r.Name asc];
            List<Invoice__c> invList = [Select id,Charge_Method__c,Net_Total__c,Tenant_Type__c,Price_Factor__c,Withholding_Tax_Amount__c,Parent_Company__c,Property_Name__r.Remarks_Credit_Note__c,
        									Exchange_Rate__c,Currency_Code__c,Rent_Roll__r.Ex_Rate_Date__c,Rent_Roll__r.Billing_Type__c,
        									Amount__c,Name,Account__c,Lease__r.Name,Tenant_Name__r.Customer_Code__c, 
        									Tenant_Name__r.Phone,Tenant_Name__r.BillingStreet,Tenant_Name__r.BillingCity,
        									Tenant_Name__r.BillingCountry,Tenant_Name__r.BillingState,Tenant_Name__r.BillingPostalCode,
        									Lease__r.Tenant__r.Phone,Lease__r.Tenant__r.BillingStreet,Lease__r.Tenant__r.BillingCity,
        									Lease__r.Tenant__r.BillingCountry,Lease__r.Tenant__r.BillingState,Lease__r.Tenant__r.BillingPostalCode,Invoice_Date__c,
        									Payment_Due_Date__c,Property__c,Property_Name__r.Name,Property_Name__r.Logo__c,
        									Property_Name__r.Address__c,Property_Name__r.Remarks__c,Property_Name__r.Utility_Usage_Remarks__c,
        									Property_Name__r.Remarks_Other_Invoices__c,Lease__c,Lease__r.Property__c,Lease__r.Property__r.Remarks_Credit_Note__c, 
        									Lease__r.Property__r.Name,Lease__r.Property__r.Logo__c,Lease__r.Property__r.Address__c,Lease__r.Property__r.Comm_Tax__c,
        									Lease__r.Property__r.Remarks__c,Lease__r.Property__r.Utility_Usage_Remarks__c,Lease__r.Property__r.Remarks_Other_Invoices__c,
        									(Select Lease_Charge__r.Lease_Unit__r.Unit__r.Description__c,Lease_Charge__r.Lease_Unit__r.Unit__r.Space_Type__c,
        									Withholding_Tax__c,Lease_Charge__r.Withholding_Tax_Rate__c,Lease_Charge__r.Lease_Unit__r.Unit__r.Charge_Method__c,
        									on_Invoice__c,Lease_Charge__r.Cumulative_for_each_Tier__c,
        									Lease_Charge__r.Currency_Code__c,Lease_Charge__r.Tiered_Limit__c,Lease_Charge__r.Tier_1_Rate__c  ,
        									Lease_Charge__r.Tier_1_Upper_Limit__c  ,Lease_Charge__r.Tier_2_Rate__c ,Lease_Charge__r.Tier_2_Upper_Limit__c  ,
        									Lease_Charge__r.Tier_3_Rate__c ,Lease_Charge__r.Tier_3_Upper_Limit__c  ,Lease_Charge__r.Tier_4_Rate__c ,
        									Lease_Charge__r.Tier_4_Upper_Limit__c  ,Lease_Charge__r.Tier_5_Rate__c ,Lease_Charge__r.Tier_5_Upper_Limit__c  ,
        									Lease_Charge__r.Tier_6_Rate__c ,Lease_Charge__r.Tier_6_Upper_Limit__c  ,Lease_Charge__r.Tier_7_Rate__c ,
        									Lease_Charge__r.Tier_7_Upper_Limit__c  ,Lease_Charge__r.Tier_8_Rate__c ,Lease_Charge__r.Tier_8_Upper_Limit__c  ,
        									Lease_Charge__r.Tier_9_Rate__c     ,Lease_Charge__r.Tiered_Lower_Limit__c  ,id,GTO_Amount__c,Sales_Amount__c,
        									Due_Days__c,Invoice_old__c,Late_Rate__c,Outstanding_Amount__c,Amount__c,Charge_Name__c,Start_Date__c,
        									End_Date__c,Lease_Charge__r.Base_Rent_Calculation_Local__c,Lease_Charge__r.Type__c,Lease_Charge__r.Frequency__c,
        									Lease_Charge__r.Commercial_Tax_Apply__c,Lease_Charge__r.Charge_Type__c,Lease_Charge__r.Charge_Rate__c,
        									Lease_Charge__r.Lease_Unit__c,Lease_Charge__r.Lease_Unit__r.Unit__r.Name,Lease_Charge__r.Lease_Unit__r.Area_Sq_Ft__c,
        									Comm_Tax_Amount__c,Transaction_Start_Date__c,
        									Transaction_End_Date__c,Description__c,Lease_Charge__c 
        									from Invoice_Line_Items__r 
        										ORDER BY Lease_Charge__r.Lease_Unit__r.Unit__r.Name ASC,Period_Start_Date__c ASC,Lease_Charge__r.Name ASC),Comm_Tax_Amount__c
            									from Invoice__c 
            										where Rent_Roll__c=:rentRoll.Id order by Lease__r.Tenant__r.Name asc];
            List<Bank_Information__c> tempBankInfoList = [select Id, Account_No__c,Bank_Address__c,Bank_Name__c,Beneficiary_Name__c,Branch_Name__c,Currency_Code__c,Property__c,Swift_Code__c from Bank_Information__c];
        	List<Rent_Schedules__c> rsList = [Select Invoice_Line_Item__c,Cap_Applicable__c, Id, Cap_Value__c From Rent_Schedules__c where Invoice_Line_Item__r.Invoice__r.Rent_Roll__c =: rentRoll.Id];
	        Map<Id,Rent_Schedules__c> iliIdwithRS = new Map<Id, Rent_Schedules__c>();
	        for(Rent_Schedules__c rs: rsList){
	        	if(rs.Invoice_Line_Item__c != null)
	        		iliIdwithRS.put(rs.Invoice_Line_Item__c, rs);
	        }
            if(invList.size()>0){
                bankInfoMap = new  map<String,Bank_Information__c> ();
                for(Bank_Information__c bi:tempBankInfoList){
                  bankInfoMap.put(bi.Currency_Code__c+bi.Property__c,bi);
                  System.debug('bi.Currency_Code__c+bi.Property__c-->'+bi.Currency_Code__c+bi.Property__c);
                }
                
                Set<Id> leaseIds = new Set<Id>();
                for(Invoice__c inv:invList){
                    if(inv.Currency_Code__c == null || inv.Currency_Code__c == ''){
                        inv.Currency_Code__c = label.Default_Currency;
                    }
                    leaseIds.add(inv.Lease__c);
                }
                List<Lease_Unit__c> leaseUnitList = [Select id,Unit__r.Name,Lease_Agreement_No__c from Lease_Unit__c where Lease_Agreement_No__c in:leaseIds order by Unit__r.Name ASC];
                Map<Id,string> LeaseToUnitMap = new Map<Id,string>();
                for(Lease_Unit__c lu:leaseUnitList){
                    string tempStr = '';
                    if(leaseToUnitMap.containsKey(lu.Lease_Agreement_No__c)){
                        tempStr = leaseToUnitMap.get(lu.Lease_Agreement_No__c);
                    }
                    tempStr += lu.unit__r.Name + ', ';
                    leaseToUnitMap.put(lu.Lease_Agreement_No__c,tempStr);
                }
                Set<Id> lineItemIds = new Set<Id>();
                for(Invoice__c inv:invList){
                    InvoiceWrapper iw = new InvoiceWrapper();
                    iw.invoice = inv;
                    iw.concatIncAddFields = (inv.Lease__r.Tenant__r.BillingCity!=null?inv.Lease__r.Tenant__r.BillingCity+',':'') + (inv.Lease__r.Tenant__r.BillingState!=null?inv.Lease__r.Tenant__r.BillingState+',':'') + (inv.Lease__r.Tenant__r.BillingCountry!=null?inv.Lease__r.Tenant__r.BillingCountry:'');
                    
                    iw.priceFactor = (inv.Price_Factor__c != null)? Integer.valueOf((1 - inv.Price_Factor__c)*100):0;
                    if(inv.Charge_Method__c== 'Monthly Rate - CL'){
		        		iw.billType = 'Monthly With Holding';	
		        	}else if(inv.Charge_Method__c =='Daily Rate'){
		        		iw.billType = 'Daily With Holding';
		        	}else{
		        		iw.billType = inv.Rent_Roll__r.Billing_Type__c;
		        	}
		        	
                    if(iw.concatIncAddFields!=null && iw.concatIncAddFields.endsWith(',')){
                        iw.concatIncAddFields = iw.concatIncAddFields.subString(0,iw.concatIncAddFields.length()-1);
                    }
                    if(inv.Rent_Roll__r.Ex_Rate_Date__c != null){
		            	iw.exchangeRateDate = inv.Rent_Roll__r.Ex_Rate_Date__c.Day()+ RentRollPdfController.getDayOfMonthSuffix(inv.Rent_Roll__r.Ex_Rate_Date__c.Day()) + ' '+ monthMap.get(inv.Rent_Roll__r.Ex_Rate_Date__c.Month()) + ' '+inv.Rent_Roll__r.Ex_Rate_Date__c.year();
		            }
		            
                    iw.bankInfoList = new List<Bank_Information__c>();
                    if(inv.Currency_Code__c != label.Default_Currency){
                        if(bankInfoMap.containsKey(inv.Currency_Code__c+inv.Lease__r.Property__c)){
                            iw.bankInfoList.add(bankInfoMap.get(inv.Currency_Code__c+inv.Lease__r.Property__c));
                        }
                        System.debug(inv.Currency_Code__c+inv.Lease__r.Property__c+'containsKey111-->'+bankInfoMap.containsKey(inv.Currency_Code__c+inv.Lease__r.Property__c));
                    }
                     System.debug('containsKey222-->'+bankInfoMap.containsKey(label.Default_Currency+inv.Lease__r.Property__c));
                    if(bankInfoMap.containsKey(label.Default_Currency+inv.Lease__r.Property__c)){
                        iw.bankInfoList.add(bankInfoMap.get(label.Default_Currency+inv.Lease__r.Property__c));
                    }
                    System.debug('iw.bankInfoList-->'+iw.bankInfoList);
                    iw.withHoldingTax = 0;
                    for(Invoice_Line_Item__c ili:inv.Invoice_Line_Items__r){
                    	if(inv.Withholding_Tax_Amount__c > 0){
		            		if(ili.Withholding_Tax__c)
		            			iw.withHoldingTax = Integer.valueOf(ili.Lease_Charge__r.Withholding_Tax_Rate__c);
			            }
			            
                    	if(!iw.isCapValue && iliIdwithRS.containsKey(ili.Id)){
		            		if(iliIdwithRS.get(ili.Id).Cap_Applicable__c)
		            			iw.isCapValue = true;
		            	}
                    	if(ili.Lease_Charge__r.Commercial_Tax_Apply__c ||  ili.Comm_Tax_Amount__c > 0){
		            		iw.ctApplicable = true;
		            	}
                    	if(ili.Lease_Charge__r.Type__c == 'GTO (Higher)' && iw.chargeType == null){
		            		iw.chargeType = 'GTO (Higher)';
		            	}else if(ili.Lease_Charge__r.Type__c == 'GTO (Sum)' && iw.chargeType == null){
		            		iw.chargeType = 'GTO (Sum)';
		            	}
                    	if(ili.Lease_Charge__r.Tiered_Limit__c && ili.Lease_Charge__r.Cumulative_for_each_Tier__c && iw.tieredRates == 0 ){
		            		iw.leaseCharge = ili.Lease_Charge__r;
		            		iw.tieredRates = 1;	
		            	}else if(ili.Lease_Charge__r.Tiered_Limit__c && !ili.Lease_Charge__r.Cumulative_for_each_Tier__c &&  iw.tieredRates == 0){
		            		iw.leaseCharge = ili.Lease_Charge__r;
		            		iw.tieredRates = 2;
		            	}
		            	if(ili.Sales_Amount__c > iw.maxSalesAmt){
		            		iw.maxSalesAmt = ili.Sales_Amount__c;
		            	}
		            	
                        baseRentAnPRateMap.put(ili.Id,0.00);
                        lineItemIds.add(ili.Id);
                        usageUnitMap.put(ili.Id,0.00);
                        latePaymentRateMap.put(ili.Id,0.00);
                        rrdInvAmountMap.put(ili.Id,0.00);
                        baseRentLCPresentMap.put(ili.Id,false);
                        tieredCheckMap.put(ili.Id,false);
                        DNCNoldInvoiceMap.put(ili.Id,'');
                        remarksMap.put(ili.Id,'');
                        if(ili.Amount__c!=null && !ili.Withholding_Tax__c){
                            iw.totalAMount += ili.Amount__c;
                        }
                        
                        if(ili.Lease_Charge__r.Charge_Type__c =='A&P' && ili.Lease_Charge__r.Type__c == 'By Percent'){
                            anpChargeIds.add(ili.Lease_Charge__c);
                        }
                        
                        if(ili.Lease_Charge__r.Charge_Type__c =='GTO Rent'){
	                		if(ili.Sales_Amount__c >= ili.Lease_Charge__r.Tier_8_Upper_Limit__c){
	                			tierPercent.put(ili.Id,ili.Lease_Charge__r.Tier_9_Rate__c);
	                		}else if(ili.Sales_Amount__c >= ili.Lease_Charge__r.Tier_7_Upper_Limit__c){
	                			tierPercent.put(ili.Id,ili.Lease_Charge__r.Tier_8_Rate__c);
	                		}else if(ili.Sales_Amount__c >= ili.Lease_Charge__r.Tier_6_Upper_Limit__c){
	                			tierPercent.put(ili.Id,ili.Lease_Charge__r.Tier_7_Rate__c);
	                		}else if(ili.Sales_Amount__c >= ili.Lease_Charge__r.Tier_5_Upper_Limit__c){
	                			tierPercent.put(ili.Id,ili.Lease_Charge__r.Tier_6_Rate__c);
	                		}else if(ili.Sales_Amount__c >= ili.Lease_Charge__r.Tier_4_Upper_Limit__c){
	                			tierPercent.put(ili.Id,ili.Lease_Charge__r.Tier_5_Rate__c);
	                		}else if(ili.Sales_Amount__c >= ili.Lease_Charge__r.Tier_3_Upper_Limit__c){
	                			tierPercent.put(ili.Id,ili.Lease_Charge__r.Tier_4_Rate__c);
	                		}else if(ili.Sales_Amount__c >= ili.Lease_Charge__r.Tier_2_Upper_Limit__c){
	                			tierPercent.put(ili.Id,ili.Lease_Charge__r.Tier_3_Rate__c);
	                		}else if(ili.Sales_Amount__c >= ili.Lease_Charge__r.Tier_1_Upper_Limit__c){
	                			tierPercent.put(ili.Id,ili.Lease_Charge__r.Tier_2_Rate__c);
	                		}else if(ili.Sales_Amount__c >= ili.Lease_Charge__r.Tiered_Lower_Limit__c){
	                			tierPercent.put(ili.Id,ili.Lease_Charge__r.Tier_1_Rate__c);
	                		}else{
	                			tierPercent.put(ili.Id,0);
	                		}
		                }
                    }
                	if(	iw.leaseCharge.Tier_1_Rate__c==null)
		            	iw.leaseCharge.Tier_1_Rate__c= 0 ;
					if(iw.leaseCharge.Tier_1_Upper_Limit__c==null)
						iw.leaseCharge.Tier_1_Upper_Limit__c= 0 ;
					if(iw.leaseCharge.Tier_2_Rate__c==null)
						iw.leaseCharge.Tier_2_Rate__c= 0 ;
					if(iw.leaseCharge.Tier_2_Upper_Limit__c==null)
							iw.leaseCharge.Tier_2_Upper_Limit__c= 0 ;
					if(iw.leaseCharge.Tier_3_Rate__c==null)
						iw.leaseCharge.Tier_3_Rate__c= 0 ;
					if(iw.leaseCharge.Tier_3_Upper_Limit__c==null)
							iw.leaseCharge.Tier_3_Upper_Limit__c= 0 ;
					if(iw.leaseCharge.Tier_4_Rate__c==null)
						iw.leaseCharge.Tier_4_Rate__c= 0 ;
					if(iw.leaseCharge.Tier_4_Upper_Limit__c==null)
						iw.leaseCharge.Tier_4_Upper_Limit__c= 0 ;
					if(iw.leaseCharge.Tier_5_Rate__c==null)
						iw.leaseCharge.Tier_5_Rate__c= 0 ;
					if(iw.leaseCharge.Tier_5_Upper_Limit__c==null)
						iw.leaseCharge.Tier_5_Upper_Limit__c= 0 ;
					if(iw.leaseCharge.Tier_6_Rate__c==null)
						iw.leaseCharge.Tier_6_Rate__c= 0 ;
					if(iw.leaseCharge.Tier_6_Upper_Limit__c==null)
						iw.leaseCharge.Tier_6_Upper_Limit__c= 0 ;
					if(iw.leaseCharge.Tier_7_Rate__c==null)
						iw.leaseCharge.Tier_7_Rate__c= 0 ;
					if(iw.leaseCharge.Tier_7_Upper_Limit__c==null)
							iw.leaseCharge.Tier_7_Upper_Limit__c= 0 ;
					if(iw.leaseCharge.Tier_8_Rate__c==null)
						iw.leaseCharge.Tier_8_Rate__c= 0 ;
					if(iw.leaseCharge.Tier_8_Upper_Limit__c==null)
						iw.leaseCharge.Tier_8_Upper_Limit__c= 0 ;
					if(iw.leaseCharge.Tier_9_Rate__c==null)
						iw.leaseCharge.Tier_9_Rate__c= 0 ;
					if(iw.leaseCharge.Tiered_Lower_Limit__c==null)
						iw.leaseCharge.Tiered_Lower_Limit__c= 0 ;
							
					 if(inv.Lease__r.Property__r.Comm_Tax__c != null ){
		            	iw.taxPercent = Integer.valueOf(inv.Lease__r.Property__r.Comm_Tax__c);
		            }
                    iw.grandTotalAmount = iw.totalAmount+iw.invoice.Comm_Tax_Amount__c;
                    iw.totalAmount = iw.totalAmount.setScale(2);
                    iw.grandTotalAmount = iw.grandTotalAmount.setScale(2);
                    
                    if(leaseToUnitMap.containsKey(inv.Lease__c)){
                        iw.units = leaseToUnitMap.get(inv.Lease__c);
                    }
                    if(iw.units!=null && iw.units.endsWith(', ')){
                        iw.units = iw.units.substring(0,iw.units.Length()-2);
                    }
                    
                    iw.firstUnitNo = iw.Units.split(',')[0];
                    
                    invWrapList.add(iw);
                }
                
                Map<Id,List<Rent_Schedules__c>> anpLcToRsMap = new Map<Id,List<Rent_Schedules__c>>();
            
                for(Rent_Schedules__c rs:[Select id,Start_Date__c,End_Date__c,Base_Rent_LC__c,Lease_Charge__c,Base_Rent_LC__r.Charge_Rate__c from Rent_Schedules__c where Lease_Charge__c in:anpChargeIds and Base_Rent_LC__c!=null]){
                    List<Rent_Schedules__c> tempList = new List<Rent_Schedules__c>();
                    if(anpLcToRsMap.containsKey(rs.Lease_Charge__c)){
                        tempList.addAll(anpLcToRsMap.get(rs.Lease_Charge__c));
                    }
                    tempList.add(rs);
                    anpLcToRsMap.put(rs.Lease_Charge__c,tempList);
                }
                
                for(Invoice__c inv:invList){
                    for(Invoice_Line_Item__c ili:inv.Invoice_Line_Items__r){
                        if(ili.Lease_Charge__r.Charge_Type__c =='A&P' && ili.Lease_Charge__r.Type__c == 'By Percent'){
                            if(anpLcToRsMap.containsKey(ili.Lease_Charge__c)){
                                for(Rent_Schedules__c rs:anpLcToRsMap.get(ili.Lease_Charge__c)){
                                    if(ili.start_Date__c>=rs.Start_Date__c && ili.Start_Date__c<=rs.End_Date__c){
                                        if(rs.Base_Rent_LC__r.Charge_Rate__c!=null && ili.Lease_Charge__r.Charge_Rate__c!=null){
                                            decimal anpRate = rs.Base_Rent_LC__r.Charge_Rate__c*ili.Lease_Charge__r.Charge_Rate__c/100;
                                            baseRentAnPRateMap.put(ili.Id,anpRate);
                                        }
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            
                invWrapList.sort();
                Set<Id> rrDetIds = new Set<Id>();
                for(Rent_Roll_Detail__c rrd:[Select id,Total_Units_p__c,Invoice_Line_Item__c,Late_Percent_Rate__c,Invoice__r.Amount__c,Remarks__c from Rent_Roll_Detail__c where Invoice_Line_Item__c in:lineItemIds]){
                    Decimal tempVal = 0;
                    if(usageUnitMap.containsKey(rrd.Invoice_Line_Item__c)){
                        tempVal = usageUnitMap.get(rrd.Invoice_Line_Item__c);
                    }
                    tempVal += (rrd.Total_Units_p__c!=null?rrd.Total_Units_p__c:0);
                    usageUnitMap.put(rrd.Invoice_Line_Item__c,tempVal);
                    
                    if(rrd.Late_Percent_Rate__c!=null){
                        latePaymentRateMap.put(rrd.Invoice_Line_Item__c,rrd.Late_Percent_Rate__c);
                    }
                    if(rrd.Invoice__r.Amount__c!=null){
                        rrdInvAmountMap.put(rrd.Invoice_Line_Item__c,rrd.Invoice__r.Amount__c);
                    }
                    
                    rrDetIds.add(rrd.Id);
                    
                    if(rrd.Remarks__c!=null){
                        remarksMap.put(rrd.Invoice_Line_Item__c,rrd.Remarks__c);
                    }
                }
                
                for(Rent_Schedules__c rs:[Select id,Tiered__c,Rent_Roll_Detail__r.Invoice_Line_Item__c,Base_Rent_LC__c,Base_Rent_LC__r.Charge_Rate__c,Invoice_Line_Item__r.Invoice__r.Name from Rent_Schedules__c where Rent_Roll_Detail__c in:rrDetIds]){
                    if(rs.Base_Rent_LC__c!=null){
                        baseRentLCPresentMap.put(rs.Rent_Roll_Detail__r.Invoice_Line_Item__c,true);
                        baseRentLCChargeRateMap.put(rs.Rent_Roll_Detail__r.Invoice_Line_Item__c,rs.Base_Rent_LC__r.Charge_Rate__c);
                    }
                    if(rs.Invoice_Line_Item__r.Invoice__r.Name!=null){
                        DNCNoldInvoiceMap.put(rs.Rent_Roll_Detail__r.Invoice_Line_Item__c,rs.Invoice_Line_Item__r.Invoice__r.Name);
                    }
                    if(rs.Tiered__c){
                        tieredCheckMap.put(rs.Rent_Roll_Detail__r.Invoice_Line_Item__c,true);
                    }
                }
            }
        }
    }
    
    global class InvoiceWrapper implements Comparable{
        public Invoice__c invoice{get;set;}
        public decimal totalAmount{get;set;}
        public boolean ctApplicable{get;set;}
        public boolean isCapValue{get;set;}
        public decimal grandTotalAmount{get;set;}
        public string concatIncAddFields{get;set;}
        public String units{get;set;}
        public string firstUnitNo{get;set;}
        public String chargeType{get;set;}
        public String exchangeRateDate{get;set;}
        public Integer tieredRates{get;set;}
        public Integer taxPercent{get;set;}
        public Lease_Charges__c leaseCharge{get;set;}
        public decimal maxSalesAmt{get;set;}
        public List<Bank_Information__c> bankInfoList{get;set;}
        
        public string billType{get;set;}
        public Integer priceFactor{get;set;}
        public decimal withHoldingTax{get;set;}
        
        public InvoiceWrapper(){
            invoice = new Invoice__c();
            totalAmount = 0;
            ctApplicable = false;
            isCapValue = false;
            chargeType = null;
            exchangeRateDate = '';
            tieredRates = 0 ;
            leaseCharge = new Lease_Charges__c();
            maxSalesAmt = 0;
            taxPercent=0;
            billType ='';
        }
        
        global Integer compareTo(Object compareTo){
            if (firstUnitNo == ((InvoiceWrapper)compareTo).firstUnitNo) return 0;
            if (firstUnitNo > ((InvoiceWrapper)compareTo).firstUnitNo) return 1;
            return -1;
        }
    }
}