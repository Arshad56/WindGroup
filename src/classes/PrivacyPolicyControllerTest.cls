@isTest
public class PrivacyPolicyControllerTest {

    @isTest
    public static void PrivacyPolicyControllerTestMethod(){
        Document document;
        document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'iOPS Privacy Policy';
        document.FolderId = [select id from folder where name = 'Shared Documents'].id;
        insert document;
        
        PrivacyPolicyController cntr = new PrivacyPolicyController();
    }
}