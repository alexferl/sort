# sort

A port of Go's [sort](https://pkg.go.dev/sort@go1.20.5) package to [V](https://vlang.io/).

## Installing
```shell
v install alexferl.sort
```

# Using
More complex examples [here](examples).

## sort
```v
module main

import alexferl.sort

fn main() {
	data := [3, 2, 4, 1, 0, 5]
	clone := data.clone()
	mut a := sort.IntSlice{clone}
	sort.sort(mut a)
	assert sort.is_sorted(a), 'sorted ${data} got ${clone}'
}
```

## search
```v
module main

import alexferl.sort
import readline

fn main() {
	println("Pick an integer from 0 to 100.")
	answer := sort.search(100, fn(i int) bool {
		mut r := readline.Readline{}
		r.enable_raw_mode()
		defer {
			r.disable_raw_mode()
		}
		s := r.read_line("Is your number <= ${i}? ") or { panic(err) }
		return s != "" && s.starts_with('y')
	})
	println("Your number is ${answer}.")
}
```
