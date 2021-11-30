import { LightningElement, api, track } from 'lwc';
import Id from '@salesforce/user/Id'
import getRelatedContactsForCurrentUser from '@salesforce/apex/X7S_MaintenanceRequestController.getRelatedContactsForCurrentUser';

import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";

export default class ModalPopupLWC extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    userId = Id;
    mode;
    userData;
    userName = "";
    modeEmail=false;
    //modeEmailNew=false;
    modePhone=false;
    modeName=false;
    modeAddress=false;
    @track isModalOpen = false;
    @track currentUser;
    chevron = WEG_LOGO_PATH + '/WEG_Assets/icons/chevronright.png';

    
    openModal(event) {
        this.userName = "";
        this.mode = event.currentTarget.dataset.id;
        switch(this.mode) {
            case 'email':
                this.modePhone = false;
                this.modeName = false;
                this.modeAddress = false;
                this.modeEmail = true;
                //this.modeEmailNew = false;
              break;
              case 'emailnew':
                this.modePhone = false;
                this.modeName = false;
                this.modeAddress = false;
                this.modeEmail = false;
                //this.modeEmailNew = true;
              break;
            case 'address':
                this.modePhone = false;
                this.modeName = false;
                this.modeEmail = false;
                this.modeAddress = true;
                //this.modeEmailNew = false;
              break;
            case 'name':
                this.modePhone = false;
                this.modeEmail = false;
                this.modeAddress = false;
                this.modeName = true;
                //this.modeEmailNew = false;
              break;
            case 'phone':
                this.modeEmail = false;
                this.modeAddress = false;
                this.modeName = false;
                this.modePhone = true;
                //this.modeEmailNew = false;
              break;
            default:
              // code block
          }
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.userData = this.retrieveUserData();
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    retrieveUserData(){
        //////////////////// get the user information
        getRelatedContactsForCurrentUser()
            .then((result) => {
                this.currentUser = result;
                //this.userName = result[0].FirstName + ' ' + result[0].LastName;
                this.error = undefined;
                //////
                let optionsValues = [];
                for(let i=0; i<this.currentUser.length; i++){
                    optionsValues.push({
                        label: this.currentUser[i].FirstName + " " + this.currentUser[i].LastName,
                        value: this.currentUser[i].Id,
                    })
                    this.options = optionsValues;

                }
                //////
            })
            .catch((error) => {
                this.error = error;
                //console.log('usererror', error);
        });
        ////////////////////
        
        //////////////////// get the user information
        /*getCurrentUserInfo({ userId: this.userid })
            .then((result) => {
                this.userData = result;
                let optionsValues = [];
                for(let i=0; i<result.length; i++){
                    optionsValues.push({
                        label: result[i].FirstName + " " + result[i].LastName,
                        value: result[i].Id,
                    })
                    this.options = optionsValues;
                    console.log('options', this.options);

                }
            })
            .catch((error) => {
                this.error = error;
        });*/
        ////////////////////
    }

    @api handleUserSelected(event){
        this.userName = event.detail.name;
    }

    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }
}