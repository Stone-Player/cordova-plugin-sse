import Alamofire
import AlamofireEventSource

@objc(SSEPlugin)
class SSEPlugin: CDVPlugin {
    var request: Alamofire.Request?

    @objc(startEventSource:)
    func startEventSource(command: CDVInvokedUrlCommand) {
        let urlString = command.arguments[0] as! String
        let url = URL(string: urlString)!
        
        self.request = Session.default.eventSourceRequest(url, lastEventID: "0").responseEventSource { eventSource in
            switch eventSource.event {
            case .message(let message):
                print("Event source received message:", message)
            case .complete(let completion):
                print("Event source completed:", completion)
            }
        }
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc(stopEventSource:)
    func stopEventSource(command: CDVInvokedUrlCommand) {
        self.request?.cancel()
        self.request = nil
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
}

