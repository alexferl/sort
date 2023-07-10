module sort

// insertion_sort sorts data[a:b] using insertion
fn insertion_sort(mut data Interface, a int, b int) {
	for i := a + 1; i < b; i++ {
		for j := i; j > a && data.less(j, j - 1); j-- {
			data.swap(j, j - 1)
		}
	}
}

// sift_down implements the heap property on data[lo:hi].
// first is an offset into the array where the root of the heap lies.
fn sift_down(mut data Interface, lo int, hi int, first int) {
	mut root := lo
	for {
		mut child := 2 * root + 1
		if child >= hi {
			break
		}
		if child + 1 < hi && data.less(first + child, first + child + 1) {
			child++
		}
		if !data.less(first + root, first + child) {
			return
		}
		data.swap(first + root, first + child)
		root = child
	}
}

fn heap_sort(mut data Interface, a int, b int) {
	first := a
	lo := 0
	hi := b - a

	// Build heap with greatest element at top.
	for i := (hi - 1) / 2; i >= 0; i-- {
		sift_down(mut data, i, hi, first)
	}

	// Pop elements, largest first, into end of data.
	for i := hi - 1; i >= 0; i-- {
		data.swap(first, first + i)
		sift_down(mut data, lo, i, first)
	}
}

fn pdqsort(mut data Interface, a int, b int, limit int) {
	mut mut_a := a
	mut mut_b := b
	mut mut_limit := limit
	max_insertion := 12

	mut was_balanced := true // whether the last partitioning was reasonably balanced
	mut was_partitioned := true // whether the slice was already partitioned

	for {
		length := mut_b - mut_a

		if length <= max_insertion {
			insertion_sort(mut data, mut_a, mut_b)
			return
		}

		// Fall back to heapsort if too many bad choices were made.
		if mut_limit == 0 {
			heap_sort(mut data, mut_a, mut_b)
			return
		}

		// If the last partitioning was imbalanced, we need to breaking patterns.
		if !was_balanced {
			break_patterns(mut data, mut_a, mut_b)
			mut_limit--
		}

		mut pivot, mut hint := choose_pivot(data, mut_a, mut_b)
		if hint == SortedInt.decreasing_hint {
			reverse_range(mut data, mut_a, mut_b)
			// The chosen pivot was pivot-a elements after the start of the array.
			// After reversing it is pivot-a elements before the end of the array.
			// The idea came from Rust's implementation.
			pivot = (mut_b - 1) - (pivot - mut_a)
			hint = SortedInt.increasing_hint
		}

		// The slice is likely already sorted.
		if was_balanced && was_partitioned && hint == SortedInt.increasing_hint {
			if partial_insertion_sort(mut data, mut_a, mut_b) {
				return
			}
		}

		// Probably the slice contains many duplicate elements, partition the slice into
		// elements equal to and elements greater than the pivot.
		if mut_a > 0 && !data.less(mut_a - 1, pivot) {
			mid := partition_equal(mut data, mut_a, mut_b, pivot)
			mut_a = mid
			continue
		}

		mid, already_partitioned := partition(mut data, mut_a, mut_b, pivot)
		was_partitioned = already_partitioned

		left_len, right_len := mid - mut_a, mut_b - mid
		balance_threshold := length / 8
		if left_len < right_len {
			was_balanced = left_len >= balance_threshold
			pdqsort(mut data, mut_a, mid, mut_limit)
			mut_a = mid + 1
		} else {
			was_balanced = right_len >= balance_threshold
			pdqsort(mut data, mid + 1, mut_b, mut_limit)
			mut_b = mid
		}
	}
}

// partition does one quicksort partition.
// Let p = data[pivot]
// Moves elements in data[a:b] around, so that data[i]<p and data[j]>=p for i<newpivot and j>newpivot.
// On return, data[newpivot] = p
fn partition(mut data Interface, a int, b int, pivot int) (int, bool) {
	data.swap(a, pivot)
	mut i, mut j := a + 1, b - 1 // i and j are inclusive of the elements remaining to be partitioned

	for i <= j && data.less(i, a) {
		i++
	}
	for i <= j && !data.less(j, a) {
		j--
	}
	if i > j {
		data.swap(j, a)
		return j, true
	}
	data.swap(i, j)
	i++
	j--

	for {
		for i <= j && data.less(i, a) {
			i++
		}
		for i <= j && !data.less(j, a) {
			j--
		}
		if i > j {
			break
		}
		data.swap(i, j)
		i++
		j--
	}
	data.swap(j, a)
	return j, false
}

