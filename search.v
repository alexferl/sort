module sort

// search uses binary search to find and return the smallest index i
// in [0, n) at which f(i) is true, assuming that on the range [0, n),
// f(i) == true implies f(i+1) == true. That is, search requires that
// f is false for some (possibly empty) prefix of the input range [0, n)
// and then true for the (possibly empty) remainder; search returns
// the first true index. If there is no such index, search returns n.
// search calls f(i) only for i in the range [0, n).
//
// A common use of search is to find the index i for a value x in
// a sorted, index-able data structure such as an array or slice.
// In this case, the argument f, typically a closure, captures the value
// to be searched for, and how the data structure is indexed and
// ordered.
//
// For instance, given a slice data sorted in ascending order,
// the call search(data.len, fn(i int) bool { return data[i] >= 23 })
// returns the smallest index i such that data[i] >= 23. If the caller
// wants to find whether 23 is in the slice, it must test data[i] == 23
// separately.
//
// Searching data sorted in descending order would use the <=
// operator instead of the >= operator.
//
// To complete the example above, the following code tries to find the value
// x in an integer slice data sorted in ascending order:
//
//	x := 23
//	i := search(data.len, fn(i int) bool { return data[i] >= x })
//	if i < data.len && data[i] == x {
//		// x is present at data[i]
//	} else {
//		// x is not present in data,
//		// but i is the index where it would be inserted.
//	}
//
// As a more whimsical example, this program guesses your number:
//
//  fn guessing_game() {
//      println("Pick an integer from 0 to 100.")
//      answer := search(100, fn(i int) bool {
// 	        mut r := readline.Readline{}
// 	        r.enable_raw_mode()
// 	        defer {
// 		        r.disable_raw_mode()
// 	        }
// 	        s := r.read_line("Is your number <= ${i}? ") or { panic(err) }
// 	        return s != "" && s.starts_with('y')
//      })
//      println("Your number is ${answer}.")
//  }
pub fn search(n int, f fn (int) bool) int {
	// Define f(-1) == false and f(n) == true.
	// Invariant: f(i-1) == false, f(j) == true.
	mut i, mut j := 0, n
	for i < j {
		h := int(u32(i + j) >> 1) // avoid overflow when computing h
		// i ≤ h < j
		if !f(h) {
			i = h + 1 // preserves f(i-1) == false
		} else {
			j = h // preserves f(j) == true
		}
	}
	// i == j, f(i-1) == false, and f(j) (= f(i)) == true  =>  answer is i.
	return i
}

// find uses binary search to find and return the smallest index i in [0, n)
// at which cmp(i) <= 0. If there is no such index i, find returns i = n.
// The found result is true if i < n and cmp(i) == 0.
// find calls cmp(i) only for i in the range [0, n).
//
// To permit binary search, find requires that cmp(i) > 0 for a leading
// prefix of the range, cmp(i) == 0 in the middle, and cmp(i) < 0 for
// the final suffix of the range. (Each sub-range could be empty.)
// The usual way to establish this condition is to interpret cmp(i)
// as a comparison of a desired target value t against entry i in an
// underlying indexed data structure x, returning <0, 0, and >0
// when t < x[i], t == x[i], and t > x[i], respectively.
//
// For example, to look for a particular string in a sorted, random-access
// list of strings:
//
//	i, found := find(x.len, fn(i int) int {
//	    return compare_strings(target, x[i]))
//	})
//	if found {
//      println("found ${target} at entry ${i}")
//	} else {
//      println("${target} not found, would insert at ${i}")
//	}
pub fn find(n int, cmp fn (int) int) (int, bool) {
	// The invariants here are similar to the ones in search.
	// Define cmp(-1) > 0 and cmp(n) <= 0
	// Invariant: cmp(i-1) > 0, cmp(j) <= 0
	mut i, mut j := 0, n
	for i < j {
		h := int(u32(i + j) >> 1) // avoid overflow when computing h
		// i ≤ h < j
		if cmp(h) > 0 {
			i = h + 1 // preserves cmp(i-1) > 0
		} else {
			j = h // preserves cmp(j) <= 0
		}
	}
	// i == j, cmp(i-1) > 0 and cmp(j) <= 0
	return i, i < n && cmp(i) == 0
}

// search_ints searches for x in a sorted slice of ints and returns the index
// as specified by search. The return value is the index to insert x if x is
// not present (it could be a.len).
// The slice must be sorted in ascending order.
pub fn search_ints(a []int, x int) int {
	return search(a.len, fn [a, x] (i int) bool {
		return a[i] >= x
	})
}

// search_f64s searches for x in a sorted slice of float64s and returns the index
// as specified by search. The return value is the index to insert x if x is not
// present (it could be a.len).
// The slice must be sorted in ascending order.
pub fn search_f64s(a []f64, x f64) int {
	return search(a.len, fn [a, x] (i int) bool {
		return a[i] >= x
	})
}

// search_strings searches for x in a sorted slice of strings and returns the index
// as specified by search. The return value is the index to insert x if x is not
// present (it could be a.len).
// The slice must be sorted in ascending order.
pub fn search_strings(a []string, x string) int {
	return search(a.len, fn [a, x] (i int) bool {
		return a[i] >= x
	})
}

// search returns the result of applying search_ints to the receiver and x.
pub fn (p IntSlice) search(x int) int {
	return search_ints(p, x)
}

// search returns the result of applying search_f64s to the receiver and x.
pub fn (p F64Slice) search(x f64) int {
	return search_f64s(p, x)
}

// search returns the result of applying search_strings to the receiver and x.
pub fn (p StringSlice) search(x string) int {
	return search_strings(p, x)
}
