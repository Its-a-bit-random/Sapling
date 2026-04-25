--!strict

--[=[
    The Ok type, the `value` key is generic and can be anything.
]=]
export type Ok<T> = {
    ok: true,
    value: T,
}

--[=[
    The Error type, where the `error` key is generic and can be anything.
]=]
export type Error<T> = {
    ok: false,
    error: T,
}

--[=[
    A result type, where T is the value if the result is `Ok` and E is the value of the result if the result is `Error`
]=]
export type Result<T, E> = Ok<T> | Error<E>

--[=[
    A simple package matching as close as possible to Rust's std::result for Roblox Luau.
]=]
local Result = {}

--[=[
    Wraps the `value` into a Ok<T> type

    @param value the value to wrap
    @return Ok<T>
]=]
function Result.ok<T>(value: T): Ok<T>
    return {
        ok = true,
        value = value,
    } :: Ok<T>
end

--[=[
    Wraps the `value` into a Error<T> type

    @param value the value to wrap
    @return Error<T>
]=]
function Result.err<E>(value: E): Error<E>
    return {
        ok = false,
        error = value,
    } :: Error<E>
end

--[=[
    Unwrap the passed Result into its value. If the Result is of a `Error<T>` type,
    the function will error with the `Result<T, E>`'s value. Optionally a custom errorMessage
    can be used with the `errorMessage` param.

    @param result The result object to unwrap
    @param errorMessage Optional error string
    @return the value of the retult
]=]
function Result.unwrap<T, E>(result: Result<T, E>, errorMessage: string?): T
    if result.ok then
        return result.value
    else
        error(errorMessage or tostring(result.error))
    end
end

--[=[
    Unwrap the `result` however if the `result` is of type `Error<T>` the passed `defaultValue`
    will be used instead of throwing an error.

    @param result the result to unwrap
    @param defaultValue the value to default to
    @return T
]=]
function Result.unwrapOr<T, E>(result: Result<T, E>, defaultValue: T): T
    if result.ok then
        return result.value
    end

    return defaultValue
end

return Result
