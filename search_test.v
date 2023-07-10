module sort

import benchmark

fn f_(a []int, x int) fn (int) bool {
	return fn [a, x] (i int) bool {
		return a[i] >= x
	}
}

const data = [-10, -5, 0, 1, 2, 3, 5, 7, 11, 100, 100, 100, 1000, 10000]

struct SearchTest {
	name string
	n    int
	f    fn (int) bool
	i    int
}

const search_tests = [
	SearchTest{'empty', 0, unsafe { nil }, 0},
	SearchTest{'1 1', 1, fn (i int) bool {
		return i >= 1
	}, 1},
	SearchTest{'1 true', 1, fn (i int) bool {
		return true
	}, 0},
	SearchTest{'1 false', 1, fn (i int) bool {
		return false
	}, 1},
	SearchTest{'1000000000 991', 1000000000, fn (i int) bool {
		return i >= 991
	}, 991},
	SearchTest{'1000000000 true', 1000000000, fn (i int) bool {
		return true
	}, 0},
	SearchTest{'1000000000 false', 1000000000, fn (i int) bool {
		return false
	}, 1000000000},
	SearchTest{'data -20', data.len, f_(data, -20), 0},
	SearchTest{'data -10', data.len, f_(data, -10), 0},
	SearchTest{'data -9', data.len, f_(data, -9), 1},
	SearchTest{'data -6', data.len, f_(data, -6), 1},
	SearchTest{'data -5', data.len, f_(data, -5), 1},
	SearchTest{'data 3', data.len, f_(data, 3), 5},
	SearchTest{'data 11', data.len, f_(data, 11), 8},
	SearchTest{'data 99', data.len, f_(data, 99), 9},
	SearchTest{'data 100', data.len, f_(data, 100), 9},
	SearchTest{'data 101', data.len, f_(data, 101), 12},
	SearchTest{'data 10000', data.len, f_(data, 10000), 13},
	SearchTest{'data 10001', data.len, f_(data, 10001), 14},
	SearchTest{'descending a', 7, fn (i int) bool {
		return [99, 99, 59, 42, 7, 0, -1, -1][i] <= 7
	}, 4},
	SearchTest{'descending 7', 1000000000, fn (i int) bool {
		return 1000000000 - i <= 7
	}, 1000000000 - 7},
	SearchTest{'overflow', 2000000000, fn (i int) bool {
		return false
	}, 2000000000},
]

fn test_search() {
	for t in search_tests {
		i := search(t.n, t.f)
		assert i == t.i, '${t.name}: expected index ${t.i}; got ${i}'
	}
}

struct FindTest {
	data       []string
	target     string
	want_pos   int
	want_found bool
}

fn test_find() {
	str1 := ['foo']
	str2 := ['ab', 'ca']
	str3 := ['mo', 'qo', 'vo']
	str4 := ['ab', 'ad', 'ca', 'xy']

	// slice with repeating elements
	str_repeats := ['ba', 'ca', 'da', 'da', 'da', 'ka', 'ma', 'ma', 'ta']

	// slice with all element equal
	str_same := ['xx', 'xx', 'xx']

	find_tests := [
		FindTest{[]string{}, 'foo', 0, false},
		FindTest{[]string{}, '', 0, false},
		FindTest{str1, 'foo', 0, true},
		FindTest{str1, 'bar', 0, false},
		FindTest{str1, 'zx', 1, false},
		FindTest{str2, 'aa', 0, false},
		FindTest{str2, 'ab', 0, true},
		FindTest{str2, 'ad', 1, false},
		FindTest{str2, 'ca', 1, true},
		FindTest{str2, 'ra', 2, false},
		FindTest{str3, 'bb', 0, false},
		FindTest{str3, 'mo', 0, true},
		FindTest{str3, 'nb', 1, false},
		FindTest{str3, 'qo', 1, true},
		FindTest{str3, 'tr', 2, false},
		FindTest{str3, 'vo', 2, true},
		FindTest{str3, 'xr', 3, false},
		FindTest{str4, 'aa', 0, false},
		FindTest{str4, 'ab', 0, true},
		FindTest{str4, 'ac', 1, false},
		FindTest{str4, 'ad', 1, true},
		FindTest{str4, 'ax', 2, false},
		FindTest{str4, 'ca', 2, true},
		FindTest{str4, 'cc', 3, false},
		FindTest{str4, 'dd', 3, false},
		FindTest{str4, 'xy', 3, true},
		FindTest{str4, 'zz', 4, false},
		FindTest{str_repeats, 'da', 2, true},
		FindTest{str_repeats, 'db', 5, false},
		FindTest{str_repeats, 'ma', 6, true},
		FindTest{str_repeats, 'mb', 8, false},
		FindTest{str_same, 'xx', 0, true},
		FindTest{str_same, 'ab', 0, false},
		FindTest{str_same, 'zz', 3, false},
	]

	for t in find_tests {
		cmp := fn [t] (i int) int {
			return compare_strings(t.target, t.data[i])
		}

		pos, found := find(t.data.len, cmp)
		assert pos == t.want_pos || found == t.want_found
	}
}

