public class AccountAfterUpdateTriggerHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		process((List<Account>)tp.newList, (Map<Id,Account>)tp.oldMap);
	}
	
	private static void process(List<Account> listNewAccounts, Map<Id, Account> oldMap) {
        
        Map<Id, Account> accounts = new Map<Id, Account>();
        
        for(Account acc : listNewAccounts) {
			Account oldAccount = oldMap.get(acc.Id);
            if(acc.SendToGoogleDrive__c && acc.SendToGoogleDrive__c != oldAccount.SendToGoogleDrive__c ){
                accounts.put(acc.Id, acc);
            }
        }
        
        if(!accounts.isEmpty()) {
            // Buscar content document links de las cuentas
            List<ContentDocumentLink> links = [
                SELECT ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :accounts.keyset()
            ];
            
            
            Map<Id, List<ContentDocumentLink>> accountLinksMap = new Map<Id, List<ContentDocumentLink>>();
                        
			for (ContentDocumentLink link : links) {
                if (!accountLinksMap.containsKey(link.LinkedEntityId)) {
                    accountLinksMap.put(link.LinkedEntityId, new List<ContentDocumentLink>());
                }
                
            	accountLinksMap.get(link.LinkedEntityId).add(link);
            }
            
            for(Id accId: accountLinksMap.keySet()) {
                FileUploader.handleUpload(accountLinksMap.get(accId));
            }
        }
	}
	
	public override void inProgressEntry(TriggerParameters tp) {
		System.debug('This is an example for reentrant code...');
	}
}