var exec = require('cordova/exec');

exports.startEventSource = function (success, error, message) {
    exec(success, error, 'SSEPlugin', 'startEventSource', [message]);
};

exports.stopEventSource = function (success, error) {
    exec(success, error, 'SSEPlugin', 'stopEventSource');
};