/*
 *  Name        :    JournalVoucherTrigger Test
 *  Author      :    Mohd Anas
 *  Date        :    22 March 2017
 *  Description :    Unit Test Class for Journal Voucher Trigger
*/

@isTest
public class JournalVoucherTriggerTEST {
    
//---------------------------For Journal Voucher value changed to Void----------------------------
    static testMethod void JournalVouchertriggerTestMethod(){
        
        //---------------Data entry for Invoice---------------------
        Invoice__c inv= new Invoice__c();
        inv.Name='testing';
        inv.JV_Status__c='Generated';
        insert inv;

        //---------------Data entry for Journal Voucher---------------------        
        Journal_Voucher__c jV=new Journal_Voucher__C();
        jV.Name='jourTesting';
        jV.Invoice__c=inv.id;
        jV.Posting_Status__c='Posted';
        insert jV;
        
        //---------------Data entry for Journal Entry---------------------        
        Journal_Entry__c jE=new Journal_Entry__c();
        jE.name='jouEntryTesting';
        jE.Journal_Voucher__c=jV.id;
        jE.Posting_Status__c='Unposted';
        insert jE;
        
        test.startTest();
            jV.Posting_Status__c='Void';
            update jv;
        test.stopTest();
      /*  //---------------------------For Journal Voucher value Updated to Posted----------------------------
        Journal_Voucher__c jE2=[Select id,Posting_Status__c from Journal_Voucher__c where id=:jV.id limit 1];
        jE2.Posting_Status__c='Posted';
        update jE2;
        
        //---------------------------For Journal Voucher value Updated to Void----------------------------
        Journal_Voucher__c jE3=[Select id,Posting_Status__c from Journal_Voucher__c where id=:jV.id limit 1];
        jE3.Posting_Status__c='Void';
        update jE3;
    
        //---------------------------For Journal Voucher value Updated to Canceled----------------------------  
        
        Journal_Voucher__c jE4=[Select id,Posting_Status__c from Journal_Voucher__c where id=:jV.id limit 1];
        jE4.Posting_Status__c='Canceled';
        update jE4;*/
     }
}