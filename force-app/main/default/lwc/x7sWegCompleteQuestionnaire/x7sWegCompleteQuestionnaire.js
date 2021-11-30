import { api,LightningElement } from 'lwc';
import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";
import getLastUpdatedDate from "@salesforce/apex/x7s_FinancialProfileController.getFinancialProfilePersonalInfoForCurrentUser";


export default class X7sWegCompleteQuestionnaire extends LightningElement {
    @api title = 'Complete Financial Profile';
    @api lastUpdated = 'Last updated';
    @api buttonLabel = 'Launch Financial Profile';
    @api documentVaultPageApi = 'Docuvault_Test__c';
    
    isModalOpen = false;
    updatedDate = '';
    iconPath = WEG_LOGO_PATH + "/WEG_Assets/icons/complete-questionairre-icon.png";
    myData;
    
    connectedCallback(){
        this.getMyUpdatedData();
    }

    getMyUpdatedData(){
        this.myData = getLastUpdatedDate()
            .then((result) => {
                this.userData = result;
                this.updatedDate = this.userData.LastModifiedDate;
            })
            .catch((error) => {
                this.error = error;
            });
    }

    openModal() {
        // to open modal set isModalOpen track value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
}