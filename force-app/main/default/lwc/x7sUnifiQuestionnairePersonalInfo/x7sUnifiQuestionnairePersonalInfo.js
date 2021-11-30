import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import UNIFI_OBJECT from '@salesforce/schema/Financial_Profile__c';
import HEADER from '@salesforce/label/c.x7sUnifiQuestionnaire_Personalinfo_Header';
//import INTRO from '@salesforce/label/c.x7sUnifiQuestionnaire_Personalinfo_Paragraph';
import { track, api, wire, LightningElement } from 'lwc';

export default class X7sUnifiQuestionnairePersonalInfo extends LightningElement {
    @api debug = false;
    @api coClientId = false;

    @api header = HEADER;

    @api allowMultipleEmails = false;
    @api allowMultiplePhones = false;

    @api firstName = '';
    @api middleInitial = '';
    lenMiddleInitial = 1;
    @api lastName = '';
    @api suffix = '';
    lenSuffix = 5;

    @api dateOfBirth = '';
    @api streetAddress = '';
    @api city = '';
    @api state = '';
    @api zipCode = '';

    @api set email(val) { this.emails[0] = { ...this.emails[0], id: Date.now(), email: val }; }
    get email() { return this.emails[0].email; }
    @api set emailType(val) { this.emails[0] = { ...this.emails[0], id: Date.now(), type: val }; }
    get emailType() { return this.emails[0].type; }
    @api set phone(val) { this.phones[0] = { ...this.phones[0], id: Date.now(), phone: val }; }
    get phone() { return this.phones[0].phone; }
    @api set phoneType(val) { this.phones[0] = { ...this.phones[0], id: Date.now(), type: val }; }
    get phoneType() { return this.phones[0].type; }

    @track emails = [];
    @track phones = [];

    @track optionsEmailType = [];
    @track optionsPhoneType = [];
    @track optionsState = [];

    // get object info for unifi questionnaire
    @track objectInfoData;
    @wire(getObjectInfo, { objectApiName: UNIFI_OBJECT })
    objectInfo({data,error}) {
        if (error) console.error(error);
        if (data) this.objectInfoData = data;
    }

    // get picklist values using objectInfo
    @wire(getPicklistValuesByRecordType, {
        recordTypeId: '$objectInfoData.defaultRecordTypeId',
        objectApiName: UNIFI_OBJECT,
    })
    getPicklistValues({ data, error }) {
        if (error) console.error(error);
        if (data) {
            this.optionsEmailType = data.picklistFieldValues.Email_Type__c.values;
            this.optionsPhoneType = data.picklistFieldValues.Phone_Type__c.values;
            this.optionsState = data.picklistFieldValues.State__c.values;
        }
    }

    connectedCallback() {}

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

            Email__c: this.emails[0] ? this.emails[0].email : '',
            Email_Type__c: this.emails[0] ? this.emails[0].type : '',
            Phone__c: this.phones[0] ? this.phones[0].phone : '',
            Phone_Type__c: this.phones[0] ? this.phones[0].type : '',
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

    handleChangeEmail(event) {
        this.emails[event.currentTarget.dataset.index].email =
            event.detail.value;
        this.dispatchData();
    }
    handleChangeEmailType(event) {
        this.emails[event.currentTarget.dataset.index].type =
            event.detail.value;
        this.dispatchData();
    }
    handleChangePhone(event) {
        this.phones[event.currentTarget.dataset.index].phone =
            event.detail.value;
        this.dispatchData();
    }
    handleChangePhoneType(event) {
        this.phones[event.currentTarget.dataset.index].type =
            event.detail.value;
        this.dispatchData();
    }

    handleClickAddAnotherEmail() {
        this.emails.push({ id: Date.now(), email: '', type: '' });
    }
    handleClickAddAnotherPhone() {
        this.phones.push({ id: Date.now(), phone: '', type: '' });
    }
}