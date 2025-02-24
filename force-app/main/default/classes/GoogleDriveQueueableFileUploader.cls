public class GoogleDriveQueueableFileUploader implements System.Queueable  {
    Map<Id, List<ContentDocumentLink>> records;
    Map<Id, String> accountWithFolders;
    
    public GoogleDriveQueueableFileUploader(Map<Id, List<ContentDocumentLink>> records, Map<Id,String> accountWithFolders) {
        this.records = records;
        this.accountWithFolders = accountWithFolders;
    }
    
    public void execute(QueueableContext context) {
        
        if(!accountWithFolders.isEmpty()) {
            for(Id accountId : accountWithFolders.keyset()) {
                List<ContentDocumentLink> links = records.get(accountId);    
            	String folderId = accountWithFolders.get(accountId);
                
                if (links != null && folderId != null) {
                    FileUploader.handleUpload(links, folderId);
                }
            }
        }
    }
}