/**
 * Created by karolbrennan on 4/9/21.
 */

import { LightningElement } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import fonts from "@salesforce/resourceUrl/proximaNovaFont";

export default class wv6TermsAndConditions extends LightningElement {
  connectedCallback() {
    Promise.all([loadStyle(this, fonts + "/font.css")]).then(() => {
      // do nothing
    });
  }

  exitFlow() {
    window.open("https://www.wealthenhancement.com/", "_top");
  }
}