@isTest
Class TestExchangeRateLookupController{
        static TestMethod void Test(){
            ExchangeRateLookupController er = new ExchangeRateLookupController();
            er.getMonthList();
            er.getYearList();
            er.search();
        }
}