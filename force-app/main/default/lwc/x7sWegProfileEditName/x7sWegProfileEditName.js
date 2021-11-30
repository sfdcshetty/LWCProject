import { LightningElement,api,wire } from 'lwc';
//import Id from '@salesforce/user/Id'
import getRelatedContactsForCurrentUser from '@salesforce/apex/X7S_MaintenanceRequestController.getRelatedContactsForCurrentUser';
import updateNames from '@salesforce/apex/X7S_MaintenanceRequestController.updateNames';
import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";
import { showToast } from 'c/x7sShrUtils';
import {fireEvent} from 'c/x7sShrUtils';
import {CurrentPageReference} from 'lightning/navigation';

export default class X7sWegProfileEditName extends LightningElement {
    @api userid;
    @api username;

    nameSelectedId = '';
    nameSelectedData = {};
    nameFields = ['salutation','firstName','middleName','lastName','suffix','informalName'];
    requiredFields = ['firstName','lastName'];
    salutationOptions = [
        {'label': 'Mr.', 'value': 'Mr.'},
        {'label': 'Ms.', 'value': 'Ms.'},
        {'label': 'Mrs.', 'value': 'Mrs.'},
        {'label': 'Dr.', 'value': 'Dr.'},
        {'label': 'Prof.', 'value': 'Prof.'},
    ];
    showForm = false;
    showPage1 = true;
    showPage2 = false;
    showPage3 = false;
    userData = [];
    checkmarkImage = WEG_LOGO_PATH + '/WEG_Assets/images/checkmark.png';

    @wire(CurrentPageReference) pageRef;
    /**
     * Should the name selection form's submit button be disabled?
     */
    get disableButtonNameSelect() { return !this.nameSelectedId; }
    /**
     * Should the save name form's submit button be disabled?
     */
    get disableButtonSaveName() { return !this.isValidNameData };

    /**
     * check if this.nameSelectedData is valid for submitting to the backend.
     */
    get isValidNameData() {
        let isValid = true;
        this.requiredFields.forEach(i=>{
            isValid = isValid && this.nameSelectedData[i] && this.nameSelectedData[i].length;
        });
        return isValid;
    }

    /**
     * Return the single object containing data corresponding to this.nameSelectedId.
     */
    get nameData() {
        return  (this.nameSelectedId && this.userData.length) ? this.userData.find(i=>{return i.Id===this.nameSelectedId}) : {};
    }

    /**
     * Convert the full array of userData objects into an array of options suitable for a lightning-radio-group.
     */
    get nameSelectOptions() {
        return this.userData ? this.userData.map(i=>({ label: i.FirstName+' '+i.LastName, value: i.Id })) : [];
    }

    get requiredFieldsLabel() {
        if (this.requiredFields.length) {
            let strRequired = this.titleCase(this.requiredFields.join(', ').replace(/([a-z])([A-Z])/g,'$1 $2'));
            return "The following fields are required: "+strRequired;
        }
        return '';
    }

    /**
     * utility method to capitalize words in a string. https://stackoverflow.com/a/5574446
     */
    titleCase(str) {
        return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
    };

    // ================================================================================================================

    connectedCallback(){
        // pull data from the org on demand. (Should this be @wire instead? -- mblase)
        this.retrieveUserData();
    }

    /**
     * Close the parent modal.
     */
    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'));
        this.showPage1 = true;
        this.showPage2 = false;
        this.showPage3 = false;
    }

    /**
     * Update this.nameSelectedId when the radio button is changed.
     * @param event 
     */
    handleChangeUserName(event) {
        this.nameSelectedId = event.detail.value;
    }

    /**
     * Update this.nameSelectedData with the changed name fields.
     */
    handleChangeNameFields(event) {
        // event.detail contains: salutation, firstName, middleName, lastName, informalName,suffix,vailidity
        this.nameSelectedData = {...event.detail, contactId: this.nameSelectedId};
        console.log('Inside Name Edit::::', this.nameSelectedId);
    }
    /**
     * When the name selection is submitted, switch to the edit form.
     */
    handleClickNameSelect() {
        if (this.nameSelectedId) {
            let name = this.nameData.FirstName + ' ' + this.nameData.LastName;
            const userSelectedEvent = new CustomEvent('userselected', {
                detail:{name: name}
            });
            this.dispatchEvent(userSelectedEvent);

            this.showPage1 = false;
            this.showPage2 = true;
            this.showPage3 = false;
            let myRows = this.template.querySelector('div');
            console.log('myRows', myRows);
        }
    }

    handleClickSaveName() {
        if (!this.isValidNameData) {
            showToast('Save error','You must complete all required fields.','error','pester');
        } else {
            console.log('Inside Name Edit::::', this.nameSelectedId);
            fireEvent(this.pageRef, 'changeName',  {id: this.nameSelectedId, value: 'Name'});
            //updateNames params: String contactId, String salutation, String firstName, String middleName, String lastName, String suffix, String informalName
            updateNames(this.nameSelectedData)
            .then(result=>{
                if (!result) { // returns false if unsuccessful
                    //showToast('Save successful','Your name was successfully updated.','success','pester');
                    //this.closeModal();
                //} else {
                    showToast('Save error','An error occurred while saving. Your name was not updated.','error','pester');
                }
            })
            .catch(error=>{
                console.error(error);
                showToast('Save error','An error occurred while saving. Your name was not updated.','error','pester');
            });

            this.showPage2 = false;
            this.showPage3 = true;
        }
    }

    /**
     * Pull user information from the org on demand, and populate this.userData with the results.
     */
    retrieveUserData(){
        // get the user information
        getRelatedContactsForCurrentUser()
            .then((result) => {
                this.userData = result;
            })
            .catch((error) => {
                this.error = error;
                showToast('Retrieve error','An error occurred while retrieving your names.','error','pester');
        });
    }

}