// log2 computes the binary logarithm of x, rounded up to the next integer.
// (log2(0) == 0, log2(1) == 0, log2(2) == 1, log2(3) == 2, etc.)
fn log2(x int) int {
	mut n := 0
	for p := 1; p < x; p += p {
		// p == 2**n
		n++
	}
	// p/2 < x <= p == 2**n
	return n
}

fn test_search_efficiency() {
	mut n := 100
	mut step := 1
	for exp := 2; exp < 10; exp++ {
		// n == 10**exp
		// step == 10**(exp-2)
		max := log2(n)
		for x := 0; x < n; x += step {
			mut count := 0
			i := search(n, fn [mut count, x] (i int) bool {
				count++
				return i >= x
			})
			assert i == x, 'n = ${n}: expected index ${x}; got ${i}'
			assert count < max, 'n = ${n}, x = ${x}: expected <= ${max} calls; got ${count}'
		}
		n *= 10
		step *= 10
	}
}

const fdata = [-3.14, 0, 1, 2, 1000.7]

const sdata = ['f', 'foo', 'foobar', 'x']

struct SearchWrapperTest {
	name   string
	result int
	i      int
}

const search_wrapper_tests = [
	SearchWrapperTest{'search_ints', search_ints(data, 11), 8},
	SearchWrapperTest{'search_f64s', search_f64s(fdata, 2.1), 4},
	SearchWrapperTest{'search_strings', search_strings(sdata, ''), 0},
	SearchWrapperTest{'IntSlice.search', IntSlice(data).search(0), 2},
	SearchWrapperTest{'F64Slice.search', F64Slice(fdata).search(2.0), 3},
	SearchWrapperTest{'StringSlice.search', StringSlice(sdata).search('x'), 3},
]

fn test_search_wrappers() {
	for t in search_wrapper_tests {
		assert t.result == t.i, '${t.name}: expected index ${t.i}; got ${t.result}'
	}
}

fn run_search_wrappers() {
	search_ints(data, 11)
	search_f64s(fdata, 2.1)
	search_strings(sdata, '')
	IntSlice(data).search(0)
	F64Slice(fdata).search(2.0)
	StringSlice(sdata).search('x')
}

fn test_benchmark_search_wrappers() {
	mut bmark := benchmark.new_benchmark()
	bmark.set_total_expected_steps(100)
	for i := 0; i < bmark.nexpected_steps; i++ {
		bmark.step()
		run_search_wrappers()
		bmark.ok()
	}
	bmark.stop()
	bmark.measure(@FN)
}

// Abstract exhaustive test: all sizes up to 100,
// all possible return values. If there are any small
// corner cases, this test exercises them.
fn test_search_exhaustive() {
	for size := 0; size <= 100; size++ {
		for targ := 0; targ <= size; targ++ {
			i := search(size, fn [targ] (i int) bool {
				return i >= targ
			})
			assert i == targ, 'search(${size}, ${targ}) = ${i}'
		}
	}
}

// Abstract exhaustive test for find.
fn test_find_exhaustive() {
	// Test find for different sequence sizes and search targets.
	// For each size, we have a (unmaterialized) sequence of integers:
	//   2,4...size*2
	// And we're looking for every possible integer between 1 and size*2 + 1.
	for size := 0; size <= 100; size++ {
		for x := 1; x <= size * 2 + 1; x++ {
			mut want_found := false
			mut want_pos := 0

			cmp := fn [x] (i int) int {
				// Encodes the unmaterialized sequence with elem[i] == (i+1)*2
				return x - (i + 1) * 2
			}
			pos, found := find(size, cmp)

			if x % 2 == 0 {
				want_pos = x / 2 - 1
				want_found = true
			} else {
				want_pos = x / 2
				want_found = false
			}
			assert found == want_found || pos == want_pos, 'find(${size}, ${x}): got (${pos}, ${found}), want (${want_pos}, ${want_found})'
		}
	}
}
