-- Implementation of require function for ComputerCraft
local loaded = {}
local loading = {}

function require(name)
    if loaded[name] then
        return loaded[name]
    end
    
    if loading[name] then
        error("circular dependency detected: " .. name, 2)
    end
    
    loading[name] = true
    
    local path = name:gsub("%.", "/") .. ".lua"
    
    if not fs.exists(path) then
        error("module '" .. name .. "' not found", 2)
    end
    
    local func, err = loadfile(path)
    if not func then
        error("error loading module '" .. name .. "': " .. err, 2)
    end
    
    local result = func()
    loaded[name] = result or true
    loading[name] = nil
    
    return loaded[name]
end
