# 🌳 Balanced Binary Tree

![Image](https://cdn.programiz.com/sites/tutorial2program/files/unbalanced-binary-tree.png)

![Image](https://www.researchgate.net/publication/338372783/figure/fig21/AS%3A963469125894162%401606720348383/Balanced-versus-unbalanced-binary-tree-a-balanced-and-b-unbalanced.png)

![Image](https://assets.leetcode.com/uploads/2020/10/06/balance_1.jpg)

![Image](https://deen3evddmddt.cloudfront.net/uploads/content-images/balanced-binary-tree-height.webp)

## 📌 Definition

A **Balanced Binary Tree** is a binary tree where the height difference between the left and right subtree of **every node** is at most **1**.

This difference is called the **balance factor**:

```
Balance Factor = Height(Left) - Height(Right)
```

For a balanced tree:

```
Balance Factor ∈ {-1, 0, +1}
```

---

## 🎯 Why Balanced Trees Matter?

If a binary tree becomes **skewed** (like a linked list), operations degrade:

| Operation | Balanced Tree | Unbalanced Tree |
| --------- | ------------- | --------------- |
| Search    | O(log n)      | O(n)            |
| Insert    | O(log n)      | O(n)            |
| Delete    | O(log n)      | O(n)            |

So balanced trees keep operations **efficient**.

---

## 📚 Types of Balanced Binary Trees

### 1️⃣ AVL Tree

AVL tree

* Strictly balanced
* Performs rotations after insert/delete
* Faster lookups

### 2️⃣ Red-Black Tree

Red-Black tree

* Slightly relaxed balancing
* Used in many libraries (e.g., Java TreeMap, C++ map)

### 3️⃣ B-Tree (for databases)

B-tree

* Used in databases and file systems
* Optimized for disk reads

---

## 🧠 Example

Balanced:

```
        10
       /  \
      5    15
     / \     
    3   7
```

Unbalanced:

```
    10
      \
       15
         \
          20
```

---

## 🔁 How Balancing Happens (AVL Example)

If imbalance occurs after insertion:

* Left-Left → Right Rotation
* Right-Right → Left Rotation
* Left-Right → Left + Right Rotation
* Right-Left → Right + Left Rotation

---

## 💻 Example Check (Conceptual Algorithm)

```python
def isBalanced(root):
    def height(node):
        if not node:
            return 0
        left = height(node.left)
        right = height(node.right)
        if left == -1 or right == -1 or abs(left-right) > 1:
            return -1
        return max(left, right) + 1
    return height(root) != -1
```

Time Complexity: **O(n)**
Space Complexity: **O(h)** (height of tree)

---

## Java Implementation

See the following Java classes for implementation:
- `TreeNode.java` - Basic tree node structure
- `BalancedBinaryTree.java` - Check if a binary tree is balanced
- `AVLTree.java` - Self-balancing AVL tree implementation

---

## Additional Resources

* [Balanced Binary Tree on GeeksforGeeks](https://www.geeksforgeeks.org/balanced-binary-tree/)
* [AVL Tree on Wikipedia](https://en.wikipedia.org/wiki/AVL_tree)
* [Red-Black Tree on Wikipedia](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree)
