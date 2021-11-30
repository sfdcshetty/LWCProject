import { api,LightningElement } from 'lwc';

export default class X7sUnifiProgressBar extends LightningElement {
    @api percent = 0;
    @api percentString = "% Complete";

    connectedCallback() {
    }
    renderedCallback() {
        this.updateProgressBarLength();
    }

    updateProgressBarLength() {
        this.template.host.style.setProperty('--progress-width',`${Math.max(Math.min(this.percent,100),0)}%`);
    }
}