// partition_equal partitions data[a:b] into elements equal to data[pivot] followed by elements greater than data[pivot].
// It assumed that data[a:b] does not contain elements smaller than the data[pivot].
fn partition_equal(mut data Interface, a int, b int, pivot int) int {
	data.swap(a, pivot)
	mut i, mut j := a + 1, b - 1

	for {
		for i <= j && !data.less(a, i) {
			i++
		}
		for i <= j && data.less(a, j) {
			j--
		}
		if i > j {
			break
		}
		data.swap(i, j)
		i++
		j--
	}
	return i
}

// partial_insertion_sort partially sorts a slice, returns true if the slice is sorted at the end.
fn partial_insertion_sort(mut data Interface, a int, b int) bool {
	max_steps := 5 // maximum number of adjacent out-of-order pairs that will get shifted
	shortest_shifting := 50 // don't shift any elements on short arrays

	mut i := a + 1
	for j := 0; j < max_steps; j++ {
		for i < b && !data.less(i, i - 1) {
			i++
		}

		if i == b {
			return true
		}

		if b - a < shortest_shifting {
			return false
		}

		data.swap(i, i - 1)

		// Shift the smaller one to the left.
		if i - a >= 2 {
			for k := i - 1; k >= 1; k-- {
				if !data.less(k, k - 1) {
					break
				}
				data.swap(k, k - 1)
			}
		}
		// Shift the greater one to the right.
		if b - i >= 2 {
			for l := i + 1; l < b; l++ {
				if !data.less(l, l - 1) {
					break
				}
				data.swap(l, l - 1)
			}
		}
	}
	return false
}

// break_patterns scatters some elements around in an attempt to break some patterns
// that might cause imbalanced partitions in quick
fn break_patterns(mut data Interface, a int, b int) {
	length := b - a
	if length >= 8 {
		mut random := Xorshift(u64(length))
		modulus := next_power_of_two(length)

		for idx := a + (length / 4) * 2 - 1; idx <= a + (length / 4) * 2 + 1; idx++ {
			mut other := int(u64(random.next()) & (modulus - 1))
			if other >= length {
				other -= length
			}
			data.swap(idx, a + other)
		}
	}
}

// choose_pivot chooses a pivot in data[a:b].
//
// [0,8): chooses a static pivot.
// [8,shortest_ninther): uses the simple median-of-three method.
// [shortest_ninther,∞): uses the Tukey ninther method.
fn choose_pivot(data Interface, a int, b int) (int, SortedInt) {
	shortest_ninther := 50
	max_swaps := 4 * 3

	l := b - a

	swaps := 0
	mut i := a + l / 4 * 1
	mut j := a + l / 4 * 2
	mut k := a + l / 4 * 3

	if l >= 8 {
		if l >= shortest_ninther {
			i = median_adjacent(data, i, swaps)
			j = median_adjacent(data, j, swaps)
			k = median_adjacent(data, k, swaps)
		}
		// Find the median among i, j, k and stores it into j.
		j = median(data, i, j, k, swaps)
	}

	match swaps {
		0 {
			return j, SortedInt.increasing_hint
		}
		max_swaps {
			return j, SortedInt.decreasing_hint
		}
		else {
			return j, SortedInt.unknown_hint
		}
	}
}

// order2 returns x,y where data[x] <= data[y], where x,y=a,b or x,y=b,a.
fn order2(data Interface, a int, b int, swaps int) (int, int) {
	if data.less(b, a) {
		unsafe { swaps++ }
		return b, a
	}
	return a, b
}

// median returns x where data[x] is the median of data[a],data[b],data[c], where x is a, b, or c.
fn median(data Interface, a int, b int, c int, swaps int) int {
	mut mut_a := a
	mut mut_b := b
	mut mut_c := c
	mut_a, mut_b = order2(data, mut_a, mut_b, swaps)
	mut_b, mut_c = order2(data, mut_b, mut_c, swaps)
	mut_a, mut_b = order2(data, mut_a, mut_b, swaps)
	return mut_b
}

// median_adjacent finds the median of data[a - 1], data[a], data[a + 1] and stores the index into a.
fn median_adjacent(data Interface, a int, swaps int) int {
	return median(data, a - 1, a, a + 1, swaps)
}

fn reverse_range(mut data Interface, a int, b int) {
	mut i := a
	mut j := b - 1
	for i < j {
		data.swap(i, j)
		i++
		j--
	}
}

