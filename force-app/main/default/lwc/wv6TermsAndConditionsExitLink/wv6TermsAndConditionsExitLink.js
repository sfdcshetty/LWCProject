/**
 * Created by karolbrennan on 4/19/21.
 */

import {LightningElement} from 'lwc';

export default class Wv6TermsAndConditionsExitLink extends LightningElement {

    exitFlow() {
        window.open("https://www.wealthenhancement.com/", "_top");
    }
}