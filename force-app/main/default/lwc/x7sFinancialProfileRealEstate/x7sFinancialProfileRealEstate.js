import { track,LightningElement } from 'lwc';

export default class X7sFinancialProfileRealEstate extends LightningElement {
    optionsOwner = [
        { label: 'Joanna', value: 'Joanna' }, // TODO: retrieve these options from the org
        { label: 'Thomas', value: 'Thomas' },
    ];
    optionsTypes = [ // TODO: retrieve these options from the org
        { label: 'Vacation Home', value: 'Vacation Home' },
    ];
    @track rowData = [{ id: 0, type: '', name: '', owner: '', amount: 0 }];

    handleUpdateRowData(event) {
        this.rowData = [...event.detail];
    }
}