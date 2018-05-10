public class ExchangeRateLookupController{
    public Integer month{get;set;}
    public Integer year{get;set;}
    public List<Exchange_Rate__c> exRateList{get;set;}
    string curCode;
    public ExchangeRateLookupController(){
        month = system.today().month();
        year = system.today().year();
        exRateList = new List<Exchange_Rate__c>();
        curCode = Apexpages.currentPage().getParameters().get('curCode');
        search();
        
    }
    
    public void search(){
        if(curCode!=null){
            exRateList = [Select id,Name,Currency_Code__c,Conversion_Rate__c,Start_Date_Time__c from Exchange_Rate__c where Applicable_Function__c = 'Operations' And Currency_Code__c=:curCode and Start_Date_Time__c<=:system.now() and Calendar_Month(Start_Date_Time__c)=:month and Calendar_Year(Start_Date_Time__c)=:year order by Start_Date_Time__c desc];
        }
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
        for(Integer i=currentYear;i>=currentYear-10;i--){
            tempList.add(new selectOption(''+i+'',''+i+''));
        }
        return tempList;
    }
}