public with sharing class TaskHistory_Extension {
	public id taskId{get;set;}
	public Double offset{
		get{
	        TimeZone tz = UserInfo.getTimeZone();
	        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    	}
	}
	public List<Task_Activity_History__c> tahList{get;set;}
    public TaskHistory_Extension(ApexPages.StandardController controller) {      
     taskId = [select id from Task where id = : ApexPages.currentPage().getParameters().get('id')].Id;
     tahList= new List<Task_Activity_History__c>(); 
     if(taskId != null)
         tahList = [select id,Comment__c,Date_Time__c,Equipment__c,Estimated_Completion__c,Estimated_Cost__c,Estimated_Work_Days__c,Location__c,Property__c,Request_ID__c,Task_ID__c,Task_Record_ID__c,User_Name__r.Name from Task_Activity_History__c where Task_Record_ID__c = :taskId ORDER BY Date_Time__c Desc];
    Integer i = 0;  
     i = 0; 
     i = 0; 
     i = 0; 
     i = 0; 
    }
}