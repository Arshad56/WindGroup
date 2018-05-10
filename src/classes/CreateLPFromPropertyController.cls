public with sharing class CreateLPFromPropertyController {
	public Boolean success{get;set;}
	public Property__c prop{get;set;}
	List < SelectOption > yearOptions;
	public List<SelectOption> getYearOptions(){
		return yearOptions;
	}
	public List<SelectOption> setYearOptions(Integer tempYear){
        yearOptions = new List<SelectOption>();
        for(Integer i=0; i<=15;i++){
        	if(tempYear < 2030)
            	yearOptions.add(new SelectOption(++tempYear+'', tempYear+''));
        }
        return yearOptions;
    }
	public CreateLPFromPropertyController(){
		String propId = Apexpages.currentPage().getParameters().get('Id');
		prop = new Property__c();
		for(Property__c prp: [select Id,End_Year__c from Property__c where Id =: propId]){
			prop = prp;
		}
		setYearOptions((prop.End_Year__c != null && prop.End_Year__c != '')?Integer.valueOf(prop.End_Year__c):System.today().year()-1);
	} 
	public void  updateProperty() {
		success = true;
		try{
			update prop;
		}catch(Exception e){
			System.debug('Exception Occured--->'+e);
		}
	}  
}