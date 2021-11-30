import { LightningElement,api, track, wire} from 'lwc';
//import Id from '@salesforce/user/Id'
import getCurrentUserInfo from '@salesforce/apex/X7S_MaintenanceRequestController.getRelatedContactsForCurrentUser';
import savePhoneInfo from '@salesforce/apex/X7S_MaintenanceRequestController.updatePhones';
import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";
import {fireEvent} from 'c/x7sShrUtils';
import {CurrentPageReference} from 'lightning/navigation';

export default class X7sWegProfileEditPhone extends LightningElement {
    @api userid;
    @api username;
    @track selectedUser;
    @track options = [];
    page_1 = true;
    page_2 = false;
    page_3 = false;
    currentPage;
    isContinueDisabled = true;
    isSaving = false;
    
    userData;
    userIndex;
    testUser = [];
    options = [];
    cellOptions = [];
    workOptions = [];
    homeOptions = [];

    primaryPhone;
    primaryOrig;
    hasPrimaryChanged = false;
    userToEdit;

    cellPhone;
    isCellPrimary=false;
    workPhone;
    isWorkPrimary=false;
    homePhone;
    isHomePrimary=false;

    changePhoneType = new Set();
    //changePhoneType = [];
    @wire(CurrentPageReference) pageRef;
    
    checkmarkImage = WEG_LOGO_PATH + '/WEG_Assets/images/checkmark.png';
    connectedCallback(){
        this.retrieveUserData();
    }

    renderedCallback(){
        if(this.template.querySelector('lightning-input[data-id="cellField"]')){
            this.template.querySelector('lightning-input[data-id="cellField"]').value = this.getPhoneNumberFormatting(this.template.querySelector('lightning-input[data-id="cellField"]').value);
        }
        if(this.template.querySelector('lightning-input[data-id="homeField"]')){
            this.template.querySelector('lightning-input[data-id="homeField"]').value = this.getPhoneNumberFormatting(this.template.querySelector('lightning-input[data-id="homeField"]').value);
        }
        if(this.template.querySelector('lightning-input[data-id="workField"]')){
            this.template.querySelector('lightning-input[data-id="workField"]').value = this.getPhoneNumberFormatting(this.template.querySelector('lightning-input[data-id="workField"]').value);
        }
    }

    retrieveUserData(){
        //////////////////// get the user information
        getCurrentUserInfo({ userId: this.userid })
            .then((result) => {
                this.userData = result;
                let optionsValues = [];
                for(let i=0; i<result.length; i++){
                    this.userName = result[i].FirstName + " " + result[i].LastName;
                    optionsValues.push({
                        label: result[i].FirstName + " " + result[i].LastName,
                        value: result[i].Id,
                    })
                    this.options = optionsValues;
                }
                console.log('userdata', this.userData);
            })
            .catch((error) => {
                this.error = error;
        });
        ////////////////////
    }
    selectUser(event){
        this.selectedUser = event.target.value;
        this.isContinueDisabled = false;
        
        for(let i=0;i<this.userData.length;i++){
            if(this.userData[i].Id === this.selectedUser){ this.userIndex = i;}
        }
        this.primaryOrig = this.userData[this.userIndex].WEGP1_PrimaryPhone__c;
        this.setPrimary(this.userIndex);
    }

    setPrimary(index){
        //console.log('setP', this.userData[index].WEGP1_PrimaryPhone__c);
        let primaryValue = this.userData[index].WEGP1_PrimaryPhone__c;
        switch(primaryValue){
            case "Home":
                this.isHomePrimary = true;
                this.isCellPrimary = false;
                this.isWorkPrimary = false;
                break;
            case "Cell":
                this.isCellPrimary = true;
                this.isHomePrimary = false;
                this.isWorkPrimary = false;
                break;
            case "Work":
                this.isWorkPrimary = true;
                this.isCellPrimary = false;
                this.isHomePrimary = false;
                break;
            default:
                
        }
    }

