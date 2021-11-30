import { LightningElement, track } from 'lwc';
import Id from '@salesforce/user/Id';

export default class X7sWegSecureMessaging extends LightningElement {
    @track userId
    connectedCallback(){
        this.getClonedRecord();
    }

    getClonedRecord(){
        this.userId="uid="+Id;
    }
}