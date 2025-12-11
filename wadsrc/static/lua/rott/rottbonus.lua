--[[
  Rise of The Triad Bonus Items (rottbonus.lua)
  
  Defines score-based bonus items (Ankh, Gold Bar, Trophy) which grant
  points to the player's score upon pickup.
--]]

local OmniWolf = require("omniwolf_api")

local ROTTBonuses = {}

--=============================================================================
-- SHARED PICKUP ACTION
--=============================================================================

--- Standard score pickup action. Adds points to the player's score.
--- @param actor_self table The bonus actor instance.
local function A_ScorePickup(actor_self)
    local player = actor_self.Target
    local scoreAmount = actor_self.ScoreValue or 0
    
    if player and scoreAmount > 0 then
        -- Assume the player actor has a score property or an AddScore function
        if player.AddScore then
            player.AddScore(scoreAmount)
        else
            -- Fallback if AddScore doesn't exist (e.g., if using a global score system)
            OmniWolf.A_SetGlobalScore(scoreAmount)
        end
        
        actor_self.PlaySound("ITEM_BONUS_PICKUP")
        OmniWolf.A_Print(actor_self, string.format("Bonus! +%d Points!", scoreAmount))
            
        -- Remove the pickup from the map
        actor_self.Destroy()
    end
end

--=============================================================================
-- BONUS ITEM DEFINITIONS
--=============================================================================

-- 1. ANKH (Low Value Score Item)
ROTTBonuses.Ankh = {
    Name = "Ankh",
    ScoreValue = 100, -- 100 points
    Radius = 10,
    Height = 16,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true },
    
    States = {
        Spawn = { Sprite = "ANKHAB", Duration = 8, Loop = true, Action = "A_Wobble" },
        Pickup = { Action = A_ScorePickup, NextState = "Stop" }
    }
}

-- 2. GOLD BAR (Medium Value Score Item)
ROTTBonuses.GoldBar = {
    Name = "GoldBar",
    ScoreValue = 500, -- 500 points
    Radius = 12,
    Height = 20,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true },
    
    States = {
        Spawn = { Sprite = "GOLDAB", Duration = 6, Loop = true, Action = "A_Wobble" },
        Pickup = { Action = A_ScorePickup, NextState = "Stop" }
    }
}

-- 3. GOLD TROPHY (High Value Score Item)
ROTTBonuses.GoldTrophy = {
    Name = "GoldTrophy",
    ScoreValue = 1000, -- 1000 points
    Radius = 14,
    Height = 24,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true, SHADOW = true },
    
    States = {
        Spawn = { Sprite = "TROPAB", Duration = 4, Loop = true, Action = "A_Rotate" },
        Pickup = { Action = A_ScorePickup, NextState = "Stop" }
    }
}


--=============================================================================
-- REGISTRATION
--=============================================================================

if OmniWolf.RegisterActorClass then
    for name, def in pairs(ROTTBonuses) do
        if def.Flags and def.Flags.IS_PICKUP then
            -- Register the physical bonus actor
            OmniWolf.RegisterActorClass("ROTTBonus_" .. name, def)
            OmniWolf.Print("Registered ROTT Bonus Item: ROTTBonus_" .. name)
        end
    end
end

return ROTTBonuses
