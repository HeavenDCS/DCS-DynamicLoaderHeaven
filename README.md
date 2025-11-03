# 🚀 Heaven DynamicScriptLoader DCS

<div align="center">

**Keep your DCS mission scripts private and organized**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![DCS World](https://img.shields.io/badge/DCS%20World-Compatible-blue.svg)](https://www.digitalcombatsimulator.com/)
[![Lua](https://img.shields.io/badge/Lua-5.1-purple.svg)](https://www.lua.org/)

*Hide your code from mission files • Load scripts dynamically • Keep intellectual property safe*

[Features](#-features) • [Installation](#-installation) • [Configuration](#-configuration) • [Usage](#-usage) • [FAQ](#-faq)

</div>

---

## 🎯 What is HeavenLoader?

HeavenLoader is a **dynamic script loader** for DCS World that separates your mission logic from your mission files. Instead of embedding all your code directly into mission triggers (where anyone can see and copy it), HeavenLoader lets you keep your scripts in a separate, protected directory.

### The Problem
- Mission files contain all your scripts in plain text
- Anyone can open the `.miz` file and steal your code
- Large scripts make mission files bloated and hard to manage
- Updating scripts requires re-editing the mission file

### The Solution
Your mission file contains **just one line**:
```lua
dofile(lfs.writedir()..'Scripts\\DynamicLoaderHeaven.lua')
```

All your actual code lives in a separate folder that players never see. 🔒

---

## ✨ Features

- **🔐 Privacy First** - Your scripts stay outside the mission file
- **📁 Organized Structure** - Keep all scripts in one dedicated folder
- **🎯 Load Priority** - Control exactly which scripts load and in what order
- **🔄 Auto-Update** - Optionally reload scripts during runtime
- **📊 Smart Logging** - Detailed feedback on script loading
- **⚡ Fast & Lightweight** - Minimal performance impact
- **🛡️ Error Handling** - Graceful failure with helpful error messages
- **🔤 Flexible Loading** - Alphabetic or priority-based loading modes

---

## 📦 Installation

### Step 1: File Placement
Copy `DynamicLoaderHeaven.lua` to your DCS Scripts folder:
```
C:\Users\[YourName]\Saved Games\DCS\Scripts\DynamicLoaderHeaven.lua
```

### Step 2: Create Script Directory
Create a folder for your protected scripts:
```
C:\Users\[YourName]\Saved Games\DCS\Scripts\ServerSide\
```
*(Or any folder you configure)*

### Step 3: Mission Integration
In your DCS mission editor, create a **MISSION START** trigger:

- **TYPE**: `4 MISSION START`
- **ACTION**: `DO SCRIPT`
- **SCRIPT**: 
  ```lua
  dofile(lfs.writedir()..'Scripts\\DynamicLoaderHeaven.lua')
  ```

### Step 4: Add Your Scripts
Place your `.lua` files in the `ServerSide` folder:
```
Scripts\ServerSide\
  ├── Moose.lua
  ├── SARSystem.lua
  └── YourScript.lua
```

---

## ⚙️ Configuration

Open `DynamicLoaderHeaven.lua` and customize the `CONFIG` table:

```lua
local CONFIG = {
    -- Directory where your scripts are stored
    scriptDirectory = lfs.writedir() .. "Scripts\\ServerSide\\",
    
    -- Enable/disable the loader
    enabled = true,
    
    -- Loading mode
    alphabeticOrder = false,  -- false = use scriptFiles list
                              -- true = load all .lua files A-Z
    
    -- Scripts to load (in priority order, top loads first)
    scriptFiles = {
        "Moose.lua",
        "SARSystem.lua",
    },
    
    -- File pattern to match
    filePattern = "%.lua$",
    
    -- Detailed logging
    verbose = true,
    
    -- Auto-reload scripts during mission
    autoUpdate = false,
    
    -- Seconds between reloads (if autoUpdate = true)
    updateInterval = 300,
}
```

### Configuration Options Explained

| Option | Type | Description |
|--------|------|-------------|
| `scriptDirectory` | string | Path to your scripts folder |
| `enabled` | boolean | Master on/off switch |
| `alphabeticOrder` | boolean | `true` = load all `.lua` files alphabetically<br>`false` = only load files in `scriptFiles` list |
| `scriptFiles` | table | Array of script filenames in load order |
| `filePattern` | string | Lua pattern for matching files (default: `.lua`) |
| `verbose` | boolean | Enable detailed logging |
| `autoUpdate` | boolean | Reload scripts periodically during mission |
| `updateInterval` | number | Seconds between auto-reloads |

---

## 🎮 Usage

### Basic Usage (Priority Loading)
```lua
local CONFIG = {
    alphabeticOrder = false,
    scriptFiles = {
        "init.lua",      -- Loads first
        "utils.lua",     -- Loads second
        "mission.lua",   -- Loads third
    },
}
```

### Load All Scripts Alphabetically
```lua
local CONFIG = {
    alphabeticOrder = true,
    -- scriptFiles is ignored in this mode
}
```

### Custom Directory
```lua
local CONFIG = {
    scriptDirectory = "D:\\MyDCSScripts\\Protected\\",
}
```

### Development Mode (Auto-Reload)
```lua
local CONFIG = {
    autoUpdate = true,
    updateInterval = 60,  -- Reload every 60 seconds
    verbose = true,       -- See detailed logs
}
```

### Production Mode (Silent)
```lua
local CONFIG = {
    autoUpdate = false,
    verbose = false,      -- Minimal logging
}
```

---

## 📋 What You'll See

### Successful Load (Verbose Mode)
```
[HeavenLoader] HeavenLoader v1.0 initializing...
[HeavenLoader] ═══════════════════════════════════
[HeavenLoader] HeavenLoader v1.0
[HeavenLoader] Directory: C:\Users\...\Scripts\ServerSide\
[HeavenLoader] ═══════════════════════════════════
[HeavenLoader] Priority 1: Moose.lua
[HeavenLoader] Priority 2: SARSystem.lua
[HeavenLoader] Loading: Moose.lua
[HeavenLoader] ✓ Loaded: Moose.lua
[HeavenLoader] Loading: SARSystem.lua
[HeavenLoader] ✓ Loaded: SARSystem.lua
[HeavenLoader] ═══════════════════════════════════
[HeavenLoader] Loaded: 2 | Failed: 0
[HeavenLoader] ═══════════════════════════════════
[HeavenLoader] Ready!
```

### Error Handling
```
[HeavenLoader] Script not found: missing.lua
[HeavenLoader] Failed to open: corrupt.lua
[HeavenLoader] Load error in bad.lua: unexpected symbol near '}'
```

---

## ❓ FAQ

### Why use HeavenLoader?

**Protect your work** - Mission builders invest hours creating scripts. HeavenLoader keeps your intellectual property safe.

**Cleaner workflow** - Update scripts without touching mission files. Test changes without re-saving missions.

**Professional setup** - Separate code from data, just like real software development.

### Is this safe for multiplayer?

**Yes!** The scripts run server-side only. The loader itself is lightweight and well-tested.

### Does this work with MOOSE/Mist/Other frameworks?

**Absolutely!** Load any Lua script in any order. Perfect for frameworks, libraries, and custom code.

### Can I use multiple script folders?

Not directly, but you can create multiple instances with different configs or use subdirectories.

### Will this slow down mission loading?

**No.** Impact is negligible. Scripts load in milliseconds.

### What if a script fails to load?

HeavenLoader continues loading remaining scripts and logs the error. Your mission won't crash.

### Can I edit scripts while the mission is running?

With `autoUpdate = true`, yes! Changes reload automatically. Great for live testing.

---

## 🔧 Advanced Tips

### Load Order Matters
Some scripts depend on others. Put dependencies first:
```lua
scriptFiles = {
    "Moose.lua",        -- Framework first
    "MyMooseCode.lua",  -- Code using framework second
}
```

### Subdirectories
Organize with folders:
```
Scripts\ServerSide\
  ├── frameworks\
  │   └── Moose.lua
  └── missions\
      └── MyMission.lua
```

Then reference: `"frameworks\\Moose.lua"`

### Debugging
Enable verbose mode and check `dcs.log`:
```
C:\Users\[YourName]\Saved Games\DCS\Logs\dcs.log
```

---

## 🤝 Contributing

Contributions welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Share your use cases

---

## 📄 License

This project is licensed under the MIT License - see below:

```
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software.

Copyright (c) 2025

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
```

---

## 💬 Support

- **Issues**: Use GitHub Issues for bug reports
- **Discussions**: Share tips and ask questions in Discussions

---

<div align="center">

**Made with ❤️ for the DCS community**

⭐ Star this repo if HeavenLoader helps your missions!

</div>
