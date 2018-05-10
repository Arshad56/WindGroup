public class PrivacyPolicyController{
    public string docId{get;set;}
    public PrivacyPolicyController(){
        for(Document doc:[select id from Document where name='iOPS Privacy Policy']){
            docId = doc.Id;
        }
    }
}