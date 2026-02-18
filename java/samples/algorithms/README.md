# Java Algorithms

[← Back to Java Samples](../README.md)

## Overview

This directory contains implementations of various algorithms and data structures in Java, organized by category:

- **Tree Algorithms**: Binary trees, balanced trees, AVL trees
- **Graph Algorithms**: BFS, DFS, shortest path, cycle detection
- **Network Algorithms**: Dijkstra's algorithm, MST, Floyd-Warshall

## Directory Structure

```
algorithms/
├── README.md                           # This file
├── tree/                               # Tree data structures and algorithms
│   ├── BALANCED_BINARY_TREE.md        # Comprehensive guide on balanced binary trees
│   ├── TreeNode.java                  # Basic tree node structure
│   ├── BalancedBinaryTree.java        # Check if a binary tree is balanced
│   └── AVLTree.java                   # Self-balancing AVL tree implementation
├── graph/                              # Graph algorithms
│   └── GraphAlgorithms.java           # BFS, DFS, cycle detection, shortest path
└── network/                            # Network algorithms
    └── NetworkAlgorithms.java         # Dijkstra, MST, Floyd-Warshall
```

## Tree Algorithms

### Balanced Binary Tree

A balanced binary tree is a tree where the height difference between left and right subtrees of every node is at most 1. This ensures O(log n) time complexity for search, insert, and delete operations.

**Key Features:**
- Check if a binary tree is balanced
- Calculate balance factor for any node
- Understand the importance of tree balancing

See [BALANCED_BINARY_TREE.md](tree/BALANCED_BINARY_TREE.md) for detailed documentation.

**Run Example:**
```bash
cd java/samples
javac algorithms/tree/BalancedBinaryTree.java algorithms/tree/TreeNode.java
java algorithms.tree.BalancedBinaryTree
```

### AVL Tree

AVL tree is a self-balancing binary search tree where the heights of two child subtrees differ by at most one.

**Operations (all O(log n)):**
- Insert with automatic rebalancing
- Delete with automatic rebalancing
- Search

**Rotations:**
- Left rotation
- Right rotation
- Left-Right rotation
- Right-Left rotation

**Run Example:**
```bash
cd java/samples
javac algorithms/tree/AVLTree.java
java algorithms.tree.AVLTree
```

## Graph Algorithms

Graph algorithms for traversal, pathfinding, and cycle detection.

**Implemented Algorithms:**
- **BFS (Breadth-First Search)**: Level-order traversal, O(V+E)
- **DFS (Depth-First Search)**: Depth-first traversal, O(V+E)
- **Shortest Path**: BFS-based path finding for unweighted graphs, O(V+E)
- **Cycle Detection**: Detect cycles in directed graphs, O(V+E)

**Run Example:**
```bash
cd java/samples
javac algorithms/graph/GraphAlgorithms.java
java algorithms.graph.GraphAlgorithms
```

## Network Algorithms

Advanced graph algorithms for weighted networks.

**Implemented Algorithms:**
- **Dijkstra's Algorithm**: Single-source shortest path, O((V+E) log V)
- **Prim's Algorithm**: Minimum spanning tree, O((V+E) log V)
- **Floyd-Warshall**: All-pairs shortest path, O(V³)
- **Connectivity Check**: Check if graph is connected, O(V+E)

**Run Example:**
```bash
cd java/samples
javac algorithms/network/NetworkAlgorithms.java
java algorithms.network.NetworkAlgorithms
```

## Complexity Reference

| Algorithm | Time Complexity | Space Complexity |
|-----------|----------------|------------------|
| Balanced Tree Check | O(n) | O(h) |
| AVL Insert | O(log n) | O(log n) |
| AVL Delete | O(log n) | O(log n) |
| AVL Search | O(log n) | O(log n) |
| BFS | O(V + E) | O(V) |
| DFS | O(V + E) | O(V) |
| Dijkstra | O((V+E) log V) | O(V) |
| Prim's MST | O((V+E) log V) | O(V) |
| Floyd-Warshall | O(V³) | O(V²) |

Where:
- n = number of nodes in tree
- h = height of tree
- V = number of vertices
- E = number of edges

## Compilation and Execution

### Compile All Files
```bash
cd java/samples
javac algorithms/tree/*.java
javac algorithms/graph/*.java
javac algorithms/network/*.java
```

### Run Individual Examples
```bash
# Balanced Binary Tree
java algorithms.tree.BalancedBinaryTree

# AVL Tree
java algorithms.tree.AVLTree

# Graph Algorithms
java algorithms.graph.GraphAlgorithms

# Network Algorithms
java algorithms.network.NetworkAlgorithms
```

## Learning Path

1. **Start with Tree Basics**: Understand TreeNode and BalancedBinaryTree
2. **Learn Self-Balancing**: Study AVL tree rotations and balancing
3. **Graph Traversal**: Master BFS and DFS algorithms
4. **Advanced Graphs**: Explore Dijkstra and MST algorithms
5. **Network Optimization**: Study all-pairs shortest path problems

## Resources

- [Balanced Binary Tree Documentation](tree/BALANCED_BINARY_TREE.md)
- [GeeksforGeeks - Tree Data Structures](https://www.geeksforgeeks.org/tree-data-structure/)
- [Visualgo - Algorithm Visualizations](https://visualgo.net/)
- [Princeton Algorithms Course](https://algs4.cs.princeton.edu/)

## Contributing

When adding new algorithms:
1. Follow the existing package structure
2. Include comprehensive JavaDoc comments
3. Add example usage in main() method
4. Document time and space complexity
5. Update this README with new content
