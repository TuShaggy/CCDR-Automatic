local function loadConfig()
    if fs.exists("peripherals.cfg") then
        local file = fs.open("peripherals.cfg", "r")
        if file then
            local data = file.readAll()
            file.close()
            local config, err = textutils.unserialize(data)
            if config then
                return config
            end
        end
    end
    return nil
end

local function saveConfig(config)
    local file = fs.open("peripherals.cfg", "w")
    if file then
        file.write(textutils.serialize(config))
        file.close()
    end
end

local config = loadConfig()
if config then
    return config
end

term.clear()
term.setCursorPos(1, 1)

local function findPeripherals(types)
    local names = peripheral.getNames()
    local found = {}
    for _, name in ipairs(names) do
        local per = peripheral.wrap(name)
        if per then
            for _, pType in ipairs(types) do
                if per.getType() == pType then
                    table.insert(found, name)
                    break
                end
            end
        end
    end
    return found
end

local function choosePeripheral(prompt, types, optional)
    local peripherals = findPeripherals(types)
    if #peripherals == 0 then
        if optional then return nil end
        error("No peripheral of type " .. table.concat(types, "/") .. " found.")
    end
    if #peripherals == 1 then
        return peripherals[1]
    end

    while true do
        print(prompt)
        for i, name in ipairs(peripherals) do
            print(string.format("[%d] %s", i, name))
        end
        io.write("> ")
        local input = io.read()
        local choice = tonumber(input)
        if choice and choice >= 1 and choice <= #peripherals then
            return peripherals[choice]
        end
        printError("Invalid selection.")
    end
end

local reactorName = choosePeripheral("Choose Draconic Reactor:", {"draconic_reactor"})
local inputGateName = choosePeripheral("Choose Input Flux Gate:", {"flux_gate", "flow_gate"})
local outputGateName = choosePeripheral("Choose Output Flux Gate:", {"flux_gate", "flow_gate"})
local monitorName = choosePeripheral("Choose Monitor (optional):", {"monitor"}, true)

local newConfig = {
    reactorName = reactorName,
    outputGateName = outputGateName,
    inputGateName = inputGateName,
    monitorName = monitorName
}

saveConfig(newConfig)
term.clear()
term.setCursorPos(1,1)

return newConfig