@isTest
public class DupLOIUnitPeriodTest {
    @isTest
    static void test1(){
        Account tenant=new Account();
        tenant.name='test';
        tenant.Trade_Category__c='Mobile, Electronic & Lifestyle';
        tenant.sub_Trade_Category__c='Electronic Shop'; 
        tenant.WItholding_Eligible__c = true;
        insert tenant;
        
        LOI__c loi=new LOI__c();
        loi.name='Test loi';
        loi.Tenant_Type__c='tenant';
        loi.LOI_Start_Date__c=Date.newInstance(2100,01,26);
        loi.Tenant__c=tenant.id;
        loi.LOI_Tenure_Days__c='2';
        loi.LOI_Tenure_Mths__c=24;
        insert loi;
        
        property__c pr=new property__c();
        pr.name='test Property';
        pr.LOI_Unit_Index__c=2;
        pr.LOI_Index__c=2;
        pr.Deposit_Index__c=2;
        pr.short_code__c='ABC';
        pr.Witholding_Tax__c = 3;
        pr.Witholding_Tax_Limit__c = 10;
        insert pr;
        
        Level__c le=new Level__c();
        le.name='test level';
        le.Property__c=pr.id;
        insert le;
        
        Units__c unt=new Units__c();
        unt.name='Test Unit';
        unt.Space_Type__c='Shop'; 
        unt.Property__c=pr.id;
        unt.Level__c=le.id;
        unt.NLA_SQF__c=234.32;
        unt.rent_hurdle__c = 100;
        unt.Rent_Hurdle_Lower_Limit__c = 10;
        unt.Rent_Hurdle_Upper_Limit__c = 20;
        unt.Charge_Method__c='Monthly Rate - CL';
        insert unt;
        
        Units__c unt2=new Units__c();
        unt2.name='Test Unit2';
        unt2.Space_Type__c='Shop'; 
        unt2.Property__c=pr.id;
        unt2.Level__c=le.id;
        unt2.NLA_SQF__c=234.32;
        unt2.rent_hurdle__c = 100;
        unt2.Rent_Hurdle_Lower_Limit__c = 10;
        unt2.Rent_Hurdle_Upper_Limit__c = 20;
        unt2.Charge_Method__c='Monthly Rate - CL';
        insert unt2;
        
        LOI_Unit__c lu=new LOI_Unit__c();
        lu.LOI_Agreement_No__c=loi.Id;
        lu.Unit__c=unt.Id;
        lu.Extension_Date__c=date.today();
        
        insert lu;
        
        
        LOI_Unit__c lu2=new LOI_Unit__c();
        lu2.LOI_Agreement_No__c=loi.Id;
        lu2.Unit__c=unt.Id;
        lu2.Extension_Date__c=date.today();
        
        insert lu2;
        lu.Unit__c=unt2.id;
        update lu;
    }
}