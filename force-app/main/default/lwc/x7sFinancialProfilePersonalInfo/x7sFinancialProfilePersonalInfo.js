import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import UNIFI_OBJECT from '@salesforce/schema/Financial_Profile__c';
import HEADER from '@salesforce/label/c.x7sFinancialProfile_Personalinfo_Header';
//import INTRO from '@salesforce/label/c.x7sFinancialProfile_Personalinfo_Paragraph';
import { track, api, wire, LightningElement } from 'lwc';
import updateEmails from '@salesforce/apex/X7S_MaintenanceRequestController.updateEmails';

export default class X7sFinancialProfilePersonalInfo extends LightningElement {
    @api debug = false;
    @api coClientId = false;

    @api header = HEADER;

    @api firstName = '';
    @api middleInitial = '';
    lenMiddleInitial = 40;
    @api lastName = '';
    @api suffix = '';
    lenSuffix = 5;

    @api dateOfBirth = '';
    @api streetAddress = '';
    @api city = '';
    @api state = '';
    @api zipCode = '';

    @api emailWork;
    @api emailPersonal;
    @api emailOther;
    @api phoneMobile;
    @api phoneWork;
    @api phoneHome;

    @track optionsState = [];

    // get object info for unifi questionnaire
    @wire(getObjectInfo, { objectApiName: UNIFI_OBJECT })
    objectInfo;

    // get picklist values using objectInfo
    @wire(getPicklistValuesByRecordType, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        objectApiName: UNIFI_OBJECT,
    })
    getPicklistValues({ data, error }) {
        if (error) console.error(error);
        if (data) {
            //this.optionsEmailType = data.picklistFieldValues.Email_Type__c.values;
            //this.optionsPhoneType = data.picklistFieldValues.Phone_Type__c.values;
            this.optionsState = data.picklistFieldValues.State__c.values;
        }
    }

    /**
     * send the current data up to the parent component for saving to the org
     */
    dispatchData() {
        const obj = {
            First_Name__c: this.firstName,
            Middle_Initial__c: this.middleInitial,
            Last_Name__c: this.lastName,
            Suffix__c: this.suffix,
            Date_of_Birth__c: this.dateOfBirth,

            Street__c: this.streetAddress,
            City__c: this.city,
            State__c: this.state,
            PostalCode__c: this.zipCode,

            Business_Email__c: this.emailWork,
            Personal_Email__c: this.emailPersonal,
            Other_Email__c: this.emailOther,

            Phone__c: this.phoneMobile,
            Work_Phone__c: this.phoneWork,
            Home_Phone__c: this.phoneHome,
        };
        if (this.coClientId){
            this.dispatchEvent(
                new CustomEvent('savetempdata', { detail: { coClient: obj } })
            );
        } else {
            this.dispatchEvent(
                new CustomEvent('savetempdata', { detail: { personalInfo: obj } })
            );
        }
    }

    // change event handler for the various form fields
    handleChangeFirstName(event) {
        this.firstName = event.detail.value;
        this.dispatchData();
    }
    handleChangeMiddleInitial(event) {
        this.middleInitial = event.detail.value;
        this.dispatchData();
    }
    handleChangeLastName(event) {
        this.lastName = event.detail.value;
        this.dispatchData();
    }
    handleChangeSuffix(event) {
        this.suffix = event.detail.value;
        this.dispatchData();
    }
    handleChangeDateOfBirth(event) {
        this.dateOfBirth = event.detail.value;
        this.dispatchData();
    }

    handleChangeStreetAddress(event) {
        this.streetAddress = event.detail.value; 
        this.dispatchData();
    }
    handleChangeCity(event) {
        this.city = event.detail.value; 
        this.dispatchData();
    }
    handleChangeState(event) {
        this.state = event.detail.value; 
        this.dispatchData();
    }
    handleChangeZipCode(event) {
        this.zipCode = event.detail.value; 
        this.dispatchData();
    }

    handleChangeEmailWork(event) {
        this.emailWork = event.detail.value;
        this.dispatchData();
    }
    handleChangeEmailPersonal(event) {
        this.emailPersonal = event.detail.value;
        this.dispatchData();
    }
    handleChangeEmailOther(event) {
        this.emailOther = event.detail.value;
        this.dispatchData();
    }

    handleChangePhoneWork(event) {
        this.phoneWork = event.detail.value;
        this.dispatchData();
    }
    handleChangePhoneHome(event) {
        this.phoneHome = event.detail.value;
        this.dispatchData();
    }
    handleChangePhoneMobile(event) {
        this.phoneMobile = event.detail.value;
        this.dispatchData();
    }
}