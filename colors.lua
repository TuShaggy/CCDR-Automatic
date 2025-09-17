local colors = {}

local function combine( c1, c2 )
    return bit32.bor( c1, c2 )
end

local function subtract( c1, c2 )
    return bit32.band( c1, bit32.bnot( c2 ) )
end

local function test( c1, c2 )
    return bit32.band( c1, c2 ) ~= 0
end

local function packRGB( r, g, b )
    return bit32.bor( bit32.lshift( r, 16 ), bit32.lshift( g, 8 ), b )
end

local function unpackRGB( color )
    local r = bit32.rshift( bit32.band( color, 0xFF0000 ), 16 )
    local g = bit32.rshift( bit32.band( color, 0x00FF00 ), 8 )
    local b = bit32.band( color, 0x0000FF )
    return r, g, b
end

local function toBlit( colour )
    if type(colour) == "number" then
        if colour >= 0 and colour <= 15 then
            return string.char( ("0123456789abcdef"):sub( colour + 1, colour + 1 ) )
        elseif colour >= 0 and colour <= 0xffffff then
            return string.format( "#%06x", colour )
        end
    end
    error( "bad argument #1 (invalid color)", 2 )
end

colors.combine = combine
colors.subtract = subtract
colors.test = test
colors.packRGB = packRGB
colors.unpackRGB = unpackRGB
colors.toBlit = toBlit

local _blittable = {
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"
}
for i=0,15 do
    colors[ _blittable[i+1] ] = 2^i
end

return colors