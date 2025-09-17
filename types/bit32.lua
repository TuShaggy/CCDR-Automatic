-- Fallback implementation of the bit32 API for Lua 5.1.
-- Copyright (C) 2012-2013 Lua.org, PUC-Rio.
-- See Copyright Notice at the end of this file.

-- This is a straight port of the C implementation, with some obvious
-- simplifications for a Lua implementation.

local math = math
local type = type
local error = error
local select = select
local tonumber = tonumber
local pcall = pcall
local floor = math.floor

local function tobit(x)
  return floor(x)
end

local function checkint(n, arg)
  local x = tonumber(select(n, ...))
  if not x then
    error("bad argument #"..arg.." (number expected, got no value)", 2)
  end
  return tobit(x)
end

local function checkint_any(n, arg)
  local x = select(n, ...)
  if x == nil then
    error("bad argument #"..arg.." (value expected)", 2)
  end
  x = tonumber(x)
  if not x then
    error("bad argument #"..arg.." (number has no integer representation)", 2)
  end
  return tobit(x)
end

local function b_and(...)
  local res = -1
  for i=1,select('#', ...) do
    res = res & checkint(i, i, ...)
  end
  return res
end

local function b_or(...)
  local res = 0
  for i=1,select('#', ...) do
    res = res | checkint(i, i, ...)
  end
  return res
end

local function b_xor(...)
  local res = 0
  for i=1,select('#', ...) do
    res = res ~ checkint(i, i, ...)
  end
  return res
end

local function b_not(x)
  return -1 ~ checkint_any(1, 1, x)
end

local function b_lshift(x, y)
  x = checkint_any(1, 1, x)
  y = checkint_any(2, 2, y)
  if y < 0 then
    if y <= -32 then return 0 end
    return tobit(x / 2^-y)
  else
    if y >= 32 then return 0 end
    return tobit(x * 2^y)
  end
end

local function b_rshift(x, y)
  x = checkint_any(1, 1, x)
  y = checkint_any(2, 2, y)
  if y < 0 then
    if y <= -32 then return 0 end
    return tobit(x * 2^-y)
  else
    if y >= 32 then return 0 end
    return tobit(x / 2^y)
  end
end

local function b_arshift(x, y)
  x = checkint_any(1, 1, x)
  y = checkint_any(2, 2, y)
  if y < 0 then
    if y <= -32 then
      if x < 0 then return -1 else return 0 end
    end
    return tobit(x * 2^-y)
  else
    if y >= 32 then
      if x < 0 then return -1 else return 0 end
    end
    if x < 0 then
      return tobit(-(-x / 2^y))
    else
      return tobit(x / 2^y)
    end
  end
end

local function b_extract(n, field, width)
  n = checkint_any(1, 1, n)
  field = checkint_any(2, 2, field)
  width = checkint(3, 3, width)
  if field < 0 or field > 31 then
    error("bad argument #2 (field out of range)", 2)
  end
  if width <= 0 or field+width > 32 then
    error("bad argument #3 (width out of range)", 2)
  end
  return (n >> field) & ((1 << width) - 1)
end

local function b_replace(n, v, field, width)
  n = checkint_any(1, 1, n)
  v = checkint_any(2, 2, v)
  field = checkint_any(3, 3, field)
  width = checkint(4, 4, width)
  if field < 0 or field > 31 then
    error("bad argument #3 (field out of range)", 2)
  end
  if width <= 0 or field+width > 32 then
    error("bad argument #4 (width out of range)", 2)
  end
  local mask = ((1 << width) - 1)
  v = v & mask
  mask = mask << field
  return (n & ~mask) | (v << field)
end

return {
  band = b_and,
  bor = b_or,
  bxor = b_xor,
  bnot = b_not,
  lshift = b_lshift,
  rshift = b_rshift,
  arshift = b_arshift,
  extract = b_extract,
  replace = b_replace,
}

--[[
Copyright (C) 2012-2013 Lua.org, PUC-Rio.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
