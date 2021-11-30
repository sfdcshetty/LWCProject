/**
 * Copyright (c) 2020.  7Summits Inc. All rights reserved.
 */

/**
 * Return a textual message of a thrown error by a Lightning Data Service.
 * https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.data_error
 *
 * ...but test to see if is a non-LDS thrown error first.
 *
 * @param error
 * @returns {string}
 */
export function stringifyThrownLdsError(error) {
    let errorMessage = 'Unknown Error';
    if (error.hasOwnProperty('message')) {
        errorMessage = error.toString();
    } else if (Array.isArray(error.body)) {
        errorMessage = error.body.map(e => e.message).join(', ');
    } else if (typeof error.body.message === 'string') {
        errorMessage = error.body.message;
    }
    return errorMessage;
}