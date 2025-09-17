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

local textutils = {}

local function slowWrite( sText, nRate )
    if type(sText) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if nRate and type(nRate) ~= "number" then
        error( "bad argument #2 (expected number)", 2 )
    end
    nRate = nRate or 20
    for i=1, #sText do
        write( string.sub( sText, i, i ) )
        sleep( 1 / nRate )
    end
end

local function slowPrint( sText, nRate )
    if type(sText) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if nRate and type(nRate) ~= "number" then
        error( "bad argument #2 (expected number)", 2 )
    end
    slowWrite( sText, nRate )
    print()
end

local function tabulate( t, nSpacing )
    if type(t) ~= "table" then
        error( "bad argument #1 (expected table)", 2 )
    end
    if nSpacing and type(nSpacing) ~= "number" then
        error( "bad argument #2 (expected number)", 2 )
    end
    nSpacing = nSpacing or 2

    local nColumns = 0
    local tColumnWidths = {}
    for y,row in pairs( t ) do
        if type(row) == "table" then
            for x,cell in pairs( row ) do
                if x > nColumns then
                    nColumns = x
                end
                local s = tostring(cell)
                if tColumnWidths[x] == nil or #s > tColumnWidths[x] then
                    tColumnWidths[x] = #s
                end
            end
        end
    end

    for y,row in pairs( t ) do
        if type(row) == "table" then
            for x=1,nColumns do
                local cell = row[x]
                if cell ~= nil then
                    local s = tostring(cell)
                    write( s )
                    if x < nColumns then
                        for i=1,tColumnWidths[x] - #s do
                            write( " " )
                        end
                        for i=1,nSpacing do
                            write( " " )
                        end
                    end
                end
            end
        end
        print()
    end
end

local function pagedTabulate( t, nSpacing )
    if type(t) ~= "table" then
        error( "bad argument #1 (expected table)", 2 )
    end
    if nSpacing and type(nSpacing) ~= "number" then
        error( "bad argument #2 (expected number)", 2 )
    end
    nSpacing = nSpacing or 2

    local nColumns = 0
    local tColumnWidths = {}
    for y,row in pairs( t ) do
        if type(row) == "table" then
            for x,cell in pairs( row ) do
                if x > nColumns then
                    nColumns = x
                end
                local s = tostring(cell)
                if tColumnWidths[x] == nil or #s > tColumnWidths[x] then
                    tColumnWidths[x] = #s
                end
            end
        end
    end

    local w, h = term.getSize()
    local yPos = 1
    for y,row in pairs( t ) do
        if type(row) == "table" then
            for x=1,nColumns do
                local cell = row[x]
                if cell ~= nil then
                    local s = tostring(cell)
                    write( s )
                    if x < nColumns then
                        for i=1,tColumnWidths[x] - #s do
                            write( " " )
                        end
                        for i=1,nSpacing do
                            write( " " )
                        end
                    end
                end
            end
        end
        print()
        yPos = yPos + 1
        if yPos >= h then
            write( "[More]" )
            os.pullEvent( "key" )
            term.clearLine()
            yPos = 1
        end
    end
end

local function pagedPrint( sText )
    if type(sText) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    local w, h = term.getSize()
    local yPos = 1
    for line in string.gmatch( sText, "[^\n]+" ) do
        print( line )
        yPos = yPos + 1
        if yPos >= h then
            write( "[More]" )
            os.pullEvent( "key" )
            term.clearLine()
            yPos = 1
        end
    end
end

local function serialize( t, opts )
    local s = "{\n"
    local level = 1
    local function doSerialize( t )
        for k,v in pairs( t ) do
            for i=1,level do
                s = s .. "  "
            end
            if type(k) == "string" then
                s = s .. "[\"" .. k .. "\"] = "
            else
                s = s .. "[" .. tostring(k) .. "] = "
            end
            if type(v) == "table" then
                s = s .. "{\n"
                level = level + 1
                doSerialize( v )
                level = level - 1
                for i=1,level do
                    s = s .. "  "
                end
                s = s .. "},\n"
            elseif type(v) == "string" then
                s = s .. "\"" .. v .. "\",\n"
            else
                s = s .. tostring(v) .. ",\n"
            end
        end
    end
    doSerialize( t )
    s = s .. "}"
    return s
end

local function unserialize( s )
    if type(s) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    local fn, err = load( "return " .. s, "unserialize", "t", {} )
    if fn then
        return fn()
    end
    return nil, err
end

local function serializeJSON( t, opts )
    local s = "{\n"
    local level = 1
    local function doSerialize( t )
        local first = true
        for k,v in pairs( t ) do
            if not first then
                s = s .. ",\n"
            end
            first = false
            for i=1,level do
                s = s .. "  "
            end
            s = s .. "\"" .. tostring(k) .. "\": "
            if type(v) == "table" then
                s = s .. "{\n"
                level = level + 1
                doSerialize( v )
                level = level - 1
                for i=1,level do
                    s = s .. "  "
                end
                s = s .. "}"
            elseif type(v) == "string" then
                s = s .. "\"" .. v .. "\""
            else
                s = s .. tostring(v)
            end
        end
        if not first then
            s = s .. "\n"
        end
    end
    doSerialize( t )
    s = s .. "}"
    return s
end

