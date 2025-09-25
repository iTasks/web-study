import java.util.concurrent.*;
import java.util.concurrent.Callable;

class FactorialTask implements Callable<Long> {
    private int number;

    public FactorialTask(int number) {
        this.number = number;
    }

    @Override
    public Long call() throws Exception {
        return factorial(number);
    }

    private long factorial(int n) {
        long result = 1;
        for (int i = 2; i <= n; i++) {
            result *= i;
        }
        return result;
    }
}

public class FutureExample {
    public static void main(String[] args) {
        ExecutorService executor = Executors.newSingleThreadExecutor();
        FactorialTask task = new FactorialTask(5);

        Future<Long> future = executor.submit(task);

        try {
            // You can do other tasks here in the meantime

            // This will block until the future's task completes
            Long result = future.get();  // You can also use future.get(timeout, TimeUnit.SECONDS) to timeout
            System.out.println("Factorial of 5 is: " + result);
        } catch (InterruptedException e) {
            // handle the case where the task was interrupted during processing
            Thread.currentThread().interrupt();
            System.err.println("Task was interrupted");
        } catch (ExecutionException e) {
            // handle the case where the task threw an exception
            System.err.println("Error occurred: " + e.getCause());
        } finally {
            // It's important to shutdown your executor service!
            executor.shutdown();
        }
    }
}
