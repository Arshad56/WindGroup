/**
 * @author Sudhir Dudeja
 * @version 1.0
 *  Trigger would roll up the amount from rent sechdules and create rent roll up bases of different different property
 **/

global class batchRentRollUp implements Database.Batchable<sObject> {

     String query;     //Query to be execute by batch class
     set<ID> propertyID=new set<ID>();
            list<Rent_Schedules__c> rentList=new list<Rent_Schedules__c>();
            Map<String,Rent_Roll__c> rentMap=new Map<String,Rent_Roll__c>();
            Map<String,Rent_Roll__c> propertyMap=new Map<String,Rent_Roll__c>();
            Decimal Count=0;

           public list<AggregateResult> rentRollList=new list<AggregateResult>();

    global batchRentRollUp() {

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
       // query='Select id,Amount__c,Unit__r.Property__c,Property__c from Rent_Schedules__c where Billing_Date__c=TODAY';
        //query='Select id,Amount__c,Unit__r.Property__c,Property__c from Rent_Schedules__c where Billing_Date__c=:system.today()';
        
        //System.debug('query is'+query);

        //System.debug('Database Query is'+Database.getQueryLocator(query));

        return Database.getQueryLocator([Select id,Amount__c,Unit__r.Property__c,Property__c from Rent_Schedules__c where Billing_Date__c=:system.today()]);


    }

    global void execute(Database.BatchableContext BC, List<Rent_Schedules__c> scope) {


                     for(Rent_Schedules__c rs : scope){

    rentMap.put(rs.Unit__r.Property__c, new Rent_Roll__c(Property__c=rs.Unit__r.Property__c,Total_Amount__c=0,Name='RR-'+rs.Property__c+'-'+'Date'+'-'+Date.Today().Day()+Date.Today().Month()+'-'+Date.Today().Year()));     //map contaning property id and rent roll
                                propertyID.add(rs.Unit__r.Property__c);

                                System.debug(rs.Unit__r.Property__c);
                                System.debug('propoertyID is'+propertyID);
                                System.debug('rentMap'+rentMap);
                     }

                     if(!rentMap.isEmpty()){


                                rentRollList=[Select id,Sum(Amount__c) , Unit__r.Property__c from Rent_Schedules__c where Unit__r.Property__c IN :propertyID AND Billing_Date__c=TODAY group by id,Unit__r.Property__c];

                                System.debug('rentRollList is'+rentRollList);

                     }
                     if(!rentRollList.isEmpty()){

                                for(AggregateResult tt:rentRollList){
                                    System.debug('property value is'+rentMap.containsKey((ID)tt.get('Property__c')));
                                    if(rentMap.containsKey((ID)tt.get('Property__c'))){

                                        Count+=(Decimal)tt.get('expr0');

                                        System.debug('Count is'+Count);

                                        rentMap.get((ID)tt.get('Property__c')).Total_Amount__c=Count;

                                    }
                                }
                     }

                     if(!rentMap.isEmpty()){

                               insert rentMap.values();

                     }





    }

    global void finish(Database.BatchableContext BC) {

    }

}