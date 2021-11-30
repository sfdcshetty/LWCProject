/**
 * Created by 7Summits on 4/14/21.
 */

 import {api, LightningElement} from 'lwc';
 import getCurrentUserInfo from '@salesforce/apex/X7S_MaintenanceRequestController.getRelatedContactsForCurrentUser';
 import updateEmails from '@salesforce/apex/X7S_MaintenanceRequestController.updateEmails';
 import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
 export default class X7SWegProfileEditEmail extends LightningElement {
 
     @api userid;
     @api userinfo;
     userData;
     selectedUserId;
     selectedUser;

     currentPage;
     isContinueDisabled = true;
     @api myoptions;
 
     @api isModalOpen = false;
     onStep1 = true;
     onStep2 = false;
     onStep3 = false;
     valuesPassedCheck = false;
 
     isWorkEmailPrimary = false;
     isPersonalEmailPrimary = false;
     isOtherEmailPrimary = false;
 
     primaryEmailWasChanged = false;
     priorPrimaryEmail = '';
 
     isSaving = false;

     checkmarkImage = WEG_LOGO_PATH + '/WEG_Assets/images/checkmark.png';
 
     connectedCallback(){
        this.retrieveUserData();
         //this.retrieveUserEmailData();
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
                console.log('ops', this.options);
            })
            .catch((error) => {
                this.error = error;
            });
    }
 
     retrieveUserEmailData(){
         getCurrentUserInfo()
             .then((result) => {
                 this.userData = result;
                 let optionsValues = [];
                     let i = 0;
                     optionsValues.push({
                         label: result[i].FirstName + " " + result[i].LastName,
                         value: result[i].Id
                     })
                     this.options = optionsValues[0];
                     console.log('ops', this.options);
             })
             .catch((error) => {
                 this.error = error;
             });
     }

    selectPrimary(event){
        /*let myOtherCheckbox = this.template.querySelector("[data-id='Other']");
        let myHomeCheckbox = this.template.querySelector("[data-id='Home']");
        let myWorkCheckbox = this.template.querySelector("[data-id='Work']");*/
        
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
 
     changeSelectedUser(event){
         this.selectedUserId = event.detail.value;
         this.selectUser(this.selectedUserId);
         this.selectedUser = this.userData[this.userIndex];

         this.isContinueDisabled = false;
         this.onStep1 = true;
         this.onStep2 = false; 
     }

     selectUser(selectedUserId){
        
        this.isContinueDisabled = false;
        for(let i=0;i<this.userData.length;i++){
            if(this.userData[i].Id === selectedUserId){ this.userIndex = i;}
        }
        this.setPrimary(this.userIndex);
    }
 

     setPrimary(index){
        let primary = this.userData[index].WEGP1_PrimaryEmail__c;

        //let myPersonal = this.template.querySelector("[data-id]='Personal'");
        /*let myPersonal = this.template.querySelector("[data-id='Personal']");
        let myWork = this.template.querySelector("[data-id='Work']");
        let myOther = this.template.querySelector("[data-id='Other']");*/

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

     checkEmailEntries(){
        let primary = this.selectedUser.WEGP1_PrimaryEmail__c;
        let emailFieldToCheck = '[data-id="email_' + primary + '"]';
        let myEmailToCheck = this.template.querySelector(emailFieldToCheck);
        if(myEmailToCheck.value.length < 1){ //test the length
            this.error = "You must populate the primary email address";
            this.showErrorMessage('Email Change Error', "You must populate the primary email address");
        } else {
            this.valuesPassedCheck = true;
        }
     }

     handleFieldUpdated(event){
         this.selectedUser[event.target.name] = event.target.value;
     }

     handleSaveEmailClick(){
         this.selectedUser.WEGP1_PrimaryEmail__c = this.isPersonalEmailPrimary ? 'Personal' : this.isWorkEmailPrimary ? 'Work' : this.isOtherEmailPrimary ? 'Other' : '';
         this.checkEmailEntries();
         if(this.valuesPassedCheck) this.saveEmails();
     }
 
     showErrorMessage(title="Error", message="Something went wrong. Please contact your advisor team for support or try again later") {
         const evt = new ShowToastEvent({
             title: title,
             message: message,
             variant: 'error',
         });
         this.dispatchEvent(evt);
     }

     get nameSelectOptions() {
        return this.userData ? this.userData.map(i=>({ label: i.FirstName+' '+i.LastName, value: i.AccountId })) : [];
    }
    
     closeModal(){
        //this.isModalOpen = false;
        // this.onStep1 = false;
        // this.onStep2 = false;
        // this.onStep3 = false;
        // this.selectedUser = undefined;
        // this.selectedUserId = undefined;
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
 }