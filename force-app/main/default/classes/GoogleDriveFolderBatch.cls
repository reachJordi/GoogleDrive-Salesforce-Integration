global class GoogleDriveFolderBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful{
    
    private Map<Id, String> recordsToPass = new Map<Id, String>();
    
    global Database.querylocator start(Database.BatchableContext BC) {
        string query  = 'Select Id, Name, SendToGoogleDrive__c FROM Account WHERE SendToGoogleDrive__c = true';    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountList){
        for(Account account : accountList) {
            String folderId = GoogleDrive.createGoogleDriveFolder(account.Name);
            if (folderId != null) {
                recordsToPass.put(account.Id, folderId); 
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){ 
        // Start the second batch and pass the records
        Database.executeBatch(new GoogleDriveSendFileBatch(recordsToPass), 200);
    }
    
    //Schedulable methods
    global void execute(System.SchedulableContext schContext) {
        
    }


}