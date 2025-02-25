global class GoogleDriveFolderBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful{
    
    private Map<Id, String> recordsToPass = new Map<Id, String>();
    private List<Account> accountsToUpdate = new List<Account>();
    
    global Database.querylocator start(Database.BatchableContext BC) {
        string query  = 'Select Id, Name, GoogleDriveFolderId__c, SendToGoogleDrive__c FROM Account WHERE SendToGoogleDrive__c = true';    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountList){
        
        for(Account account : accountList) {
            // in case we don't have any folder for this account
            if(account.GoogleDriveFolderId__c == null) {
                // create a new folder
                String folderId = GoogleDrive.createGoogleDriveFolder(account.Name + ' - Id: ' + account.Id);
                accountsToUpdate.add(new Account(
                    Id = account.Id,
                    GoogleDriveFolderId__c = folderId
                ));
                
                recordsToPass.put(account.Id, folderId); 
            } else {
            	recordsToPass.put(account.Id, account.GoogleDriveFolderId__c);    
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){ 
        // Start the second batch and pass the records
        Database.executeBatch(new GoogleDriveSendFileBatch(recordsToPass, accountsToUpdate), 200);
    }
    
    //Schedulable methods
    global void execute(System.SchedulableContext schContext) {
        
    }


}