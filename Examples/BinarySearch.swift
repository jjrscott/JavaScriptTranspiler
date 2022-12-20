
// MARK: - BinarySearch.js

func binary_search_recursive(_ a: /* BinarySearch.js, binary_search_recursive, a */ Any, _ value: /* BinarySearch.js, binary_search_recursive, value */ Any, _ lo: /* BinarySearch.js, binary_search_recursive, lo */ Any, _ hi: /* BinarySearch.js, binary_search_recursive, hi */ Any)  {
	if hi < lo {
		return nil
	}
	var mid /* BinarySearch.js, binary_search_recursive, mid */ = Math.floor(lo + hi / 2)
	if a[mid] > value {
		return binary_search_recursive(a, value, lo, mid - 1)
	}
	if a[mid] < value {
		return binary_search_recursive(a, value, mid + 1, hi)
	}
	return mid
}
