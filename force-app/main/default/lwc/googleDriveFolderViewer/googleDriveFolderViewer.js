import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getGoogleDriveFiles from '@salesforce/apex/GoogleDrive.getGoogleDriveFiles';

export default class GoogleDriveFolderViewer extends LightningElement {
    @api recordId;
    @api folderId;
    files = [];

    @wire(getRecord, { recordId: '$recordId', fields: ['Account.GoogleDriveFolderId__c'] })
    wiredRecord({ error, data }) {
        if (data) {
            this.folderId = data.fields.GoogleDriveFolderId__c.value;
            console.log('*** Folder ID: ' + this.folderId);
            this.loadFiles();
        } else if (error) {
            console.error('Error loading record', error);
        }
    }

    loadFiles() {
        getGoogleDriveFiles({ folderId: this.folderId })
            .then(result => {
                console.log('**** Files: ' + JSON.stringify(result));
                this.files = JSON.parse(result);
            })
            .catch(error => {
                console.error('Error loading files', error);
            });
        
    }
}