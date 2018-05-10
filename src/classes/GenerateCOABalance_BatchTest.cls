@isTest 
public class GenerateCOABalance_BatchTest {
    @isTest Static void myTest(){
        list<COA_Master__c> cmList=new list<COA_Master__c>();
        list<COA_Balance__c> cbList=new list<COA_Balance__c>();
        COA_Master__c cm=new COA_Master__c();
        cm.Name='testAc';
        cmList.add(cm);
        
        COA_Master__c cmm=new COA_Master__c();
        cmm.Name='testAc3';
        cmList.add(cmm);
        insert cmList;
        
        Account ac=new Account();
        ac.Name='TestAc';
        insert ac;
        
        COA_Group__c cg=new COA_Group__c();
        cg.name='TestCOA';
        insert cg;
        
        
        Fiscal_Year__c fy=new Fiscal_Year__c();
        fy.name='testFY';
        insert fy;
        
        Fiscal_Period__c fp=new Fiscal_Period__c();
        fp.name='testFP';
        fp.Fiscal_Year__c=fy.Id;
        insert fp;
        
        COA_Master_FY_Balance__c coaMasFyBal = new COA_Master_FY_Balance__c();
        coaMasFyBal.COA_Master__c = cmm.id; 
        coaMasFyBal.Fiscal_Year__c = fy.id;
        insert coaMasFyBal;
        
        COA_Balance__c cb=new COA_Balance__c();
        cb.name='Testcb';
        cb.COA_Master__c=cm.Id;
        cb.Company__c=ac.id;
        cb.Fiscal_Period__c=fp.id;
        cb.COA_Master_FY_Balance__c= coaMasFyBal.id;
        cblist.add(cb);
        
        COA_Balance__c cbb=new COA_Balance__c();
        cbb.name='Testcb';
        cbb.COA_Master__c=cm.Id;
        cbb.Company__c=ac.id;
        cbb.Fiscal_Period__c=fp.id;
        cbb.COA_Master_FY_Balance__c = coaMasFyBal.id;
        cblist.add(cbb);
        insert cbList;
        
        Test.startTest();
        GenerateCOABalance_Batch obj=new GenerateCOABalance_Batch(ac.Id, cg.Id, fy.Id);
        database.executeBatch(obj);
        obj.execute(null, cmList);
        obj.finish(null);
        Test.stopTest();
    }
}