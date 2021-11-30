/**
 * Created by 7Summits on 4/15/21.
 */

import {api, LightningElement, track, wire} from 'lwc';
import getCurrentUserInfo from '@salesforce/apex/X7S_MaintenanceRequestController.getRelatedContactsForCurrentUser';
import updateAddresses from '@salesforce/apex/X7S_MaintenanceRequestController.updateAddresses';
import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {inLexMode, fireEvent, registerListener, unregisterAllListeners} from 'c/x7sShrUtils';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';

export default class X7SWegProfileEditAddresses extends LightningElement {
    @api userId;
    @api username;
    @track options = [];
    userData;
    selectedUserId;
    selectedUser;

    @api isModalOpen = false;
    page_1 = true;
    page_2 = false;
    page_3 = false;

    isPersonalAddressPrimary = false;
    isWorkAddressPrimary = false;
    isOtherAddressPrimary = false;
    myPrimary;

    changeHomeForCoClient = false;
    changeOtherForCoClient = false;
    updateCustodianAccount = false;
    isContinueDisabled = true;

    primaryAddressWasChanged = false;
    priorPrimaryAddress = '';

    isSaving = false;

    changeAddressType = {'Home' : false, 'Work' : false, 'Other' : false};

    @wire(CurrentPageReference) pageRef;

    checkmarkImage = WEG_LOGO_PATH + '/WEG_Assets/images/checkmark.png';
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
    handleFieldUpdated(event){
        console.log(event.target.value);
        console.log(event.target.name);

        //Code Added By Janavi
        if(this.changeAddressType['Home'] === false){
            this.changeAddressType['Home'] = event.target.name.includes('Billing');
        }
        if(this.changeAddressType['Work'] === false){
            this.changeAddressType['Work'] = event.target.name.includes('Shipping');
        }
        if(this.changeAddressType['Other'] === false){
            this.changeAddressType['Other'] = event.target.name.includes('Other');
        }
        //End

        if(event.target.name.includes('.')){
            let index = event.target.name.indexOf('.');
            let fieldName = event.target.name.substring(index+1);
            let objectName = event.target.name.substring(0,index);
            this.selectedUser[objectName][fieldName] = event.target.value;
        } else {
            this.selectedUser[event.target.name] = event.target.value;
        }
    }

    handleCheckboxFieldUpdated(event){
        this[event.target.name] = event.target.checked;
    }

    saveAddresses(){
        this.isSaving = true;
        if(this.isPersonalAddressPrimary === true){
            this.myPrimary = "Home";
        }else if(this.isWorkAddressPrimary === true){
            this.myPrimary = "Work";
        }else if(this.isOtherAddressPrimary === true){
            this.myPrimary = "Other";
        }

        //Code Added by janavi

        // let billingStreet = this.template.querySelector("[data-id='BillingStreet']");
        // let billingCity = this.template.querySelector("[data-id='BillingCity']");
        // let billingState = this.template.querySelector("[data-id='BillingState']");
        // let billingPostalCode = this.template.querySelector("[data-id='BillingPostalCode']");

        // let shippingStreet = this.template.querySelector("[data-id='ShippingStreet']");
        // let shippingCity = this.template.querySelector("[data-id='ShippingCity']");
        // let shippingState = this.template.querySelector("[data-id='ShippingState']");
        // let shippingPostalCode = this.template.querySelector("[data-id='ShippingPostalCode']");

        // let otherStreet = this.template.querySelector("[data-id='OtherStreet']");
        // let otherCity = this.template.querySelector("[data-id='OtherCity']");
        // let otherState = this.template.querySelector("[data-id='OtherState']");
        // let otherPostalCode = this.template.querySelector("[data-id='OtherPostalCode']");
        
        // console.log('billingPostalCode', billingPostalCode.value);
        // console.log('this.selectedUser.Account.BillingPostalCode', this.selectedUser.Account.BillingPostalCode);
        
        // if((this.selectedUser.Account.BillingStreet != billingStreet.value) ||
        //     (this.selectedUser.Account.BillingCity != billingCity.value) || 
        //     (this.selectedUser.Account.BillingState != billingState.value) ||
        //     (this.selectedUser.Account.BillingPostalCode != billingPostalCode.value)){
        //     console.log('Inside Billing');
        //     this.changeAddressType['Home'] = true;
        // }

        // if((this.selectedUser.Account.ShippingStreet != shippingStreet.value) ||
        //     (this.selectedUser.Account.ShippingCity != shippingCity.value) || 
        //     (this.selectedUser.Account.ShippingState != shippingState.value) ||
        //     (this.selectedUser.Account.ShippingPostalCode != shippingPostalCode.value)){
        //     console.log('Inside Shipping');
        //     this.changeAddressType['Work'] = true;
        // }

        // if((this.selectedUser.OtherStreet != otherStreet.value) ||
        //     (this.selectedUser.OtherCity != otherCity.value) || 
        //     (this.selectedUser.OtherState != otherState.value) ||
        //     (this.selectedUser.OtherPostalCode != otherPostalCode.value)){
        //     console.log('Inside Other');
        //     this.changeAddressType['Other'] = true;
        // }

        fireEvent(this.pageRef, 'changeAddress',  {id: this.selectedUserId, value: this.changeAddressType});
        //End

        if(this.myPrimary !== this.priorPrimaryAddress){
            this.primaryAddressWasChanged = true;
        }

        updateAddresses({
            contactId: this.selectedUserId,
            homeStreet: this.selectedUser.Account.BillingStreet, homeCity: this.selectedUser.Account.BillingCity, homeState: this.selectedUser.Account.BillingState, homeZip: this.selectedUser.Account.BillingPostalCode, alsoChangeHomeAddressForCoClient: this.changeHomeForCoClient,
            workStreet:  this.selectedUser.Account.ShippingStreet, workCity: this.selectedUser.Account.ShippingCity, workState: this.selectedUser.Account.ShippingState, workZip: this.selectedUser.Account.ShippingPostalCode, alsoChangeWorkAddressForCoClient: false,
            otherStreet: this.selectedUser.OtherStreet, otherCity: this.selectedUser.OtherCity, otherState: this.selectedUser.OtherState, otherZip: this.selectedUser.OtherPostalCode, alsoChangeOtherAddressForCoClient: this.changeOtherForCoClient,
            updateCustodianAccountsWithPrimaryAddress: this.updateCustodianAccount, primaryAddress: this.myPrimary, isPrimaryAddressUpdated: this.primaryAddressWasChanged
        })
            .then((result) => {
                this.isSaving = false;
                if(result){
                    this.page_2 = false;
                    this.page_3 = true;
                }
            })
            .catch((error) => {
                this.error = error;
                this.isSaving = false;
                this.showErrorMessage();
            });

        this.isSaving = false;
        this.page_2 = false;
        this.page_3 = true;

    }

