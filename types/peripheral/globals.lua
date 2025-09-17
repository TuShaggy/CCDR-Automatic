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

_CC_DEFAULT_SETTINGS = [[
#Default ComputerCraft client-side config settings
#Monitors are resizable by default
monitor_resizable=true
#Maximum distance for a user to be able to use a monitor
monitor_user_range=8
#The default width for a new fixed-size monitor
monitor_width=51
#The default height for a new fixed-size monitor
monitor_height=19

#The default width for a new fixed-size turtle
turtle_width=39
#The default height for a new fixed-size turtle
turtle_height=13

#The default width for a new fixed-size pocket computer
pocket_width=26
#The default height for a new fixed-size pocket computer
pocket_height=20
]]

_HOST = "ComputerCraft 1.100.0 (CraftOS 1.8)"

function sleep( nTime )
    if nTime == nil then
        os.pullEvent( "timer" )
    elseif type(nTime) == "number" and nTime > 0 then
        os.startTimer( nTime )
        os.pullEvent( "timer" )
    end
end

function write( sText )
    local s = tostring(sText)
    local w, h = term.getSize()
    local x, y = term.getCursorPos()
    term.setCursorPos( x + #s, y )
    term.write( s )
end

function print( ... )
    local tArgs = {...}
    local sLine = ""
    for i=1, #tArgs do
        if i > 1 then
            sLine = sLine .. "\t"
        end
        sLine = sLine .. tostring(tArgs[i])
    end
    term.write( sLine )
    term.scroll( 1 )
    local w, h = term.getSize()
    local x, y = term.getCursorPos()
    term.setCursorPos( 1, y )
end

function printError( ... )
    local tArgs = {...}
    local sLine = ""
    for i=1, #tArgs do
        if i > 1 then
            sLine = sLine .. "\t"
        end
        sLine = sLine .. tostring(tArgs[i])
    end

    local oldTextColor = term.getTextColor()
    term.setTextColor( colors.red )
    term.write( sLine )
    term.scroll( 1 )
    local w, h = term.getSize()
    local x, y = term.getCursorPos()
    term.setCursorPos( 1, y )
    term.setTextColor( oldTextColor )
end

function read( sReplaceChar, _tHistory, _fnComplete, _sDefault )
    term.setCursorBlink( true )

    local sLine = ""
    if type(_sDefault) == "string" then
        sLine = _sDefault
        term.write( sLine )
    end

    local nHistoryPos = nil
    if _tHistory then
        nHistoryPos = #_tHistory + 1
    end

    local nCursorPos = #sLine + 1

    local bRunning = true
    while bRunning do
        local event, param1, param2, param3 = os.pullEvent()
        if event == "char" then
            sLine = string.sub( sLine, 1, nCursorPos - 1 ) .. param1 .. string.sub( sLine, nCursorPos )
            term.write( param1 )
            local after = string.sub( sLine, nCursorPos + 1 )
            if #after > 0 then
                term.write( after )
                local cx, cy = term.getCursorPos()
                term.setCursorPos( cx - #after, cy )
            end
            nCursorPos = nCursorPos + 1

        elseif event == "key" then
            if param1 == 28 then -- Enter
                bRunning = false

            elseif param1 == 14 then -- Backspace
                if nCursorPos > 1 then
                    local before = string.sub( sLine, 1, nCursorPos - 2 )
                    local after = string.sub( sLine, nCursorPos )
                    sLine = before .. after
                    local cx, cy = term.getCursorPos()
                    term.setCursorPos( cx - 1, cy )
                    term.write( after .. " " )
                    term.setCursorPos( cx - 1, cy )
                    nCursorPos = nCursorPos - 1
                end

            elseif param1 == 211 then -- Delete
                if nCursorPos -1 < #sLine then
                    local before = string.sub( sLine, 1, nCursorPos - 1 )
                    local after = string.sub( sLine, nCursorPos + 1 )
                    sLine = before .. after
                    local cx, cy = term.getCursorPos()
                    term.write( after .. " " )
                    term.setCursorPos( cx, cy )
                end

            elseif param1 == 203 then -- Left
                if nCursorPos > 1 then
                    local cx, cy = term.getCursorPos()
                    term.setCursorPos( cx - 1, cy )
                    nCursorPos = nCursorPos - 1
                end

            elseif param1 == 205 then -- Right
                if nCursorPos - 1 < #sLine then
                    local cx, cy = term.getCursorPos()
                    term.setCursorPos( cx + 1, cy )
                    nCursorPos = nCursorPos + 1
                end

            elseif param1 == 199 then -- Home
                local cx, cy = term.getCursorPos()
                term.setCursorPos( cx - (nCursorPos - 1), cy )
                nCursorPos = 1

            elseif param1 == 207 then -- End
                local cx, cy = term.getCursorPos()
                term.setCursorPos( cx + (#sLine - (nCursorPos - 1)), cy )
                nCursorPos = #sLine + 1

            elseif param1 == 200 and _tHistory then -- Up
                if nHistoryPos > 1 then
                    nHistoryPos = nHistoryPos - 1
                    local cx, cy = term.getCursorPos()
                    term.setCursorPos( cx - (nCursorPos - 1), cy )
                    term.clearLine()
                    sLine = _tHistory[nHistoryPos]
                    term.write( sLine )
                    nCursorPos = #sLine + 1
                end

            elseif param1 == 208 and _tHistory then -- Down
                if nHistoryPos < #_tHistory then
                    nHistoryPos = nHistoryPos + 1
                    local cx, cy = term.getCursorPos()
                    term.setCursorPos( cx - (nCursorPos - 1), cy )
                    term.clearLine()
                    sLine = _tHistory[nHistoryPos]
                    term.write( sLine )
                    nCursorPos = #sLine + 1
                elseif nHistoryPos == #_tHistory then
                    nHistoryPos = nHistoryPos + 1
                    local cx, cy = term.getCursorPos()
                    term.setCursorPos( cx - (nCursorPos - 1), cy )
                    term.clearLine()
                    sLine = ""
                    nCursorPos = 1
                end

            elseif param1 == 15 and _fnComplete then -- Tab
                local sBefore = string.sub( sLine, 1, nCursorPos - 1 )
                local tCompletions = _fnComplete( sBefore )
                if #tCompletions > 0 then
                    local sFirst = tCompletions[1]
                    if #tCompletions == 1 then
                        -- Complete to the only entry
                        local sAfter = string.sub( sLine, nCursorPos )
                        local sAddition = string.sub( sFirst, #sBefore + 1 )
                        sLine = sBefore .. sAddition .. sAfter
                        term.write( sAddition )
                        nCursorPos = nCursorPos + #sAddition
                        if #sAfter > 0 then
                            term.write( sAfter )
                            local cx, cy = term.getCursorPos()
                            term.setCursorPos( cx - #sAfter, cy )
                        end
                    else
                        -- Complete to the common root of all entries
                        local sRoot = ""
                        for i=1, #sFirst do
                            local sChar = string.sub( sFirst, i, i )
                            local bShared = true
                            for j=2, #tCompletions do
                                local sOther = tCompletions[j]
                                if string.sub( sOther, i, i ) ~= sChar then
                                    bShared = false
                                    break
                                end
                            end
                            if bShared then
                                sRoot = sRoot .. sChar
                            else
                                break
                            end
                        end

                        if #sRoot > #sBefore then
                            local sAfter = string.sub( sLine, nCursorPos )
                            local sAddition = string.sub( sRoot, #sBefore + 1 )
                            sLine = sBefore .. sAddition .. sAfter
                            term.write( sAddition )
                            nCursorPos = nCursorPos + #sAddition
                            if #sAfter > 0 then
                                term.write( sAfter )
                                local cx, cy = term.getCursorPos()
                                term.setCursorPos( cx - #sAfter, cy )
                            end
                        end
                    end
                end
            end

        elseif event == "paste" and type(param1) == "string" then
            sLine = string.sub( sLine, 1, nCursorPos - 1 ) .. param1 .. string.sub( sLine, nCursorPos )
            term.write( param1 )
            local after = string.sub( sLine, nCursorPos + #param1 )
            if #after > 0 then
                term.write( after )
                local cx, cy = term.getCursorPos()
                term.setCursorPos( cx - #after, cy )
            end
            nCursorPos = nCursorPos + #param1

        elseif event == "term_resize" then
            -- Do nothing, just redraw
            local cx, cy = term.getCursorPos()
            term.setCursorPos( 1, cy )
            term.clearLine()
            term.write( sLine )
            term.setCursorPos( cx, cy )
        end
    end

    term.setCursorBlink( false )
    term.scroll( 1 )
    local w, h = term.getSize()
    local x, y = term.getCursorPos()
    term.setCursorPos( 1, y )

    if _tHistory and #sLine > 0 then
        table.insert( _tHistory, sLine )
    end

    if sReplaceChar then
        local len = #sLine
        sLine = ""
        for i=1,len do
            sLine = sLine .. sReplaceChar
        end
    end

    return sLine
end

function getsysteminfo()
    return {
        bios = {
            ["6.0"] = 0x80000000,
        },
        os = {
            version = "1.8",
        },
        runtime = {
            ["lua_version"] = "5.2",
            ["craftos_version"] = "1.8",
        },
        computer = {
            id = os.getcomputerid(),
            label = os.getcomputerlabel(),
            ["advanced"] = term.iscolor(),
        },
        session = {
            ["started_time"] = os.time(),
            ["trusted"] = true,
        },
    }
end

function _G.assert(value, message, ...)
    if not value then
        if message == nil then
            error("assertion failed!", 2)
        elseif type(message) ~= "string" then
            return message, ...
        else
            error(message, 2)
        end
    end
    return value, message, ...
end
