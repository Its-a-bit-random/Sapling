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
        _Not: boolean,
    },
    QueryBuilder
))

--[=[
    @prop _Query string
    @private
    @readonly
    @within QueryBuilder

    The current query string. Do NOT access this directly, instead use [QueryBuilder.query]
]=]

--[=[
    @prop _Not boolean
    @private
    @readonly
    @within QueryBuilder

    Controls if the next query is negated. [QueryBuilder.negate]
]=]

--[=[]=]
function QueryBuilder.new()
    local self = setmetatable({}, QueryBuilder) :: QueryBuilder
    self._Query = ""
    self._Not = false
    return self
end

--[=[
    @private
    @method _AppendToQuery
    @param append string
    @within QueryBuilder
    
    Internal function to directly append to the qurey string. Also appends any needed characters
    like a closing brace if a §not§ operation was used.
]=]
function QueryBuilder._AppendToQuery(self: QueryBuilder, append: string)
    self._Query ..= append
    if self._Not then
        self._Not = false
        self:_AppendToQuery(")")
    end
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
    self:_AppendToQuery(`.{tag}`)
    return self
end

--[=[
    @tag returns-self

    @method either
    @param tag string
    @return QueryBuilder
    @within QueryBuilder
    An `or` operation between whats on the left to the right. For example:
    ```lua
    :withTag("Apple"):either():withTag("Orange"):hasAttribute("IsPeeled")
    -- Has the tag "Apple" OR Has the tag "Orange" with an attribute of "IsPeeled"
    ```
]=]
function QueryBuilder.either(self: QueryBuilder)
    self:_AppendToQuery(", ")
    return self
end

--[=[
    @tag returns-self

    @method child
    @return QueryBuilder
    @within QueryBuilder
    Anything after this method is called will act on children of queried instances
    that match the previous cases.
]=]
function QueryBuilder.child(self: QueryBuilder)
    self:_AppendToQuery(" > ")
    return self
end

--[=[
    @tag returns-self

    @method descendant
    @return QueryBuilder
    @within QueryBuilder
    Same as [QueryBuilder.child] but for descendant.
]=]
function QueryBuilder.descendant(self: QueryBuilder)
    self:_AppendToQuery(" >> ")
    return self
end

--[=[
    @tag returns-self

    @method negate
    @return QueryBuilder
    @within QueryBuilder
    Negates the next function that is aclled. For example:
    ```lua
    :negate():withTag("cool") -- Does NOT have the tag "cool"
    ```
]=]
function QueryBuilder.negate(self: QueryBuilder)
    self:_AppendToQuery(":not(")
    self._Not = true
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
    self:_AppendToQuery(`[${attributeName}]`)
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
    self:_AppendToQuery(`[${attributeName} = {attributeValue}]`)
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
    self:_AppendToQuery(class)
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
    self:_AppendToQuery(`#{name}`)
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
    self:_AppendToQuery(`[{property} = {value}]`)
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
