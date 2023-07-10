module main

import alexferl.sort

struct Mobile {
	brand string
	price int
}

struct ByPrice {
	mut:
	data []Mobile
}

fn (a ByPrice) len() int {
	return a.data.len
}

fn (mut a ByPrice) swap(i int, j int) {
	a.data[i], a.data[j] = a.data[j], a.data[i]
}

fn (a ByPrice) less(i int, j int) bool {
	return a.data[i].price < a.data[j].price
}

struct ByBrand {
	mut:
	data []Mobile
}

fn (a ByBrand) len() int {
	return a.data.len
}

fn (mut a ByBrand) swap(i int, j int) {
	a.data[i], a.data[j] = a.data[j], a.data[i]
}

fn (a ByBrand) less(i int, j int) bool {
	return a.data[i].brand > a.data[j].brand
}

fn main() {
	mut mobiles := []Mobile{}
	mobiles << Mobile{'Sony', 952}
	mobiles << Mobile{'Nokia', 468}
	mobiles << Mobile{'Apple', 1219}
	mobiles << Mobile{'Samsung', 1045}

	mut a := ByPrice{mobiles}

	println('Before sort:')
	for m in mobiles {
		println('${m.brand} ${m.price}')
	}
	println('')

	sort.sort(mut a)

	println('sort by price (ascending):')
	for m in mobiles {
		println('${m.brand} ${m.price}')
	}
	println('')

	mut b := ByBrand{mobiles}
	sort.sort(mut b)

	println('sort by brand (descending):')
	for m in mobiles {
		println('${m.brand} ${m.price}')
	}
}

/*
Before sort:
Sony 952
Nokia 468
Apple 1219
Samsung 1045

sort by price (ascending):
Nokia 468
Sony 952
Samsung 1045
Apple 1219

sort by brand (descending):
Sony 952
Samsung 1045
Nokia 468
Apple 1219
 */
