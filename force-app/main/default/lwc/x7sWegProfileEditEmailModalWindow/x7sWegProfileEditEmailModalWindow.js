import { LightningElement,wire } from 'lwc';
//import getRelatedContactsForCurrentUser from '@salesforce/apex/X7S_MaintenanceRequestController.getRelatedContactsForCurrentUser';
import getCurrentUserInfo from '@salesforce/apex/X7S_MaintenanceRequestController.getRelatedContactsForCurrentUser';
import updateEmails from '@salesforce/apex/X7S_MaintenanceRequestController.updateEmails';
import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {fireEvent} from 'c/x7sShrUtils';
import {CurrentPageReference} from 'lightning/navigation';

export default class X7sWegProfileEditEmailModalWindow extends LightningElement {
    userData = [];
    onStep1 = true;
    onStep2 = false;
    onStep3 = false;
    valuesPassedCheck = false;
 
    isWorkEmailPrimary = false;
    isPersonalEmailPrimary = false;
    isOtherEmailPrimary = false;
    isContinueDisabled = true;

    selectedUserId;
    selectedUser;

    primaryEmailSettingToTrack;
    originalEmail;
    myOriginalEmail;
    primaryEmailWasChanged = false;
    priorPrimaryEmail = '';
 
    isSaving = false;
    checkmarkImage = WEG_LOGO_PATH + '/WEG_Assets/images/checkmark.png';
    cautionImage = WEG_LOGO_PATH + '/WEG_Assets/images/caution.png';

    changeEmailType = new Set();
    @wire(CurrentPageReference) pageRef;

    connectedCallback(){
        // pull data from the org on demand. (Should this be @wire instead? -- mblase)
        this.retrieveUserData();
    }

    retrieveUserData(){
        // get the user information
        getCurrentUserInfo()
            .then((result) => {
                this.userData = result;
            })
            .catch((error) => {
                this.error = error;
                //showToast('Retrieve error','An error occurred while retrieving your names.','error','pester');
        });
    }

    changeSelectedUser(event){
        this.selectedUserId = event.detail.value;
        this.selectUser(this.selectedUserId);
        this.selectedUser = this.userData[this.userIndex];
        switch(this.selectedUser.WEGP1_PrimaryEmail__c){
            case "Other":
                this.myOriginalEmail = this.selectedUser.WEGP1_OtherEmail__c;
            break;
            case "Personal":
                this.myOriginalEmail = this.selectedUser.WEGP1_PersonalEmail__c;
            break;
            case "Work":
                this.myOriginalEmail = this.selectedUser.WEG_Business_Email__c;
            break;
            default:
            break;
        }
        this.isContinueDisabled = false;
        this.onStep1 = true;
        this.onStep2 = false; 
    }

    selectUser(selectedUserId){
        //console.log('userData', this.userData);
        this.isContinueDisabled = false;
        for(let i=0;i<this.userData.length;i++){
            //console.log(selectedUserId, this.userData[i].Id);
            if(this.userData[i].Id === selectedUserId){ 
                this.userIndex = i;
                this.primaryEmailSettingToTrack = this.userData[i].WEGP1_PrimaryEmail__c;
            }
        }
        this.setPrimary(this.userIndex);
    }

    setPrimary(index){
        let primary = this.userData[index].WEGP1_PrimaryEmail__c;
        switch(primary){
            case "Personal":
                this.isPersonalEmailPrimary = true;
                this.isWorkEmailPrimary = false;
                this.isOtherEmailPrimary = false;
                break;
            case "Work":
                this.isPersonalEmailPrimary = false;
                this.isWorkEmailPrimary = true;
                this.isOtherEmailPrimary = false;
                break;
            case "Other":
                this.isPersonalEmailPrimary = false;
                this.isWorkEmailPrimary = false;
                this.isOtherEmailPrimary = true;
                break;
            default:  
        }
    }

    handleUserSelectContinue(){
        this.onStep1 = false;
        let name = this.selectedUser.FirstName + ' ' + this.selectedUser.LastName;
        const userSelectedEvent = new CustomEvent('userselected', {
            detail:{name: name}
        });
        this.dispatchEvent(userSelectedEvent);

        if(this.selectedUser.WEGP1_PrimaryEmail__c === 'Personal') {
            this.isPersonalEmailPrimary = true;
            this.isWorkEmailPrimary = false;
            this.isOtherEmailPrimary = false;
            this.priorPrimaryEmail = this.selectedUser.WEGP1_PersonalEmail__c;
        }
        if(this.selectedUser.WEGP1_PrimaryEmail__c === 'Work') {
            this.isPersonalEmailPrimary = false;
            this.isWorkEmailPrimary = true;
            this.isOtherEmailPrimary = false;
            this.priorPrimaryEmail = this.selectedUser.WEG_Business_Email__c;
        }
        if(this.selectedUser.WEGP1_PrimaryEmail__c === 'Other') {
            this.isPersonalEmailPrimary = false;
            this.isWorkEmailPrimary = false;
            this.isOtherEmailPrimary = true;
            this.priorPrimaryEmail = this.selectedUser.WEGP1_OtherEmail__c;
        }

        this.onStep2 = true;
    }

