/*
*    Name           :    Journal Entry Trigger Test 
*    Author         :    Mohd Anas
*    Date           :    6 April 2017
*    Description    :    Unit Test Class for Journal Entry Trigger.
*/
@isTest
public class JournalEntryTriggerTest {
    @isTest
    static void methodJournalEntrytrigger(){
        
        
        
        
        
        //---------------Data entry for Journal Voucher---------------------        
        Journal_Voucher__c jV=new Journal_Voucher__C();
        jV.Name='jourTesting';
        jV.Posting_Status__c='Posted';
        insert jV;
        
        COA_Master_FY_Balance__c coaMasFyBal = new COA_Master_FY_Balance__c();
        insert coaMasFyBal; 
        
        
        //---------------Data entry for COA Balance---------------------
        COA_Balance__c co=new COA_Balance__c();
        co.name='test coa balance';
        co.COA_Master_FY_Balance__c = coaMasFyBal.id;
        insert co;
        
        //---------------Data entry for Journal Entry---------------------        
        Journal_Entry__c jE=new Journal_Entry__c();
        jE.name='jouEntryTesting';
        jE.Journal_Voucher__c=jV.id;
        jE.Posting_Status__c='Unposted';
        jE.COA_Balance__c=co.id;
        insert jE;
        
        //---------------Updating Posting Status as 'Posted'---------------------        
        Journal_Entry__c jE2=[Select id from Journal_Entry__c where id=:jE.id];
        jE2.Posting_Status__c='Posted';
        update jE2;
       
    }
}