public class CheckListRestAPITestClass {
    /*
    public static void doTest(){
        dataEntry();
    } 
    
    public static void dataEntry(){
        
        Set<Id> checkItemSet = new Set<Id>();
        List<CheckListData.CheckListRemarkWrapper> checkListRemarkWrapperList = new List<CheckListData.CheckListRemarkWrapper>();
        List<CheckListData.CheckListItemWrapper> checkListItemWrapper = new List<CheckListData.CheckListItemWrapper>();
        CheckListData chkData;
        
        
        List<Checklist__c> checkList = [SELECT Id, (SELECT Id,Name,Checklist__c,Action_Date_Time__c,Condition__c,Description__c,Number__c,SN__c,Status__c FROM Checklist_Items__r) FROM Checklist__c limit 1];
        
        if(checkList != null){
            for(Checklist_Item__c chkItem : checkList.get(0).Checklist_Items__r){
                checkItemSet.add(chkItem.Id);
            }
        }
        
        if(!checkItemSet.isEmpty()){
            List<Checklist_Remarks__c> checkRemarks = [SELECT Id,Checklist_Item__c,Remarks__c FROM Checklist_Remarks__c WHERE Checklist_Item__c IN : checkItemSet];
        
            if(checkRemarks != null){
                for(Checklist__c chkList : checkList){
                    for(Checklist_Item__c chkItem : chkList.Checklist_Items__r){
                        for(Checklist_Remarks__c chRk : checkRemarks){
                            if(chkItem.Id == chRk.Checklist_Item__c){
                                checkListRemarkWrapperList.add(new CheckListData.CheckListRemarkWrapper(chRk));
                            }
                        }
                        checkListItemWrapper.add(new CheckListData.CheckListItemWrapper(chkItem,checkListRemarkWrapperList));
                    }
                
                    chkData = new CheckListData();
                    chkData.checkListId = chkList.Id;
                    chkData.checkListItemList = checkListItemWrapper;
                }
            } 
        }
        if(chkData != null){
            String jsonData = JSON.serialize(chkData);
            System.debug('>>>>jsonData>>'+ jsonData);
        }       
    }*/
}