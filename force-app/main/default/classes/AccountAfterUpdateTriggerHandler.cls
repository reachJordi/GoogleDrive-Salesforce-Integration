public class AccountAfterUpdateTriggerHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		process((List<Account>)tp.newList, (Map<Id,Account>)tp.oldMap);
	}
	
	private static void process(List<Account> listNewAccounts, Map<Id, Account> oldMap) {
	}
	
	public override void inProgressEntry(TriggerParameters tp) {
		System.debug('This is an example for reentrant code...');
	}
}