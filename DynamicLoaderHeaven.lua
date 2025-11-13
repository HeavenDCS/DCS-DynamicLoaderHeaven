--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                         HeavenLoader v1.1                             ║
    ║                   Hides your code from mission files                  ║
    ╚═══════════════════════════════════════════════════════════════════════╝
    
    HOW IT HIDES YOUR CODE:
    ✓ Mission file ONLY has one line (dofile)
    ✓ Your scripts are in a SEPARATE folder players can't access
    ✓ Your code stays PRIVATE 🔒
    
    INSTALLATION:
    1. Put this file in: Scripts\DynamicLoaderHeaven.lua
    2. Mission trigger (DO SCRIPT): dofile(lfs.writedir()..'Scripts\\DynamicLoaderHeaven.lua')
    3. Configure settings below
    4. Put your scripts in the folder you specify
    
    CONFIGURATION:
    
    scriptDirectory - Where your scripts are
      Example: "C:\\MyScripts\\"
    
    alphabeticOrder - Load mode
      true  = Load all .lua files A-Z
      false = Load only scriptFiles list (priority order)
    
    scriptFiles - Your scripts in priority order (top = loads first)
      Example: {"init.lua", "main.lua", "functions.lua"}
    
    verbose - Logging detail
      true  = Detailed logs
      false = Quiet mode
    
    autoUpdate - Auto-reload scripts
      true  = Reload every X seconds
      false = Load once only
]]

-- ═══════════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════

local CONFIG = {
    scriptDirectory = lfs.writedir() .. "Scripts\\ServerSide\\",
    enabled = true,
    alphabeticOrder = false,
    scriptFiles = {
        "Moose.lua",
        "SARSystem.lua",
    },
    filePattern = "%.lua$",
    verbose = true,
    autoUpdate = false,
    updateInterval = 300,
}

-- ═══════════════════════════════════════════════════════════════════════
-- CODE
-- ═══════════════════════════════════════════════════════════════════════

local HeavenLoader = {
    version = "1.0",
    loadedScripts = {},
    updateTimer = nil,
}

local function log(message, level)
    level = level or "INFO"
    local fullMsg = "[HeavenLoader] " .. message
    
    if level == "ERROR" then
        env.error(fullMsg, false)
    elseif level == "WARN" then
        env.warning(fullMsg, false)
    else
        env.info(fullMsg, false)
    end
end

local function getScriptFiles()
    local files = {}
    local dirExists = lfs.attributes(CONFIG.scriptDirectory, "mode")
    
    if not dirExists then
        log("Directory not found: " .. CONFIG.scriptDirectory, "WARN")
        log("Creating directory...", "INFO")
        lfs.mkdir(CONFIG.scriptDirectory)
        return files
    end
    
    if CONFIG.alphabeticOrder then
        for filename in lfs.dir(CONFIG.scriptDirectory) do
            if filename ~= "." and filename ~= ".." then
                if filename:match(CONFIG.filePattern) then
                    table.insert(files, filename)
                end
            end
        end
        table.sort(files)
        
        if CONFIG.verbose then
            log("Found " .. #files .. " scripts (alphabetic order)", "INFO")
        end
    else
        for i, filename in ipairs(CONFIG.scriptFiles) do
            local filepath = CONFIG.scriptDirectory .. filename
            local fileExists = lfs.attributes(filepath, "mode") == "file"
            
            if fileExists then
                table.insert(files, filename)
                if CONFIG.verbose then
                    log(string.format("Priority %d: %s", i, filename), "INFO")
                end
            else
                log("Script not found: " .. filename, "WARN")
            end
        end
    end
    
    return files
end

local function loadScript(filename)
    local filepath = CONFIG.scriptDirectory .. filename
    
    if CONFIG.verbose then
        log("Loading: " .. filename, "INFO")
    end
    
    local file = io.open(filepath, "r")
    if not file then
        log("Failed to open: " .. filename, "ERROR")
        return false
    end
    
    local scriptData = file:read("*all")
    file:close()
    
    if not scriptData or #scriptData == 0 then
        log("Empty file: " .. filename, "WARN")
        return false
    end
    
    local loadedFunc, loadErr = loadstring(scriptData, "@" .. filename)
    if not loadedFunc then
        log("Load error in " .. filename .. ": " .. tostring(loadErr), "ERROR")
        return false
    end
    
    local success, execErr = pcall(loadedFunc)
    if not success then
        log("Execute error in " .. filename .. ": " .. tostring(execErr), "ERROR")
        return false
    end
    
    if CONFIG.verbose then
        log("✓ Loaded: " .. filename, "INFO")
    end
    
    HeavenLoader.loadedScripts[filename] = true
    return true
end

local function loadAllScripts()
    if not CONFIG.enabled then
        log("Loader DISABLED", "WARN")
        return false
    end
    
    log("═══════════════════════════════════", "INFO")
    log("HeavenLoader v" .. HeavenLoader.version, "INFO")
    log("Directory: " .. CONFIG.scriptDirectory, "INFO")
    log("═══════════════════════════════════", "INFO")
    
    local files = getScriptFiles()
    
    if #files == 0 then
        log("NO SCRIPTS FOUND!", "WARN")
        log("Put .lua files in: " .. CONFIG.scriptDirectory, "INFO")
        return false
    end
    
    local loaded = 0
    local failed = 0
    
    for i, filename in ipairs(files) do
        if loadScript(filename) then
            loaded = loaded + 1
        else
            failed = failed + 1
        end
    end
    
    log("═══════════════════════════════════", "INFO")
    log(string.format("Loaded: %d | Failed: %d", loaded, failed), "INFO")
    log("═══════════════════════════════════", "INFO")
    
    return loaded > 0
end

local function updateCallback()
    if CONFIG.verbose then
        log("Auto-update check...", "INFO")
    end
    
    HeavenLoader.loadedScripts = {}
    loadAllScripts()
    
    return timer.getTime() + CONFIG.updateInterval
end

local function scheduleAutoUpdate()
    if not CONFIG.autoUpdate then return end
    
    if HeavenLoader.updateTimer then
        timer.removeFunction(HeavenLoader.updateTimer)
    end
    
    HeavenLoader.updateTimer = timer.scheduleFunction(updateCallback, nil, 
        timer.getTime() + CONFIG.updateInterval)
    
    log("Auto-update enabled (" .. CONFIG.updateInterval .. "s interval)", "INFO")
end

-- ═══════════════════════════════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════════════════════════════

log("HeavenLoader v" .. HeavenLoader.version .. " initializing...", "INFO")

if loadAllScripts() then
    scheduleAutoUpdate()
    log("Ready!", "INFO")
else
    log("No scripts loaded", "WARN")
end

return HeavenLoader