    findPhones(){
        let thisUser = this.userData[this.userIndex];
        let cellOptionValues = [];
        let workOptionValues = [];
        let homeOptionValues = [];
        if(thisUser.MobilePhone){
            this.cellPhone = thisUser.MobilePhone;
            cellOptionValues.push({label:"Cell", value:"Cell"}) 
        }
        if(thisUser.AssistantPhone){
            this.workPhone = thisUser.AssistantPhone;
            workOptionValues.push({label:"Work", value:"Work"}) 
        }
        if(thisUser.HomePhone){ 
            this.homePhone = thisUser.HomePhone; 
            homeOptionValues.push({label:"Home", value:"Home"})
        }
        this.cellOptions = cellOptionValues;
        this.workOptions = workOptionValues;
        this.homeOptions = homeOptionValues;

        this.primaryPhone = thisUser.WEGP1_PrimaryPhone__c;
        console.log('primePhone='+this.primaryPhone);
        switch(this.primaryPhone){
            case "Home":
                this.ishomeprimary = 'checked';
                this.iscellprimary = '';
                this.isworkprimary = '';
                break;
            case "Cell":
                this.iscellprimary = 'checked';
                this.ishomeprimary = '';
                this.isworkprimary = '';
                break;
            case "Work":
                this.isworkprimary = 'checked';
                this.iscellprimary = '';
                this.ishomeprimary = '';
                break;
            default:
                // code block
        }

        //console.log('primaryoptions', this.primaryPhone);
    }

    selectPrimary(event){
        let myCellCheckbox = this.template.querySelector("[data-id='Cell']");
        let myHomeCheckbox = this.template.querySelector("[data-id='Home']");
        let myWorkCheckbox = this.template.querySelector("[data-id='Work']");
        this.primaryPhone = event.target.value;
        switch(event.target.value){
            case "Home":
                if(event.target.checked===true) this.userData.WEGP1_PrimaryPhone__c = "Home";
                myWorkCheckbox.checked = false;
                myCellCheckbox.checked = false;
                break;
            case "Cell":
                if(event.target.checked===true) this.userData.WEGP1_PrimaryPhone__c = "Cell";
                myWorkCheckbox.checked = false;
                myHomeCheckbox.checked = false;
                break;
            case "Work":
                if(event.target.checked===true) this.userData.WEGP1_PrimaryPhone__c = "Work";
                myCellCheckbox.checked = false;
                myHomeCheckbox.checked = false;
                break;
            default:
        }
    }

    handleContinue(){
        let name = this.userData[this.userIndex].FirstName + ' ' + this.userData[this.userIndex].LastName;
        const userSelectedEvent = new CustomEvent('userselected', {
            detail:{name: name}
        });
        this.dispatchEvent(userSelectedEvent);

        this.findPhones();
        if(this.page_1===true){
            this.page_1 = false;
            this.page_2 = true;
        }else if(this.page_2===true){
            this.page_2 = false;
            this.page_3 = true; 
        }
    }

    handleSave(){
        this.isSaving = true;
        let myCell = this.template.querySelector("[data-id='cellField']");
        let myHome = this.template.querySelector("[data-id='homeField']");
        let myWork = this.template.querySelector("[data-id='workField']");

        if(this.cellPhone != myCell.value){
            this.changePhoneType.add('Cell');
        }
        if(this.workPhone != myWork.value){
            this.changePhoneType.add('Work');
        }
        if(this.homePhone != myHome.value){
            this.changePhoneType.add('Home');
        }
        fireEvent(this.pageRef, 'changePhone',  {id: this.selectedUser, value: this.changePhoneType});
        
        if(this.primaryOrig !== this.primaryPhone){ this.hasPrimaryChanged = true; }
        console.log("id:" + this.userData[this.userIndex].Id + " mobile:" + myCell.value + " work:" + myWork.value + " home" + myHome.value + " primary: " + this.primaryOrig + " | newPrimary: " + this.primaryPhone + " | hasPrimaryChanged: " + this.hasPrimaryChanged);        
        savePhoneInfo({ 
            contactId: this.userData[this.userIndex].Id, 
            mobilePhone: myCell.value, 
            workPhone: myWork.value, 
            homePhone: myHome.value, 
            otherPhone: myCell.value, 
            primaryPhone: this.primaryPhone 
        });
        this.isSaving = false;
        this.page_1 = false;
        this.page_2 = false;
        this.page_3 = true;
    }

    handleCancel(){
        this.page_1 = true;
        this.page_2 = false;
        this.page_3 = false;
        this.currentPage = 'page_1';
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handlePhoneNumberChange(event){
        var formattedNumber = this.getPhoneNumberFormatting(event.target.value);
        event.target.value = formattedNumber;
        let copyData = JSON.parse(JSON.stringify([...this.contactData]));
        var fieldName = event.target.dataset.id;
        copyData[0][fieldName] = event.target.value.replace(/\D/g,'');
        this.contactData = [...copyData];
    }

    getPhoneNumberFormatting(phoneNumberValue){
        const x = phoneNumberValue.replace(/\D+/g, '')
            .match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
        return !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);            
    }

}