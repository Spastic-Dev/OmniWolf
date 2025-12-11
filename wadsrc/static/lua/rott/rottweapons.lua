--[[
  Rise of the Triad Weapons (rottweapons.lua)
  
  This script defines weapon behavior for several iconic ROTT weapons,
  using the OmniWolf native Lua API (omniwolf_api.lua) for world
  interaction, such as spawning projectiles.
  
  Note: This assumes the OmniWolf engine provides a system to register
  these Lua tables as usable in-game weapon classes and handles the
  state machine (Ready, Fire, etc.) based on the table structure.
--]]

-- Assume OmniWolf API is loaded
local OmniWolf = require("omniwolf_api")

-- A central place to store weapon definitions
local ROTTWeapons = {}

--=============================================================================
-- HELPER FUNCTIONS (Simulating engine actions/variables)
--=============================================================================

--- Utility function to get the current player's location and direction.
--- In a real engine, this data would come from the weapon's 'self' context.
--- @return number x, number y, number z, number angle
local function GetPlayerViewpoint()
    local player = OmniWolf.GetPlayer()
    -- This is a placeholder structure. A real actor table would expose these.
    if player and player.x and player.y and player.z and player.angle then
        return player.x, player.y, player.z, player.angle
    end
    -- Fallback dummy data if GetPlayer fails or object structure is incomplete
    return 0, 0, 0, 90 
end

--- Utility to calculate projectile spawn position and spread.
--- @param angle number The base angle (player angle).
--- @param spread number The spread in degrees (0 for perfect accuracy).
--- @return number adjusted_angle
local function ApplySpread(angle, spread)
    if spread == 0 then return angle end
    -- Generate a random offset between -spread/2 and +spread/2
    local offset = (math.random() * spread) - (spread / 2)
    return angle + offset
end

--- Utility to check and consume ammo.
--- @param ammoType string (e.g., "Bullet", "Missile")
--- @param amount integer
--- @return boolean True if ammo was consumed successfully.
local function TryConsumeAmmo(ammoType, amount)
    -- In ROTT, bullet weapons often have infinite ammo, which we'll handle internally.
    if ammoType == "Bullet" then return true end
    
    -- Placeholder for actual engine ammo check/consumption
    -- A real implementation would check player inventory/ammo count here.
    -- For now, we assume success if it's not a bullet weapon.
    OmniWolf.Print("Consuming " .. amount .. " " .. ammoType)
    return true
end

--=============================================================================
-- WEAPON ACTION FUNCTIONS
--=============================================================================

--- Fires the MP40 (or Dual MP40). A fast-firing, infinite-ammo bullet weapon.
local function Fire_MP40(weapon_self)
    local x, y, z, angle = GetPlayerViewpoint()
    local fire_angle = ApplySpread(angle, 4) -- Small spread for SMG

    if TryConsumeAmmo("Bullet", 1) then
        -- Spawn a fast projectile with a small spread
        -- Projectile class name is arbitrary, assuming 'ROTT_Bullet' exists
        OmniWolf.SpawnActor("ROTT_Bullet", x, y, z + 32, fire_angle)
        
        -- Play a sound (assumed to be bound to a numerical ID or string name)
        weapon_self.PlaySound("MP40_FIRE") 
        
        -- Check for dual-wielding, if applicable to the 'weapon_self' instance
        if weapon_self.IsDual then
            -- Spawn a second projectile with opposite slight offset
            local offset_angle = ApplySpread(angle + 180, 4)
            OmniWolf.SpawnActor("ROTT_Bullet", x, y, z + 32, offset_angle)
        end
        
        -- Indicate the next state after firing (usually a flash/delay state)
        return "Flash" 
    end
    return "Ready"
end

--- Fires the Bazooka. A simple, straight-flying missile.
local function Fire_Bazooka(weapon_self)
    local x, y, z, angle = GetPlayerViewpoint()

    if TryConsumeAmmo("Missile", 1) then
        OmniWolf.SpawnActor("ROTT_BazookaMissile", x, y, z + 48, angle)
        weapon_self.PlaySound("BAZOOKA_FIRE")
        OmniWolf.DisplayMessage("Bazooka Fired!", 1.0)
        return "Flash"
    end
    return "Ready"
end

--- Fires the Drunk Missile. Spawns multiple projectiles with high variance.
local function Fire_DrunkMissile(weapon_self)
    local x, y, z, angle = GetPlayerViewpoint()

    if TryConsumeAmmo("Missile", 1) then
        -- ROTT's Drunk Missile fires 5 wobbly projectiles at once.
        for i = 1, 5 do
            -- High spread for a "drunk" effect
            local fire_angle = ApplySpread(angle, 45) 
            -- The 'ROTT_DrunkMissile' actor class would handle the wobbly movement
            OmniWolf.SpawnActor("ROTT_DrunkMissile", x, y, z + 48, fire_angle)
        end
        
        weapon_self.PlaySound("DRUNK_FIRE")
        OmniWolf.DisplayMessage("Drunk Missile Barrage!", 1.5)
        return "Flash"
    end
    return "Ready"
