trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert) {
    // This is the only line of code that is required.
	TriggerFactory.createTriggerDispatcher(ContentDocumentLink.sObjectType);
}