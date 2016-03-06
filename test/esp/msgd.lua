local msgd = require("msgd")
local m = msgd.new()

print()
print()
print("+++ Testing enqueue once")
print()

do

	m:enqueue("first", 1)
	assert("first" == m:dequeue())
	assert(nil == m:dequeue())
	
end


print()
print()
print("+++ Testing enqueue repeated")
print()

do

	m:enqueue("first", 2)
	assert("first" == m:dequeue())
	assert("first" == m:dequeue())
	assert(nil == m:dequeue())
	
end


print()
print()
print("+++ Testing enqueue repeated alternating")
print()

do

	m:enqueue("first", 2)
	m:enqueue("second", 2)
	assert("first" == m:dequeue())
	assert("second" == m:dequeue())
	assert("first" == m:dequeue())
	assert("second" == m:dequeue())
	assert(nil == m:dequeue())
	
end