# 🏈 JRP Tackle Script

<div align="center">

![FiveM](https://img.shields.io/badge/FiveM-Compatible-blue?style=for-the-badge&logo=fivem)
![Lua](https://img.shields.io/badge/Lua-5.4-blue?style=for-the-badge&logo=lua)
![Version](https://img.shields.io/badge/Version-2.5.0-green?style=for-the-badge)
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
✅ **Two-phase stun system** - 5 seconds on ground + 5 seconds stunned recovery  
✅ **E key activation** - Simple press while running to tackle  
✅ **Synchronized animations** - Locked, uninterruptible tackle sequences  
✅ **Movement protection** - Players frozen during animations to prevent glitches  
✅ **Dynamic physics** - Directional tackles based on tackler momentum  
✅ **Real-time countdown** - Visual stun timer for victims  
✅ **Movement impairment** - 50% speed reduction during recovery phase  
✅ **Forced ground time** - Victims cannot get up for 5 seconds  
✅ **Sound effects** - Native GTA impact sounds for immersion  
✅ **Screen shake** - Camera shake on impact for victims  
✅ **UI notifications** - Detailed feedback throughout tackle sequence  
✅ **Permission system** - ACE permission controlled (VIP+ exclusive)  
✅ **Custom notifications** - Styled permission denial messages  
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

**E Key (While Running/Sprinting)**
- Press **E** while running or sprinting near a player to tackle

### Requirements
- Player must be running or sprinting
- Target player must be within 1.25 units
- Cooldown timer must be ready
- Player must not be swimming
- Must have VIP+ permission

### Stun System Timeline

```
🎬 TACKLE IMPACT (0-3s)
├─ Animation plays
├─ Screen shake + impact sound
└─ "You've been tackled! Stunned for 10 seconds..."

💥 PHASE 1: ON GROUND (3-8s = 5 seconds)
├─ Forced ragdoll on ground
├─ Cannot move, jump, or stand
├─ All controls disabled
└─ Continuous enforcement

🚶 PHASE 2: STUNNED RECOVERY (8-13s = 5 seconds)
├─ Player gets up automatically
├─ 50% movement speed
├─ Cannot sprint, jump, or attack
├─ Real-time countdown: "Stunned: 5s... 4s... 3s..."
└─ "Getting up... Still stunned for 5 seconds"

✅ FULL RECOVERY (13s)
└─ "You've recovered from the tackle!" + success sound
```

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
PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)  -- Recovery sound

-- Screen shake for victim
ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.5)

-- Directional physics
ApplyForceToEntity(ped, 1, tackleDirection.x * force, tackleDirection.y * force, 0.5, ...)

-- Two-phase stun system
-- Phase 1: 5 seconds on ground (forced ragdoll)
SetPedToRagdoll(ped, 5000, 5000, 0, 0, 0, 0)

-- Phase 2: 5 seconds stunned (50% speed, no sprint/jump)
SetPedMoveRateOverride(ped, 0.5)  -- Slow movement

-- Real-time countdown display
DisplayHelpTextFromStringLabel("~o~Stunned: ~r~" .. timeLeft .. "s")
```

### Technical Specifications

| Specification | Value | Description |
|--------------|-------|-------------|
| **Detection Range** | 1.25 units (~1.5m) | Maximum distance to tackle |
| **Animation Duration** | 3 seconds | Tackle animation time |
| **Phase 1: Ground** | 5 seconds | Forced ragdoll, cannot stand |
| **Phase 2: Stun** | 5 seconds | 50% speed, no sprint/jump |
| **Total Incapacitation** | 13 seconds | Full tackle sequence |
| **Tackler Cooldown** | 15 seconds | Time between tackles |
| **Target Cooldown** | 3 seconds | Victim's short cooldown |
| **Movement Reduction** | 50% | Speed during recovery |
| **Activation** | E Key | While running/sprinting |
| **Permission** | jrp.tackle | ACE permission node |

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
-- Synchronized Native GTA functions with two-phase stun
FreezeEntityPosition(ped, true)  -- Lock players during animation
TaskPlayAnim(ped, dict, anim, 8.0, 8.0, 3000, 1, 0, false, false, false)

-- Impact effects
PlaySoundFrontend(-1, "TENNIS_POINT_WON", "HUD_AWARDS", true)
ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.5)
ApplyForceToEntity(ped, 1, tackleDirection.x * force, tackleDirection.y * force, 0.5, ...)

-- Two-phase stun system (10 seconds total)
-- Phase 1: 5 seconds forced on ground
SetPedToRagdoll(ped, 5000, 5000, 0, 0, 0, 0)

-- Phase 2: 5 seconds stunned recovery
SetPedMoveRateOverride(ped, 0.5)  -- 50% speed
-- Real-time countdown + control disabling

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
| **Code Lines** | ~150 lines | ~280 lines | ✅ Feature-Rich |
| **Unused Functions** | 2 (GetClosestPlayer) | 0 | ✅ Cleaned Up |
| **Animation Handling** | VRP Wrapper | Synchronized Native | ✅ More Efficient |
| **Animation Sync** | ❌ Interruptible | ✅ Locked & Protected | ✅ 100% Reliable |
| **Movement Issues** | ❌ Animation Glitches | ✅ Freeze Protection | ✅ Problem Solved |
| **Impact Feedback** | ❌ None | ✅ Sound + Screen Shake | ✅ Immersive |
| **Physics** | ❌ Static | ✅ Dynamic Directional | ✅ Realistic |
| **Tackle Strength** | ❌ Fixed | ✅ Two-Phase Stun (10s) | ✅ Balanced |
| **Permissions** | ❌ None | ✅ ACE Permission System | ✅ VIP Control |
| **Stun System** | ❌ Instant Recovery | ✅ 5s Ground + 5s Stunned | ✅ Realistic |
| **Visual Feedback** | ❌ None | ✅ Real-time Countdown | ✅ User-Friendly |

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
- ✅ **Two-phase stun system (5s ground + 5s recovery)**
- ✅ **Real-time countdown timer for victims**
- ✅ **Movement speed reduction (50%) during recovery**
- ✅ **Forced ground enforcement (cannot get up for 5s)**
- ✅ **E key activation while running**
- ✅ Dynamic directional physics based on tackle momentum
- ✅ Native GTA sound effects for tackler and victim
- ✅ Screen shake camera effect on impact
- ✅ UI notifications for tackle feedback
- ✅ Force application in tackle direction
- ✅ Forced stun system to prevent instant recovery
- ✅ Control disabling during ragdoll period
- ✅ Server-side input validation and security checks
- ✅ ACE permission system for VIP control
- ✅ Custom styled permission denial notifications
- ✅ Server-side permission validation
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

### How do I tackle someone?
Run or sprint toward a player and press **E** when you're close (within 1.5 meters).

### How do I give tackle permission to players?
Add the ACE permission `jrp.tackle` to their group or identifier in `server.cfg`:
```cfg
add_ace group.vip jrp.tackle allow
```

### How long does the stun last?
Total of **13 seconds**:
- 3 seconds: Tackle animation
- 5 seconds: Forced on ground (ragdoll)
- 5 seconds: Stunned recovery (50% speed, no sprint/jump)

### Can victims get up early?
No! The script **forces them to stay down** for the full 5-second ground phase. If they try to get up, they're immediately put back into ragdoll.

### Can I change the permission denial message?
Yes! Edit `client.lua` around line ~150 in the `tackle:PermissionDenied` event handler.

### How do I make it available to everyone?
Add this to your `server.cfg`:
```cfg
add_ace builtin.everyone jrp.tackle allow
```

### Can I change the permission node name?
Yes, change `jrp.tackle` to your desired name in both `server.lua` and your ACE permission config.

### What if someone tries to tackle without permission?
They'll see a styled notification with your custom VIP message and an error sound will play. The tackle won't execute.

### Can I adjust the stun duration?
Yes! Edit the values in `client.lua`:
- Ground phase: Line ~103 `groundPhaseEnd = groundPhaseStart + 5000` (5000 = 5 seconds)
- Stun phase: Line ~127 `stunPhaseEnd = stunPhaseStart + 5000` (5000 = 5 seconds)

### Why do I see a countdown timer?
During the recovery phase (last 5 seconds), victims see a countdown showing how much stun time is left: "Stunned: 5s... 4s... 3s..."

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