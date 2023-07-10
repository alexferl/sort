module sort

import math.bits

// An implementation of Interface can be sorted by the routines in this package.
// The methods refer to elements of the underlying collection by integer index.
pub interface Interface {
	// len is the number of elements in the collection.
	len() int
	// less reports whether the element with index i
	// must sort before the element with index j.
	//
	// If both less(i, j) and less(j, i) are false,
	// then the elements at index i and j are considered equal.
	// sort may place equal elements in any order in the final result,
	// while stable preserves the original input order of equal elements.
	//
	// less must describe a transitive ordering:
	//  - if both less(i, j) and less(j, k) are true, then less(i, k) must be true as well.
	//  - if both less(i, j) and less(j, k) are false, then less(i, k) must be false as well.
	//
	// Note that floating-point comparison (the < operator on f32 or f64 values)
	// is not a transitive ordering when not-a-number (NaN) values are involved.
	// See F64Slice.less for a correct implementation for floating-point values.
	less(i int, j int) bool
mut:
	swap(i int, j int) // swap swaps the elements with indexes i and j.
}

// sort sorts data in ascending order as determined by the less method.
// It makes one call to data.len to determine n and O(n*log(n)) calls to
// data.less and data.swap. The sort is not guaranteed to be stable.
pub fn sort(mut data Interface) {
	n := data.len()
	if n <= 1 {
		return
	}

	limit := bits.len_64(u64(n))
	pdqsort(mut data, 0, n, limit)
}

enum SortedInt {
	unknown_hint
	increasing_hint
	decreasing_hint
}

// Xorshift paper: https://www.jstatsoft.org/article/view/v008i14/xorshift.pdf
type Xorshift = u64

pub fn (mut r Xorshift) next() u64 {
	r ^= r << 13
	r ^= r >> 17
	r ^= r << 5
	return r
}

fn next_power_of_two(length int) u64 {
	shift := u64(bits.len_64(u64(length)))
	return u64(1 << shift)
}

// LessSwap is a pair of less and swap function for use with the
// auto-generated func-optimized variant of v in
// zsortfunction.v.
struct LessSwap {
	less fn (i int, j int) bool
	swap fn (i int, j int)
}

// is_sorted reports whether data is sorted.
pub fn is_sorted(data Interface) bool {
	n := data.len()
	for i := n - 1; i > 0; i-- {
		if data.less(i, i - 1) {
			return false
		}
	}
	return true
}

// pub type IntSlice = []int

// IntSlice attaches the methods of Interface to []int, sorting in increasing order.
pub struct IntSlice {
mut:
	data []int
}

pub fn (p IntSlice) len() int {
	return p.data.len
}

pub fn (p IntSlice) less(i int, j int) bool {
	return p.data[i] < p.data[j]
}

pub fn (mut p IntSlice) swap(i int, j int) {
	p.data[i], p.data[j] = p.data[j], p.data[i]
}

// sort is a convenience method: x.sort() calls sort(x).
pub fn (mut p IntSlice) sort() {
	sort(mut p)
}

// pub type F64Slice = []int

// F64Slice implements Interface for a []f64, sorting in increasing order,
// with not-a-number (NaN) values ordered before other values.
pub struct F64Slice {
mut:
	data []f64
}

pub fn (p F64Slice) len() int {
	return p.data.len
}

// less reports whether x[i] should be ordered before x[j], as required by the sort Interface.
// Note that floating-point comparison by itself is not a transitive relation: it does not
// report a consistent ordering for not-a-number (NaN) values.
// This implementation of less places NaN values before any others, by using:
//	x[i] < x[j] || (math.is_nan(x[i]) && !math.is_nan(x[j]))
pub fn (p F64Slice) less(i int, j int) bool {
	return p.data[i] < p.data[j] || (is_nan(p.data[i]) && !is_nan(p.data[j]))
}

pub fn (mut p F64Slice) swap(i int, j int) {
	p.data[i], p.data[j] = p.data[j], p.data[i]
}

// is_nan is a copy of math.is_nan to avoid a dependency on the math package.
fn is_nan(f f64) bool {
	return f != f
}

// sort is a convenience method: x.sort() calls sort(x).
pub fn (mut p F64Slice) sort() {
	sort(mut p)
}

// pub type StringSlice = []string

// StringSlice attaches the methods of Interface to []string, sorting in increasing order.
pub struct StringSlice {
mut:
	data []string
}

pub fn (p StringSlice) len() int {
	return p.data.len
}

pub fn (p StringSlice) less(i int, j int) bool {
	return p.data[i] < p.data[j]
}

pub fn (mut p StringSlice) swap(i int, j int) {
	p.data[i], p.data[j] = p.data[j], p.data[i]
}

// sort is a convenience method: x.sort() calls sort(x).
pub fn (mut p StringSlice) sort() {
	sort(mut p)
}

// ints sorts a slice of ints in increasing order.
pub fn ints(x []int) {
	mut int_slice := IntSlice{x}
	sort(mut int_slice)
}

// f64s sorts a slice of f64s in increasing order.
// Not-a-number (NaN) values are ordered before other values.
pub fn f64s(x []f64) {
	mut f64_slice := F64Slice{x}
	sort(mut f64_slice)
}

// strings sorts a slice of strings in increasing order.
pub fn strings(x []string) {
	mut string_slice := StringSlice{x}
	sort(mut string_slice)
}

// ints_are_sorted reports whether the slice x is sorted in increasing order.
pub fn ints_are_sorted(x []int) bool {
	mut int_slice := IntSlice{x}
	return is_sorted(int_slice)
}

// f64s_are_sorted reports whether the slice x is sorted in increasing order,
// with not-a-number (NaN) values before any other values.
pub fn f64s_are_sorted(x []f64) bool {
	mut f64_slice := F64Slice{x}
	return is_sorted(f64_slice)
}

// strings_are_sorted reports whether the slice x is sorted in increasing order.
pub fn strings_are_sorted(x []string) bool {
	mut string_slice := StringSlice{x}
	return is_sorted(string_slice)
}

// stable sorts data in ascending order as determined by the less method,
// while keeping the original order of equal elements.
// It makes one call to data.len to determine n, O(n*log(n)) calls to
// data.less and O(n*log(n)*log(n)) calls to data.swap.
pub fn stable(mut data Interface) {
	stable_(mut data, data.len())
}
