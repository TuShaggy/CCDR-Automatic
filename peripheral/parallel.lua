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

local parallel = {}

local function pcall( f, ... )
    local co = coroutine.create( f )
    local ok, err = coroutine.resume( co, ... )
    if not ok then
        error( err, 2 )
    end
end

local function waitForAll( ... )
    local fns = { ... }
    local threads = {}
    for i, fn in ipairs( fns ) do
        threads[i] = coroutine.create( fn )
    end

    local running = true
    while running do
        running = false
        for i, co in ipairs( threads ) do
            if coroutine.status( co ) ~= "dead" then
                running = true
                local ok, err = coroutine.resume( co )
                if not ok then
                    error( err, 2 )
                end
            end
        end
    end
end

local function waitForAny( ... )
    local fns = { ... }
    local threads = {}
    for i, fn in ipairs( fns ) do
        threads[i] = coroutine.create( fn )
    end

    while true do
        for i, co in ipairs( threads ) do
            if coroutine.status( co ) ~= "dead" then
                local ok, err = coroutine.resume( co )
                if not ok then
                    error( err, 2 )
                end
                if coroutine.status( co ) == "dead" then
                    return
                end
            end
        end
    end
end

parallel.waitForAll = waitForAll
parallel.waitForAny = waitForAny

return parallel
