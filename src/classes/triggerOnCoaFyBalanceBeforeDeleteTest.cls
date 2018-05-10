/*
*    Name             :     triggerOnCoaFyBalanceBeforeDeleteTest 
*    Author           :     Prabhakar
*    Date             :     29th June 2017
*    Edited           :     11th July 2017
*    Description      :     A unit test class for trigger named triggerOnCoaFyBalanceBeforeDelete
*/
@isTest
public class triggerOnCoaFyBalanceBeforeDeleteTest {
    Static testmethod void CoaFyBalanceTest(){
        
     
        Purchase_Order__c purOrder = new Purchase_Order__c();
        purOrder.PO_Start_Date__c = System.today();
        purOrder.Po_End_Date__c = system.today()+20;
        purOrder.Status__c='Draft';
        insert purOrder;
        
        Coa_Fy_Balance__c coa = new COA_FY_Balance__c();
        coa.Budget_Amount__c = 100;
        coa.PO_Pending__c = 200;
        insert coa;
        
     
        PO_Line_Item__c poLineItem1 = new PO_Line_Item__c();
        poLineItem1.Budget_Line__c = 'Hardware Maintenance';
        poLineItem1.Amount__c = 2000;
        poLineItem1.COA_FY_Balance__c = coa.id;
        poLineItem1.Purchase_Order__c = purOrder.id;
        poLineItem1.Product_Type__c = 'Equipment';
        insert poLineItem1;
        
        try{
            delete coa;
            System.assert(FALSE, 'Cannot delete because it is being referenced by PO Line Item');
        }
        catch(DMLException e){
            System.assert(TRUE, 'TEST FAILED');
        }
    }
}