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

local term = {}

local function redirect( target )
    if type(target) ~= "table" or
       type(target.write) ~= "function" or
       type(target.scroll) ~= "function" or
       type(target.setCursorPos) ~= "function" then
        error( "bad argument #1 (expected table with write, scroll, setCursorPos)", 2 )
    end
    return native.term_redirect( target )
end

local function current()
    return native.term_current()
end

local function native()
    return native.term_native()
end

local function write( text )
    if type(text) ~= "string" and type(text) ~= "number" then
        error( "bad argument #1 (expected string)", 2 )
    end
    return native.term_write( tostring(text) )
end

local function scroll( y )
    if type(y) ~= "number" then
        error( "bad argument #1 (expected number)", 2 )
    end
    return native.term_scroll( y )
end

local function setCursorPos( x, y )
    if type(x) ~= "number" then
        error( "bad argument #1 (expected number)", 2 )
    end
    if type(y) ~= "number" then
        error( "bad argument #2 (expected number)", 2 )
    end
    return native.term_setCursorPos( x, y )
end

local function setCursorBlink( blink )
    if type(blink) ~= "boolean" then
        error( "bad argument #1 (expected boolean)", 2 )
    end
    return native.term_setCursorBlink( blink )
end

local function setTextColor( color )
    if type(color) ~= "number" then
        error( "bad argument #1 (expected number)", 2 )
    end
    return native.term_setTextColor( color )
end

local function setBackgroundColor( color )
    if type(color) ~= "number" then
        error( "bad argument #1 (expected number)", 2 )
    end
    return native.term_setBackgroundColor( color )
end

local function setPaletteColor( color, r, g, b )
    if type(color) ~= "number" then
        error( "bad argument #1 (expected number)", 2 )
    end
    if type(r) == "number" and (not g or not b) then
        if r < 0 or r > 0xFFFFFF then
            error( "bad argument #2 (expected number between 0 and 0xFFFFFF)", 2 )
        end
        return native.term_setPaletteColour( color, r )
    elseif type(r) == "number" and type(g) == "number" and type(b) == "number" then
        if r < 0 or r > 1 then
            error( "bad argument #2 (expected number between 0 and 1)", 2 )
        end
        if g < 0 or g > 1 then
            error( "bad argument #3 (expected number between 0 and 1)", 2 )
        end
        if b < 0 or b > 1 then
            error( "bad argument #4 (expected number between 0 and 1)", 2 )
        end
        return native.term_setPaletteColour( color, r, g, b )
    else
        error( "bad arguments (expected number, number, number or number)", 2 )
    end
end

local function getPaletteColor( color )
    if type(color) ~= "number" then
        error( "bad argument #1 (expected number)", 2 )
    end
    return native.term_getPaletteColour( color )
end

term.redirect = redirect
term.current = current
term.native = native
term.write = write
term.scroll = scroll
term.setCursorPos = setCursorPos
term.setCursorBlink = setCursorBlink
term.setTextColor = setTextColor
term.setBackgroundColor = setBackgroundColor
term.setPaletteColor = setPaletteColor
term.getPaletteColor = getPaletteColor
term.getCursorPos = native.term_getCursorPos
term.getSize = native.term_getSize
term.clear = native.term_clear
term.clearLine = native.term_clearLine
term.getTextColor = native.term_getTextColor
term.getTextColour = native.term_getTextColor
term.getBackgroundColor = native.term_getBackgroundColor
term.getBackgroundColour = native.term_getBackgroundColor
term.isColor = native.term_isColor
term.isColour = native.term_isColor
term.blit = native.term_blit
term.getPaletteColour = getPaletteColor
term.setPaletteColour = setPaletteColor

return term
