module sort

import benchmark
import math
import rand

const (
	// vfmt off
	ints_ = [74, 59, 238, -784, 9845, 959, 905, 0, 0, 42, 7586, -5467984, 7586]
	f64s_ = [74.3, 59.0, math.inf(1), 238.2, -784.0, 2.3, math.nan(), math.nan(), math.inf(-1), 9845.768, -959.7485, 905, 7.8, 7.8]
	strings_ = ['', 'Hello', 'foo', 'bar', 'foo', 'f00', '%*&^*&^&', '***']
		// vfmt on
)

fn test_sort_int_slice() {
	data := ints_.clone()
	mut a := IntSlice(data)
	sort(mut a)
	assert is_sorted(a), 'sorted ${ints_} got ${data}'
}

fn test_sort_f64_slice() {
	data := f64s_.clone()
	mut a := F64Slice(data)
	sort(mut a)
	assert is_sorted(a), 'sorted ${f64s_} got ${data}'
}

fn test_sort_string_slice() {
	data := strings_.clone()
	mut a := StringSlice(data)
	sort(mut a)
	assert is_sorted(a), 'sorted ${strings_} got ${data}'
}

fn test_ints() {
	data := ints_.clone()
	ints(data)
	assert ints_are_sorted(data), 'sorted ${ints_} got ${data}'
}

fn test_f64s() {
	data := f64s_.clone()
	f64s(data)
	assert f64s_are_sorted(data), 'sorted ${f64s_} got ${data}'
}

fn test_strings() {
	data := strings_.clone()
	strings(data)
	assert strings_are_sorted(data), 'sorted ${strings_} got ${data}'
}

fn test_sort_large_random() {
	n := 1000000
	mut data := []int{len: n}
	for i := 0; i < data.len; i++ {
		data[i] = rand.intn(100) or { panic(err) }
	}
	assert !ints_are_sorted(data), 'terrible rand.intn'
	ints(data)
	assert ints_are_sorted(data), "sort didn't sort - 1M ints"
}

fn test_break_patterns() {
	// Special slice used to trigger break_patterns.
	mut data := []int{len: 30}
	for i in data {
		data[i] = 30
	}
	data[(data.len / 4) * 1] = 0
	data[(data.len / 4) * 2] = 1
	data[(data.len / 4) * 3] = 2
	mut a := IntSlice(data)
	sort(mut a)
}

fn test_reverse_range() {
	mut data := [1, 2, 3, 4, 5, 6, 7]
	mut a := IntSlice(data)
	reverse_range(mut a, 0, data.len)
	for i := data.len - 1; i > 0; i-- {
		assert data[i] < data[i - 1], "reverse_range didn't work"
	}

	mut data1 := [1, 2, 3, 4, 5, 6, 7]
	data2 := [1, 2, 5, 4, 3, 6, 7]
	mut b := IntSlice(data1)
	reverse_range(mut b, 2, 5)
	for i, v in data1 {
		assert v == data2[i], "reverse_range didn't work"
	}
}

fn test_benchmark_sort_string_1k() {
	mut bmark := benchmark.new_benchmark()
	bmark.set_total_expected_steps(1000)
	for i := 0; i < bmark.nexpected_steps; i++ {
		mut data := []string{len: 1 << 10}
		for j := 0; j < data.len; j++ {
			data[j] = (j ^ 0x2cc).str()
		}
		bmark.step()
		strings(data)
		bmark.ok()
	}
	bmark.stop()
	bmark.measure(@FN)
}

fn test_benchmark_sort_stable_string_1k() {
	mut bmark := benchmark.new_benchmark()
	bmark.set_total_expected_steps(1000)
	for i := 0; i < bmark.nexpected_steps; i++ {
		mut data := []string{len: 1 << 10}
		for j := 0; j < data.len; j++ {
			data[j] = (j ^ 0x2cc).str()
		}
		mut a := StringSlice(data)
		bmark.step()
		stable(mut a)
		bmark.ok()
	}
	bmark.stop()
	bmark.measure(@FN)
}

fn test_benchmark_sort_int_1k() {
	mut bmark := benchmark.new_benchmark()
	bmark.set_total_expected_steps(1000)
	for i := 0; i < bmark.nexpected_steps; i++ {
		mut data := []int{len: 1 << 10}
		for j := 0; j < data.len; j++ {
			data[j] = j ^ 0x2cc
		}
		bmark.step()
		ints(data)
		bmark.ok()
	}
	bmark.stop()
	bmark.measure(@FN)
}

fn test_benchmark_sort_int_1k_sorted() {
	mut bmark := benchmark.new_benchmark()
	bmark.set_total_expected_steps(1000)
	for i := 0; i < bmark.nexpected_steps; i++ {
		mut data := []int{len: 1 << 10}
		for j := 0; j < data.len; j++ {
			data[j] = j
		}
		bmark.step()
		ints(data)
		bmark.ok()
	}
	bmark.stop()
	bmark.measure(@FN)
}

fn test_benchmark_sort_int_1k_reversed() {
	mut bmark := benchmark.new_benchmark()
	bmark.set_total_expected_steps(1000)
	for i := 0; i < bmark.nexpected_steps; i++ {
		mut data := []int{len: 1 << 10}
		for j := 0; j < data.len; j++ {
			data[j] = data.len - j
		}
		bmark.step()
		ints(data)
		bmark.ok()
	}
	bmark.stop()
	bmark.measure(@FN)
}

fn test_benchmark_sort_int_1k_mod8() {
	mut bmark := benchmark.new_benchmark()
	bmark.set_total_expected_steps(1000)
	for i := 0; i < bmark.nexpected_steps; i++ {
		mut data := []int{len: 1 << 10}
		for j := 0; j < data.len; j++ {
			data[j] = j % 8
		}
		bmark.step()
		ints(data)
		bmark.ok()
	}
	bmark.stop()
	bmark.measure(@FN)
}

fn test_benchmark_stable_int_1k() {
	mut bmark := benchmark.new_benchmark()
	bmark.set_total_expected_steps(1000)
	for i := 0; i < bmark.nexpected_steps; i++ {
		mut data := []int{len: 1 << 10}
		for j := 0; j < data.len; j++ {
			data[j] = j ^ 0x2cc
		}
		mut a := IntSlice(data)
		bmark.step()
		stable(mut a)
		bmark.ok()
	}
	bmark.stop()
	bmark.measure(@FN)
}

fn test_benchmark_sort_int_64k() {
	mut bmark := benchmark.new_benchmark()
	bmark.set_total_expected_steps(100)
	for i := 0; i < bmark.nexpected_steps; i++ {
		mut data := []int{len: 1 << 16}
		for j := 0; j < data.len; j++ {
			data[j] = j ^ 0xcccc
		}
		bmark.step()
		ints(data)
		bmark.ok()
	}
	bmark.stop()
	bmark.measure(@FN)
}

fn test_benchmark_stable_int_64k() {
	mut bmark := benchmark.new_benchmark()
	bmark.set_total_expected_steps(100)
	for i := 0; i < bmark.nexpected_steps; i++ {
		mut data := []int{len: 1 << 16}
		for j := 0; j < data.len; j++ {
			data[j] = j ^ 0xcccc
		}
		mut a := IntSlice(data)
		bmark.step()
		stable(mut a)
		bmark.ok()
	}
	bmark.stop()
	bmark.measure(@FN)
}

fn test_stable_ints() {
	mut data := ints_.clone()
	mut a := IntSlice(data)
	stable(mut a)
	assert ints_are_sorted(data), 'nsorted ${ints_}\n   got ${data}'
}
