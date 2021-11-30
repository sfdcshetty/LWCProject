/**
 * Copyright (c) 2020.  7Summits Inc. All rights reserved.
 */

/**
 * Return a DOM attribute ready string of styles to apply, given an object property/value
 * set of CSS styles. Assists in the legibility of coding inline style lists.
 *
 * @param styleObj
 * @returns {string}
 */
export function stringifyStyles(styleObj) {
    return Object.keys(styleObj).reduce( (accum, styleProperty) => {
        if ((styleObj[styleProperty] !== 'undefined') && styleObj[styleProperty] && (styleObj[styleProperty].indexOf('undefined') === -1)) {
            return accum.concat(`${styleProperty}:${styleObj[styleProperty]};`);
        } else {
            return accum;
        }
    }, '');
}