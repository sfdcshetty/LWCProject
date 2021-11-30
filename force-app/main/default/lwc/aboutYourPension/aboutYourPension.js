import { LightningElement } from 'lwc';

export default class AboutYourPension extends LightningElement {
    description = '';
    owner = '';
    _amount = 0;
    get amount() { return this._amount; }
    set amount(val) { this._amount = parseInt(val,10) || 0; }

    handleChangeDescription(event) { this.description = event.detail.value; }
    handleChangeAmount(event) { this.amount = event.detail.value; }
    handleChangeOwner(event) { this.owner = event.detail.value; }
}