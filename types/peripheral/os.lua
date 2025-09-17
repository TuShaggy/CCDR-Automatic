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

local os = {}

local function queueEvent( ... )
    native.os_queueEvent( ... )
end

local function startTimer( n )
    if type(n) ~= "number" or n < 0 then
        error( "bad argument #1 (number expected)", 2 )
    end
    return native.os_startTimer( n )
end

local function pullEvent( sFilter )
    if sFilter and type(sFilter) ~= "string" then
        error( "bad argument #1 (string expected)", 2 )
    end
    while true do
        local tEventArgs = { native.os_pullEvent() }
        if #tEventArgs > 0 then
            if not sFilter or tEventArgs[1] == sFilter then
                return unpack( tEventArgs )
            end
        end
    end
end

local function pullEventRaw( sFilter )
    if sFilter and type(sFilter) ~= "string" then
        error( "bad argument #1 (string expected)", 2 )
    end
    while true do
        local tEventArgs = { native.os_pullEventRaw() }
        if #tEventArgs > 0 then
            if not sFilter or tEventArgs[1] == sFilter then
                return unpack( tEventArgs )
            end
        end
    end
end

local function getComputerID()
    return native.os_getComputerID()
end

local function computerID()
    return native.os_getComputerID()
end

local function getComputerLabel()
    return native.os_getComputerLabel()
end

local function computerLabel()
    return native.os_getComputerLabel()
end

local function setComputerLabel( s )
    if s and type(s) ~= "string" then
        error( "bad argument #1 (string expected)", 2 )
    end
    native.os_setComputerLabel( s )
end

local function run( tEnv, sPath, ... )
    if type(tEnv) ~= "table" then
        error( "bad argument #1 (table expected)", 2 )
    end
    if type(sPath) ~= "string" then
        error( "bad argument #2 (string expected)", 2 )
    end
    local fn, err = loadfile( sPath, tEnv )
    if fn then
        local ok, err = pcall( fn, ... )
        if ok then
            return true
        else
            return false, err
        end
    else
        return false, err
    end
end

local function loadAPI( sPath )
    if type(sPath) ~= "string" then
        error( "bad argument #1 (string expected)", 2 )
    end
    if not fs.exists( sPath ) or fs.isDir( sPath ) then
        return false
    end
    local tEnv = {}
    setmetatable( tEnv, { __index = _G } )
    local fn, err = loadfile( sPath, tEnv )
    if fn then
        local ok, err = pcall( fn )
        if ok then
            for k,v in pairs( tEnv ) do
                if k ~= "_G" then
                    _G[k] = v
                end
            end
            return true
        else
            printError( err )
            return false
        end
    else
        printError( err )
        return false
    end
end

local function unloadAPI( sName )
    if type(sName) ~= "string" then
        error( "bad argument #1 (string expected)", 2 )
    end
    if _G[sName] then
        _G[sName] = nil
    end
end

local function apis()
    local tApis = {}
    for sDir in string.gmatch( settings.get( "bios.lua.api_path" ), "([^;]+)" ) do
        sDir = fs.combine( "/", sDir )
        if fs.isDir( sDir ) then
            local tFiles = fs.list( sDir )
            for i, sFile in ipairs( tFiles ) do
                if not fs.isDir( fs.combine( sDir, sFile ) ) then
                    local sName = sFile
                    if string.sub( sName, -4 ) == ".lua" then
                        sName = string.sub( sName, 1, -5 )
                    end
                    if not tApis[sName] then
                        tApis[sName] = true
                    end
                end
            end
        end
    end
    local tApiList = {}
    for sName in pairs( tApis ) do
        table.insert( tApiList, sName )
    end
    table.sort( tApiList )
    return tApiList
end

local function shutdown()
    native.os_shutdown()
end

local function reboot()
    native.os_reboot()
end

local function time( sLocation )
    if sLocation == nil then sLocation = "ingame" end
    if type(sLocation) ~= "string" then
        error( "bad argument #1 (string expected)", 2 )
    end
    return native.os_time( sLocation )
end

local function day()
    return native.os_day()
end

local function clock()
    return native.os_clock()
end

local function epoch( sLocation )
    if sLocation == nil then sLocation = "utc" end
    if type(sLocation) ~= "string" then
        error( "bad argument #1 (string expected)", 2 )
    end
    return native.os_epoch( sLocation )
end

local function date( format, time )
    return native.os_date( format, time )
end

os.queueEvent = queueEvent
os.startTimer = startTimer
os.pullEvent = pullEvent
os.pullEventRaw = pullEventRaw
os.getComputerID = getComputerID
os.computerID = computerID
os.getComputerLabel = getComputerLabel
os.computerLabel = computerLabel
os.setComputerLabel = setComputerLabel
os.run = run
os.loadAPI = loadAPI
os.unloadAPI = unloadAPI
os.apis = apis
os.shutdown = shutdown
os.reboot = reboot
os.time = time
os.day = day
os.clock = clock
os.epoch = epoch
os.date = date
os.cancelTimer = native.os_cancelTimer
os.cancelAlarm = native.os_cancelAlarm
os.setAlarm = native.os_setAlarm
os.getPriority = native.os_getPriority
os.setPriority = native.os_setPriority

return os
