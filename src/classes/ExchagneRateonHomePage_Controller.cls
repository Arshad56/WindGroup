public with sharing class ExchagneRateonHomePage_Controller {
	public List<exchageRateWrapper> exRtWrapList{get;set;}
	public exchageRateWrapper foreignCCRate{get;set;}
	public Map<String,Exchange_Rate__c> exchangeRateMap{get;set;}
    public ExchagneRateonHomePage_Controller(){
    	List<Exchange_Rate__c> financeRateList   = [select Name, Id, Conversion_Rate__c, Duplicate_Check__c, Currency_Code__c, CreatedDate, Applicable_Function__c  from Exchange_Rate__c where Currency_Code__c !=: label.Default_Currency And Applicable_Function__c = 'Finance'    And CreatedDate >= LAST_N_MONTHS:6 Order By CreatedDate Desc ];
     	List<Exchange_Rate__c> operationsRateList= [select Name, Id, Conversion_Rate__c, Duplicate_Check__c, Currency_Code__c, CreatedDate, Applicable_Function__c  from Exchange_Rate__c where Currency_Code__c !=: label.Default_Currency And Applicable_Function__c = 'Operations' And CreatedDate >= LAST_N_MONTHS:6 Order By CreatedDate Desc ];
    	 
    	Set<String> duplicateCC = new Set<String>();
    	exRtWrapList  = new List<exchageRateWrapper>();
    	foreignCCRate = new exchageRateWrapper();
    	exchageRateWrapper erWrap;
    	for(Exchange_Rate__c ff:financeRateList){
            system.debug('good-------------'+label.Base_Foreign_Currency);
    		if(!duplicateCC.contains(ff.Currency_Code__c) && label.Base_Foreign_Currency != ff.Currency_Code__c){
    			erWrap = new exchageRateWrapper();
	    		erWrap = new exchageRateWrapper();
	    		erWrap.currencyCode = ff.Currency_Code__c;
	    		erWrap.FinanceRate = ff.Conversion_Rate__c;
	    		duplicateCC.add(ff.Currency_Code__c);
	    		exRtWrapList.add(erWrap);
    		}else if(!duplicateCC.contains(ff.Currency_Code__c) && label.Base_Foreign_Currency == ff.Currency_Code__c){
    			foreignCCRate.currencyCode = ff.Currency_Code__c;
	    		foreignCCRate.FinanceRate = ff.Conversion_Rate__c;
	    		duplicateCC.add(ff.Currency_Code__c);
    		}
    	}
    	duplicateCC = new Set<String>();
    	for(Exchange_Rate__c op:operationsRateList){
    		if(!duplicateCC.contains(op.Currency_Code__c) && label.Base_Foreign_Currency != op.Currency_Code__c){
    			for(exchageRateWrapper erw:exRtWrapList){
    				if(erw.currencyCode == op.Currency_Code__c ){
    					erw.OperationRate = op.Conversion_Rate__c;
    					break;
    				}
    			}
	    		duplicateCC.add(op.Currency_Code__c);
    		}else if(!duplicateCC.contains(op.Currency_Code__c) && label.Base_Foreign_Currency == op.Currency_Code__c){
				foreignCCRate.OperationRate = op.Conversion_Rate__c;
	    		duplicateCC.add(op.Currency_Code__c);
    		}
    	}
    }
    
     public class exchageRateWrapper {
     	public Integer srNo{get;set;}
     	public String  currencyCode {get;set;}
        public Decimal OperationRate {get;set;}
        public Decimal FinanceRate {get;set;}
        public exchageRateWrapper(){
        	currencyCode = '';
        	OperationRate = 0;
        	FinanceRate = 0;
        }
     }
}