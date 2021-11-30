import { LightningElement,api } from 'lwc';

export default class X7sWebMyProfileInformation extends LightningElement {

    @api header;
    @api clientId;
    @api coClientId;
    @api headerName;
    @api clientOrCoClientName;
    @api clientOrCoClientBirthDate;

    @api clientOrCoClientHomeAddress = {};
    @api clientOrCoClientHomeCity;
    @api clientOrCoClientHomeStreet;
    @api clientOrCoClientHomeState;
    @api clientOrCoClientHomePostalCode;

    @api clientOrCoClientWorkAddress = {};

    @api clientOrCoClientOtherAddress;
    @api clientOrCoClientOtherCity;
    @api clientOrCoClientOtherStreet;
    @api clientOrCoClientOtherState;
    @api clientOrCoClientOtherPostalCode;

    @api clientOrCoClientPhone;
    @api clientOrCoClientHomePhone;
    @api clientOrCoClientOtherPhone;
    @api clientOrCoClientWorkPhone;
    @api clientOrCoClientPersonalEmail;
    @api clientOrCoClientWorkEmail;
    @api clientOrCoClientOtherEmail;

    @api beneficiaryId;
    @api beneficiaryName;
    @api beneficiaryDateOfBirth;
    @api beneficiaryState;
    @api relationship;

    @api trusteeId;
    @api trusteeName;
    @api trusteePhone;
    @api trusteeEmail;
    @api trusteeRelationship;

    get isClientAndCoClient() { return (this.clientId || this.coClientId); }

    renderedCallback(){
        if(this.template.querySelector('lightning-formatted-text[data-id="phone"]')){
            this.template.querySelector('lightning-formatted-text[data-id="phone"]').value = this.getPhoneNumberFormatting(this.template.querySelector('lightning-formatted-text[data-id="phone"]').value);
        }
        if(this.template.querySelector('lightning-formatted-text[data-id="homePhone"]')){
            this.template.querySelector('lightning-formatted-text[data-id="homePhone"]').value = this.getPhoneNumberFormatting(this.template.querySelector('lightning-formatted-text[data-id="homePhone"]').value);
        }
        if(this.template.querySelector('lightning-formatted-text[data-id="otherPhone"]')){
            this.template.querySelector('lightning-formatted-text[data-id="otherPhone"]').value = this.getPhoneNumberFormatting(this.template.querySelector('lightning-formatted-text[data-id="otherPhone"]').value);
        }
        if(this.template.querySelector('lightning-formatted-text[data-id="workPhone"]')){
            this.template.querySelector('lightning-formatted-text[data-id="workPhone"]').value = this.getPhoneNumberFormatting(this.template.querySelector('lightning-formatted-text[data-id="workPhone"]').value);
        }
    }

    getPhoneNumberFormatting(phoneNumberValue){
        if(phoneNumberValue){
            const x = phoneNumberValue.replace(/\D+/g, '')
            .match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
           return !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);   
        }
        else{
            return;
        }
    }

}