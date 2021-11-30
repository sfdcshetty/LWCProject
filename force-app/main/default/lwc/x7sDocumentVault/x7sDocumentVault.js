/**
 * Created by karolbrennan on 4/15/21.
 */

import {LightningElement, api, track} from 'lwc';
import USER_ID from '@salesforce/user/Id';
import getFiles from '@salesforce/apex/x7s_RecentDocumentsController.getListOfDocumentsForCurrentUser';
import deleteFile from '@salesforce/apex/x7s_RecentDocumentsController.deleteCloudFile';
import iconResource from '@salesforce/resourceUrl/x7sToDoIcons';
import BASE_PATH from '@salesforce/community/basePath';
import {registerListener, unregisterAllListeners} from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class X7SDocumentVault extends LightningElement {
    @track isLoading = false;
    @track sortedFiles = {
        fromMyAdvisors: {
            category: 'From My Advisors',
            folders: {
                "Agreements": {name: "Agreements", files: []},
                "Plans, Reviews & Meeting Notes": {name: "Plans, Reviews & Meeting Notes", files: []},
                "Disclosures": {name: "Disclosures", files: []},
            }
        },
        mySharedDocs: {
            category: 'My Shared Documents',
            folders: {
                "Account Statements": {name: "Account Statements", files: []},
                "Tax Returns": {name: "Tax Returns", files: []},
                "Estate Documents": {name: "Estate Documents", files: []},
                "Other": {name: "Other", files: []},
                "My Vault": {name: "My Vault", files: []}
            }
        },
        recentDocs: {category: 'Recent Documents', files: []}
    };

    /*sortedFiles = {
        fromMyAdvisors: {
            category: 'From My Advisors',
            folders: {}
        },
        mySharedDocs: {
            category: 'My Shared Documents',
            folders: {
                "Account Statements": {name: "Account Statements", files: []},
                "Tax Returns": {name: "Tax Returns", files: []},
                "Estate Documents": {name: "Estate Documents", files: []},
                "Other": {name: "Other", files: []},
                "My Vault": {name: "My Vault", files: []}
            }
        },
        recentDocs: {category: 'Recent Documents', files: []}
    };*/

    @track fileCount = 0;
    @track activeFolder = '';
    @track activeCategory = 'From My Advisors';
    @track inFolderView = false;
    @api originalFileList;
    @api noFilesMessage = "There are no files to display.";

    // Pagination
    @track currentPage = 1;
    @track startIndex = 0;
    @api perPage = 15;

    // Used to keep track of the folders
    //@api fromMyAdvisorsFolders = [];
    @api fromMyAdvisorsFolders = [ "Agreements", "Plans, Reviews & Meeting Notes", "Disclosures" ];
    @api mySharedDocsFolders = ["Account Statements", "Tax Returns", "Estate Documents", "Other", "My Vault"];

    @track refresh = false;
    // Icons
    icons = {
        view: iconResource + '/preview-gray.svg',
        download: iconResource + '/download-gray.svg',
        delete: iconResource + '/delete-gray.svg',
    }
    /**
     * Connected callback
     * Retrieve the file list, then register the listener
     * that will alert us of new uploads so we can re-retrieve the files list
     */
    connectedCallback() {
        this.getFileList();
        registerListener("updatevault",  this.updateVault, this);
    }

    /**
     * When the component disconnects, unregister the listeners
     */
    disconnectedCallback() {
        unregisterAllListeners(this);
    }
    
    updateVault() {
        this.getFileList(); 
    }

    /**
     * Retrieve the file list, then sort them.
     */
    getFileList = () => {
        this.isLoading = true;
        getFiles({userId: USER_ID}).then((result, error) => {
            //console.log(result);
            if(result){
                this.originalFileList = result;
                // Sort files into folders and categories
                this.sortFiles(result);
            }
            if(error){
                this.isLoading = false;
                console.error(error);
            }
            this.resetPagination();
        });
    };

    /**
     * Sorts the given file list array into categories > folders > files
     * @param files
     */
    sortFiles(files){
        let fileList = JSON.parse(JSON.stringify(files));
        let recentDocList = [];
        let fileCount = 0;
        this.resetFileListObj();
        fileList.forEach(file => {
            console.log('!!!IS CFB Folder-->'+file.TVA_CFB__Folder__c);
            console.log('!!!IS PORTAL FOLDER-->'+file.Portal_Folder__c);
            let folder = (file.TVA_CFB__Folder__c !== undefined) ? file.TVA_CFB__Folder__c : file.Portal_Folder__c;
            console.log('!!!file-->'+file.Name);
            console.log('!!!folder-->'+folder);
            file.folder = folder;
            // If the folder is undefined, we should not be displaying the file
            // So if the folder is NOT undefined or Trash, continue, otherwise do nothing with the file.
            if(folder !== undefined && folder !== 'Trash') {
                // Replace download/view link text with icons
                file.iconName = this.getFileIcon(file.Name);
                if (file.hasOwnProperty('TVA_CFB__Download_File__c')) {
                    // Fix broken original link
                    if (!file.TVA_CFB__Download_File__c.includes(BASE_PATH)) {
                        file.TVA_CFB__Download_File__c = file.TVA_CFB__Download_File__c.replace('/apex', (BASE_PATH.substring(0, BASE_PATH.length - 2) + '/apex'));
                    }
                    // set up links for downloading
                    file.downloadLink = file.TVA_CFB__Download_File__c.replace('Download File', file.Name);
                    file.downloadIcon = file.TVA_CFB__Download_File__c.replace('Download File',
                        `<img src="${this.icons.download}" class="small-icon" alt="Download File"/>`);
                }
                if (file.hasOwnProperty('TVA_CFB__View_File__c')) {
                    // Fix broken original link
                    if (!file.TVA_CFB__View_File__c.includes(BASE_PATH)) {
                        file.TVA_CFB__View_File__c = file.TVA_CFB__View_File__c.replace('/apex', (BASE_PATH.substring(0, BASE_PATH.length - 2) + '/apex'));
                    }
                    // set up links for viewing
                    file.viewLinkId = file.id;
                    file.viewLink = file.TVA_CFB__View_File__c.replace('View File', file.Name);
                    file.viewIcon = file.TVA_CFB__View_File__c.replace('View File',
                        `<img src="${this.icons.view}" class="small-icon" alt="View File"/>`);
                }
                if(file.hasOwnProperty('CreatedById')) {
                    file.allowDelete = file.CreatedById === USER_ID;
                }
                recentDocList.push(file);
                fileCount++;

                // The My Shared Docs folder list is set, so first check to see if the folder exists
                // In this context, if it does, the file should be added to the appropriate folder.
                // If it doesn't, we want to add it to the fromMyAdvisors list.
                if (this.mySharedDocsFolders.includes(folder)) {
                    Object.keys(this.sortedFiles.mySharedDocs.folders).forEach(myFolder => {
                        if (myFolder === folder) {
                            console.log('found ' + myFolder + ' and ' + folder, file);
                            //this.sortedFiles.mySharedDocs.folders[myFolder].files.push(file);
                            this.sortedFiles.mySharedDocs.folders[myFolder].files.push(file);
                            //console.log('inserted file', this.sortedFiles.mySharedDocs.folders[myFolder].files);
                        }
                    });
                } else {
                    // If the folder already exists in the fromMyAdvisorsFolders list, push the file to it
                    // If the folder doesn't exist, create it
                    if (this.fromMyAdvisorsFolders.includes(folder) && (this.sortedFiles.fromMyAdvisors.folders[folder] !== undefined)) {
                        this.sortedFiles.fromMyAdvisors.folders[folder].files.push(file);
                    } else {
                        this.fromMyAdvisorsFolders.push(folder);
                        this.sortedFiles.fromMyAdvisors.folders[folder] = {name: folder, files: [file]};
                    }
                }
            }
        });
        setTimeout(() => {
            this.fileCount = fileCount;
            this.sortedFiles.recentDocs.files = recentDocList;
            this.refresh = !this.refresh;
            this.isLoading = false;
        },0)
    }


    getFileIcon(fileName) {
        let icon = "doctype:unknown";
        // current doc types
        // doc, docx, xls, xlsx, ppt, pptx, pdf, txt, csv, jpg, gif, epub
        if(fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
            icon = "doctype:word";
        }
        if(fileName.endsWith('.xlx') || fileName.endsWith('.xlsx')) {
            icon = "doctype:excel";
        }
        if(fileName.endsWith('.') || fileName.endsWith('.')) {
            icon = "doctype:";
        }
        if(fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
            icon = "doctype:ppt";
        }
        if(fileName.endsWith('.pdf') || fileName.endsWith('.pdf')) {
            icon = "doctype:pdf";
        }
        if(fileName.endsWith('.txt') || fileName.endsWith('.txt')) {
            icon = "doctype:txt";
        }
        if(fileName.endsWith('.csv') || fileName.endsWith('.csv')) {
            icon = "doctype:csv";
        }
        if(fileName.endsWith('.jpg') || fileName.endsWith('.jpeg') || fileName.endsWith('.gif') || fileName.endsWith('.gif')) {
            icon = "doctype:image";
        }
        return icon;
    }

    /**
     * Resets the file list object for when we retrieve new files
     * After deleting a file from the list. This ensures we don't get
     * duplicate views
     */
    resetFileListObj(){
        this.sortedFiles = {
            fromMyAdvisors: {
                category: 'From My Advisors',
                folders: {}
            },
            mySharedDocs: {
                category: 'My Shared Documents',
                folders: {
                    "Account Statements": {name: "Account Statements", files: []},
                    "Tax Returns": {name: "Tax Returns", files: []},
                    "Estate Documents": {name: "Estate Documents", files: []},
                    "Other": {name: "Other", files: []},
                    "My Vault": {name: "My Vault", files: []}
                }
            },
            recentDocs: {category: 'Recent Documents', files: []}
        }
    }

    /**
     * Handles the click event when a user selects a category
     * @param event
     */
    handleCategorySelect(event){
        this.activeCategory = event.target.dataset.id;
        // reset active folder upon category select
        this.activeFolder = '';
        // if the category is Recent Documents, there are no folders to display
        // so set inFolderView to true so it will display the files
        this.inFolderView = (this.activeCategory === 'Recent Documents');
        // Reset pagination since we will be starting on a new page
        this.resetPagination();
    }

    /**
     * Handles the click event when a user selects a folder
     * @param event
     */
    handleFolderSelect(event){
        this.activeFolder = event.target.dataset.id;
        this.inFolderView = true;
        this.resetPagination();
    }

    /**
     * Handles deletion of a file. This merely marks the file as going into a trash folder
     * Users can only do this for their own files, not ones uploaded by advisors
     * @param event
     */
    handleFileDelete(event){
        let id = event.currentTarget.dataset.id;
        this.isLoading = true;
        deleteFile({fileId: id}).then(result => {
            if(result === true){
                this.resetFileListObj();
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Your file has been deleted',
                    variant: 'success',
                }));
            } else {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'There was a problem deleting your file',
                    variant: 'error',
                }) );
            }
        }).finally(() => {
            this.isLoading = false;
            this.getFileList();
            this.refresh = !this.refresh;
        });
    }

    /**
     * Handles the previous page button
     * if the current page is greater than 1, continue
     * else, do nothing - the button should be disabled if the current page is the first page.
     */
    handlePrevPage(){
        if(this.currentPage > 1){
            this.scrollToTop();
            this.currentPage = (this.currentPage - 1);
            this.startIndex = (this.startIndex - this.perPage);
            if(this.startIndex < 0) {
                this.startIndex = 0;
            }
        }
    }

    /**
     * Handles the next page button
     * if the current page is less than the total number of pages, allow the
     * user to advance a page. If not, do nothing (the button should be disabled at
     * this time anyway so it shouldn't affect anything
     */
    handleNextPage(){
        if(this.currentPage < this.paginationData.totalPages){
            this.scrollToTop();
            this.currentPage = (this.currentPage + 1);
            this.startIndex = (this.startIndex + this.perPage);
        }
    }

    /**
     * Resets the pagination, setting current page to 1 and start index to 0
     */
    resetPagination(){
        this.scrollToTop();
        this.currentPage = 1;
        this.startIndex = 0;
    }

    /**
     * Scrolls to the top of the component
     */
    scrollToTop(){
        //window.scrollTo({top: this.template.querySelector('.x7sDocumentVault').offsetTop, behavior: "smooth"});
    }

    /**
     * Returns a list of categories, using the getter allows us to set dynamic classes
     * on the element showing if the link is active or not
     * @returns {({name: string, url: string, classList: (string)}|{name: string, url: string, classList: (string)}|{name: string, url: string, classList: (string)})[]}
     */
    get categories() {
        return  [
            {name: 'From My Advisors', url: 'javascript:void(0)', classList: this.activeCategory === 'From My' +
                ' Advisors' ? 'folder-link active' : 'folder-link'},
            {name: 'My Shared Documents', url: 'javascript:void(0)', classList: this.activeCategory === 'My Shared' +
                ' Documents' ? 'folder-link active' : 'folder-link'},
            {name: 'Recent Documents', url: 'javascript:void(0)', classList: this.activeCategory === 'Recent Documents' ? 'folder-link active' : 'folder-link'}
        ]
    }

    /**
     * Gets the sorted file list for display on the front end.
     * This allows us to dynamically show paged results
     * @returns {[]}
     */
    get sortedFileList(){
        let sortedFileList  = [];
        Object.keys(this.sortedFiles).forEach(categoryKey => {
            let categoryName = this.sortedFiles[categoryKey].category;
            // Set up the category object, setting classes for display on the front
            // end if the category is active or not
            let categoryObj = {
                name: categoryName,
                active: this.activeCategory === categoryName,
                classList: this.activeCategory === categoryName ? 'folder-link active' : 'folder-link'
            };
            // If recent documents, there are no folders, so set the files
            if(categoryName === 'Recent Documents'){
                // sets paged results for display on the front end
                categoryObj.files = this.sortedFiles[categoryKey].files.slice(this.startIndex, (this.startIndex + this.perPage));
                categoryObj.totalPages = Math.ceil(this.sortedFiles[categoryKey].files.length / this.perPage);
                categoryObj.hasFolders = false;
            } else {
                categoryObj.folders = [];
                categoryObj.hasFolders = true;

                // Populate the folders with the files
                if ((this.sortedFiles[categoryKey] !== undefined) && (this.sortedFiles[categoryKey].folders !== undefined)) {
                    Object.keys(this.sortedFiles[categoryKey].folders).forEach(folder => {
                        let folderObj = {
                            name: folder,
                            active: this.activeFolder === folder,
                            files: [],
                            totalPages: 1
                        };
                        if (this.sortedFiles[categoryKey].folders[folder] !== undefined) {
                            folderObj.totalPages = Math.ceil(this.sortedFiles[categoryKey].folders[folder].files.length / this.perPage);
                            folderObj.files = this.sortedFiles[categoryKey].folders[folder].files.slice(this.startIndex, (this.startIndex + this.perPage));
                        }
                        if(folderObj.files.length > 0) {
                            categoryObj.folders.push(folderObj);
                        }
                    });
                }
            }
            sortedFileList.push(categoryObj);
        });
        return sortedFileList;
    }

    /**
     * Gets a pagination object that is dynamic and will return appropriate data
     * for whatever file result page we are looking at
     * @returns {{nextButtonDisabled: boolean, startIndex: number, perPage: number, endIndex, totalPages: number|number, prevButtonDisabled: boolean, currentPage: number}}
     */
    get paginationData() {
        let totalPages = 0;
        this.sortedFileList.forEach(category => {
            if(category.active === true){
                if(category.hasFolders === true){
                    category.folders.forEach(folder => {
                        if(folder.active === true){
                            totalPages = folder.totalPages;
                        }
                    });
                } else {
                    totalPages = category.totalPages;
                }
            }
        });
        let paginationObj = {
            currentPage: this.currentPage,
            totalPages: totalPages >= 1 ? totalPages : 1,
            perPage: this.perPage,
            prevButtonDisabled: (this.currentPage === 1),
            nextButtonDisabled: (this.currentPage === totalPages),
            startIndex: this.startIndex,
            endIndex: (this.startIndex + this.perPage)
        }
        return paginationObj;
    }

    /**
     *
     * @returns {boolean}
     */
    get currentViewHasFiles(){
        let returnValue = false;
        Object.keys(this.sortedFileList).forEach(category => {
            let currentCategory = this.sortedFileList[category];
            if(currentCategory.active){
                if(currentCategory.hasFolders && currentCategory.folders.length > 0){
                    let foldersHaveFiles = false;
                    currentCategory.folders.forEach(folder => {
                        if(folder.files.length > 0) {
                            foldersHaveFiles = true;
                        }
                    })
                    returnValue = foldersHaveFiles;
                } else {
                    if(currentCategory.hasFolders === false){
                        returnValue = currentCategory.files.length > 0;
                    }
                }
            }
        });
        return returnValue;
    }

    /**
     * Returns a file count string that shows the total number of files
     * @returns {string|string}
     */
    get fileCountString(){
        return this.fileCount === 1 ? '1 File' : (this.fileCount + ' Files');
    }

    viewFileEvent(event){
        let closeWindow = true;
        var viewFileId = event.target.dataset.id;
        var fileName = event.target.dataset.filename;
        var viewFileUrl = BASE_PATH.substring(0, BASE_PATH.length - 2)+"/apex/TVA_CFB__ViewFile?id="+viewFileId;
        var fileType = fileName.split('.').pop();
        var popout = window.open(viewFileUrl);

        if(fileType=='pdf' || fileType=='jpeg' || fileType=='png' || fileType=='jpg' || fileType=='gif'){
             closeWindow = false;
        }
        if(closeWindow){
            window.setTimeout(function(){
                popout.close();
            }, 8000);
        }
        
        
    }

}