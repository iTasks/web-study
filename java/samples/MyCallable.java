import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class MyCallable implements Callable<String> {
    @Override
    public String call() throws Exception {
        return "Result from " + Thread.currentThread().getName();
    }

    public static void main(String[] args) throws ExecutionException, InterruptedException {
        ExecutorService executor = Executors.newFixedThreadPool(1);
        MyCallable myCallable = new MyCallable();
        Future<String> future = executor.submit(myCallable);
        
        //waits for the thread to complete and fetches the result
        String result = future.get();
        System.out.println(result);
        executor.shutdown();
    }
}
