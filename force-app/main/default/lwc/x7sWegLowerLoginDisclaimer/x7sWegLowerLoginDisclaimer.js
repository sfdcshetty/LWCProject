import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class X7SWegLowerLoginDisclaimer extends NavigationMixin(LightningElement) {
    @api linkDestination;

    goToWeg() {

        this[NavigationMixin.GenerateUrl]({
            type: "standard__webPage",
            attributes: {
                url: this.linkDestination
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }
}