    openModal(){
        this.isModalOpen = true;
        this.page_1 = true;
    }
    closeModal(){
        this.isModalOpen = false;
        this.page_1 = true;
        this.page_2 = false;
        this.page_3 = false;
        this.selectedUser = undefined;
        this.selectedUserId = undefined;
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
    handleUserSelectChange(event){
        this.isContinueDisabled = false;
        this.selectedUserId = event.detail.value;
    }

    handleContinue(){
        this.page_1 = false;

        this.selectedUser = this.userData.find(x => (x.Id === this.selectedUserId));
        console.log(this.selectedUser);


        let name = this.selectedUser.FirstName + ' ' + this.selectedUser.LastName;

        const userSelectedEvent = new CustomEvent('userselected', {
            detail:{name: name}
        });
        this.dispatchEvent(userSelectedEvent);


        if(this.selectedUser.WEGP1_PrimaryAddress__c == 'Home' || this.selectedUser.WEGP1_PrimaryAddress__c == 'Personal') {
            this.isPersonalAddressPrimary = true;
            this.isWorkAddressPrimary = false;
            this.isOtherAddressPrimary = false;
        }
        if(this.selectedUser.WEGP1_PrimaryAddress__c == 'Work') {
            this.isPersonalAddressPrimary = false;
            this.isWorkAddressPrimary = true;
            this.isOtherAddressPrimary = false;
        }
        if(this.selectedUser.WEGP1_PrimaryAddress__c == 'Other') {
            this.isPersonalAddressPrimary = false;
            this.isWorkAddressPrimary = false;
            this.isOtherAddressPrimary = true;
        }
        this.priorPrimaryAddress = this.selectedUser.WEGP1_PrimaryAddress__c;

        this.page_2 = true;

        setTimeout(()=>{ this.updateCheckboxSelections(); }, 1000);

    }

    handleHomeSelectedAsPrimary(){
        this.isPersonalAddressPrimary = true;
        this.isWorkAddressPrimary = false;
        this.isOtherAddressPrimary = false;
        this.updateCheckboxSelections();
    }
    handleWorkSelectedAsPrimary(){
        this.isPersonalAddressPrimary = false;
        this.isWorkAddressPrimary = true;
        this.isOtherAddressPrimary = false;
        this.updateCheckboxSelections();
    }
    handleOtherSelectedAsPrimary(){
        this.isPersonalAddressPrimary = false;
        this.isWorkAddressPrimary = false;
        this.isOtherAddressPrimary = true;
        this.updateCheckboxSelections();
    }


    updateCheckboxSelections(){
        let homeCheckbox = this.template.querySelector("[data-id='home']");
        let workCheckbox = this.template.querySelector("[data-id='work']");
        let otherCheckbox = this.template.querySelector("[data-id='other']");

        homeCheckbox.checked = this.isPersonalAddressPrimary;
        workCheckbox.checked = this.isWorkAddressPrimary;
        otherCheckbox.checked = this.isOtherAddressPrimary;
    }


    handleSave(){
        // this.selectedUser.WEGP1_PrimaryAddress__c = this.isPersonalEmailPrimary ? 'Personal' : this.isWorkEmailPrimary ? 'Work' : this.isOtherEmailPrimary ? 'Other' : '';
        this.saveAddresses();
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