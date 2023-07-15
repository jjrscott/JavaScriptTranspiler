// BinarySearch.js

func binary_search_recursive<T: Comparable>(_ a: [T], _ value: T, _ lo: Int, _ hi: Int) -> Int? {
    if hi < lo {
        return nil
    }
    var mid : Int = Math.floor(lo + hi / 2)
    if a[mid] > value {
        return binary_search_recursive(a, value, lo, mid - 1)
    }
    if a[mid] < value {
        return binary_search_recursive(a, value, mid + 1, hi)
    }
    return mid
}
