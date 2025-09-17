local base = "https://raw.githubusercontent.com/TuShaggy/CCDR-Automatic/refs/heads/main/"
local api_base = "https://api.github.com/repos/TuShaggy/CCDR-Automatic/contents"

local function wget(url, filename, dir, nooverride)
    if nooverride and fs.exists(dir..'/'..filename) then return end
    if dir then fs.makeDir(dir) end

    local res = http.get(url)
    if not res then error("Failed to download: " .. url) end

    local fd = fs.open(dir .. '/' .. filename, "w")
    fd.write(res.readAll())
    fd.close()
    res.close()
    print("Downloaded: " .. (dir and dir.."/" or "") .. filename)
end

local function getRepoFiles(path)
    path = path or ""
    local url = path == "" and api_base or api_base .. "/" .. path
    local res = http.get(url)
    if not res then 
        printError("Failed to get repo contents from: " .. url)
        return {}
    end
    
    local content = res.readAll()
    res.close()
    
    local files = textutils.unserialiseJSON(content)
    if not files then
        printError("Failed to parse JSON from GitHub API")
        return {}
    end
    
    local filelist = {}
    
    for _, item in ipairs(files) do
        if item.type == "file" and item.name:match("%.lua$") then
            local dir = path == "" and "." or path
            table.insert(filelist, {
                file = item.name:gsub("%.lua$", ""),
                dir = dir == "." and nil or dir,
                url = item.download_url,
                nooverride = item.name == "peripherals_config.lua"
            })
        elseif item.type == "dir" then
            -- Recursively get files from subdirectories
            local subFiles = getRepoFiles(item.path)
            for _, subFile in ipairs(subFiles) do
                table.insert(filelist, subFile)
            end
        end
    end
    
    return filelist
end

print("Getting file list from GitHub repository...")
local filelist = getRepoFiles()

if #filelist == 0 then
    printError("No files found in repository!")
    return
end

print("Found " .. #filelist .. " Lua files. Starting download...")

local function fork(value)
    local dir = value.dir or "."
    local filename = value.file .. ".lua"
    local fileurl = value.url or base .. (dir == "." and "" or dir .. "/") .. filename
    
    local status, err = pcall(wget, fileurl, value.file, dir, value.nooverride)
    if not status then 
        printError("wget " .. fileurl .. " -> " .. filename .. " error! " .. tostring(err))
    end
end

local function fork2(index)
    local value = filelist[index]
    if value == nil then return end

    parallel.waitForAll(
        function() fork2(index+1) end,
        function() fork(value) end
    )
end

fork2(1)
print("Installation complete!")