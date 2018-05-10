@isTest public class RentFreeLeaseControllerTest {
    @isTest Static void myTest(){
        Account ac=new Account();
        ac.Name='TestAc';
        insert ac;
        
        Property__c Prop=new Property__c();
        prop.name='testProp';
        prop.Short_Code__c='abc';
        insert prop;
        
        Lease__c l=new Lease__c();
        l.Tenant__c=ac.Id;
        l.Rent_Free_Start_Date__c=date.today();
        l.Rent_Free_End_Date__c=date.today()+5;
        
        l.Property__c=prop.Id;
        l.Lease_Start_Date__c=date.today();
        l.Lease_Tenure_Mths__c=10;
        l.Lease_Tenure_Days__c='5';
        l.Lease_Status__c='new';
        insert l;
        
    }
}