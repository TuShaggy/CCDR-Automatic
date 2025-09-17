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
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local peripheral = {}

local function getNames()
    return native.peripheral_getNames()
end

local function isPresent( sName )
    if type(sName) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    return native.peripheral_isPresent( sName )
end

local function getType( sName )
    if type(sName) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if isPresent( sName ) then
        return native.peripheral_getType( sName )
    end
    return nil
end

local function getMethods( sName )
    if type(sName) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if isPresent( sName ) then
        return native.peripheral_getMethods( sName )
    end
    return nil
end

local function call( sName, sMethod, ... )
    if type(sName) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if type(sMethod) ~= "string" then
        error( "bad argument #2 (expected string)", 2 )
    end
    if isPresent( sName ) then
        return native.peripheral_call( sName, sMethod, ... )
    end
    error( "No peripheral attached", 2 )
end

local function wrap( sName )
    if type(sName) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if isPresent( sName ) then
        local tMethods = getMethods( sName )
        if tMethods then
            local tPeripheral = {}
            for n, sMethod in pairs( tMethods ) do
                tPeripheral[sMethod] = function( ... )
                    return call( sName, sMethod, ... )
                end
            end
            return tPeripheral
        end
        return nil
    end
    return nil
end

local function find( sType, filter )
    if type(sType) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if filter and type(filter) ~= "function" then
        error( "bad argument #2 (expected function)", 2 )
    end

    for _, name in ipairs(getNames()) do
        if getType(name) == sType then
            local wrapped = wrap(name)
            if not filter or filter(name, wrapped) then
                return wrapped
            end
        end
    end
    return nil
end

local function getHost( name )
    if type(name) ~= "string" then
        error( "bad argument #1 (expected string)", 2 )
    end
    if not isPresent( name ) then
        error( "No peripheral attached", 2 )
    end
    return native.peripheral_getHost( name )
end

peripheral.getNames = getNames
peripheral.isPresent = isPresent
peripheral.getType = getType
peripheral.getMethods = getMethods
peripheral.call = call
peripheral.wrap = wrap
peripheral.find = find
peripheral.getName = native.peripheral_getName
peripheral.getNamesRemote = native.peripheral_getNamesRemote
peripheral.isPresentRemote = native.peripheral_isPresentRemote
peripheral.getTypeRemote = native.peripheral_getTypeRemote
peripheral.getMethodsRemote = native.peripheral_getMethodsRemote
peripheral.callRemote = native.peripheral_callRemote
peripheral.getRemote = native.peripheral_getRemote
peripheral.transmit = native.peripheral_transmit
peripheral.getHost = getHost

return peripheral
