global class GoogleDriveSendFileBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    private Map<Id, String> recordsFromFirstBatchMap;
    private List<Id> recordsFromFirstBatch;
    
    global GoogleDriveSendFileBatch(Map<Id, String> records) {
        this.recordsFromFirstBatchMap = records;
        this.recordsFromFirstBatch = new List<Id>(records.keySet());
    }
    
    global List<sObject> start(Database.BatchableContext BC) {
        return [SELECT Id FROM Account WHERE Id IN :recordsFromFirstBatch];
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Id> accIds = new List<Id>();
        for (SObject obj : scope) {
            accIds.add(obj.Id);
        }
        
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :accIds
        ];
        
        Map<Id, List<ContentDocumentLink>> accountLinksMap = new Map<Id, List<ContentDocumentLink>>();
        
        for (ContentDocumentLink link : links) {
            if (!accountLinksMap.containsKey(link.LinkedEntityId)) {
                accountLinksMap.put(link.LinkedEntityId, new List<ContentDocumentLink>());
            }
            
            accountLinksMap.get(link.LinkedEntityId).add(link);
        }
        
        System.enqueueJob(new GoogleDriveQueueableFileUploader(accountLinksMap, this.recordsFromFirstBatchMap));
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}