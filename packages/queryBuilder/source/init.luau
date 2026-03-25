--[=[
    @class QueryBuilder
    A small utility to build selector strings for [Instance.QueryDescendants](https://create.roblox.com/docs/reference/engine/classes/Instance#QueryDescendants).

    All functions on the class return self so you can chain like so:
    ```lua
    local myModel = ...
    myModel:QueryDescendants(QueryBuilder.new():withTag("Cool"):query())
    ```
]=]
local QueryBuilder = {}
QueryBuilder.__index = QueryBuilder

export type QueryBuilder = typeof(setmetatable(
	{} :: {
		_Query: string,
	},
	QueryBuilder
))

--[=[]=]
function QueryBuilder.new()
	local self = setmetatable({}, QueryBuilder) :: QueryBuilder
	self._Query = ""
	return self
end

--[=[
    @tag returns-self

    @method withTag
    @param tag string
    @return QueryBuilder
    @within QueryBuilder
    Adds the `tag` to the search query.
]=]
function QueryBuilder.withTag(self: QueryBuilder, tag: string)
	self._Query ..= `.{tag}`
	return self
end

--[=[
    @tag returns-self

    @method hasAttribute
    @param attributeName string
    @return QueryBuilder
    @within QueryBuilder
    Anything which has the `attributeName` set to anything but nil
]=]
function QueryBuilder.hasAttribute(self: QueryBuilder, attributeName: string)
	self._Query ..= `[${attributeName}]`
	return self
end

--[=[
    @tag returns-self

    @method hasAttribute
    @param attributeName string
    @param attributeValue string | any
    @return QueryBuilder
    @within QueryBuilder
    Anything which has the `attributeName` set to `attributeValue`. See more info about how `attributeValue` works: [QueryBuilder.wherePropertyIs]
]=]
function QueryBuilder.whereAttributeIs(self: QueryBuilder, attributeName: string, attributeValue: string | any)
	self._Query ..= `[${attributeName} = {attributeValue}]`
	return self
end

--[=[
    @tag returns-self

    @method whichIsA
    @param class string
    @return QueryBuilder
    @within QueryBuilder
    Anything which is a of class `class` (`:IsA()`)
]=]
function QueryBuilder.whichIsA(self: QueryBuilder, class: string)
	self._Query ..= class
	return self
end

--[=[
    @tag returns-self

    @method named
    @param name string
    @return QueryBuilder
    @within QueryBuilder
    Anything which has the name `name`.
]=]
function QueryBuilder.named(self: QueryBuilder, name: string)
	self._Query ..= `#{name}`
	return self
end

--[=[
    @tag returns-self

    @method wherePropertyIs
    @param property string
    @param value string | any
    @return QueryBuilder
    @within QueryBuilder
    Anything which has the its `property` set to `value`. For best results you should pass the value as a string, for example:
    ```lua
    :wherePropertyIs("CanCollide", "false")
    ```

    :::warning
    If you pass a normal value into `value` then `tostring(value)` will be called on the value.
    :::
]=]
function QueryBuilder.wherePropertyIs(self: QueryBuilder, property: string, value: string | any)
	self._Query ..= `[{property} = {value}]`
	return self
end

--[=[
    @method query
    @return string
    @within QueryBuilder
    Returns the built up query string.
]=]
function QueryBuilder.query(self: QueryBuilder): string
	return self._Query
end

return QueryBuilder
