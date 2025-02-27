import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getGoogleDriveFiles from '@salesforce/apex/GoogleDrive.getGoogleDriveFiles';
import deleteGoogleDriveFile from '@salesforce/apex/GoogleDrive.deleteGoogleDriveFile';

export default class GoogleDriveFolderViewer extends LightningElement {
    @api recordId;
    @api folderId;
    files = [];
    displayFiles = [];
    currentPage = 1;
    recordsPerPage = 3;
    totalPages = 0;

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
                this.calculatePages();
                this.displayFilesForCurrentPage();
            })
            .catch(error => {
                console.error('Error loading files', error);
            });
    }

    handleDeleteFile(event) {
        const fileId = event.target.dataset.fileId;
        deleteGoogleDriveFile({ fileId: fileId })
            .then(() => {
                console.log('File deleted successfully');
                this.loadFiles(); // Refresh the file list
            })
            .catch(error => {
                console.error('Error deleting file', error);
            });
    }

    calculatePages() {
        this.totalPages = Math.ceil(this.files.length / this.recordsPerPage);
    }

    displayFilesForCurrentPage() {
        const start = (this.currentPage - 1) * this.recordsPerPage;
        const end = start + this.recordsPerPage;
        this.displayFiles = this.files.slice(start, end);
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.displayFilesForCurrentPage();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.displayFilesForCurrentPage();
        }
    }

    get avoidPaginationButtons() {
        return this.totalPages < 2;
    }

    get showPreviousButton() {
        return this.currentPage != 1;
    }

    get showNextButton() {
        return this.currentPage != this.totalPages;
    }
}