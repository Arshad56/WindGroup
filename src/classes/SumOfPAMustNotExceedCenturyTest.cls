@isTest
public class SumOfPAMustNotExceedCenturyTest{
    @isTest
    static void test1(){
        Account ac1=new Account();
        ac1.Name='testAc1';
        insert ac1;
        
        Payment_Arrangement__c pa1 = new Payment_Arrangement__c();
        pa1.Name = 'Test1';
        pa1.Payment_Due__c = '30 Days';
        pa1.Payment_Term__c = 10;
        pa1.Seq_No__c = '1';
        pa1.Vendor_Name__c = ac1.Id;
        insert pa1;
        
        Payment_Arrangement__c pa2 = new Payment_Arrangement__c();
        pa2.Name = 'Test2';
        pa2.Payment_Due__c = '60 Days';
        pa2.Payment_Term__c = 20;
        pa2.Seq_No__c = '2';
        pa2.Vendor_Name__c = ac1.Id;
        insert pa2;
        
       
    }
}