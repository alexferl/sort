# sort

A port of Go's [sort](https://pkg.go.dev/sort@go1.20.5) package to [V](https://vlang.io/).

## Installing
```shell
v install alexferl.sort
```

# Using
```v
import alexferl.sort

fn main() {
    data := [3, 2, 4, 1, 0, 5]
    clone := data.clone()
	mut a := IntSlice{clone}
	sort(mut a)
	assert is_sorted(a), 'sorted ${data} got ${clone}'
}
```
