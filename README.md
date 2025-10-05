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
✅ **Synchronized animations** - Locked, uninterruptible tackle sequences  
✅ **Movement protection** - Players frozen during animations to prevent glitches  
✅ **Dynamic physics** - Directional tackles based on tackler momentum  
✅ **Variable strength** - Tackle power scales with running speed  
✅ **Forced stun system** - Victims stay down for full duration (no instant recovery)  
✅ **Control disabling** - Movement locked during stun period  
✅ **Sound effects** - Native GTA impact sounds for immersion  
✅ **Screen shake** - Camera shake on impact for victims  
✅ **UI notifications** - Alert when tackled  
✅ **Smooth animations** - Realistic tackle mechanics with proper timing  
✅ **Cooldown system** - Prevents tackle spam  
✅ **Range detection** - Proximity-based tackling  
✅ **Permission system** - ACE permission controlled (VIP+ exclusive)  
✅ **Custom notifications** - Styled permission denial messages  
✅ **Performance optimized** - Efficient code structure  
✅ **Easy to install** - Plug and play  

## 📦 Installation

1. **Download** the script files
2. **Extract** to your resources folder
3. **Add** to your `server.cfg`:
   ```cfg
   ensure JRP-TackleScript
   ```
4. **Configure permissions** in your `server.cfg`:
   ```cfg
   # Grant tackle permission to VIP+ players
   add_ace group.vip jrp.tackle allow
   add_ace group.admin jrp.tackle allow
   
   # Or grant to all players (not recommended for VIP exclusive)
   # add_ace builtin.everyone jrp.tackle allow
   ```
5. **Restart** your server

## 🎮 Usage

### Controls
- **E Key** - Tackle nearby players (while running/sprinting)

### Requirements
- Player must be running or sprinting
- Target player must be within 1.25 units
- Cooldown timer must be ready
- Player must not be swimming

### Animation System
- **Synchronized Playback** - Both players locked during 3-second animation
- **Movement Prevention** - Players frozen to prevent animation interruption
- **Collision Management** - Temporary collision disable for smooth animations
- **Ragdoll Protection** - Victim can't ragdoll until animation completes

### Impact Effects
- **Sound Effects** - Native GTA audio for tackle and impact sounds
- **Screen Shake** - Camera shake for victim on impact
- **Physics System** - Directional force applied based on tackle direction
- **Variable Strength** - Ragdoll duration (3-7 seconds) based on tackler speed
- **UI Notifications** - Visual feedback when tackled

## 🔧 Configuration

### Permission System

The tackle script uses ACE permissions to control who can tackle.

**Permission Node:** `jrp.tackle`

#### Grant to Specific Groups:
```cfg
# VIP+ Donators
add_ace group.vip jrp.tackle allow
add_ace group.vipplus jrp.tackle allow

# Admins/Moderators
add_ace group.admin jrp.tackle allow
add_ace group.mod jrp.tackle allow
```

#### Grant to Individual Players:
```cfg
# By Steam ID
add_ace identifier.steam:110000XXXXXXXX jrp.tackle allow

# By License
add_ace identifier.license:XXXXXXXXXXXXXXXX jrp.tackle allow
```

#### Grant to Everyone (Not Recommended for VIP Exclusive):
```cfg
add_ace builtin.everyone jrp.tackle allow
```

### Permission Denial Message

Players without permission will see:
```
⚠️ ACCESS DENIED
JRP VIP+ Donator rank required
Visit store.jrpserver.com to unlock!
```

You can customize this message in `client.lua` line ~95

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

### Animation Control
```lua
-- Synchronized animation system
FreezeEntityPosition(ped, true)      -- Lock player position
SetEntityCollision(ped, false)       -- Disable collision during animation
TaskPlayAnim(ped, dict, anim, 8.0, 8.0, 3000, 1, 0, false, false, false)  -- Force animation flag = 1
```

### Impact Effects
```lua
-- Sound effects (native GTA)
PlaySoundFrontend(-1, "TENNIS_POINT_WON", "HUD_AWARDS", true)  -- Tackler sound
PlaySoundFrontend(-1, "PLAYER_DEATH", "HUD_FRONTEND_MP_COLLECTABLE_SOUNDS", true)  -- Victim sound

-- Screen shake for victim
ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.5)

-- Directional physics
ApplyForceToEntity(ped, 1, tackleDirection.x * force, tackleDirection.y * force, 0.5, ...)

-- Variable ragdoll time based on speed
local ragdollDuration = math.min(7000, 3000 + (speedMultiplier * 2000))
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
-- Synchronized Native GTA functions with physics
FreezeEntityPosition(ped, true)  -- Lock players during animation
TaskPlayAnim(ped, dict, anim, 8.0, 8.0, 3000, 1, 0, false, false, false)

-- Impact effects
PlaySoundFrontend(-1, "TENNIS_POINT_WON", "HUD_AWARDS", true)
ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.5)
ApplyForceToEntity(ped, 1, tackleDirection.x * force, tackleDirection.y * force, 0.5, ...)

-- Variable strength system
local ragdollDuration = 3000 + (speedMultiplier * 2000)  -- 3-7 seconds

-- Standalone operation with full physics
-- No external dependencies, all native GTA
```