end

--- Fires the Excalibat's projectile attack (baseball).
local function Fire_Excalibat(weapon_self)
    local x, y, z, angle = GetPlayerViewpoint()

    if TryConsumeAmmo("Magic", 1) then
        -- Spawns a bouncing/exploding baseball projectile
        OmniWolf.SpawnActor("ROTT_Baseball", x, y, z + 48, angle)
        weapon_self.PlaySound("EXCALIBAT_SWING")
        OmniWolf.DisplayMessage("Batter Up!", 1.0)
        return "Flash"
    end
    return "Ready"
end

--=============================================================================
-- WEAPON DEFINITIONS (ROTTWeapons table)
--=============================================================================

-- 1. MP40 (Submachine Gun)
ROTTWeapons.MP40 = {
    Name = "MP40",
    Slot = 3,
    AmmoType = "Bullet",
    FireRateTics = 3, -- Very fast rate of fire (3 tics = ~0.086 seconds)
    
    States = {
        Ready = { Sprite = "MP4A0", Duration = 1, Action = "A_WeaponReady", Loop = true },
        Fire = { Sprite = "MP4A0", Duration = 3, Action = Fire_MP40, NextState = "Hold" },
        Hold = { Sprite = "MP4A0", Duration = 3, Action = Fire_MP40, NextState = "Hold", ReFire = true },
        Flash = { Sprite = "MP4F0", Duration = 2, NextState = "Ready" }, -- Muzzle flash state
        Select = { Sprite = "MP4A0", Duration = 4, Action = "A_Raise", Loop = true },
        Deselect = { Sprite = "MP4A0", Duration = 4, Action = "A_Lower", Loop = true }
    }
}

-- 2. BAZOOKA (Straight Missile)
ROTTWeapons.Bazooka = {
    Name = "Bazooka",
    Slot = 5,
    AmmoType = "Missile",
    AmmoPerShot = 1,
    FireRateTics = 35, -- Slow rate (half a second)
    
    States = {
        Ready = { Sprite = "BAZA0", Duration = 1, Action = "A_WeaponReady", Loop = true },
        Fire = { Sprite = "BAZB0", Duration = 4, Action = Fire_Bazooka, NextState = "Flash" },
        Flash = { Sprite = "BAZF0", Duration = 6, NextState = "Ready" },
        Select = { Sprite = "BAZA0", Duration = 5, Action = "A_Raise", Loop = true },
        Deselect = { Sprite = "BAZA0", Duration = 5, Action = "A_Lower", Loop = true }
    }
}

-- 3. DRUNK MISSILE (Multi-shot scatter missile)
ROTTWeapons.DrunkMissile = {
    Name = "DrunkMissile",
    Slot = 5, -- Same slot as Bazooka, assuming the engine handles selection logic
    AmmoType = "Missile",
    AmmoPerShot = 1,
    FireRateTics = 40,
    
    States = {
        Ready = { Sprite = "DRNA0", Duration = 1, Action = "A_WeaponReady", Loop = true },
        Fire = { Sprite = "DRNB0", Duration = 5, Action = Fire_DrunkMissile, NextState = "Flash" },
        Flash = { Sprite = "DRNF0", Duration = 8, NextState = "Ready" },
        Select = { Sprite = "DRNA0", Duration = 5, Action = "A_Raise", Loop = true },
        Deselect = { Sprite = "DRNA0", Duration = 5, Action = "A_Lower", Loop = true }
    }
}

-- 4. EXCALIBAT (Magic Weapon, Projectile Fire Mode)
ROTTWeapons.Excalibat = {
    Name = "Excalibat",
    Slot = 6, -- Magic weapons slot
    AmmoType = "Magic",
    AmmoPerShot = 1,
    FireRateTics = 20, -- Medium speed
    
    States = {
        Ready = { Sprite = "EXCAA0", Duration = 1, Action = "A_WeaponReady", Loop = true },
        -- In ROTT, a short press is a melee swing, a long press is the projectile.
        -- We will model the projectile fire here (the Excaliblast).
        Fire = { Sprite = "EXCAB0", Duration = 5, Action = Fire_Excalibat, NextState = "Flash" },
        Flash = { Sprite = "EXCF0", Duration = 5, NextState = "Ready" },
        Select = { Sprite = "EXCAA0", Duration = 5, Action = "A_Raise", Loop = true },
        Deselect = { Sprite = "EXCAA0", Duration = 5, Action = "A_Lower", Loop = true }
    }
}

--=============================================================================
-- REGISTRATION (Final step in the OmniWolf engine)
--=============================================================================

--- Register all defined ROTT weapons with the engine.
if OmniWolf.RegisterWeapon then
    for name, weaponDef in pairs(ROTTWeapons) do
        OmniWolf.RegisterWeapon(name, weaponDef)
        OmniWolf.Print("Registered ROTT Weapon: " .. name)
    end
end

-- Export the weapon definitions (useful for other Lua scripts to inspect)
return ROTTWeapons
