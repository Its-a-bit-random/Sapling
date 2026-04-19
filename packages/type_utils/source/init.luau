--[[
	No doc comments because this is more of an "internal" package, people can use it if they 
	want but not really hyper intended.
]]

-- ES7 Types
export type Map<K, V> = { [K]: V }
export type Array<V> = { V }

-- Every type a value can be when using :GetAttribute()
export type PossibleAttributeValue =
    number
    | string
    | boolean
    | UDim
    | UDim2
    | BrickColor
    | Color3
    | Vector2
    | Vector3
    | CFrame
    | NumberSequence
    | ColorSequence
    | NumberRange
    | Rect
    | Font

return nil
