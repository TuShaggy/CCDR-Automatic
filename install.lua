local base = "https://raw.githubusercontent.com/TuShaggy/CCDR-Automatic/refs/heads/main/"

local function wget(url, filename, dir, nooverride)
    if nooverride and fs.exists((dir or ".")..'/'..filename..".lua") then 
        print("Skipped: " .. filename .. " (already exists)")
        return 
    end
    if dir then fs.makeDir(dir) end

    local res = http.get(url)
    if not res then error("Failed to download: " .. url) end

    local path = (dir or ".") .. '/' .. filename .. ".lua"
    local fd = fs.open(path, "w")
    fd.write(res.readAll())
    fd.close()
    res.close()
    print("Downloaded: " .. path)
end

-- Lista manual de archivos basada en tu repositorio
local filelist = {
    { file = "colors" },
    { file = "install" },
    { file = "main" },
    { file = "peripherals_config", nooverride = true },
    { file = "constructor", dir = "lib" },
    { file = "draconicreactor", dir = "lib" },
    { file = "drmon", dir = "lib" },
    { file = "monutil", dir = "lib" },
    { file = "util", dir = "lib" },
    { file = "impl_require", dir = "lib" },
}

print("Starting download from GitHub repository...")

for _, fileInfo in ipairs(filelist) do
    local dir = fileInfo.dir or "."
    local filename = fileInfo.file
    local url = base .. (dir == "." and "" or dir .. "/") .. filename .. ".lua"
    
    local status, err = pcall(wget, url, filename, fileInfo.dir, fileInfo.nooverride)
    if not status then 
        printError("Error downloading " .. filename .. ": " .. tostring(err))
    end
end

print("Installation complete!")