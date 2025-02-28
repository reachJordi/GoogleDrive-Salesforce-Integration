global class GoogleDriveSendFileBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    private Map<Id, String> recordsFromFirstBatchMap;
    private List<Id> recordsFromFirstBatch;
    private List<SObject> recordsToUpdate;
    
    global GoogleDriveSendFileBatch(Map<Id, String> records, List<SObject> recordsToUpdate) {
        this.recordsFromFirstBatchMap = records;
        this.recordsFromFirstBatch = new List<Id>(records.keySet());
        this.recordsToUpdate = recordsToUpdate;
    }
    
    global List<sObject> start(Database.BatchableContext BC) {
        String sObjectType = recordsFromFirstBatch[0].getSObjectType().getDescribe().getName();
        return Database.query('SELECT Id FROM ' + sObjectType + ' WHERE Id IN :recordsFromFirstBatch');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Id> recordIds = new List<Id>();
        for (SObject obj : scope) {
            recordIds.add(obj.Id);
        }
        
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :recordIds
        ];
        
        
        Map<Id, List<ContentDocumentLink>> recordLinksMap = new Map<Id, List<ContentDocumentLink>>();
        
        for (ContentDocumentLink link : links) {
            if (!recordLinksMap.containsKey(link.LinkedEntityId)) {
                recordLinksMap.put(link.LinkedEntityId, new List<ContentDocumentLink>());
            }
            
            recordLinksMap.get(link.LinkedEntityId).add(link);
        }
        
        System.enqueueJob(new GoogleDriveQueueableFileUploader(recordLinksMap, this.recordsFromFirstBatchMap));
    }
    
    global void finish(Database.BatchableContext BC) {
        if(!recordsToUpdate.isEmpty()) {
            Database.update(recordsToUpdate, false);
        }
    }
}