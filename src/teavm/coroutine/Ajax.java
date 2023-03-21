public class Ajax {
    @Async
    public static native String get(String url) throws IOException;
    private static void get(String url, AsyncCallback<String> callback) {
        var xhr = XMLHttpRequest.create();
        xhr.open("get", url);
        xhr.setOnReadyStateChange(() -> {
            if (xhr.getReadyState() != XMLHttpRequest.DONE) {
                return;
            }
            
            int statusGroup = xhr.getStatus() / 100;
            if (statusGroup != 2 && statusGroup != 3) {
                callback.error(new IOException("HTTP status: " + 
                        xhr.getStatus() + " " + xhr.getStatusText()));
            } else {
                callback.complete(xhr.getResponseText());
            }
        });
