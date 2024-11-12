import java.util.Random;
import java.util.concurrent.atomic.AtomicBoolean;

public class PingPongGame {
    // Shared object to synchronize on
    private static final Object ball = new Object();

    static class Player implements Runnable {
        private String name;
        private AtomicBoolean gameEnd;

        public Player(String name, AtomicBoolean gameEnd) {
            this.name = name;
            this.gameEnd = gameEnd;
        }

        @Override
        public void run() {
            while (!gameEnd.get()) {
                synchronized (ball) {
                    try {
                        // Wait with the ball
                        Random random = new Random();
                        int waitTime = random.nextInt(10001); // Random time from 0 to 10 seconds
                        System.out.println(name + " received the ball, waiting " + waitTime + " ms");
                        Thread.sleep(waitTime);

                        if (gameEnd.get()) {
                            System.out.println(name + " has the ball. Game over!");
                            return;
                        }

                        System.out.println(name + " hits the ball back");
                        // Notify the other player
                        ball.notify();
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                        return;
                    }

                    try {
                        // Release the lock and allow the other player to take it
                        ball.wait();
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                }
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {
        AtomicBoolean gameEnd = new AtomicBoolean(false);

        Thread player1 = new Thread(new Player("Player 1", gameEnd));
        Thread player2 = new Thread(new Player("Player 2", gameEnd));

        player1.start();
        player2.start();

        // Start the game by waking up Player 1
        synchronized (ball) {
            ball.notify();
        }

        // Let the game run for 2 minutes (120000 milliseconds)
        Thread.sleep(120000);
        gameEnd.set(true);

        player1.join();
        player2.join();

        System.out.println("Ping pong game finished.");
    }
}
