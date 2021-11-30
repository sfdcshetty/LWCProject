/**
 * Copyright (c) 2020.  7Summits Inc. All rights reserved.
 */

/**
 * Grab only text characters from a string
 * @param str
 * @returns {string}
 */
export function getText(str) {
    return str.match(/[a-zA-Z]/g).join('');
}

/**
 * Grab only numeric characters from a string
 * @param str
 * @returns {integer}
 */
export function getInteger(str) {
    return parseInt(str.match(/\d/g).join(''), 10);
}