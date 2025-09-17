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

local fs = {}

local function complete( sPath, sLocation )
    if not sLocation or sLocation == "" then
        sLocation = "/"
    end
    if string.sub( sPath, 1, 1 ) ~= "/" then
        -- Relative path
        if string.sub( sLocation, -1, -1 ) ~= "/" then
            sLocation = fs.getDir( sLocation )
        end
        sPath = sLocation .. sPath
    end

    -- Remove "/./"
    sPath = string.gsub( sPath, "/%./", "/" )

    -- Remove "/../"
    while string.find( sPath, "/../" ) do
        sPath = string.gsub( sPath, "(/[^/]+)/../", "/" )
    end

    return sPath
end

local function combine( sPath, sChildPath )
    if type(sPath) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if type(sChildPath) ~= "string" then
        error( "bad argument #2 (expected string)", 2 )
    end
    return complete( sChildPath, sPath )
end

local function getDir( sPath )
    if type(sPath) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    local i = #sPath
    while i > 0 do
        if string.sub( sPath, i, i ) == "/" then
            if i == 1 then
                return "/"
            else
                return string.sub( sPath, 1, i - 1 )
            end
        end
        i = i - 1
    end
    return ""
end

local function getName( sPath )
    if type(sPath) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    local i = #sPath
    while i > 0 do
        if string.sub( sPath, i, i ) == "/" then
            return string.sub( sPath, i + 1 )
        end
        i = i - 1
    end
    return sPath
end

local function getDrive( sPath )
    if type(sPath) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if fs.isDriveRoot( sPath ) then
        return sPath
    end
    local name = fs.getName( sPath )
    local dir = fs.getDir( sPath )
    if dir == "" and name ~= "" and not fs.isDriveRoot( name ) then
        return nil
    end
    return fs.getDrive( dir )
end

local function makeDir( sPath )
    if type(sPath) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if fs.exists( sPath ) then
        if not fs.isDir( sPath ) then
            error( "File exists", 2 )
        end
    else
        local parent = fs.getDir( sPath )
        if parent ~= "" and not fs.isDir( parent ) then
            error( "Access denied", 2 )
        end
        return native.fs_makeDir( sPath )
    end
end

local function move( sPathFrom, sPathTo )
    if type(sPathFrom) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if type(sPathTo) ~= "string" then
        error( "bad argument #2 (expected string)", 2 )
    end
    if not fs.exists( sPathFrom ) then
        error( "No such file", 2 )
    end
    if fs.exists( sPathTo ) then
        error( "File exists", 2 )
    end
    local parent = fs.getDir( sPathTo )
    if parent ~= "" and not fs.isDir( parent ) then
        error( "Access denied", 2 )
    end
    return native.fs_move( sPathFrom, sPathTo )
end

local function copy( sPathFrom, sPathTo )
    if type(sPathFrom) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if type(sPathTo) ~= "string" then
        error( "bad argument #2 (expected string)", 2 )
    end
    if not fs.exists( sPathFrom ) then
        error( "No such file", 2 )
    end
    if fs.isDir( sPathFrom ) then
        error( "Cannot copy directories", 2 )
    end
    if fs.exists( sPathTo ) then
        error( "File exists", 2 )
    end
    local parent = fs.getDir( sPathTo )
    if parent ~= "" and not fs.isDir( parent ) then
        error( "Access denied", 2 )
    end
    return native.fs_copy( sPathFrom, sPathTo )
end

local function delete( sPath )
    if type(sPath) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if fs.isDir( sPath ) then
        if #fs.list( sPath ) > 0 then
            error( "Directory not empty", 2 )
        end
    end
    return native.fs_delete( sPath )
end

