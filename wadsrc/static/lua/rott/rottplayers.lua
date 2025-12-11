--[[
  Rise of The Triad Player Classes (rottplayers.lua)
  
  Defines the four playable characters from ROTT, each with unique
  movement speed and maximum health characteristics, using the
  OmniWolf native Lua API for player class registration.
  
  The engine is assumed to map these properties to the underlying
  player actor (inheriting from PlayerPawn).
--]]

local OmniWolf = require("omniwolf_api")

-- Base configuration constants (relative to a standard GZDoom/OmniWolf player)
local BASE_HEALTH = 100
local BASE_SPEED = 1.0 -- Default speed factor

-- Table to hold all player class definitions
local ROTTPlayers = {}

--=============================================================================
-- 1. IAN PAUL FREELEY (Balanced)
-- The default, balanced character.
--=============================================================================
ROTTPlayers.IanFreeley = {
    Name = "Ian Paul Freeley",
    Description = "The balanced operative. Average speed and health.",
    
    Default = {
        Health = BASE_HEALTH,
        PlayerSpeed = BASE_SPEED * 1.0, -- Default
        DamageFactor = 1.0,
        AirControl = 0.9 -- Good air control
    },
    
    States = {
        -- Placeholder states - actual sprites (PLAY) would be required in a WAD/PK3
        Spawn = { Sprite = "PLAYA0", Duration = -1 },
        Ready = { Sprite = "PLAYA0", Duration = 1, Action = "A_WeaponReady", Loop = true }
    }
}


--=============================================================================
-- 2. DOUG WENDT (Tank)
-- Slowest character, highest starting health, can take the most damage.
--=============================================================================
ROTTPlayers.DougWendt = {
    Name = "Doug Wendt",
    Description = "The tank. Slow but can sustain a large amount of damage.",
    
    Default = {
        Health = math.ceil(BASE_HEALTH * 1.25), -- 125 Health
        PlayerSpeed = BASE_SPEED * 0.85, -- Slower than average
        DamageFactor = 1.0,
        AirControl = 0.8 -- Slightly less agile
    },
    
    States = ROTTPlayers.IanFreeley.States -- Reuse standard player states
}


--=============================================================================
-- 3. LORELEI NI (Agile)
-- Fast, slightly less health, and generally known for high accuracy/agile feel.
--=============================================================================
ROTTPlayers.LoreleiNi = {
    Name = "Lorelei Ni",
    Description = "Agile and quick, but with lower endurance.",
    
    Default = {
        Health = math.ceil(BASE_HEALTH * 0.9), -- 90 Health
        PlayerSpeed = BASE_SPEED * 1.1, -- Faster than average
        DamageFactor = 1.0,
        AirControl = 0.95 -- Very good air control
    },
    
    States = ROTTPlayers.IanFreeley.States
}

--=============================================================================
-- 4. THI BARRETT (Speedster)
-- Fastest character, lowest health. The high-risk, high-reward choice.
--=============================================================================
ROTTPlayers.ThiBarrett = {
    Name = "Thi Barrett",
    Description = "The speedster. Very fast, but quite fragile.",
    
    Default = {
        Health = math.ceil(BASE_HEALTH * 0.8), -- 80 Health (Lowest)
        PlayerSpeed = BASE_SPEED * 1.2, -- Fastest movement
        DamageFactor = 1.0,
        AirControl = 1.0 -- Best air control
    },
    
    States = ROTTPlayers.IanFreeley.States
}


--=============================================================================
-- REGISTRATION
--=============================================================================

--- Register all defined ROTT player classes with the engine.
if OmniWolf.RegisterPlayerClass then
    for name, playerDef in pairs(ROTTPlayers) do
        -- The registration function takes the class name and the definition table
        OmniWolf.RegisterPlayerClass("ROTTPlayer_" .. name, playerDef)
        OmniWolf.Print("Registered ROTT Player Class: ROTTPlayer_" .. name)
    end
end

-- Export the player definitions
return ROTTPlayers
