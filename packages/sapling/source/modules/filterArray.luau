return function<T>(array: { T }, filterFn: (item: T) -> boolean)
    local newArray = {}

    for k, v in array do
        local shouldAdd = filterFn(v)
        if not shouldAdd then
            continue
        end

        table.insert(newArray, v)
    end

    return newArray
end
