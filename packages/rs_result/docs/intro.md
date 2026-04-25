# Introduction

The `rs_result` package intends to emulate [Result](https://doc.rust-lang.org/std/result/) from rust's std crate.

## Example

Result objects allow you to returning and propagating errors without throwing errors which allows the caller to decide how to handle failure. This makes your code better as it forces you to think of all the outcomes when you call something. For example:

```lua
local function div(num1: number, num2: number): number
    assert(num1 > 0, "Cannot divide by 0")
    assert(num2 > 0, "Cannot divide by 0")
    return num1 / num2
end

local myNumber = math.random(0, 10)
local anotherNumber = math.random(0, 10)
local result = div(myNumber, anotherNumber) -- If one of these numbers are 0 we are forced to throw
```

Obviously you could surround your function calls with pcalls however it isnt forced which still means you can have errors that you dont catch. Here is the same example using result:

```lua
local function div(num1: number, num2: number): Result<number, string>
    if num1 == 0 or num2 == 0 then
        return Result.err("Can not divide by 0")
    end
    return Result.ok(num1 / num2)
end

local myNumber = math.random(0, 10)
local anotherNumber = math.random(0, 10)
local divResult = div(myNumber, anotherNumber)
local dividedNumber = Result.unwrapOr(divResult, 0) -- Use the division result or use 0 if the div function returned an Error result.
```

As you can see the result forces the called to think about what happens when a function fails.