fn swap_range(mut data Interface, a int, b int, n int) {
	for i := 0; i < n; i++ {
		data.swap(a + i, b + i)
	}
}

fn stable_(mut data Interface, n int) {
	mut block_size := 20 // must be > 0
	mut a, mut b := 0, block_size
	for b <= n {
		insertion_sort(mut data, a, b)
		a = b
		b += block_size
	}
	insertion_sort(mut data, a, n)

	for block_size < n {
		a, b = 0, 2 * block_size
		for b <= n {
			sym_merge(mut data, a, a + block_size, b)
			a = b
			b += 2 * block_size
		}
		m := a + block_size
		if m < n {
			sym_merge(mut data, a, m, n)
		}
		block_size *= 2
	}
}

// sym_merge merges the two sorted subsequences data[a:m] and data[m:b] using
// the SymMerge algorithm from Pok-Son Kim and Arne Kutzner, "Stable Minimum
// Storage Merging by Symmetric Comparisons", in Susanne Albers and Tomasz
// Radzik, editors, Algorithms - ESA 2004, volume 3221 of Lecture Notes in
// Computer Science, pages 714-723. Springer, 2004.
//
// Let M = m-a and N = b-n. Wolog M < N.
// The recursion depth is bound by ceil(log(N+M)).
// The algorithm needs O(M*log(N/M + 1)) calls to data.Less.
// The algorithm needs O((M+N)*log(M)) calls to data.Swap.
//
// The paper gives O((M+N)*log(M)) as the number of assignments assuming a
// rotation algorithm which uses O(M+N+gcd(M+N)) assignments. The argumentation
// in the paper carries through for Swap operations, especially as the block
// swapping rotate uses only O(M+N) Swaps.
//
// sym_merge assumes non-degenerate arguments: a < m && m < b.
// Having the caller check this condition eliminates many leaf recursion calls,
// which improves performance.
fn sym_merge(mut data Interface, a int, m int, b int) {
	// Avoid unnecessary recursions of sym_merge
	// by direct insertion of data[a] into data[m:b]
	// if data[a:m] only contains one element.
	if m - a == 1 {
		// Use binary search to find the lowest index i
		// such that data[i] >= data[a] for m <= i < b.
		// Exit the search loop with i == b in case no such index exists.
		mut i := m
		mut j := b
		for i < j {
			h := int(u32(i + j) >> 1)
			if data.less(h, a) {
				i = h + 1
			} else {
				j = h
			}
		}
		// Swap values until data[a] reaches the position before i.
		for k := a; k < i - 1; k++ {
			data.swap(k, k + 1)
		}
		return
	}

	// Avoid unnecessary recursions of sym_merge
	// by direct insertion of data[m] into data[a:m]
	// if data[m:b] only contains one element.
	if b - m == 1 {
		// Use binary search to find the lowest index i
		// such that data[i] > data[m] for a <= i < m.
		// Exit the search loop with i == m in case no such index exists.
		mut i := a
		mut j := m
		for i < j {
			h := int(u32(i + j) >> 1)
			if !data.less(m, h) {
				i = h + 1
			} else {
				j = h
			}
		}
		// Swap values until data[m] reaches the position i.
		for k := m; k > i; k-- {
			data.swap(k, k - 1)
		}
		return
	}
	mid := int(u32(a + b) >> 1)
	n := mid + m
	mut start := 0
	mut r := 0
	if m > mid {
		start = n - b
		r = mid
	} else {
		start = a
		r = m
	}
	p := n - 1

	for start < r {
		c := int(u32(start + r) >> 1)
		if !data.less(p - c, c) {
			start = c + 1
		} else {
			r = c
		}
	}

	end := n - start
	if start < m && m < end {
		rotate(mut data, start, m, end)
	}
	if a < start && start < mid {
		sym_merge(mut data, a, start, mid)
	}
	if mid < end && end < b {
		sym_merge(mut data, mid, end, b)
	}
}

// rotate rotates two consecutive blocks u = data[a:m] and v = data[m:b] in data:
// Data of the form 'x u v y' is changed to 'x v u y'.
// rotate performs at most b-a many calls to data.swap,
// and it assumes non-degenerate arguments: a < m && m < b.
fn rotate(mut data Interface, a int, m int, b int) {
	mut i := m - a
	mut j := b - m

	for i != j {
		if i > j {
			swap_range(mut data, m - i, m, j)
			i -= j
		} else {
			swap_range(mut data, m - i, m + j - i, i)
			j -= i
		}
	}
	// i == j
	swap_range(mut data, m - i, m, i)
}
