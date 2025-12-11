/**
 * DEPTH DWELLERS WEAPONS DATA
 *
 * This object defines the properties and behaviors for each weapon the player
 * can wield in the Depth Dwellers module for OmniWolf. These properties
 * would be used by the engine's rendering (spriteBase) and combat (damage, rate)
 * systems.
 *
 * NOTE: FireRate is defined in milliseconds (ms) for engine timing checks.
 */

const DepthDwellersWeapons = {
    // --- AMMO TYPES ---
    AMMO_TYPE: {
        ENERGY: 'Energy Cell',
        ROCKETS: 'Rocket Ammo',
        FUEL: 'Flamer Fuel',
        MINES: 'Strategic Mine',
    },

    // 1. LASER PISTOL (Default Weapon)
    'Laser Pistol': {
        name: 'Laser Pistol',
        id: 'pistol',
        type: 'hitscan',        // Instant hit (like W3D's gun)
        damage: 15,             // Low base damage
        ammoType: 'Energy Cell',
        ammoConsumption: 1,
        fireRate: 400,          // 400ms delay between shots (moderate)
        spriteBase: 'laser_pistol', // Base file name for the weapon sprites
        description: 'Standard issue energy weapon, reliable but slow.',
        sound: 'pistol_fire',
    },

    // 2. RAPID FIRE PULSE LASER (Fastest weapon)
    'Rapid Fire Pulse Laser': {
        name: 'Rapid Fire Pulse Laser',
        id: 'pulse_laser',
        type: 'hitscan',
        damage: 10,             // Lower damage per shot than pistol, but much faster
        ammoType: 'Energy Cell',
        ammoConsumption: 1,
        fireRate: 100,          // 100ms delay (very fast, like a chaingun)
        spriteBase: 'pulse_laser',
        description: 'High rate of fire, drains energy quickly, devastating up close.',
        sound: 'pulse_fire',
    },

    // 3. ROCKET LAUNCHER (Projectile Weapon)
    'Rocket Launcher': {
        name: 'Rocket Launcher',
        id: 'rocket_launcher',
        type: 'projectile',     // Launches a visible sprite projectile
        damage: 80,             // High damage on direct hit
        splashRadius: 2,        // Splash damage radius (in map tiles)
        ammoType: 'Rocket Ammo',
        ammoConsumption: 1,
        fireRate: 1500,         // 1.5s delay (slow, powerful)
        spriteBase: 'rocket_launcher',
        description: 'Launches explosive rockets for massive area damage.',
        sound: 'rocket_launch',
    },

    // 4. FLAME THROWER (Short Range / Continuous Fire)
    'Flame Thrower': {
        name: 'Flame Thrower',
        id: 'flame_thrower',
        type: 'flame',          // Continuous damage cone / short-range AoE
        damage: 3,              // Very low damage per tick
        damageFrequency: 100,   // Damage applied every 100ms (high effective DPS)
        range: 1.5,             // Short effective range (in map tiles)
        ammoType: 'Flamer Fuel',
        ammoConsumption: 0.5,   // Consumes ammo over time
        fireRate: 50,           // Animation/tick rate (very fast, continuous)
        spriteBase: 'flame_thrower',
        description: 'Incinerates enemies at close range with continuous fire.',
        sound: 'flame_hiss',
    },

    // 5. STRATEGIC MINE DISPENSER (Utility/Trap Weapon)
    'Strategic Mine Dispenser': {
        name: 'Strategic Mine Dispenser',
        id: 'mine_dispenser',
        type: 'utility',        // Plants a persistent object (mine)
        damage: 120,            // Extreme damage on detonation
        ammoType: 'Strategic Mine',
        ammoConsumption: 1,
        fireRate: 1000,         // 1.0s delay for deployment
        spriteBase: 'mine_dispenser',
        description: 'Deploys a proximity mine to trap enemies.',
        sound: 'mine_deploy',
    },
};


// --- Player Inventory Class (for managing weapon state) ---
/**
 * A utility class representing the player's weapon management system.
 * In a real engine, this would be integrated into the main Player class,
 * but this demonstrates how the data is used.
 */
class WeaponManager {
    constructor(player) {
        this.player = player;
        this.weapons = DepthDwellersWeapons;
        this.lastFireTime = 0;
        this.ammoInventory = {
            'Energy Cell': 50,
            'Rocket Ammo': 0,
            'Flamer Fuel': 0,
            'Strategic Mine': 0,
        };
        this.equippedWeaponId = 'pistol'; // Start with Laser Pistol
    }

    /**
     * Attempts to fire the currently equipped weapon.
     * @param {number} currentTime The current timestamp (e.g., performance.now()).
     * @returns {boolean} True if the shot was fired, false otherwise.
     */
    tryFire(currentTime) {
        const weapon = Object.values(this.weapons).find(w => w.id === this.equippedWeaponId);

        if (!weapon) {
            console.error("No weapon equipped!");
            return false;
        }

        // Check fire rate delay
        if (currentTime < this.lastFireTime + weapon.fireRate) {
            return false; // Too fast
        }

        // Check ammo
        if (this.ammoInventory[weapon.ammoType] >= weapon.ammoConsumption) {
            this.ammoInventory[weapon.ammoType] -= weapon.ammoConsumption;
            this.lastFireTime = currentTime;

            // Log action for the game loop to handle the actual firing/raycasting
            console.log(`[${weapon.name}] Fired! Ammo left: ${this.ammoInventory[weapon.ammoType]}`);

            // The engine would use the 'type' property here:
            // if (weapon.type === 'hitscan') { /* Do raycast hitscan */ }
            // else if (weapon.type === 'projectile') { /* Spawn Rocket entity */ }

            return true;
        } else {
            console.log(`[${weapon.name}] Click! Need ${weapon.ammoType}.`);
            return false;
        }
    }

    /**
     * Changes the currently equipped weapon.
     * @param {string} weaponId The ID of the weapon to equip (e.g., 'rocket_launcher').
     * @returns {boolean} True if the weapon was changed.
     */
    equipWeapon(weaponId) {
        const weapon = Object.values(this.weapons).find(w => w.id === weaponId);
        if (weapon) {
            this.equippedWeaponId = weaponId;
            console.log(`Equipped: ${weapon.name}`);
            return true;
        }
        return false;
    }
}


// --- Example Usage Demonstration ---
const playerMock = { x: 1, y: 1 }; // Mock player data
const manager = new WeaponManager(playerMock);

// Give the player some starting weapons and ammo
manager.ammoInventory['Energy Cell'] = 150;
manager.ammoInventory['Rocket Ammo'] = 5;
manager.ammoInventory['Strategic Mine'] = 3;

console.log("\n--- Weapon Manager Demo ---");

// 1. Try firing the default pistol
manager.tryFire(performance.now()); // Fire 1

// 2. Equip a high-powered projectile weapon
manager.equipWeapon('rocket_launcher');
manager.tryFire(performance.now()); // Fire 1st rocket

// 3. Try firing again immediately (should fail due to 1.5s fire rate)
manager.tryFire(performance.now()); // Fails

// 4. Equip the rapid-fire laser
manager.equipWeapon('pulse_laser');
manager.tryFire(performance.now()); // Fire 1
manager.tryFire(performance.now() + 101); // Fire 2 (Rate is 100ms)

console.log(`\nCurrent Ammo Status:`, manager.ammoInven
