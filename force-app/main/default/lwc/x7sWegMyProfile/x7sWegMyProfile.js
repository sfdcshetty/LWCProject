import { LightningElement , wire, track, api} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';
import getUserInformation from '@salesforce/apex/x7sProfileInfoController.getUsersProfileData';
const USER_FIELDS = ['User.ContactId','User.AccountId'];

export default class X7sWegMyProfile extends LightningElement {
    debug = true;
    currentUserId = userId;
    contactId;
    accountId;
    primaryIndividualName;
    secondaryIndividualName;
    @track clientInfo;
    @api clientAndCoClientInfo;
    @api beneficiaryInfo;
    @api trusteeInfo;

    @wire(getRecord, { recordId: '$currentUserId', fields: USER_FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            console.error('Error in getRecord:', error);
        } else if (data) {
            if (this.debug) console.log('user info:',data);
            this.contactId = data.fields.ContactId.value;
            this.accountId = data.fields.AccountId.value;
            if(this.accountId){
                this.getUserInformation();
            }
        }
    }

    getUserInformation(){
        getUserInformation({accountId: this.accountId})
        .then(result =>{
            if (this.debug) console.log('clientAndCoClientInfo:',result);
            this.clientAndCoClientInfo = result.clientAndCoClientInfo;
            this.beneficiaryInfo = result.beneficiaryInfo;
            this.trusteeInfo = result.trusteeInfo;
        })
        .catch(error =>{
            console.error('Error in getRecord:', error);
        })

    }
}