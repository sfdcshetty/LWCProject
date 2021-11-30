import LIFE_INSURANCE_HEADER from '@salesforce/label/c.x7sFinancialProfile_LifeInsurance_Header';
import LONG_TERM_CARE_INSURANCE_HEADER from '@salesforce/label/c.x7sFinancialProfile_LongTermCareInsurance_Header';
import DISABILITY_INSURANCE_HEADER from '@salesforce/label/c.x7sFinancialProfile_DisabilityInsurance_Header';
import HEALTH_INSURANCE_HEADER from'@salesforce/label/c.x7sFinancialProfile_HealthInsurance_Header';
import PROPERTY_CASUALTY_INSURANCE_HEADER from '@salesforce/label/c.x7sFinancialProfile_PropertyCasualtyInsurance_Header';
import OTHER_INSURANCE_HEADER from '@salesforce/label/c.x7sFinancialProfile_OtherInsurance_Header';

import INSURANCE_POLICY_OBJECT from '@salesforce/schema/Financial_Profile_Insurance_Policy__c';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { fireEvent } from 'c/pubsub';
import { api,track,wire,LightningElement } from 'lwc';

export default class X7sFinancialProfileInsuranceRows extends LightningElement {
    @api debug = false;
    @api insurancePoliciesType = '';
    //@api insurancePolicies = [];
    @api primaryName = '';
    @api secondaryName = '';
    @api primaryContactId = '';
    @api secondaryContactId = '';
    @api showPrimary = false;
    @api showSecondary = false;

    @track optionsTerm = [];

    showPrimary = true;
    showSecondary = true;

    /**
     * return the current header string based on the current insurancePoliciesType
     */
     get header() {
        const headers = {
            'Life': LIFE_INSURANCE_HEADER,
            'Long-Term Care': LONG_TERM_CARE_INSURANCE_HEADER,
            'Disability': DISABILITY_INSURANCE_HEADER,
            'Health': HEALTH_INSURANCE_HEADER,
            'Property and Casualty': PROPERTY_CASUALTY_INSURANCE_HEADER,
            'Other': OTHER_INSURANCE_HEADER,
        };
        return headers[this.insurancePoliciesType];
    }

    get optionsOwner() {
        const opts = [];
        if (this.showPrimary) opts.push({ label: this.primaryName, value: this.primaryContactId });
        if (this.showSecondary) opts.push({ label: this.secondaryName, value: this.secondaryContactId });
        return opts;
    }

    get blankRow() { return { 
            Id: 0, 
            recordTypeId: this.objectRecordTypeId,
            Type__c: this.insurancePoliciesType, 
            Insurance_Type__c: '', 

            Name: '', 
            Insurance_Company__c: '',
            Policy_Number__c: '',
            Owner__c: '', 
            Insured__c: '',

            As_Of_Date: null,
            Death_Benefit__c: 0,
            Cash_Value__c: 0,
            Benefit_Amount__c: 0,
            Coverage_Amount__c: 0,
            Premium__c: 0,
            Term__c: '',
        }; 
    }
    
    // get object info for unifi questionnaire
    objectRecordTypeId = '';
    @wire(getObjectInfo, { objectApiName: INSURANCE_POLICY_OBJECT })
    objectInfo({data,error}) {
        if (error) console.error(error);
        if (data) {
            const recordTypes = Object.values(data.recordTypeInfos).find(i=>i.name===this.insurancePoliciesType); // undefined if there's no matching record type
            this.objectRecordTypeId = recordTypes ? recordTypes.recordTypeId : '';
        }
    };
    // get picklist values using objectInfo
    @wire(getPicklistValuesByRecordType, {
        recordTypeId: '$objectRecordTypeId',
        objectApiName: INSURANCE_POLICY_OBJECT,
    })
    getPicklistValues({ data, error }) {
        if (error) console.error(error);
        if (data) {
            this.optionsTerm = data.picklistFieldValues.Term__c.values; 
        }
    }

    @api allInsurancePolicies = [];
    @api set insurancePolicies(arr) { 
        if (arr && arr.length) {
            this.allInsurancePolicies = arr.map(i=>({...i})).map(j=>({...j}));  // need to unroll this object twice to completely de-proxy it
        }
        if (!this.insurancePoliciesOfType.length) {
            this.allInsurancePolicies.push(this.blankRow);
        }
    }
    get insurancePolicies() { return this.allInsurancePolicies; }

    // getters to show or hide specific fields, based on the insurance type
    get showBenefitAmount() { return this.insurancePoliciesType==='Long-Term Care' || this.insurancePoliciesType==='Disability'; }
    get showDeathBenefit() { return this.insurancePoliciesType==='Life' || this.insurancePoliciesType==='Long-Term Care'; }
    get showCashValue() { return this.insurancePoliciesType==='Life' || this.insurancePoliciesType==='Long-Term Care'; }
    get showCoverageAmount() { return this.insurancePoliciesType==='Property and Casualty' || this.insurancePoliciesType==='Other'; }
    get showPremium() { return this.insurancePoliciesType==='Health'; }
    
    // getter for the "Insured" field label
    get labelInsured() { return (this.insurancePoliciesType==='Property and Casualty') ? 'Insured Asset' : 'Insured'; }
    
