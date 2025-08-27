package cordova.plugin.sse;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.sse.EventSource;
import okhttp3.sse.EventSourceListener;
import okhttp3.sse.EventSources;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

public class SSEPlugin extends CordovaPlugin {

    private OkHttpClient client;
    private EventSource eventSource;
    private CallbackContext callbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        if (action.equals("startEventSource")) {
            if(eventSource == null) { // Check if connection already exists
                startEventSource(args.getString(0));
            }
            return true;
        } else if (action.equals("stopEventSource")) {
            stopEventSource();
            return true;
        }
        return false;
    }

    private void startEventSource(String url) {
        client = new OkHttpClient.Builder()
        .readTimeout(60, TimeUnit.SECONDS)
        .retryOnConnectionFailure(true)
                .build();

        Request request = new Request.Builder()
                .url(url)
                .build();

        eventSource = EventSources.createFactory(client).newEventSource(request, new EventSourceListener() {
            @Override
            public void onEvent(EventSource eventSource, String id, String type, String data) {
                try {
                    JSONObject result = new JSONObject();
                    result.put("event", type != null ? type : "NullEvent");
                    result.put("serverMessage", data != null ? data : "NullMessage");

                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, result.toString());
                    pluginResult.setKeepCallback(true);
                    callbackContext.sendPluginResult(pluginResult);
                } catch (JSONException e) {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "Error serializing JSON");
                    callbackContext.sendPluginResult(pluginResult);
                }
            }

            @Override
            public void onClosed(EventSource eventSource) {
                PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "Event source completed");
                callbackContext.sendPluginResult(pluginResult);
            }

            @Override
            public void onFailure(EventSource eventSource, Throwable t, Response response) {
                PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "Event source failure: " + t.getMessage());
                callbackContext.sendPluginResult(pluginResult);
            }
        });
    }

    private void stopEventSource() {
        if (eventSource != null) {
            eventSource.cancel();
            eventSource = null;
        }

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, "SSE connection closed");
        callbackContext.sendPluginResult(pluginResult);
    }
}
