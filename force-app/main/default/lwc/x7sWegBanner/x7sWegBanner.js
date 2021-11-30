import { LightningElement, api } from 'lwc';

export default class X7sWegBanner extends LightningElement {
    styles;
    @api backgroundImage;
    @api height;
    @api diagLine;

    connectedCallback(){
        this.styles = "background-image:url('" + this.backgroundImage + "'); height: "+ this.height + ";";
        if(this.diagLine === true) {
            this.styles += "clip-path: polygon(0 0, 100% 0, 100% 80%, 0 100%)";
        }
    }
}