</td>
</tr>
</table>

### Performance Improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Dependencies** | VRP Framework Required | ❌ None | ✅ 100% Standalone |
| **Code Lines** | ~150 lines | ~145 lines | ✅ Optimized |
| **Unused Functions** | 2 (GetClosestPlayer) | 0 | ✅ Cleaned Up |
| **Animation Handling** | VRP Wrapper | Synchronized Native | ✅ More Efficient |
| **Animation Sync** | ❌ Interruptible | ✅ Locked & Protected | ✅ 100% Reliable |
| **Movement Issues** | ❌ Animation Glitches | ✅ Freeze Protection | ✅ Problem Solved |
| **Impact Feedback** | ❌ None | ✅ Sound + Screen Shake | ✅ Immersive |
| **Physics** | ❌ Static | ✅ Dynamic Directional | ✅ Realistic |
| **Tackle Strength** | ❌ Fixed | ✅ Speed-Based (3-7s) | ✅ Variable |
| **Permissions** | ❌ None | ✅ ACE Permission System | ✅ VIP Control |

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
- ✅ Synchronized animation system with movement protection
- ✅ Player freezing during animations to prevent glitches
- ✅ Enhanced animation control flags (force playback)
- ✅ Collision management during tackle sequences
- ✅ Ragdoll protection until animation completion
- ✅ **Dynamic directional physics based on tackle momentum**
- ✅ **Variable tackle strength (3-7 seconds) based on speed**
- ✅ **Native GTA sound effects for tackler and victim**
- ✅ **Screen shake camera effect on impact**
- ✅ **UI notifications for tackle feedback**
- ✅ **Force application in tackle direction**
- ✅ **Forced stun system to prevent instant recovery**
- ✅ **Control disabling during ragdoll period**
- ✅ **Server-side input validation and security checks**
- ✅ **ACE permission system for VIP control**
- ✅ **Custom styled permission denial notifications**
- ✅ **Server-side permission validation**
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
- 🔄 Enhanced animation timing with synchronization locks
- 🔄 Improved animation reliability with movement freezing
- 🔄 Enhanced code readability
- 🔄 Streamlined server-client communication

## 🎬 Animation System Details

### **Synchronized Tackle Mechanics**
- **Player Freezing**: Both tackler and victim are frozen during 3-second animation
- **Movement Protection**: Prevents input interference with animations
- **Collision Management**: Temporary collision disable for smooth sequences
- **Force Playback**: Animation flag `1` ensures complete animation playback
- **Ragdoll Control**: Victim protected from early ragdolling during animation

### **Technical Specifications**
- **Detection Range**: 1.25 game units (approximately 1.5 meters)
- **Animation Duration**: 3 seconds (synchronized & locked)
- **Freeze Duration**: 3 seconds (prevents movement during animation)
- **Ragdoll Time**: 3-7 seconds (variable based on tackler speed)
- **Stun Duration**: Full ragdoll time (prevents instant recovery)
- **Control Lock**: Sprint, jump, melee attacks disabled during stun
- **Tackler Cooldown**: 15 seconds
- **Target Cooldown**: 3 seconds
- **Animation Protection**: 100% interruption prevention
- **Physics**: Directional force based on tackle momentum
- **Sound Effects**: Native GTA audio (TENNIS_POINT_WON, PLAYER_DEATH)
- **Camera Shake**: SMALL_EXPLOSION_SHAKE intensity 0.5

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

## ❓ FAQ

### How do I give tackle permission to players?
Add the ACE permission `jrp.tackle` to their group or identifier in `server.cfg`:
```cfg
add_ace group.vip jrp.tackle allow
```

### Can I change the permission denial message?
Yes! Edit `client.lua` around line ~95 in the `tackle:PermissionDenied` event handler.

### How do I make it available to everyone?
Add this to your `server.cfg`:
```cfg
add_ace builtin.everyone jrp.tackle allow
```

### Can I change the permission node name?
Yes, change `jrp.tackle` to your desired name in both `server.lua` and your ACE permission config.

### What if someone tries to tackle without permission?
They'll see a styled notification with your custom VIP message and an error sound will play. The tackle won't execute.

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