    selectPrimary(event){
        
        switch(event.target.value){
            case "Personal":
                if(event.target.checked===true) {
                this.userData.WEGP1_PrimaryEmail__c = "Personal";
                this.isPersonalEmailPrimary = true;
                this.isWorkEmailPrimary = false;
                this.isOtherEmailPrimary = false;
                }else{
                    this.isPersonalEmailPrimary = false;  
                }
                break;
            case "Other":
                if(event.target.checked===true){
                this.userData.WEGP1_PrimaryEmail__c = "Other";
                this.isOtherEmailPrimary = true;
                this.isWorkEmailPrimary = false;
                this.isPersonalEmailPrimary = false;
                }else{
                    this.isOtherEmailPrimary = false;  
                }
                break;
            case "Work":
                if(event.target.checked===true){
                this.userData.WEGP1_PrimaryEmail__c = "Work";
                this.isWorkEmailPrimary = true;
                this.isOtherEmailPrimary = false;
                this.isPersonalEmailPrimary = false;
                }else{
                    this.isWorkEmailPrimary = false;  
                }
                break;
            default:
            }
    }

    handleSaveEmailClick(){
        this.selectedUser.WEGP1_PrimaryEmail__c = this.isPersonalEmailPrimary ? 'Personal' : this.isWorkEmailPrimary ? 'Work' : this.isOtherEmailPrimary ? 'Other' : '';
        this.checkEmailEntries();
        if(this.valuesPassedCheck) {
            this.saveEmails();
        }
    }

    checkEmailEntries(){
        let primary = this.selectedUser.WEGP1_PrimaryEmail__c;
        let emailFieldToCheck = '[data-id="email_' + primary + '"]';
        let myEmailToCheck = this.template.querySelector(emailFieldToCheck);
        //console.log('checkEmailEntries', primary);
        if(myEmailToCheck.value.length < 1){ //test the length
            this.error = "You must populate the primary email address";
            this.showErrorMessage('Email Change Error', "You must populate the primary email address");
        } else {
            this.valuesPassedCheck = true;
        }
     }

     saveEmails(){
        this.isSaving = true;
        let myPersonal = this.template.querySelector("[data-id='email_Personal']");
        let myWork = this.template.querySelector("[data-id='email_Work']");
        let myOther = this.template.querySelector("[data-id='email_Other']");

        //Code added by Janavi

        if(this.selectedUser.WEGP1_PersonalEmail__c !== myPersonal.value){
            //console.log('Inside Personal Email Onchange');
            this.changeEmailType.add('Personal');
        }
        if(this.selectedUser.WEG_Business_Email__c !== myWork.value){
            //console.log('Inside Work Email Onchange');
            this.changeEmailType.add('Work');
        }
        if(this.selectedUser.WEGP1_OtherEmail__c !== myOther.value){
            //console.log('Inside Other Onchange');
            this.changeEmailType.add('Other');
        }

        fireEvent(this.pageRef, 'changeEmail',  {id: this.selectedUser, value: this.changeEmailType});

        //End
        //console.log("contactId: " + this.selectedUserId + " | personalEmail: " + this.selectedUser.WEGP1_PersonalEmail__c + " | workEmail: " + this.selectedUser.WEG_Business_Email__c + " | otherEmail: " + this.selectedUser.WEGP1_OtherEmail__c + " | primaryEmail: " + this.selectedUser.WEGP1_PrimaryEmail__c);
        //console.log("contactId: " + this.selectedUserId + " | personalEmail: " + myPersonal.value + " | workEmailllll: " + myWork.value + " | otherEmail: " + myOther.value + " | primaryEmail: " + this.selectedUser.WEGP1_PrimaryEmail__c);

        this.selectedUser.WEGP1_PersonalEmail__c = myPersonal.value;
        this.selectedUser.WEG_Business_Email__c = myWork.value;
        this.selectedUser.WEGP1_OtherEmail__c = myOther.value;
        this.originalEmail = this.selectedUser.WEGP1_PrimaryEmail__c;
        switch(this.originalEmail){
            case "Personal":
                this.originalEmail = myPersonal.value;
            break;
            case "Work":
                this.originalEmail = myWork.value;
            break;
            case "Other":
                this.originalEmail = myOther.value;
            break;
            default:
                this.originalEmail = myWork.value;
            break;
        }

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
                this.onStep2 = false;
                this.onStep3 = true;
            })
            .catch((error) => {
               this.error = error;
                this.isSaving = false;
                this.showErrorMessage();
            });
            if(this.primaryEmailSettingToTrack !== this.selectedUser.WEGP1_PrimaryEmail__c){
                this.primaryEmailWasChanged = true;
            }
    }

    showErrorMessage(title="Error", message="Something went wrong. Please contact your advisor team for support or try again later") {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }

    closeModal(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    get nameSelectOptions() {
        return this.userData ? this.userData.map(i=>({ label: `${i.FirstName} ${i.LastName}`, value: i.Id })) : [];
    }


}