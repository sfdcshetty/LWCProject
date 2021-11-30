/**
 * Copyright (c) 2020.  7Summits Inc. All rights reserved.
 */

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * dispatches a toast event
 * https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation
 * @param {string} title
 * @param {string} message
 * @param {string} variant - Values: 'error', 'warning', 'success' or 'info'
 * @param {string} mode - Values: 'dismissable', 'pester', or 'sticky'
 * @returns {boolean}
 */
const showToast = (title, message, variant, mode) => {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant ? variant : 'success',
        mode: mode ? mode : 'dismissable'
    });
    return dispatchEvent(event);
};

export { showToast };