    /**
     * return the insurancePolicies records filtered by the current insurancePoliciesType
     */
    get insurancePoliciesOfType() { 
        return this.allInsurancePolicies.filter(i=>i.Type__c===this.insurancePoliciesType)
                    .map(i=>({...i, recordTypeId: this.objectRecordTypeId })); // this might not be set in blankRow 
    }
    labelType = 'Insurance Type';
    labelName = 'Insurance Company';


    connectedCallback() {
        // check if this is even necessary, or skip to the next screen if it's not
        if (!this.showPrimary && !this.showSecondary) {
            fireEvent('goSkip','skipping '+this.insurancePoliciesType);
        }
    }

    /**
     * generic row-field-value change function that accepts a row id, a single value, and one or more field names to update in that row
     * @param {string} currId 
     * @param {*} value 
     * @param  {...any} fieldNames
     */
    handleChangeFieldValue(currId,value,...fieldNames) {
        const currIndex = this.allInsurancePolicies.findIndex(i=>i.Id==currId);
        fieldNames.forEach(i=>{ this.allInsurancePolicies[currIndex][i] = value; });
        this.deployRowData();
    }
    
    /**
     * Update the 'name' field for a specific row
     * @param {*} event 
     */
    handleChangeName(event) { 
        this.handleChangeFieldValue(event.currentTarget.dataset.rowId, event.detail.value, 'Name', 'Insurance_Company__c');
    };
    
    /**
     * Update the 'loan term' field for a specific row
     * @param {*} event 
     */
    handleChangeTerm(event) { 
        this.handleChangeFieldValue(event.currentTarget.dataset.rowId, event.detail.value, 'Term__c');
   }

    /**
     * Update the 'owner' field for a specific row
     * @param {*} event 
     */
    handleChangeOwner(event) {
        this.handleChangeFieldValue(event.currentTarget.dataset.rowId, event.detail.value, 'Owner__c');
    }

    /**
     * Update the 'as of date' field for a specific row
     * @param {*} event 
     */
     handleChangeAsOfDate(event) {
        this.handleChangeFieldValue(event.currentTarget.dataset.rowId, event.detail.value, 'As_Of_Date__c');
    }

    /**
     * Update the 'policy number' field for a specific row
     * @param {*} event 
     */
     handleChangePolicyNumber(event) {
        this.handleChangeFieldValue(event.currentTarget.dataset.rowId, event.detail.value, 'Policy_Number__c');
    }

    /**
     * Update the 'insured' field for a specific row
     * @param {*} event 
     */
     handleChangeInsured(event) {
        this.handleChangeFieldValue(event.currentTarget.dataset.rowId, event.detail.value, 'Insured__c');
    }
    
     /**
      * Update the 'amount' field for a specific row
      * @param {*} event 
      */
    handleChangePremium(event) { 
        this.handleChangeFieldValue(event.currentTarget.dataset.rowId, parseInt(event.detail.value,10) || 0, 'Premium__c');
    }
    
    /**
     * Update the 'has home equity line' field for a specific row
     * @param {*} event 
     */
     handleChangeCashValue(event) {
        this.handleChangeFieldValue(event.currentTarget.dataset.rowId, parseInt(event.detail.value,10) || 0, 'Cash_Value__c');
    }
    
    /**
     * Update the 'has loan' field for a specific row
     * @param {*} event 
     */
     handleChangeDeathBenefit(event) {
        this.handleChangeFieldValue(event.currentTarget.dataset.rowId, parseInt(event.detail.value,10) || 0, 'Death_Benefit__c');
    }
    
    /**
     * Update the 'benefit amount' field for a specific row
     * @param {*} event 
     */
     handleChangeBenefitAmount(event) {
        this.handleChangeFieldValue(event.currentTarget.dataset.rowId, parseInt(event.detail.value,10) || 0, 'Benefit_Amount__c');
    }
    
    /**
     * Update the 'coverage amount' field for a specific row
     * @param {*} event 
     */
     handleChangeCoverageAmount(event) {
        this.handleChangeFieldValue(event.currentTarget.dataset.rowId, parseInt(event.detail.value,10) || 0, 'Coverage_Amount__c');
    }


    /**
     * Add an extra blank row to the bottom
     * @param {*} event 
     */
    handleClickAddAnotherRow(event) {
        this.allInsurancePolicies = [
            ...this.allInsurancePolicies, {
                ...this.blankRow, 
                Id: this.allInsurancePolicies.length
            }
        ];
    }

    /**
     * Remove a given row, with a prompt to confirm
     * @param {*} event 
     */
    handleClickRemoveRow(event) {
        if (window.confirm('Are you sure you want to completely delete this row of data?')) {
            const rowId = event.currentTarget.dataset.rowId;
            this.allInsurancePolicies = this.allInsurancePolicies.filter(i=>i.Id!=rowId);
            this.deployRowData();
        }
    }

    deployRowData() {
        this.dispatchEvent(new CustomEvent('savetempdata', { detail: {
            insurances: this.insurancePoliciesOfType,
            insuranceType: this.insurancePoliciesType,
        }}) );
    }

}