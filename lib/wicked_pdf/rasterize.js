"use strict";
var page = require('webpage').create(),
    system = require('system'),
    format = 'A4',
    margin = '10mm',
    orientation = 'portrait',
    address, output;


if (system.args.length < 3) {
    phantom.exit(1);
} else {
    address = system.args[system.args.length-2];
    output = system.args[system.args.length-1];

    for(var i=1;i<system.args.length-2;i+=2) {
        switch(system.args[i]) {
            case '--page-size':
                format = system.args[i+1];
                break;
            case '--orientation':
                orientation = system.args[i+1];
                break;
            case '--zoom':
                page.zoomFactor = system.args[i+1];
                break;
            default:
                console.log("Unknown argument: " + system.args[i])
        }
    }

    page.paperSize = { format: format, orientation: orientation, margin: margin};

    page.open(address, function (status) {
        if (status !== 'success') {
            console.log('Unable to load the address!');
            phantom.exit(1);
        } else {
            window.setTimeout(function () {
                page.render(output);
                phantom.exit();
            }, 200);
        }
    });
}
