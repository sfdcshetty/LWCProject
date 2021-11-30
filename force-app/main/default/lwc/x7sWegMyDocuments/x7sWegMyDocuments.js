import { api,LightningElement } from 'lwc';
import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";
import { NavigationMixin } from 'lightning/navigation';
//import getListOfDocuments from '@salesforce/apex/x7s_RecentDocumentsController.getListOfDocuments';
//import getListOfDocumentsForCurrentUser from '@salesforce/apex/x7s_RecentDocumentsController.getListOfDocumentsForCurrentUser';
//import temporaryGetListOfDocuments from '@salesforce/apex/x7s_RecentDocumentsController.temporaryGetListOfDocuments';
import getListOfDocumentsForCurrentUser from '@salesforce/apex/x7s_RecentDocumentsController.getListOfDocumentsForCurrentUser';
import Id from '@salesforce/user/Id';

export default class X7sWegMyDocuments extends NavigationMixin(LightningElement) {
    @api title = 'My Documents';
    @api paragraph = 'Access and upload important documents through our secure Document Vault.';
    @api shareLabel = 'Share a New Document';
    @api accessLabel = 'Access My Recent Plans, Reviews &amp; Meeting Notes';
    @api quarterlyLabel = 'See My Quarterly Report';
    @api vaultLabel = 'Visit Document Vault';
    @api vaultPageApi = 'Docuvault_Test__c';
    @api sharePageApi = 'DocumentSharing__c';

    documentList;
    userId = Id;
    chevron = WEG_LOGO_PATH + '/WEG_Assets/icons/chevronright.png';
    navigateLink = false;
    isModalOpen;
    modalDestination;
    modalDocument = false;
    shareIcon = WEG_LOGO_PATH + '/WEG_Assets/icons/share-doc-icon.png';
    accessIcon = WEG_LOGO_PATH + '/WEG_Assets/icons/access-meeting-notes-icon.png';
    quarterlyIcon = WEG_LOGO_PATH + '/WEG_Assets/icons/see-quarterly-report.png';
    vaultUrl = '';
    shareUrl = '';

    sitePrefix = "https://clportdev-wealthenhancementgroup.cs34.force.com/clientportal";
    meetingNotes;
    presentMeetingNotes = false;
    quarterlyReport;
    presentQuarterlyReport = false;

    myDocuments = [
        {title: "My Title", openModal: true, url: 'this/is/my/path', typeOfDoc: 'a'},
        {title: "My Other Title", openModal: false, url: 'Documents', typeOfDoc: 'b'},
        {title: "My Third Title", openModal: true, url: 'this/is/my/other/path', typeOfDoc: 'c'}
    ];

    connectedCallback(){
        this.generateUrls();
        this.getHHAccountDocuments();
    }

    getDocumentLinkUrl(varToSet, valToSplitUp){
        varToSet = valToSplitUp;
        varToSet = varToSet.split('"');
        varToSet = varToSet[1];
        varToSet = this.sitePrefix + varToSet;
        return varToSet;
    }

    getHHAccountDocuments(){
        //getListOfDocuments("0012f00000cY7nXAAS")
        //getListOfDocumentsForCurrentUser()
        //getListOfDocuments('0052f000001sSS6AAM')
        //temporaryGetListOfDocuments() 
        getListOfDocumentsForCurrentUser()
            .then((result) => {
                //this.documentList = JSON.stringify(result);
                this.documentList = result;
                for(let i=0; i<this.documentList.length; i++){
                    let folder = this.documentList[i].TVA_CFB__Folder__c;
                    console.log('MY DOCUMENT LIST', this.documentList[i]);
                    
                    switch(folder) {
                        case("Roundtable Documents"):
                          this.quarterlyReport = this.getDocumentLinkUrl(this.quarterlyReport , this.documentList[i].TVA_CFB__View_File__c);
                          if(this.quarterlyReport.length>0) { this.presentQuarterlyReport = true };
                        break;
                        case("Review Notes"):
                          if(!this.meetingNotes){ //load the first instance of notes since this is the newest
                            this.meetingNotes = this.getDocumentLinkUrl(this.meetingNotes , this.documentList[i].TVA_CFB__View_File__c);
                            if(this.meetingNotes.length>0) { this.presentMeetingNotes = true; }
                            //console.log('enter3', this.meetingNotes);

                          }
                        break;
                        default:
                        // code block
                        break;
                    }
                }
                console.log('doclistfinal', this.documentList);
            })
            .catch((error) => {
                this.error = error;
            });
    }

    openNotes(){
        //let finalDest = "https://docs.google.com/gview?url=" + this.meetingNotes + "&embedded=true";
        this.modalDestination = this.meetingNotes;
        //this.modalDestination = finalDest;
        //this.openModal();
        
    }

    openQuarterly(){
        this.modalDestination = this.quarterlyReport;
        //this.openModal();
    }

    openModal() {
        // to open modal set isModalOpen track value as true
        this.isModalOpen = true;

    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    generateUrls() {
        this.generateVaultUrl();
        this.generateShareUrl();
    }

    generateVaultUrl(){
        this[NavigationMixin.GenerateUrl]({
          type: "comm__namedPage",
            attributes: {
              name: this.vaultPageApi,
          }
        }).then(url => {
            this.vaultUrl = url;
        });
    }

    generateShareUrl(){
        this[NavigationMixin.GenerateUrl]({
          type: "comm__namedPage",
            attributes: {
              name: this.sharePageApi,
          }
        }).then(url => {
            this.shareUrl = url;
        });
    }
}