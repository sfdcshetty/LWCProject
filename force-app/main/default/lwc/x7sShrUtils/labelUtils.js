/**
 * Copyright (c) 2020.  7Summits Inc. All rights reserved.
 */

/**
 * formats a text string with placeholders
 * @param label
 * @param args
 * @returns {*}
 */
export function formatText(label, ...args) {
    for (let x = 0; x < args.length; x++) {
        label = label.replace(`{${x}}`, args[x]);
    }
    return label;
}