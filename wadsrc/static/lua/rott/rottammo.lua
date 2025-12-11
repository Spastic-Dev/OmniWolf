--[[
  Rise of The Triad Ammunition (rottammo.lua)
  
  Defines the primary ammunition types and their corresponding physical pickups
  for ROTT weapons, covering standard bullets and explosive rounds.
--]]

local OmniWolf = require("omniwolf_api")

local ROTTAmmo = {}

--=============================================================================
-- INVENTORY AMMO DEFINITIONS (The items the player holds)
--=============================================================================

-- 1. Standard Bullet Ammunition (Used by Pistol, MP40, etc.)
ROTTAmmo.BulletAmmo = {
    Name = "ROTT_BulletAmmo",
    MaxAmount = 500,
    Flags = { IS_AMMO = true },
    Icon = "BULTIC", -- Placeholder icon
    Message = "Picked up standard bullet ammo.",
}

-- 2. Explosive Ammunition (Used by Bazooka, Heatseeker, etc.)
ROTTAmmo.ExplosiveAmmo = {
    Name = "ROTT_ExplosiveAmmo",
    MaxAmount = 50,
    Flags = { IS_AMMO = true },
    Icon = "EXPLOS", -- Placeholder icon
    Message = "Picked up explosive rocket ammo.",
}

--=============================================================================
-- SHARED PICKUP ACTION
--=============================================================================

--- Standard ammo pickup action. Gives the amount specified by the AmmoAmount 
--- property to the player's corresponding InventoryName ammo type.
--- @param actor_self table The ammo actor instance.
local function A_AmmoPickup(actor_self)
    local player = actor_self.Target
    local inventoryName = actor_self.InventoryName
    local amount = actor_self.AmmoAmount or 0
    
    if player and inventoryName and amount > 0 then
        local current = player.GetInventory(inventoryName)
        local max = OmniWolf.GetInventoryMax(inventoryName) -- Assumes function exists
        
        -- Only play sound/message if space is available
        if current < max then
            player.GiveInventory(inventoryName, amount)
            actor_self.PlaySound("ITEM_AMMO_PICKUP")
            OmniWolf.A_Print(actor_self, string.format("Gained %d %s!", amount, inventoryName))
        end
    end
    
    -- Remove the key from the map
    actor_self.Destroy()
end


--=============================================================================
-- PHYSICAL AMMO PICKUP DEFINITIONS (The actors placed in the world)
--=============================================================================

-- 1. SMALL BULLET BOX (Pistol/MP40 Ammo)
ROTTAmmo.SmallBulletBox = {
    Name = "SmallBulletBox",
    InventoryName = "ROTT_BulletAmmo",
    AmmoAmount = 50, -- +50 bullets
    Radius = 10,
    Height = 16,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true },
    
    States = {
        Spawn = { Sprite = "BULSAB", Duration = 6, Loop = true, Action = "A_Wobble" },
        Pickup = { Action = A_AmmoPickup, NextState = "Stop" }
    }
}

-- 2. LARGE BULLET BOX (Pistol/MP40 Ammo)
ROTTAmmo.LargeBulletBox = {
    Name = "LargeBulletBox",
    InventoryName = "ROTT_BulletAmmo",
    AmmoAmount = 150, -- +150 bullets
    Radius = 12,
    Height = 24,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true },
    
    States = {
        Spawn = { Sprite = "BULLAB", Duration = 6, Loop = true, Action = "A_Wobble" },
        Pickup = { Action = A_AmmoPickup, NextState = "Stop" }
    }
}

-- 3. SMALL EXPLOSIVE CRATE (Rocket/Heatseeker Ammo)
ROTTAmmo.SmallExplosiveCrate = {
    Name = "SmallExplosiveCrate",
    InventoryName = "ROTT_ExplosiveAmmo",
    AmmoAmount = 5, -- +5 Explosive rounds
    Radius = 14,
    Height = 18,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true },
    
    States = {
        Spawn = { Sprite = "EXPSAB", Duration = 6, Loop = true, Action = "A_Wobble" },
        Pickup = { Action = A_AmmoPickup, NextState = "Stop" }
    }
}

-- 4. LARGE EXPLOSIVE CRATE (Rocket/Heatseeker Ammo)
ROTTAmmo.LargeExplosiveCrate = {
    Name = "LargeExplosiveCrate",
    InventoryName = "ROTT_ExplosiveAmmo",
    AmmoAmount = 15, -- +15 Explosive rounds
    Radius = 16,
    Height = 28,
    Flags = { IS_PICKUP = true, TRANSLUCENT = true },
    
    States = {
        Spawn = { Sprite = "EXPLAB", Duration = 6, Loop = true, Action = "A_Wobble" },
        Pickup = { Action = A_AmmoPickup, NextState = "Stop" }
    }
}


--=============================================================================
-- REGISTRATION
--=============================================================================

if OmniWolf.RegisterActorClass and OmniWolf.RegisterInventoryClass then
    for name, def in pairs(ROTTAmmo) do
        if def.Flags and def.Flags.IS_AMMO then
            -- Register the inventory ammo item
            OmniWolf.RegisterInventoryClass(name, def)
            OmniWolf.Print("Registered ROTT Ammo Inventory: " .. name)
        elseif def.Flags and def.Flags.IS_PICKUP then
            -- Register the physical ammo pickup actor
            OmniWolf.RegisterActorClass("ROTTAmmo_" .. name, def)
            OmniWolf.Print("Registered ROTT Ammo Pickup: ROTTAmmo_" .. name)
        end
    end
end

return ROTTAmmo
