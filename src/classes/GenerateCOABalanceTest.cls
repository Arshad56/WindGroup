@istest
public class GenerateCOABalanceTest {
    static testMethod void TestGenerateCOABalance(){
        
        Account ac=new Account();
        ac.Name='TestAc';
        insert ac;
        
        COA_Group__c cg=new COA_Group__c();
        cg.name='TestCOA';
        insert cg;
        
        list<COA_Master__c> cmList=new list<COA_Master__c>();
        COA_Master__c cm=new COA_Master__c();
        cm.Name='testAc';
        cmList.add(cm);
        
        COA_Master__c cmm=new COA_Master__c();
        cmm.Name='testAc3';
        cmList.add(cmm);
        
        insert cmList;
        
        Fiscal_Year__c fy=new Fiscal_Year__c();
        fy.name='testFY';
        insert fy;
        
        Fiscal_Period__c fp=new Fiscal_Period__c();
        fp.name='testFP';
        fp.Fiscal_Year__c=fy.Id;
        insert fp;
        
       list<id> fyList = new List<id>();
        fyList.add(fy.id);
         //GenerateCOABalance obj=new GenerateCOABalance();
         GenerateCOABalance.generateRecords(string.valueof(ac.id),string.valueof(cg.id),fyList);
         //database.executeBatch(GenerateCOABalance);
       
       }
        
        
}