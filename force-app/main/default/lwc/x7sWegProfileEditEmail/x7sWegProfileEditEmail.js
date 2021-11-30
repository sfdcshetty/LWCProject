/**
 * Created by 7Summits on 4/14/21.
 */

import {api, LightningElement,wire} from 'lwc';
import getCurrentUserInfo from '@salesforce/apex/X7S_MaintenanceRequestController.getRelatedContactsForCurrentUser';
import updateEmails from '@salesforce/apex/X7S_MaintenanceRequestController.updateEmails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class X7SWegProfileEditEmail extends LightningElement {

    @api userId;
    userData;
    selectedUserId;
    selectedUser;

    @api isModalOpen = false;
    onStep1 = false;
    onStep2 = false;
    onStep3 = false;

    isWorkEmailPrimary = false;
    isPersonalEmailPrimary = false;
    isOtherEmailPrimary = false;

    primaryEmailWasChanged = false;
    priorPrimaryEmail = '';

    isSaving = false;

    connectedCallback(){
        this.retrieveUserData();
    }

    retrieveUserData(){
        getCurrentUserInfo()
            .then((result) => {
                this.userData = result;
                let optionsValues = [];
                for(let i=0; i<result.length; i++) {
                    optionsValues.push({
                        label: result[i].FirstName + " " + result[i].LastName,
                        value: result[i].Id
                    })
                    this.options = optionsValues;
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    saveEmails(){
        this.isSaving = true;
        
        updateEmails({
            contactId: this.selectedUserId,
            personalEmail: this.selectedUser.WEGP1_PersonalEmail__c,
            workEmail: this.selectedUser.WEG_Business_Email__c,
            otherEmail: this.selectedUser.WEGP1_OtherEmail__c,
            primaryEmail: this.selectedUser.WEGP1_PrimaryEmail__c})
            .then((result) => {
                this.isSaving = false;
                if(result){
                    this.onStep2 = false;
                    this.onStep3 = true;
                }
            })
            .catch((error) => {
               this.error = error;
                this.isSaving = false;
                this.showErrorMessage();
            });
    }

    openModal(){
        this.isModalOpen = true;
        this.onStep1 = true;
    }
    closeModal(){
        this.isModalOpen = false;
        this.onStep1 = false;
        this.onStep2 = false;
        this.onStep3 = false;
        this.selectedUser = undefined;
        this.selectedUserId = undefined;
    }
    handleUserSelectChange(event){
        this.selectedUserId = event.detail.value;
    }

    handleFieldUpdated(event){
        this.selectedUser[event.target.name] = event.target.value;
    }

    handleUserSelectContinue(){
        this.onStep1 = false;

        this.selectedUser = this.userData.find(x => (x.Id === this.selectedUserId));
        console.log(this.selectedUser);

        if(this.selectedUser.WEGP1_PrimaryEmail__c == 'Personal') {
            this.isPersonalEmailPrimary = true;
            this.isWorkEmailPrimary = false;
            this.isOtherEmailPrimary = false;
            this.priorPrimaryEmail = this.selectedUser.WEGP1_PersonalEmail__c;
        }
        if(this.selectedUser.WEGP1_PrimaryEmail__c == 'Work') {
            this.isPersonalEmailPrimary = false;
            this.isWorkEmailPrimary = true;
            this.isOtherEmailPrimary = false;
            this.priorPrimaryEmail = this.selectedUser.WEG_Business_Email__c;
        }
        if(this.selectedUser.WEGP1_PrimaryEmail__c == 'Other') {
            this.isPersonalEmailPrimary = false;
            this.isWorkEmailPrimary = false;
            this.isOtherEmailPrimary = true;
            this.priorPrimaryEmail = this.selectedUser.WEGP1_OtherEmail__c;
        }

        this.onStep2 = true;
    }

    handleSaveEmailClick(){
        console.log('Inside Save');
        this.selectedUser.WEGP1_PrimaryEmail__c = this.isPersonalEmailPrimary ? 'Personal' : this.isWorkEmailPrimary ? 'Work' : this.isOtherEmailPrimary ? 'Other' : '';
        this.saveEmails();
    }

    showErrorMessage() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Something went wrong. Please contact your advisor team for support or try again later..',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }
}