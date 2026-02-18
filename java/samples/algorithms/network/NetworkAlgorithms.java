package algorithms.network;

import java.util.*;

/**
 * Network algorithms and data structures.
 * 
 * This class provides implementations of network-related algorithms:
 * - Dijkstra's shortest path algorithm
 * - Network flow (Ford-Fulkerson method)
 * - Minimum spanning tree (Prim's algorithm)
 */
public class NetworkAlgorithms {

    /**
     * Weighted graph representation for network algorithms.
     */
    public static class WeightedGraph {
        private int vertices;
        private List<List<Edge>> adjList;

        public static class Edge {
            int dest;
            int weight;

            public Edge(int dest, int weight) {
                this.dest = dest;
                this.weight = weight;
            }
        }

        public WeightedGraph(int vertices) {
            this.vertices = vertices;
            this.adjList = new ArrayList<>(vertices);
            for (int i = 0; i < vertices; i++) {
                adjList.add(new ArrayList<>());
            }
        }

        public void addEdge(int source, int dest, int weight) {
            adjList.get(source).add(new Edge(dest, weight));
        }

        public void addUndirectedEdge(int source, int dest, int weight) {
            adjList.get(source).add(new Edge(dest, weight));
            adjList.get(dest).add(new Edge(source, weight));
        }

        public List<Edge> getNeighbors(int vertex) {
            return adjList.get(vertex);
        }

        public int getVertices() {
            return vertices;
        }
    }

    /**
     * Dijkstra's shortest path algorithm for weighted graphs.
     * 
     * Finds the shortest path from a source vertex to all other vertices.
     * 
     * Time Complexity: O((V + E) log V) with priority queue
     * Space Complexity: O(V)
     * 
     * @param graph the weighted graph
     * @param source the source vertex
     * @return array of shortest distances from source to each vertex
     */
    public static int[] dijkstra(WeightedGraph graph, int source) {
        int[] distances = new int[graph.getVertices()];
        boolean[] visited = new boolean[graph.getVertices()];
        Arrays.fill(distances, Integer.MAX_VALUE);
        distances[source] = 0;

        PriorityQueue<int[]> pq = new PriorityQueue<>(Comparator.comparingInt(a -> a[1]));
        pq.offer(new int[]{source, 0});

        while (!pq.isEmpty()) {
            int[] current = pq.poll();
            int vertex = current[0];

            if (visited[vertex]) {
                continue;
            }
            visited[vertex] = true;

            for (WeightedGraph.Edge edge : graph.getNeighbors(vertex)) {
                int newDist = distances[vertex] + edge.weight;
                if (newDist < distances[edge.dest]) {
                    distances[edge.dest] = newDist;
                    pq.offer(new int[]{edge.dest, newDist});
                }
            }
        }

        return distances;
    }

    /**
     * Prim's algorithm for Minimum Spanning Tree (MST).
     * 
     * Finds a minimum spanning tree for a weighted undirected graph.
     * 
     * Time Complexity: O((V + E) log V)
     * Space Complexity: O(V)
     * 
     * @param graph the weighted graph
     * @return total weight of the MST
     */
    public static int primMST(WeightedGraph graph) {
        int vertices = graph.getVertices();
        boolean[] inMST = new boolean[vertices];
        int[] key = new int[vertices];
        Arrays.fill(key, Integer.MAX_VALUE);
        key[0] = 0;

        PriorityQueue<int[]> pq = new PriorityQueue<>(Comparator.comparingInt(a -> a[1]));
        pq.offer(new int[]{0, 0});

        int totalWeight = 0;

        while (!pq.isEmpty()) {
            int[] current = pq.poll();
            int vertex = current[0];

            if (inMST[vertex]) {
                continue;
            }

            inMST[vertex] = true;
            totalWeight += current[1];

            for (WeightedGraph.Edge edge : graph.getNeighbors(vertex)) {
                if (!inMST[edge.dest] && edge.weight < key[edge.dest]) {
                    key[edge.dest] = edge.weight;
                    pq.offer(new int[]{edge.dest, edge.weight});
                }
            }
        }

        return totalWeight;
    }

