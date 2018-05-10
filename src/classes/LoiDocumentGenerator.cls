/*
*    Name              :        Loi Document Generator (webservice class)
*    Author            :        Mohd Anas
*    Date              :        23 May 2017
*    Description       :        Web services class for generation of LOI Document as Pdf.
*/
global class LoiDocumentGenerator{
    webservice static void generateLoi(id parentId){
        pageReference pg = page.LOIPdf;
        pg.getParameters().put('loiId',parentId);
        
        Attachment att = new Attachment();
        Blob body;
        
        
        if(Test.isRunningTest()){
            att.body = blob.valueOf('Test');
        }else{
            att.body = pg.getContent();
        }
        
        att.IsPrivate = FALSE;
        att.ParentId = parentId;
        att.name = 'LOI Document';
        att.contentType='application/pdf';
        
        try{
            insert att;
            system.debug(att);
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
       
    }
}