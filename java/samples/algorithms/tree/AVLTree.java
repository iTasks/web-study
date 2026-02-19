package algorithms.tree;

/**
 * AVL Tree implementation - a self-balancing binary search tree.
 * 
 * In an AVL tree, the heights of the two child subtrees of any node differ by at most one.
 * If at any time they differ by more than one, rebalancing is done to restore this property.
 * 
 * Operations (all O(log n)):
 * - Insert: Add a new node and rebalance if necessary
 * - Delete: Remove a node and rebalance if necessary
 * - Search: Find a node by value
 * 
 * Time Complexity: O(log n) for insert, delete, and search
 * Space Complexity: O(n) for storing n nodes
 */
public class AVLTree {

    private AVLNode root;

    /**
     * AVL tree node with height information.
     */
    private static class AVLNode {
        int val;
        int height;
        AVLNode left;
        AVLNode right;

        AVLNode(int val) {
            this.val = val;
            this.height = 1;
        }
    }

    /**
     * Get height of a node.
     */
    private int height(AVLNode node) {
        return node == null ? 0 : node.height;
    }

    /**
     * Get balance factor of a node.
     * Balance Factor = Height(Left) - Height(Right)
     */
    private int getBalance(AVLNode node) {
        return node == null ? 0 : height(node.left) - height(node.right);
    }

    /**
     * Update height of a node based on its children.
     */
    private void updateHeight(AVLNode node) {
        if (node != null) {
            node.height = Math.max(height(node.left), height(node.right)) + 1;
        }
    }

    /**
     * Right rotation.
     * 
     *       y                x
     *      / \              / \
     *     x   T3   ==>     T1  y
     *    / \                  / \
     *   T1  T2               T2  T3
     */
    private AVLNode rotateRight(AVLNode y) {
        AVLNode x = y.left;
        AVLNode T2 = x.right;

        // Perform rotation
        x.right = y;
        y.left = T2;

        // Update heights
        updateHeight(y);
        updateHeight(x);

        return x;
    }

    /**
     * Left rotation.
     * 
     *     x                y
     *    / \              / \
     *   T1  y    ==>     x   T3
     *      / \          / \
     *     T2  T3       T1  T2
     */
    private AVLNode rotateLeft(AVLNode x) {
        AVLNode y = x.right;
        AVLNode T2 = y.left;

        // Perform rotation
        y.left = x;
        x.right = T2;

        // Update heights
        updateHeight(x);
        updateHeight(y);

        return y;
    }

    /**
     * Insert a value into the AVL tree.
     */
    public void insert(int val) {
        root = insertNode(root, val);
    }

    /**
     * Recursive insert helper with rebalancing.
     */
    private AVLNode insertNode(AVLNode node, int val) {
        // 1. Perform normal BST insertion
        if (node == null) {
            return new AVLNode(val);
        }

        if (val < node.val) {
            node.left = insertNode(node.left, val);
        } else if (val > node.val) {
            node.right = insertNode(node.right, val);
        } else {
            // Duplicate values not allowed
            return node;
        }

        // 2. Update height of this ancestor node
        updateHeight(node);

        // 3. Get the balance factor
        int balance = getBalance(node);

        // 4. If node becomes unbalanced, there are 4 cases:

        // Left-Left Case
        if (balance > 1 && val < node.left.val) {
            return rotateRight(node);
        }

        // Right-Right Case
        if (balance < -1 && val > node.right.val) {
            return rotateLeft(node);
        }

        // Left-Right Case
        if (balance > 1 && val > node.left.val) {
            node.left = rotateLeft(node.left);
            return rotateRight(node);
        }

        // Right-Left Case
        if (balance < -1 && val < node.right.val) {
            node.right = rotateRight(node.right);
            return rotateLeft(node);
        }

        return node;
    }

    /**
     * Search for a value in the AVL tree.
     */
    public boolean search(int val) {
        return searchNode(root, val);
    }

    private boolean searchNode(AVLNode node, int val) {
        if (node == null) {
            return false;
        }

        if (val == node.val) {
            return true;
        } else if (val < node.val) {
            return searchNode(node.left, val);
        } else {
            return searchNode(node.right, val);
        }
    }

    /**
     * Delete a value from the AVL tree.
     */
    public void delete(int val) {
        root = deleteNode(root, val);
    }

    /**
     * Recursive delete helper with rebalancing.
     */
    private AVLNode deleteNode(AVLNode node, int val) {
        // 1. Perform standard BST delete
        if (node == null) {
            return null;
        }

        if (val < node.val) {
            node.left = deleteNode(node.left, val);
        } else if (val > node.val) {
            node.right = deleteNode(node.right, val);
        } else {
            // Node to be deleted found

            // Node with only one child or no child
            if (node.left == null || node.right == null) {
                node = (node.left != null) ? node.left : node.right;
            } else {
                // Node with two children: Get inorder successor
                AVLNode temp = getMinNode(node.right);
                node.val = temp.val;
                node.right = deleteNode(node.right, temp.val);
            }
        }

        // If the tree had only one node then return
        if (node == null) {
            return null;
        }

        // 2. Update height
        updateHeight(node);

        // 3. Get balance factor
        int balance = getBalance(node);

        // 4. If node becomes unbalanced, there are 4 cases:

        // Left-Left Case
        if (balance > 1 && getBalance(node.left) >= 0) {
            return rotateRight(node);
        }

        // Left-Right Case
        if (balance > 1 && getBalance(node.left) < 0) {
            node.left = rotateLeft(node.left);
            return rotateRight(node);
        }

        // Right-Right Case
        if (balance < -1 && getBalance(node.right) <= 0) {
            return rotateLeft(node);
        }

        // Right-Left Case
        if (balance < -1 && getBalance(node.right) > 0) {
            node.right = rotateRight(node.right);
            return rotateLeft(node);
        }

        return node;
    }

    /**
     * Get the node with minimum value.
     */
    private AVLNode getMinNode(AVLNode node) {
        while (node.left != null) {
            node = node.left;
        }
        return node;
    }

    /**
     * In-order traversal (sorted order).
     */
    public void inorder() {
        inorderTraversal(root);
        System.out.println();
    }

    private void inorderTraversal(AVLNode node) {
        if (node != null) {
            inorderTraversal(node.left);
            System.out.print(node.val + " ");
            inorderTraversal(node.right);
        }
    }

    /**
     * Get the height of the tree.
     */
    public int getHeight() {
        return height(root);
    }

    /**
     * Example usage and testing.
     */
    public static void main(String[] args) {
        AVLTree tree = new AVLTree();

        System.out.println("Inserting values: 10, 20, 30, 40, 50, 25");
        tree.insert(10);
        tree.insert(20);
        tree.insert(30);
        tree.insert(40);
        tree.insert(50);
        tree.insert(25);

        System.out.print("In-order traversal: ");
        tree.inorder();

        System.out.println("Tree height: " + tree.getHeight());

        System.out.println("\nSearching for 30: " + tree.search(30));
        System.out.println("Searching for 100: " + tree.search(100));

        System.out.println("\nDeleting 40");
        tree.delete(40);
        System.out.print("In-order traversal after deletion: ");
        tree.inorder();

        System.out.println("Tree height after deletion: " + tree.getHeight());
    }
}