    /**
     * Floyd-Warshall algorithm for all-pairs shortest paths.
     * 
     * Finds shortest paths between all pairs of vertices.
     * 
     * Time Complexity: O(V³)
     * Space Complexity: O(V²)
     * 
     * @param adjMatrix adjacency matrix representation (use Integer.MAX_VALUE/2 for infinity)
     * @return matrix of shortest distances between all pairs
     */
    public static int[][] floydWarshall(int[][] adjMatrix) {
        int n = adjMatrix.length;
        int[][] dist = new int[n][n];

        // Initialize distances
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                dist[i][j] = adjMatrix[i][j];
            }
        }

        // Floyd-Warshall algorithm
        for (int k = 0; k < n; k++) {
            for (int i = 0; i < n; i++) {
                for (int j = 0; j < n; j++) {
                    if (dist[i][k] != Integer.MAX_VALUE / 2 && 
                        dist[k][j] != Integer.MAX_VALUE / 2 &&
                        dist[i][k] + dist[k][j] < dist[i][j]) {
                        dist[i][j] = dist[i][k] + dist[k][j];
                    }
                }
            }
        }

        return dist;
    }

    /**
     * Check if a graph is connected using BFS.
     * 
     * Time Complexity: O(V + E)
     * Space Complexity: O(V)
     * 
     * @param graph the graph to check
     * @return true if the graph is connected, false otherwise
     */
    public static boolean isConnected(WeightedGraph graph) {
        boolean[] visited = new boolean[graph.getVertices()];
        Queue<Integer> queue = new LinkedList<>();
        
        queue.offer(0);
        visited[0] = true;
        int visitedCount = 1;

        while (!queue.isEmpty()) {
            int vertex = queue.poll();

            for (WeightedGraph.Edge edge : graph.getNeighbors(vertex)) {
                if (!visited[edge.dest]) {
                    visited[edge.dest] = true;
                    queue.offer(edge.dest);
                    visitedCount++;
                }
            }
        }

        return visitedCount == graph.getVertices();
    }

    /**
     * Example usage and testing.
     */
    public static void main(String[] args) {
        System.out.println("=== Network Algorithms Demo ===\n");

        // Create a weighted graph for Dijkstra's algorithm
        //     0 --4-- 1
        //     |  \    |
        //     2   3   1
        //     |    \  |
        //     3 --2-- 2
        WeightedGraph graph = new WeightedGraph(4);
        graph.addUndirectedEdge(0, 1, 4);
        graph.addUndirectedEdge(0, 2, 2);
        graph.addUndirectedEdge(0, 3, 3);
        graph.addUndirectedEdge(1, 2, 1);
        graph.addUndirectedEdge(2, 3, 2);

        System.out.println("Dijkstra's shortest paths from vertex 0:");
        int[] distances = dijkstra(graph, 0);
        for (int i = 0; i < distances.length; i++) {
            System.out.println("  Distance to vertex " + i + ": " + distances[i]);
        }

        System.out.println("\nMinimum Spanning Tree weight:");
        System.out.println("  Total weight: " + primMST(graph));

        System.out.println("\nIs graph connected: " + isConnected(graph));

        // Floyd-Warshall example
        System.out.println("\nFloyd-Warshall All-Pairs Shortest Paths:");
        int INF = Integer.MAX_VALUE / 2;
        int[][] adjMatrix = {
            {0, 4, INF, 3},
            {4, 0, 1, INF},
            {INF, 1, 0, 2},
            {3, INF, 2, 0}
        };
        int[][] allPairsDistances = floydWarshall(adjMatrix);
        
        System.out.println("  Distance matrix:");
        for (int i = 0; i < allPairsDistances.length; i++) {
            System.out.print("  ");
            for (int j = 0; j < allPairsDistances[i].length; j++) {
                if (allPairsDistances[i][j] == INF) {
                    System.out.print("INF ");
                } else {
                    System.out.printf("%3d ", allPairsDistances[i][j]);
                }
            }
            System.out.println();
        }
    }
}
