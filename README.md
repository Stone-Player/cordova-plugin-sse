# Cordova Plugin SSE

This is a Cordova plugin for Server-Sent Events (SSE). It provides an interface for opening and closing an SSE connection on both iOS and Android platforms.

## Installation

To install the plugin, use the following command:

```bash
cordova plugin add https://github.com/andregrillo/cordova-plugin-sse.git
```

## Usage

The plugin provides two methods: `startEventSource` and `stopEventSource`.

### startEventSource

This method opens an SSE connection to a specified URL. It takes a URL as a parameter and two callbacks for success and error.

```javascript
cordova.plugins.sse.startEventSource(successCallback, errorCallback, url);
```

### stopEventSource

This method closes the SSE connection. It takes two callbacks for success and error.

```javascript
cordova.plugins.sse.stopEventSource(successCallback, errorCallback);
```

## Example

```javascript
// Start SSE connection
cordova.plugins.sse.startEventSource(
  function(message) {
    console.log("SSE message received: ", message);
  },
  function(error) {
    console.error("Error occurred: ", error);
  },
  "https://example.com/sse"
);

// Stop SSE connection
cordova.plugins.sse.stopEventSource(
  function(message) {
    console.log("SSE connection closed: ", message);
  },
  function(error) {
    console.error("Error occurred: ", error);
  }
);
```

## Author
André Grillo - OutSystems

## License

This project is licensed under the MIT License.
