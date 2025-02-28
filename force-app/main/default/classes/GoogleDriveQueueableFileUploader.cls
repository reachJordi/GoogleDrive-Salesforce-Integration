public class GoogleDriveQueueableFileUploader implements System.Queueable  {
    Map<Id, List<ContentDocumentLink>> records;
    Map<Id, String> recordWithFolder;
    
    public GoogleDriveQueueableFileUploader(Map<Id, List<ContentDocumentLink>> records, Map<Id,String> recordWithFolder) {
        this.records = records;
        this.recordWithFolder = recordWithFolder;
    }
    
    public void execute(QueueableContext context) {
        
        if(!recordWithFolder.isEmpty()) {
            for(Id recordId : recordWithFolder.keyset()) {
                List<ContentDocumentLink> links = records.get(recordId);    
            	String folderId = recordWithFolder.get(recordId);
                
                if (links != null && folderId != null) {
                    FileUploader.handleUpload(links, folderId);
                }
            }
        }
    }
}