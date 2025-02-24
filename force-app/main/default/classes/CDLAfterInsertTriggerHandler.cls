public class CDLAfterInsertTriggerHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		process((List<ContentDocumentLink>)tp.newList);
	}
	
	private static void process(List<ContentDocumentLink> listNewCDL) {
    }
	
	public override void inProgressEntry(TriggerParameters tp) {
		System.debug('This is an example for reentrant code...');
	}
}