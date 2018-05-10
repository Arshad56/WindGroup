public class CheckListData {
    /*
   public String checkListId{get;set;}
   public List<CheckListItemWrapper> checkListItemList  {get; set;}
        
   public CheckListData(){
        checkListItemList = new List<CheckListItemWrapper>();
            
   } 
    
    
   public class CheckListItemWrapper{
        public String checkListItemId   {get; set;}
        public String checkListId       {get; set;}
        public String name              {get; set;}
        public String serialNumber      {get; set;}
        public String condition         {get; set;}
        public Boolean status           {get; set;}
        public String description       {get; set;}
        public Decimal num              {get; set;}
        public DateTime actionDateTime  {get; set;}
        public List<CheckListRemarkWrapper> checkListRemarkList {get; set;}
        
        public CheckListItemWrapper(){
            checkListRemarkList = new List<CheckListRemarkWrapper>();
        }
        public CheckListItemWrapper(Checklist_Item__c checkItem,List<CheckListRemarkWrapper> checkListRemarkList){
            this();
            this.checkListItemId = checkItem.Id;
            this.checkListRemarkList = checkListRemarkList;
            this.checkListId = checkItem.Checklist__c;
            this.name = checkItem.Name;
            this.serialNumber = checkItem.SN__c;
            this.condition = checkItem.Condition__c;
            this.status = checkItem.Status__c;
            this.description = checkItem.Description__c;
            this.num = checkItem.Number__c;
            this.actionDateTime = checkItem.Action_Date_Time__c;    
        }
        
    }
    public class CheckListRemarkWrapper{
        public String checkListItemId   {get; set;}
        public String remark            {get; set;}
        
        public CheckListRemarkWrapper(Checklist_Remarks__c checkRemark){
            this.checkListItemId = checkRemark.Checklist_Item__c;
            this.remark = checkRemark.Remarks__c;
        }
    }*/
}