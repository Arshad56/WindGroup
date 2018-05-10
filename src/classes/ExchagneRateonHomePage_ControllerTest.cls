@isTest
public class ExchagneRateonHomePage_ControllerTest {

    @isTest
    public static void ExchagneRateonHomePage_Controllermethod(){
        List<Exchange_Rate__c> ex=new List<Exchange_Rate__c>();
        Exchange_Rate__c eRate = new Exchange_Rate__c();
        eRate.Conversion_Rate__c=200;
        eRate.Currency_Code__c=Label.Base_Foreign_Currency;
        eRate.Applicable_Function__c='Operations';
        eRate.Start_Date_Time__c=system.now() ;
        ex.add(eRate);
        
        Exchange_Rate__c eRate2 = new Exchange_Rate__c();
        eRate2.Conversion_Rate__c=200;
        eRate2.Currency_Code__c='JPY';
        eRate2.Applicable_Function__c='Finance';
        eRate2.Start_Date_Time__c=system.now() ;
        ex.add(eRate2);
        insert ex;        
        ExchagneRateonHomePage_Controller cntr= new ExchagneRateonHomePage_Controller();   
        ex.clear();
        eRate2.Currency_Code__c=Label.Base_Foreign_Currency;
        ex.add(eRate2);
        
        eRate.Currency_Code__c='JPY';
        ex.add(eRate);
        update ex;
        ExchagneRateonHomePage_Controller cntr2= new ExchagneRateonHomePage_Controller();  
    }
}