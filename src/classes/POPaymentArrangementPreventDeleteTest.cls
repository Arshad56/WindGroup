/*
*      Name            :       POPaymentArrangementPreventDeleteTest
*      Author          :       Prabhakar Joshi
*      Date            :       10th July 2017
*      Description     :       The unit test class for POPaymentArrangementPreventDelete trigger
*/
@isTest
public class POPaymentArrangementPreventDeleteTest {
    @isTest
    static void test1(){
        Account ac=new Account();
        ac.Name='test ac';
        insert ac;
        
        Purchase_Order__c po=new Purchase_Order__c();
        po.Company_Name__c=ac.Id;
        po.Status__c='Draft';
        insert po;
        
        PO_Payment_Arrangement__c pa=new PO_Payment_Arrangement__c();
        pa.Payment_Term__c=50;
        pa.Purchase_Order__c=po.id;
        insert pa;
        
        
        po.Status__c='Issued';
        Update po;
        
        
        
        
        try{
            delete pa;
            System.assert(FALSE, 'PO status should be Draft or Rejected');
        }
        catch(DMLException e){
            System.assert(TRUE, 'Deletion trigger failed');
        }
        PO_Payment_Arrangement__c pa1=new PO_Payment_Arrangement__c();
        pa1.Payment_Term__c=50;
        pa1.Purchase_Order__c=po.id;
        
        insert pa1;
        pa1.Payment_Term__c=20;
        try{
            update pa1;
        }
        catch(Exception e){}
        
    }
    
    
}