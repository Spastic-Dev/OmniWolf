--[[
  Rise of The Triad Health Pickups (rotthealth.lua)
  
  Defines the primary health recovery items and the special Life Sphere 
  (Extra Life) pickup from ROTT.
--]]

local OmniWolf = require("omniwolf_api")

local ROTTHealth = {}

-- Define Supercharge maximum health for the Life Sphere effect
local SUPERCHARGE_MAX_HEALTH = 200 

--=============================================================================
-- SHARED PICKUP ACTION
--=============================================================================

--- Standard health pickup action. Adds health to the player.
--- @param actor_self table The health actor instance.
local function A_HealthPickup(actor_self)
    local player = actor_self.Target
    local amount = actor_self.HealthAmount or 0
    local isSuper = actor_self.IsSupercharge or false
    
    if player and amount > 0 then
        local maxHealth = player.MaxHealth
        local currentHealth = player.Health
        
        -- Determine the maximum health ceiling
        local ceiling = isSuper and SUPERCHARGE_MAX_HEALTH or maxHealth
        
        -- Calculate how much health to actually add
        local healAmount = math.min(amount, ceiling - currentHealth)
        
        if healAmount > 0 then
            player.Health = currentHealth + healAmount
            actor_self.PlaySound("ITEM_HEALTH_PICKUP")
            
            if isSuper then
                 OmniWolf.A_Print(actor_self, string.format("Life Sphere! Health boosted to %d!", player.Health))
            else
                 OmniWolf.A_Print(actor_self, string.format("Gained %d Health!", healAmount))
            end
            
            -- Remove the pickup from the map
            actor_self.Destroy()
        end
        -- If healAmount is 0, the player is already at or above the ceiling, so no pickup occurs.
    end
end

--=============================================================================
-- HEALTH PICKUP DEFINITIONS
--=============================================================================

-- 1. SMALL HEALING SPHERE (Pill)
ROTTHealth.SmallHealingPill = {
    Name = "SmallHealingPill",
    HealthAmount = 10,
    Radius = 10,
    Height = 16,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true },
    
    States = {
        Spawn = { Sprite = "HLTSAB", Duration = 6, Loop = true, Action = "A_Wobble" },
        Pickup = { Action = A_HealthPickup, NextState = "Stop" }
    }
}

-- 2. LARGE HEALING SPHERE (Pill)
ROTTHealth.LargeHealingPill = {
    Name = "LargeHealingPill",
    HealthAmount = 25,
    Radius = 12,
    Height = 20,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true },
    
    States = {
        Spawn = { Sprite = "HLTLAB", Duration = 6, Loop = true, Action = "A_Wobble" },
        Pickup = { Action = A_HealthPickup, NextState = "Stop" }
    }
}

-- 3. LIFE SPHERE (Extra Life / Supercharge)
-- In ROTT, this acts like an extra life, often granting a massive health boost (e.g., +100)
-- and potentially acting as a Supercharge up to 200.
ROTTHealth.LifeSphere = {
    Name = "LifeSphere",
    HealthAmount = 100, -- Large amount added
    IsSupercharge = true, -- Special flag for higher max health
    Radius = 16,
    Height = 24,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true, SHADOW = true },
    
    States = {
        Spawn = { Sprite = "LIFEAB", Duration = 4, Loop = true, Action = "A_Rotate" },
        Pickup = { Action = A_HealthPickup, NextState = "Stop" }
    }
}


--=============================================================================
-- REGISTRATION
--=============================================================================

if OmniWolf.RegisterActorClass then
    for name, def in pairs(ROTTHealth) do
        if def.Flags and def.Flags.IS_PICKUP then
            -- Register the physical health pickup actor
            OmniWolf.RegisterActorClass("ROTTHealth_" .. name, def)
            OmniWolf.Print("Registered ROTT Health Pickup: ROTTHealth_" .. name)
        end
    end
end

return ROTTHealth
