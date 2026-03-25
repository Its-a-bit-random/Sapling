--[=[
    @class QueryBuilder
    A small utility to build selector strings for [Instance.QueryDescendants](https://create.roblox.com/docs/reference/engine/classes/Instance#QueryDescendants).

    All functions on the class return self so you can chain like so:
    ```lua
    local myModel = ...
    myModel:QueryDescendants(QueryBuilder.new():withTag("Cool"):build())
    ```
]=]
local QueryBuilder = {}
QueryBuilder.__index = QueryBuilder

export type QueryBuilder = typeof(setmetatable(
	{} :: {
		_Tags: { string },
	},
	QueryBuilder
))

--[=[]=]
function QueryBuilder.new()
	local self = setmetatable({}, QueryBuilder) :: QueryBuilder
	self._Tags = {}
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
	table.insert(self._Tags, tag)
	return self
end

--[=[
    @method build
    @return string
    @within QueryBuilder
    Builds a query string.
]=]
function QueryBuilder.build(self: QueryBuilder): string
	local query = ""

	for _, tag in self._Tags do
		query ..= `.{tag}`
	end

	return query
end

return QueryBuilder
