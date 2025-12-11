--[[
  Rise of The Triad Keys (rottkey.lua)
  
  Defines the four distinct key items used in ROTT for progression.
  Each key grants a unique inventory item upon pickup, which can then
  be checked against locked doors (assumed to be defined elsewhere).
--]]

local OmniWolf = require("omniwolf_api")

local ROTTKeys = {}

--=============================================================================
-- SHARED PICKUP ACTION
--=============================================================================

--- Standard key pickup action. Adds the corresponding inventory item and plays a sound.
--- @param actor_self table The key actor instance.
local function A_KeyPickup(actor_self)
    -- Play a distinct sound for key acquisition
    actor_self.PlaySound("ITEM_KEY_PICKUP")
    
    -- Give the player the corresponding inventory item
    -- The InventoryName property is used to determine which item to give.
    local player = actor_self.Target
    if player and actor_self.InventoryName then
        player.GiveInventory(actor_self.InventoryName, 1)
        OmniWolf.Print(player.Name .. " picked up the " .. actor_self.Name)
    end
    
    -- Remove the key from the map
    actor_self.Destroy()
end

--=============================================================================
-- KEY ITEM DEFINITIONS
--=============================================================================

-- 1. GOLD KEY
ROTTKeys.GoldKey = {
    Name = "GoldKey",
    InventoryName = "ROTT_GoldKeyItem", -- Inventory item the player receives
    Radius = 16,
    Height = 16,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true },
    
    States = {
        Spawn = { Sprite = "GOLDAB", Duration = 8, Loop = true, Action = "A_Wobble" }, -- A_Wobble for visual appeal
        Pickup = { Action = A_KeyPickup, NextState = "Stop" }
    }
}

-- 2. SILVER KEY
ROTTKeys.SilverKey = {
    Name = "SilverKey",
    InventoryName = "ROTT_SilverKeyItem",
    Radius = 16,
    Height = 16,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true },
    
    States = {
        Spawn = { Sprite = "SILVAB", Duration = 8, Loop = true, Action = "A_Wobble" },
        Pickup = { Action = A_KeyPickup, NextState = "Stop" }
    }
}

-- 3. IRON KEY (Often red/bronze in ROTT)
ROTTKeys.IronKey = {
    Name = "IronKey",
    InventoryName = "ROTT_IronKeyItem",
    Radius = 16,
    Height = 16,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true },
    
    States = {
        Spawn = { Sprite = "IRONAB", Duration = 8, Loop = true, Action = "A_Wobble" },
        Pickup = { Action = A_KeyPickup, NextState = "Stop" }
    }
}

-- 4. BRONZE KEY (Often green/copper in ROTT)
ROTTKeys.BronzeKey = {
    Name = "BronzeKey",
    InventoryName = "ROTT_BronzeKeyItem",
    Radius = 16,
    Height = 16,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true },
    
    States = {
        Spawn = { Sprite = "BRNZAB", Duration = 8, Loop = true, Action = "A_Wobble" },
        Pickup = { Action = A_KeyPickup, NextState = "Stop" }
    }
}


--=============================================================================
-- INVENTORY ITEM DEFINITIONS (The items the player holds)
--=============================================================================

-- These define the actual inventory item that is tracked by the player.

ROTTKeys.GoldKeyItem = {
    Name = "ROTT_GoldKeyItem",
    MaxAmount = 1,
    Flags = { IS_KEY = true },
    Icon = "GOLDIC"
}

ROTTKeys.SilverKeyItem = {
    Name = "ROTT_SilverKeyItem",
    MaxAmount = 1,
    Flags = { IS_KEY = true },
    Icon = "SILVIC"
}

ROTTKeys.IronKeyItem = {
    Name = "ROTT_IronKeyItem",
    MaxAmount = 1,
    Flags = { IS_KEY = true },
    Icon = "IRONIC"
}

ROTTKeys.BronzeKeyItem = {
    Name = "ROTT_BronzeKeyItem",
    MaxAmount = 1,
    Flags = { IS_KEY = true },
    Icon = "BRNZIC"
}


--=============================================================================
-- REGISTRATION
--=============================================================================

if OmniWolf.RegisterActorClass and OmniWolf.RegisterInventoryClass then
    for name, def in pairs(ROTTKeys) do
        if def.Flags and def.Flags.IS_PICKUP then
            -- Register the physical key actor
            OmniWolf.RegisterActorClass("ROTTKey_" .. name, def)
            OmniWolf.Print("Registered ROTT Key Actor: ROTTKey_" .. name)
        elseif def.Flags and def.Flags.IS_KEY then
            -- Register the inventory key item
            OmniWolf.RegisterInventoryClass(name, def)
            OmniWolf.Print("Registered ROTT Key Inventory Item: " .. name)
        end
    end
end

return ROTTKeys
