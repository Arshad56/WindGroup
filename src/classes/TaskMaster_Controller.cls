public with sharing class TaskMaster_Controller {
	public Tasklist_Items__c ti{get;set;}
	public Boolean closeWindow{get;set;}
	public Boolean errorOnPage{get;set;}
	String request_Id;
    public TaskMaster_Controller(){
    	request_Id = ApexPages.currentPage().getParameters().get('request_Id');
    	ti = new Tasklist_Items__c();
    }
    public void save(){
    	
    	errorOnPage = false;
    	
    	System.debug('request_Id-->'+request_Id);
    	System.debug('ti.Tasklist_Master__c-->'+ti.Tasklist_Master__c);
    	if(ti.Tasklist_Master__c != null && request_Id != null){
    		List<Tasklist_Items__c> listTask = [select Id,Instructions__c,Priority__c,Requested_Completion_Days__c,Status__c,Subject__c,Tasklist_Master__c,User__c from Tasklist_Items__c where Tasklist_Master__c =: ti.Tasklist_Master__c];
    		List<Task> listTasks= new List<Task>();
    		for(Tasklist_Items__c ti: listTask){
    			Task tt = new Task();
    			tt.Subject= ti.Subject__c;
    			tt.Status= ti.Status__c;
    			tt.Priority= ti.Priority__c; 
    			tt.Instructions__c= ti.Instructions__c;
    			tt.OwnerId = ti.User__c;
    			if(ti.Requested_Completion_Days__c != null){
    				tt.ActivityDate = System.today().addDays(Integer.valueof(ti.Requested_Completion_Days__c));
    			}else{
    				tt.ActivityDate = System.today();
    			}
    			tt.WhatId = request_Id;
    			listTasks.add(tt);
    		}
    		System.debug('request_Id-->'+request_Id);
    		try{
    			insert listTasks;
    			closeWindow = true;
    		}catch(Exception e){
    			System.debug('Exception occured--> '+e);
    		}
    	}else{
    		errorOnPage = true;
    	}
    }
}