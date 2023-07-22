import Alamofire
import AlamofireEventSource

@objc(SSEPlugin) class SSEPlugin: CDVPlugin {
    var eventSourceRequest: Alamofire.Request?

    @objc(startEventSource:)
    func startEventSource(command: CDVInvokedUrlCommand) {
        let urlString = command.arguments[0] as! String
        guard let url = URL(string: urlString) else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid URL")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        self.eventSourceRequest = Session.default.eventSourceRequest(url, lastEventID: "0").responseEventSource { [weak self] eventSource in
            guard let self = self else { return }

            switch eventSource.event {
            case .message(let message):
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message.data)
                pluginResult?.setKeepCallbackAs(true)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            case .complete(let completion):
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Event source completed: \(completion)")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }


    @objc(stopEventSource:)
    func stopEventSource(command: CDVInvokedUrlCommand) {
        self.eventSourceRequest?.cancel()
        self.eventSourceRequest = nil

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
}
