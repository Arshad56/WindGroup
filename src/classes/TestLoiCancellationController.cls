/*
*    Name           :    TestLoiCancellationController
*    Author         :    Prabhakar Joshi
*    Date           :    12/5/2017
*    Description    :    Unit test class for LoiCancellationController
*/

@isTest public class TestLoiCancellationController {
    @isTest static void myTest(){
        Property__c prop=new Property__c();
        prop.Name='testprop';
        prop.Short_Code__c='acb';
        insert prop;
        LOI__c loi=new LOI__c();
        loi.Name='testLOi';
        loi.Property__c=prop.Id;
        insert loi;
        
        ApexPages.currentPage().getParameters().put('loiId', loi.id);
        LoiCancellationController obj=new LoiCancellationController();
        obj.cancel();
        loi.LOI_Status__c='Cancelled';
    }
}