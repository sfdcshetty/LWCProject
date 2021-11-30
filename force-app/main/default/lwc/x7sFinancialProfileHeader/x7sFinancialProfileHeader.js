/**
 * Created by martinblase on 4/6/21.
 */

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

import { api,wire,LightningElement } from "lwc";

export default class X7sFinancialProfileHeader extends LightningElement {
    headerText = ''; // initial value

    connectedCallback() {
        registerListener('updateHeader', this.updateHeader, this);
    }
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    updateHeader(val) {
        this.headerText = val;
    }

    /*handleClickUploadDocs(event) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'upload not enabled',
            variant: 'error',
        }) );
    }*/

    handleClickViewDocList(event) {
        fireEvent('showDocList','showing document list');
    }

    handleClickSaveAndClose(event) {
        fireEvent('saveData','saving data');
        this.dispatchEvent(new CustomEvent('close'));
    }
}