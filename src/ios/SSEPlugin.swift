import Alamofire
import AlamofireEventSource

@objc(SSEPlugin) class SSEPlugin: CDVPlugin {
    var eventSourceRequest: Alamofire.Request?
//    var command: CDVInvokedUrlCommand?

    @objc(startEventSource:)
    func startEventSource(command: CDVInvokedUrlCommand) {
//        self.command = command
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
//                guard let event: String = message.event else {return}
//                guard let serverMessage: String = message.data else {return}
                let result: [String: Any] = [
                    "event": message.event ?? "NullEvent",
                    "serverMessage": message.data ?? "NullMessage"
                ]
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                    
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        print("⭐️ JSON String: \(jsonString)")
//                        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "⭐️" + jsonString)
//                        pluginResult?.setKeepCallbackAs(true)
//                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                        
                        self.sendPluginResult(cdvCommand: command, status: CDVCommandStatus_OK, message: jsonString)
                    } else {
                        print("🚨 Error: Unable to convert JSON data to string.")
                        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "⭐️" + message.data!)
                        pluginResult?.setKeepCallbackAs(true)
                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    }
                } catch {
                    print("🚨 Error: Unable to serialize dictionary to JSON.")
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error serializing JSON")
                    pluginResult?.setKeepCallbackAs(true)
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                }
                
                
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
    
    func sendPluginResult(cdvCommand: CDVInvokedUrlCommand, status: CDVCommandStatus, message: String, defaultErrorCallback: Bool = false) {
            var pluginResult = CDVPluginResult()
            pluginResult?.setKeepCallbackAs(true)
            pluginResult = CDVPluginResult(status: status, messageAs: message)
            self.commandDelegate!.send(pluginResult, callbackId: cdvCommand.callbackId)
        }
}
