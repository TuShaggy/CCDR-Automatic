-- The MIT License (MIT)
--
-- Copyright (C) 2013-2021 Dan200
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local colors = {}

colors.white = 0
colors.orange = 1
colors.magenta = 2
colors.lightBlue = 3
colors.yellow = 4
colors.lime = 5
colors.pink = 6
colors.gray = 7
colors.lightGray = 8
colors.cyan = 9
colors.purple = 10
colors.blue = 11
colors.brown = 12
colors.green = 13
colors.red = 14
colors.black = 15

local function combine(...)
    local result = 0
    local count = select("#", ...)
    for i=1,count do
        local color = select(i, ...)
        if type(color) ~= "number" or color < 0 or color > 15 then
            error( "bad argument #"..i.." (number between 0 and 15 expected)", 2 )
        end
        result = result + 2^color
    end
    return result
end

local function subtract( a, ... )
    if type(a) ~= "number" then
        error( "bad argument #1 (number expected)", 2 )
    end
    local result = a
    local count = select("#", ...)
    for i=1,count do
        local color = select(i, ...)
        if type(color) ~= "number" or color < 0 or color > 15 then
            error( "bad argument #"..tostring(i+1).." (number between 0 and 15 expected)", 2 )
        end
        result = bit.band( result, bit.bnot( 2^color ) )
    end
    return result
end

local function test( colors, color )
    if type(colors) ~= "number" then
        error( "bad argument #1 (number expected)", 2 )
    end
    if type(color) ~= "number" or color < 0 or color > 15 then
        error( "bad argument #2 (number between 0 and 15 expected)", 2 )
    end
    return bit.band( colors, 2^color ) > 0
end

local function packRGB( r, g, b )
    if type(r) ~= "number" or r < 0 or r > 1 then
        error( "bad argument #1 (number between 0 and 1 expected)", 2 )
    end
    if type(g) ~= "number" or g < 0 or g > 1 then
        error( "bad argument #2 (number between 0 and 1 expected)", 2 )
    end
    if type(b) ~= "number" or b < 0 or b > 1 then
        error( "bad argument #3 (number between 0 and 1 expected)", 2 )
    end
    local nR = math.floor( r * 255 )
    local nG = math.floor( g * 255 )
    local nB = math.floor( b * 255 )
    return nR * 65536 + nG * 256 + nB
end

local function unpackRGB( rgb )
    if type(rgb) ~= "number" or rgb < 0 or rgb > 0xFFFFFF then
        error( "bad argument #1 (number between 0 and 0xFFFFFF expected)", 2 )
    end
    local nR = math.floor( rgb / 65536 )
    local nG = math.floor( (rgb % 65536) / 256 )
    local nB = rgb % 256
    return nR / 255, nG / 255, nB / 255
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