local function unserializeJSON( s )
    if type(s) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    local t = {}
    local i = 1
    local function parseValue()
        while true do
            local c = string.sub( s, i, i )
            if c == " " or c == "\n" or c == "\t" or c == "\r" then
                i = i + 1
            else
                break
            end
        end
        local c = string.sub( s, i, i )
        if c == "{" then
            return parseObject()
        elseif c == "[" then
            return parseArray()
        elseif c == "\"" then
            return parseString()
        elseif c == "t" or c == "f" or c == "n" then
            return parseKeyword()
        else
            return parseNumber()
        end
    end
    function parseObject()
        i = i + 1
        local t = {}
        while true do
            while true do
                local c = string.sub( s, i, i )
                if c == " " or c == "\n" or c == "\t" or c == "\r" then
                    i = i + 1
                else
                    break
                end
            end
            local c = string.sub( s, i, i )
            if c == "}" then
                i = i + 1
                return t
            end
            local k = parseString()
            while true do
                local c = string.sub( s, i, i )
                if c == " " or c == "\n" or c == "\t" or c == "\r" then
                    i = i + 1
                else
                    break
                end
            end
            c = string.sub( s, i, i )
            if c ~= ":" then
                return nil, "expected ':'"
            end
            i = i + 1
            local v = parseValue()
            t[k] = v
            while true do
                local c = string.sub( s, i, i )
                if c == " " or c == "\n" or c == "\t" or c == "\r" then
                    i = i + 1
                else
                    break
                end
            end
            c = string.sub( s, i, i )
            if c == "," then
                i = i + 1
            elseif c ~= "}" then
                return nil, "expected ',' or '}'"
            end
        end
    end
    function parseArray()
        i = i + 1
        local t = {}
        local n = 1
        while true do
            while true do
                local c = string.sub( s, i, i )
                if c == " " or c == "\n" or c == "\t" or c == "\r" then
                    i = i + 1
                else
                    break
                end
            end
            local c = string.sub( s, i, i )
            if c == "]" then
                i = i + 1
                return t
            end
            local v = parseValue()
            t[n] = v
            n = n + 1
            while true do
                local c = string.sub( s, i, i )
                if c == " " or c == "\n" or c == "\t" or c == "\r" then
                    i = i + 1
                else
                    break
                end
            end
            c = string.sub( s, i, i )
            if c == "," then
                i = i + 1
            elseif c ~= "]" then
                return nil, "expected ',' or ']'"
            end
        end
    end
    function parseString()
        i = i + 1
        local str = ""
        while true do
            local c = string.sub( s, i, i )
            if c == "\"" then
                i = i + 1
                return str
            elseif c == "\\" then
                i = i + 1
                c = string.sub( s, i, i )
                if c == "n" then
                    str = str .. "\n"
                elseif c == "t" then
                    str = str .. "\t"
                elseif c == "r" then
                    str = str .. "\r"
                elseif c == "b" then
                    str = str .. "\b"
                elseif c == "f" then
                    str = str .. "\f"
                elseif c == "/" then
                    str = str .. "/"
                elseif c == "\\" then
                    str = str .. "\\"
                elseif c == "\"" then
                    str = str .. "\""
                elseif c == "u" then
                    i = i + 1
                    local h = string.sub( s, i, i+3 )
                    i = i + 3
                    str = str .. utf8.char( tonumber( h, 16 ) )
                else
                    return nil, "invalid escape sequence"
                end
            else
                str = str .. c
            end
            i = i + 1
        end
    end
    function parseKeyword()
        if string.sub( s, i, i+3 ) == "true" then
            i = i + 4
            return true
        elseif string.sub( s, i, i+4 ) == "false" then
            i = i + 5
            return false
        elseif string.sub( s, i, i+3 ) == "null" then
            i = i + 4
            return nil
        else
            return nil, "invalid keyword"
        end
    end
    function parseNumber()
        local start = i
        while true do
            local c = string.sub( s, i, i )
            if (c >= "0" and c <= "9") or c == "." or c == "e" or c == "E" or c == "+" or c == "-" then
                i = i + 1
            else
                break
            end
        end
        return tonumber( string.sub( s, start, i-1 ) )
    end
    local ok, val = pcall( parseValue )
    if ok then
        return val
    else
        return nil, val
    end
end

local function formatTime( nTime, bTwentyFourHour )
    local nHour = math.floor( nTime )
    local nMinute = math.floor( (nTime - nHour) * 60 )
    if bTwentyFourHour then
        return string.format( "%02d:%02d", nHour, nMinute )
    else
        local sSuffix = "am"
        if nHour >= 12 then
            sSuffix = "pm"
            if nHour > 12 then
                nHour = nHour - 12
            end
        end
        if nHour == 0 then
            nHour = 12
        end
        return string.format( "%d:%02d%s", nHour, nMinute, sSuffix )
    end
end

textutils.slowWrite = slowWrite
textutils.slowPrint = slowPrint
textutils.tabulate = tabulate
textutils.pagedTabulate = pagedTabulate
textutils.pagedPrint = pagedPrint
textutils.serialize = serialize
textutils.unserialize = unserialize
textutils.serializeJSON = serializeJSON
textutils.unserializeJSON = unserializeJSON
textutils.formatTime = formatTime
textutils.complete = native.textutils_complete
textutils.find = native.textutils_find
textutils.urlEncode = native.textutils_urlEncode
textutils.json_decode = unserializeJSON
textutils.json_encode = serializeJSON

return textutils
