global class GenerateCOABalance{
    webservice static void generateRecords(String accId,String coaGrpId, Id[] fsYrId){ 
         System.debug('Account-->'+accId);
         System.debug('FY-->'+fsYrId); 
        // GenerateCOABalance_Batch obj = GenerateCOABalance_Batch(Id.valueOf(accId),fsYrId[0]);
        // Database.executeBatch(obj); 
        Database.executeBatch(new GenerateCOABalance_Batch(Id.valueOf(accId),Id.valueOf(coaGrpId),fsYrId[0]));
    }
}