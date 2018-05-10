@isTest()
public class TestCalcLatePaymentScheduler{
    public static TestMethod void Test(){
        CalcLatePaymentScheduler a = new CalcLatePaymentScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Calc', sch, a);
    }
}