public class SearchingAlgorithms {

    public static int linearSearch(int[] arr, int target) {
        for (int i = 0; i < arr.length; i++) {
            if (arr[i] == target) {
                return i;
            }
        }
        return -1;  // Target not found
    }

    public static int binarySearch(int[] arr, int target) {
        int left = 0, right = arr.length - 1;
        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (arr[mid] == target) {
                return mid;
            } else if (arr[mid] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
        return -1;  // Target not found
    }

    public static int binarySearchRecursive(int[] arr, int left, int right, int target) {
        if (left > right) {
            return -1;
        }
        int mid = left + (right - left) / 2;
        if (arr[mid] == target) {
            return mid;
        }
        return arr[mid] > target ? 
               binarySearchRecursive(arr, left, mid - 1, target) :
               binarySearchRecursive(arr, mid + 1, right, target);
    }

    public static int findMin(int[] nums) {
        if (nums.length == 1) {
            return nums[0];
        }
        int left = 0, right = nums.length - 1;
        while (left < right) {
            int mid = left + (right - left) / 2;
            if (mid > 0 && nums[mid] < nums[mid - 1]) {
                return nums[mid];
            }
            if (nums[left] <= nums[mid] && nums[mid] > nums[right]) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
        return nums[left];
    }

    public static int searchInsertPosition(int[] nums, int target) {
        int left = 0, right = nums.length - 1;
        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] == target) {
                return mid;
            }
            if (nums[mid] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
        return left;  // Target should be inserted at "left" index
    }

    public static void main(String[] args) {
        int[] sampleArray = {2, 5, 8, 12, 16, 23, 38, 56, 72, 91};
        int target = 23;

        System.out.println("Linear Search - Index of " + target + ": " + linearSearch(sampleArray, target));
        System.out.println("Binary Search - Index of " + target + ": " + binarySearch(sampleArray, target));
        System.out.println("Binary Search Recursive - Index of " + target + ": " + binarySearchRecursive(sampleArray, 0, sampleArray.length - 1, target));

        int[] rotatedArray = {16, 23, 38, 56, 72, 91, 2, 5, 8, 12};
        System.out.println("Minimum in Rotated Sorted Array: " + findMin(rotatedArray));

        int insertTarget = 25;
        System.out.println("Search Insert Position for " + insertTarget + ": " + searchInsertPosition(sampleArray, insertTarget));
    }
}