local function open( sPath, sMode )
    if type(sPath) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if type(sMode) ~= "string" then
        error( "bad argument #2 (expected string)", 2 )
    end

    local parent = fs.getDir( sPath )
    if parent ~= "" and not fs.isDir( parent ) then
        error( "Access denied", 2 )
    end

    local handle, err = native.fs_open( sPath, sMode )
    if handle then
        if string.find( sMode, "b" ) then
            -- Binary mode
            local tMethods = {
                read = function( self, n )
                    if n == 0 then return "" end
                    if n == nil then
                        local bytes = self.readAll()
                        if bytes ~= nil then return bytes end
                        return nil
                    end
                    if type(n) ~= "number" or n < 0 then
                        error( "bad argument #1 (expected number)", 2 )
                    end
                    local byte = native.handle_read( handle, n )
                    if byte ~= nil then return byte end
                    return nil
                end,
                readAll = function( self )
                    local bytes = native.handle_readAll( handle )
                    if bytes ~= nil then return bytes end
                    return nil
                end,
                readLine = function( self, withTrailing )
                    error( "Cannot read lines from a binary file", 2 )
                end,
                write = function( self, sText )
                    if type(sText) == "number" then
                        if sText < 0 or sText > 255 then
                            error( "bad argument #1 (number between 0 and 255 expected)", 2 )
                        end
                        return native.handle_write( handle, string.char(sText) )
                    elseif type(sText) ~= "string" then
                        error( "bad argument #1 (expected string or byte)", 2 )
                    end
                    return native.handle_write( handle, sText )
                end,
                writeLine = function( self, sText )
                    error( "Cannot write lines to a binary file", 2 )
                end,
                flush = function( self )
                    return native.handle_flush( handle )
                end,
                close = function( self )
                    return native.handle_close( handle )
                end,
                seek = function( self, whence, offset )
                    return native.handle_seek( handle, whence, offset )
                end,
            }
            return setmetatable( {}, { __index = tMethods } )
        else
            -- Text mode
            local tMethods = {
                read = function( self, n )
                    if n == 0 then return "" end
                    if n == nil then
                        local line = self.readLine()
                        if line ~= nil then return line end
                        return nil
                    elseif n == "*" then
                        -- Backwards compatibility
                        local line = self.readLine()
                        if line ~= nil then return line end
                        return nil
                    elseif type(n) == "string" and n == "*a" then
                        return self.readAll()
                    elseif type(n) == "string" and n == "*l" then
                        return self.readLine()
                    elseif type(n) == "string" and n == "*L" then
                        return self.readLine( true )
                    elseif type(n) ~= "number" or n < 0 then
                        error( "bad argument #1 (expected number or format)", 2 )
                    end
                    local str = native.handle_read( handle, n )
                    if str ~= nil then return str end
                    return nil
                end,
                readAll = function( self )
                    local str = native.handle_readAll( handle )
                    if str ~= nil then return str end
                    return nil
                end,
                readLine = function( self, withTrailing )
                    local str = native.handle_readLine( handle )
                    if str ~= nil then
                        if not withTrailing then
                            local len = #str
                            if len > 0 and str:sub(len) == "\n" then
                                len = len - 1
                                if len > 0 and str:sub(len,len) == "\r" then
                                    len = len - 1
                                end
                                return str:sub(1, len)
                            end
                        end
                        return str
                    end
                    return nil
                end,
                write = function( self, sText )
                    if type(sText) ~= "string" and type(sText) ~= "number" then
                        error( "bad argument #1 (expected string)", 2 )
                    end
                    return native.handle_write( handle, tostring(sText) )
                end,
                writeLine = function( self, sText )
                    if type(sText) ~= "string" and type(sText) ~= "number" then
                        error( "bad argument #1 (expected string)", 2 )
                    end
                    return native.handle_write( handle, tostring(sText) .. "\n" )
                end,
                flush = function( self )
                    return native.handle_flush( handle )
                end,
                close = function( self )
                    return native.handle_close( handle )
                end,
                seek = function( self, whence, offset )
                    error( "Cannot seek in a text file", 2 )
                end,
            }
            return setmetatable( {}, { __index = tMethods } )
        end
    end
    return nil, err
end

local function find( sPath )
    if type(sPath) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    local results = native.fs_find( sPath )
    if results then
        local i = 0
        return function()
            i = i + 1
            if results[i] then
                return results[i]
            end
        end
    end
    return nil
end

fs.list = native.fs_list
fs.exists = native.fs_exists
fs.isDir = native.fs_isDir
fs.isReadOnly = native.fs_isReadOnly
fs.getName = getName
fs.getDir = getDir
fs.getSize = native.fs_getSize
fs.getFreeSpace = native.fs_getFreeSpace
fs.makeDir = makeDir
fs.move = move
fs.copy = copy
fs.delete = delete
fs.combine = combine
fs.open = open
fs.find = find
fs.getDrive = getDrive
fs.getCapacity = native.fs_getCapacity
fs.isDriveRoot = native.fs_isDriveRoot
fs.complete = function( sPath, sLocation )
    if type(sPath) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if type(sLocation) ~= "string" then
        error( "bad argument #2 (expected string)", 2 )
    end
    local sCompleted = complete( sPath, sLocation )
    local sDir = getDir( sCompleted )
    local sName = getName( sCompleted )
    if not fs.exists( sDir ) then
        return {}
    end
    local tFiles = fs.list( sDir )
    local tCompletions = {}
    for n,sFile in pairs( tFiles ) do
        if string.sub( sFile, 1, #sName ) == sName then
            local sResult = sFile
            if fs.isDir( combine( sDir, sFile ) ) then
                sResult = sResult .. "/"
            end
            table.insert( tCompletions, sResult )
        end
    end
    return tCompletions
end

return fs
