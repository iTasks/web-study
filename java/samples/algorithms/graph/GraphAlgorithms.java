package algorithms.graph;

import java.util.*;

/**
 * Basic graph algorithms implementations.
 * 
 * This class provides implementations of fundamental graph algorithms including:
 * - Breadth-First Search (BFS)
 * - Depth-First Search (DFS)
 * - Cycle detection
 * - Path finding
 */
public class GraphAlgorithms {

    /**
     * Simple graph representation using adjacency list.
     */
    public static class Graph {
        private int vertices;
        private List<List<Integer>> adjList;

        public Graph(int vertices) {
            this.vertices = vertices;
            this.adjList = new ArrayList<>(vertices);
            for (int i = 0; i < vertices; i++) {
                adjList.add(new ArrayList<>());
            }
        }

        public void addEdge(int source, int dest) {
            adjList.get(source).add(dest);
        }

        public void addUndirectedEdge(int source, int dest) {
            adjList.get(source).add(dest);
            adjList.get(dest).add(source);
        }

        public List<Integer> getNeighbors(int vertex) {
            return adjList.get(vertex);
        }

        public int getVertices() {
            return vertices;
        }
    }

    /**
     * Breadth-First Search (BFS) traversal.
     * 
     * Time Complexity: O(V + E) where V is vertices and E is edges
     * Space Complexity: O(V)
     * 
     * @param graph the graph to traverse
     * @param start starting vertex
     * @return list of vertices in BFS order
     */
    public static List<Integer> bfs(Graph graph, int start) {
        List<Integer> result = new ArrayList<>();
        boolean[] visited = new boolean[graph.getVertices()];
        Queue<Integer> queue = new LinkedList<>();

        visited[start] = true;
        queue.offer(start);

        while (!queue.isEmpty()) {
            int vertex = queue.poll();
            result.add(vertex);

            for (int neighbor : graph.getNeighbors(vertex)) {
                if (!visited[neighbor]) {
                    visited[neighbor] = true;
                    queue.offer(neighbor);
                }
            }
        }

        return result;
    }

    /**
     * Depth-First Search (DFS) traversal.
     * 
     * Time Complexity: O(V + E)
     * Space Complexity: O(V)
     * 
     * @param graph the graph to traverse
     * @param start starting vertex
     * @return list of vertices in DFS order
     */
    public static List<Integer> dfs(Graph graph, int start) {
        List<Integer> result = new ArrayList<>();
        boolean[] visited = new boolean[graph.getVertices()];
        dfsHelper(graph, start, visited, result);
        return result;
    }

    private static void dfsHelper(Graph graph, int vertex, boolean[] visited, List<Integer> result) {
        visited[vertex] = true;
        result.add(vertex);

        for (int neighbor : graph.getNeighbors(vertex)) {
            if (!visited[neighbor]) {
                dfsHelper(graph, neighbor, visited, result);
            }
        }
    }

    /**
     * Check if the graph has a cycle (for directed graphs).
     * 
     * Time Complexity: O(V + E)
     * Space Complexity: O(V)
     * 
     * @param graph the graph to check
     * @return true if graph has a cycle, false otherwise
     */
    public static boolean hasCycle(Graph graph) {
        boolean[] visited = new boolean[graph.getVertices()];
        boolean[] recStack = new boolean[graph.getVertices()];

        for (int i = 0; i < graph.getVertices(); i++) {
            if (hasCycleHelper(graph, i, visited, recStack)) {
                return true;
            }
        }
        return false;
    }

    private static boolean hasCycleHelper(Graph graph, int vertex, boolean[] visited, boolean[] recStack) {
        if (recStack[vertex]) {
            return true; // Cycle detected
        }

        if (visited[vertex]) {
            return false;
        }

        visited[vertex] = true;
        recStack[vertex] = true;

        for (int neighbor : graph.getNeighbors(vertex)) {
            if (hasCycleHelper(graph, neighbor, visited, recStack)) {
                return true;
            }
        }

        recStack[vertex] = false;
        return false;
    }

    /**
     * Find shortest path between two vertices (BFS-based for unweighted graphs).
     * 
     * Time Complexity: O(V + E)
     * Space Complexity: O(V)
     * 
     * @param graph the graph
     * @param start start vertex
     * @param end end vertex
     * @return list representing the shortest path, or empty list if no path exists
     */
    public static List<Integer> findShortestPath(Graph graph, int start, int end) {
        if (start == end) {
            return Arrays.asList(start);
        }

        boolean[] visited = new boolean[graph.getVertices()];
        int[] parent = new int[graph.getVertices()];
        Arrays.fill(parent, -1);
        Queue<Integer> queue = new LinkedList<>();

        visited[start] = true;
        queue.offer(start);

        while (!queue.isEmpty()) {
            int vertex = queue.poll();

            for (int neighbor : graph.getNeighbors(vertex)) {
                if (!visited[neighbor]) {
                    visited[neighbor] = true;
                    parent[neighbor] = vertex;
                    queue.offer(neighbor);

                    if (neighbor == end) {
                        return reconstructPath(parent, start, end);
                    }
                }
            }
        }

        return new ArrayList<>(); // No path found
    }

    private static List<Integer> reconstructPath(int[] parent, int start, int end) {
        List<Integer> path = new ArrayList<>();
        for (int vertex = end; vertex != -1; vertex = parent[vertex]) {
            path.add(vertex);
        }
        Collections.reverse(path);
        return path;
    }

    /**
     * Example usage and testing.
     */
    public static void main(String[] args) {
        System.out.println("=== Graph Algorithms Demo ===\n");

        // Create a sample graph
        //     0 → 1 → 2
        //     ↓   ↓   ↓
        //     3 → 4   5
        Graph graph = new Graph(6);
        graph.addEdge(0, 1);
        graph.addEdge(0, 3);
        graph.addEdge(1, 2);
        graph.addEdge(1, 4);
        graph.addEdge(2, 5);
        graph.addEdge(3, 4);

        System.out.println("BFS starting from vertex 0:");
        System.out.println(bfs(graph, 0));

        System.out.println("\nDFS starting from vertex 0:");
        System.out.println(dfs(graph, 0));

        System.out.println("\nShortest path from 0 to 5:");
        System.out.println(findShortestPath(graph, 0, 5));

        System.out.println("\nHas cycle: " + hasCycle(graph));

        // Create a graph with a cycle
        Graph cyclicGraph = new Graph(4);
        cyclicGraph.addEdge(0, 1);
        cyclicGraph.addEdge(1, 2);
        cyclicGraph.addEdge(2, 3);
        cyclicGraph.addEdge(3, 1); // Creates a cycle

        System.out.println("\nCyclic graph has cycle: " + hasCycle(cyclicGraph));
    }
}
