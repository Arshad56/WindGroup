global class LAPDFGenerator{
    webservice static string generatePDF(Id leaseId){
        pageReference pg = page.LaPDF;
        pg.getParameters().put('Id',leaseId);
        
        Attachment att = new Attachment();
        Blob body;
        
        if(Test.isRunningTest()){
            att.body = blob.valueOf('Test');
        }else{
            att.body = pg.getContent();
        }
        
        att.IsPrivate = FALSE;
        att.ParentId = leaseId;
        att.name = 'LA Document';
        att.contentType='application/pdf';
        
        try{
            insert att;
        }
        catch(exception e){
            system.debug(e.getMessage());
            return e.getMessage();
        }
        return null;
    }
}