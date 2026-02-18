package algorithms.tree;

/**
 * Implementation to check if a binary tree is balanced.
 * 
 * A balanced binary tree is a tree where the height difference between
 * the left and right subtree of every node is at most 1.
 * 
 * Time Complexity: O(n) where n is the number of nodes
 * Space Complexity: O(h) where h is the height of the tree
 */
public class BalancedBinaryTree {

    /**
     * Check if a binary tree is balanced.
     * 
     * @param root the root of the binary tree
     * @return true if the tree is balanced, false otherwise
     */
    public static boolean isBalanced(TreeNode root) {
        return height(root) != -1;
    }

    /**
     * Calculate the height of a tree. Returns -1 if tree is unbalanced.
     * 
     * @param node current node
     * @return height of tree, or -1 if unbalanced
     */
    private static int height(TreeNode node) {
        if (node == null) {
            return 0;
        }

        int leftHeight = height(node.left);
        if (leftHeight == -1) {
            return -1; // Left subtree is unbalanced
        }

        int rightHeight = height(node.right);
        if (rightHeight == -1) {
            return -1; // Right subtree is unbalanced
        }

        // Check if current node is balanced
        if (Math.abs(leftHeight - rightHeight) > 1) {
            return -1; // Current node is unbalanced
        }

        // Return height of current subtree
        return Math.max(leftHeight, rightHeight) + 1;
    }

    /**
     * Calculate balance factor for a node.
     * Balance Factor = Height(Left) - Height(Right)
     * 
     * @param node the node to check
     * @return the balance factor
     */
    public static int getBalanceFactor(TreeNode node) {
        if (node == null) {
            return 0;
        }
        return getHeight(node.left) - getHeight(node.right);
    }

    /**
     * Get height of a tree (public version that doesn't check balance).
     * 
     * @param node current node
     * @return height of tree
     */
    private static int getHeight(TreeNode node) {
        if (node == null) {
            return 0;
        }
        return Math.max(getHeight(node.left), getHeight(node.right)) + 1;
    }

    /**
     * Example usage and testing.
     */
    public static void main(String[] args) {
        // Example 1: Balanced tree
        //       10
        //      /  \
        //     5    15
        //    / \
        //   3   7
        TreeNode root1 = new TreeNode(10);
        root1.left = new TreeNode(5);
        root1.right = new TreeNode(15);
        root1.left.left = new TreeNode(3);
        root1.left.right = new TreeNode(7);

        System.out.println("Example 1: Balanced tree");
        System.out.println("Is balanced: " + isBalanced(root1)); // true
        System.out.println("Balance factor of root: " + getBalanceFactor(root1)); // 1
        System.out.println();

        // Example 2: Unbalanced tree
        //    10
        //      \
        //       15
        //         \
        //          20
        TreeNode root2 = new TreeNode(10);
        root2.right = new TreeNode(15);
        root2.right.right = new TreeNode(20);

        System.out.println("Example 2: Unbalanced tree");
        System.out.println("Is balanced: " + isBalanced(root2)); // false
        System.out.println("Balance factor of root: " + getBalanceFactor(root2)); // -2
        System.out.println();

        // Example 3: Balanced single node
        TreeNode root3 = new TreeNode(42);

        System.out.println("Example 3: Single node");
        System.out.println("Is balanced: " + isBalanced(root3)); // true
        System.out.println("Balance factor of root: " + getBalanceFactor(root3)); // 0
        System.out.println();

        // Example 4: Balanced with more complex structure
        //         1
        //        / \
        //       2   3
        //      / \
        //     4   5
        //    /
        //   6
        TreeNode root4 = new TreeNode(1);
        root4.left = new TreeNode(2);
        root4.right = new TreeNode(3);
        root4.left.left = new TreeNode(4);
        root4.left.right = new TreeNode(5);
        root4.left.left.left = new TreeNode(6);

        System.out.println("Example 4: Complex tree");
        System.out.println("Is balanced: " + isBalanced(root4)); // false
        System.out.println("Balance factor of root: " + getBalanceFactor(root4)); // 2
    }
}
