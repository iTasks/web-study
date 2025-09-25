import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.concurrent.locks.ReadLock;
import java.util.concurrent.locks.WriteLock;

public class SharedResource {
    private final ReentrantReadWriteLock rwLock = new ReentrantReadWriteLock();
    private final ReadLock readLock = rwLock.readLock();
    private final WriteLock writeLock = rwLock.writeLock();
    
    private int sharedData = 0;

    public void increment() {
        writeLock.lock();  // Acquire the write lock
        try {
            sharedData++;
            System.out.println("Data written: " + sharedData);
        } finally {
            writeLock.unlock();  // Ensure the lock is released
        }
    }

    public void printData() {
        readLock.lock();  // Acquire the read lock
        try {
            System.out.println("Data read: " + sharedData);
        } finally {
            readLock.unlock();  // Ensure the lock is released
        }
    }

    public static void main(String[] args) {
        SharedResource resource = new SharedResource();
        
        Thread writer = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                resource.increment();
                try {
                    Thread.sleep(100);  // Simulate some delay
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        });

        Thread reader = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                resource.printData();
                try {
                    Thread.sleep(50);  // Simulate some delay
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        });

        reader.start();
        writer.start();

        try {
            reader.join();
            writer.join();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        System.out.println("Final data: " + resource.sharedData);
    }
}
