import { track, LightningElement } from 'lwc';

export default class AboutYourGifts extends LightningElement {
    optionsOwner = [
        { label: 'Joanna', value: 'Joanna' }, // TODO: retrieve these options from the org
        { label: 'Thomas', value: 'Thomas' },
    ];
    @track data = [{ id: 0, description: '', owner: '', amount: 0 }];

    handleUpdateRowData(event) {
        this.data = [...event.detail];
    }
}