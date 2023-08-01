import Alamofire
import AlamofireEventSource

@objc(SSEPlugin) class SSEPlugin: CDVPlugin {
    var eventSourceRequest: Alamofire.Request?
    var callbackId: String?

    @objc(startEventSource:)
    func startEventSource(command: CDVInvokedUrlCommand) {
        if callbackId != nil {
            self.stopEventSourceOldCallback(callbackId: callbackId!)
        }
        callbackId = command.callbackId
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
                let result: [String: Any] = [
                    "event": message.event ?? "NullEvent",
                    "serverMessage": message.data ?? "NullMessage"
                ]
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        if result["event"] as! String == "sseHeartbeat" {
                        }
                        self.sendPluginResult(callbackId: command.callbackId, status: CDVCommandStatus_OK, message: jsonString, keepCallback: true)
                    } else {
                        self.sendPluginResult(callbackId: command.callbackId, status: CDVCommandStatus_ERROR, message: "Error serializing JSON")
                    }
                } catch {
                    self.sendPluginResult(callbackId: command.callbackId, status: CDVCommandStatus_ERROR, message: "Error serializing JSON")
                }
                
            case .complete(let completion):
                self.sendPluginResult(callbackId: command.callbackId, status: CDVCommandStatus_ERROR, message: "Event source completed: \(completion)")
            }
        }
    }

    func stopEventSourceOldCallback(callbackId: String) {
        self.eventSourceRequest?.cancel()
        self.eventSourceRequest = nil
        sendPluginResult(callbackId: callbackId, status: CDVCommandStatus_OK, message: "Event Source Stopped")
    }
    
    @objc(stopEventSource:)
    func stopEventSource(command: CDVInvokedUrlCommand) {
        self.eventSourceRequest?.cancel()
        self.eventSourceRequest = nil
        sendPluginResult(callbackId: command.callbackId, status: CDVCommandStatus_OK, message: "Event Source Stopped")
    }
    
    func sendPluginResult(callbackId: String, status: CDVCommandStatus, message: String, keepCallback: Bool = false) {
            var pluginResult = CDVPluginResult()
            pluginResult = CDVPluginResult(status: status, messageAs: message)
            if keepCallback {
                pluginResult?.setKeepCallbackAs(true)
            }
            self.commandDelegate!.send(pluginResult, callbackId: callbackId)
    }
}
