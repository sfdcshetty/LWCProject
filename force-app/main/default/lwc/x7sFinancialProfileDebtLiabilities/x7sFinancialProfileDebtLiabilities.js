import { track,LightningElement } from 'lwc';

export default class X7sFinancialProfileDebtLiabilities extends LightningElement {
    optionsOwner = [
        { label: 'Joanna', value: 'Joanna' }, // TODO: retrieve these options from the org
        { label: 'Thomas', value: 'Thomas' },
    ];
    optionsTypes = [ // TODO: retrieve these options from the org
        { label: 'Jewelry', value: 'Jewelry' },
    ];
    @track rowData = [{ id: 0, type: '', name: '', owner: '', amount: 0 }];

    handleUpdateRowData(event) {
        this.rowData = [...event.detail];
    }
}