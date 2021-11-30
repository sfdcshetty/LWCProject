/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */

import { LightningElement, api } from 'lwc';

export default class X7sOnboardingProgressStep extends LightningElement {

    @api show;
    @api label;
    @api completed = false;
    @api pageNumber;
    @api pageName;

    @api completedIcon = 'utility:check';
    @api todoIcon = 'utility:reassign';

    get isCompletedIcon() {
        return this.completed ? this.completedIcon : 'standard:empty';
    }

    connectedCallback() {}

    handleClick() {
        const stepClickEvent = new CustomEvent('stepclick', {
            detail: {
                        message:this.pageNumber, 
                        slide:this.pageName
                    }
        });
        this.dispatchEvent(stepClickEvent);
    }
}