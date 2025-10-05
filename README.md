# 🏈 JRP Tackle Script

<div align="center">

![FiveM](https://img.shields.io/badge/FiveM-Compatible-blue?style=for-the-badge&logo=fivem)
![Lua](https://img.shields.io/badge/Lua-5.4-blue?style=for-the-badge&logo=lua)
![Version](https://img.shields.io/badge/Version-2.0.0-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

*A standalone tackle script for FiveM developed by JGN Development for JRP Server*

</div>

## 📋 Table of Contents

- [🎯 Features](#-features)
- [📦 Installation](#-installation)
- [🎮 Usage](#-usage)
- [🔧 Configuration](#-configuration)
- [📈 Before vs After](#-before-vs-after)
- [🛠️ Changes Made](#️-changes-made)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

## 🎯 Features

✅ **Standalone** - No framework dependencies  
✅ **Smooth animations** - Realistic tackle mechanics  
✅ **Cooldown system** - Prevents tackle spam  
✅ **Range detection** - Proximity-based tackling  
✅ **Performance optimized** - Efficient code structure  
✅ **Easy to install** - Plug and play  

## 📦 Installation

1. **Download** the script files
2. **Extract** to your resources folder
3. **Add** to your `server.cfg`:
   ```cfg
   ensure JRP-TackleScript
   ```
4. **Restart** your server

## 🎮 Usage

### Controls
- **E Key** - Tackle nearby players (while running/sprinting)

### Requirements
- Player must be running or sprinting
- Target player must be within 1.25 units
- Cooldown timer must be ready
- Player must not be swimming

## 🔧 Configuration

### Animation Settings
```lua
local anim = "mic_2_ig_11_intro_goon"     -- Tackler animation
local dict = "missmic2ig_11"               -- Animation dictionary  
local anim2 = "mic_2_ig_11_intro_p_one"   -- Target animation
```

### Timing Settings
```lua
local tackleSystem = 0    -- Cooldown timer (15 seconds for tackler, 3 for target)
local tackleRange = 1.25  -- Detection range in units
```

## 📈 Before vs After

<table>
<tr>
<th>🔴 Before (VRP Dependent)</th>
<th>🟢 After (Standalone)</th>
</tr>
<tr>
<td>

```lua
-- VRP Dependencies
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

-- VRP Animation calls
vRP._playAnim(false,{"missmic2ig_11","mic_2_ig_11_intro_goon"},false)
vRP.stopAnim(false)

-- VRP Inventory integration
TriggerServerEvent("inventory:Cancel")
```

</td>
<td>

```lua
-- Native GTA functions
TaskPlayAnim(ped, dict, anim, 8.0, 8.0, 3000, 0, 0, false, false, false)
ClearPedTasks(ped)

-- Standalone operation
-- No external dependencies
```

</td>
</tr>
</table>

### Performance Improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Dependencies** | VRP Framework Required | ❌ None | ✅ 100% Standalone |
| **Code Lines** | ~150 lines | ~120 lines | ✅ 20% Reduction |
| **Unused Functions** | 2 (GetClosestPlayer) | 0 | ✅ Cleaned Up |
| **Animation Handling** | VRP Wrapper | Native | ✅ More Efficient |

## 🛠️ Changes Made

### 🗑️ Removed
- ❌ VRP Proxy system and dependencies
- ❌ VRP animation wrapper functions
- ❌ VRP inventory integration
- ❌ Unused player detection functions
- ❌ Redundant attach/detach entity logic
- ❌ Complex animation loops
- ❌ Excessive commenting

### ✅ Added
- ✅ Native GTA animation functions
- ✅ Clean, descriptive comments
- ✅ JGN Development branding
- ✅ Optimized performance
- ✅ Standalone functionality
- ✅ Better code structure
- ✅ Comprehensive documentation

### 🔄 Modified
- 🔄 Updated fxmanifest.lua for standalone operation
- 🔄 Simplified tackle detection logic
- 🔄 Improved animation timing
- 🔄 Enhanced code readability
- 🔄 Streamlined server-client communication

## 📁 File Structure

```
JRP-TackleScript/
├── 📄 client.lua       # Client-side tackle logic
├── 📄 server.lua       # Server-side event handling  
├── 📄 fxmanifest.lua   # Resource manifest
└── 📄 README.md        # This documentation
```

## 🎨 Code Quality

### Before Cleanup
```lua
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
```

### After Cleanup
```lua
-- JGN Development - JRP Tackle Script
-- Developed for JRP Server

-- Tackle system cooldown timer
local tackleSystem = 0
```

## 🤝 Contributing

We welcome contributions! Please feel free to submit a Pull Request.

### Development Guidelines
- Follow existing code style
- Add comments for new functionality  
- Test thoroughly before submitting
- Update documentation as needed

## 👥 Credits

- **Original Author**: luke.dev
- **Refactored by**: JGN Development
- **Server**: JRP Server
- **Framework**: Standalone (Previously VRP)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with ❤️ by JGN Development for JRP Server**

![Stars](https://img.shields.io/github/stars/yourusername/JRP-TackleScript?style=social)
![Forks](https://img.shields.io/github/forks/yourusername/JRP-TackleScript?style=social)

</div>