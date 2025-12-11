/**
 * DEPTH DWELLERS PICKUPS DATA
 *
 * This object defines all static items the player can collect, including
 * health, ammunition, and keys. It follows the DECORATE state format
 * but uses 'effect' and 'amount' properties for immediate impact.
 *
 * Key:
 * Tics: Game frames (35 tics = 1 second)
 * Effect: The function the engine should call (e.g., A_GiveHealth, A_GiveAmmo)
 */

const DEPTH_DWELLERS_PICKUPS = {

    // --- HEALTH & ARMOR ---

    // 1. MEDKIT (Standard Health)
    Medkit: {
        radius: 0.2,
        height: 0.4,
        effect: 'A_GiveHealth',
        amount: 25,
        limit: 100, // Max health limit
        sound: 'pickup_health',

        states: {
            Spawn: [
                { sprite: 'HPKA', tics: 6 },
                { sprite: 'HPKB', tics: 6, next: 'Spawn' } // Pulsing animation
            ],
            Pickup: { // State entered when collected
                sprite: 'HPKC',
                tics: 1,
                action: 'A_Remove'
            }
        }
    },

    // 2. STIM PACK (Small Health Boost)
    StimPack: {
        radius: 0.15,
        height: 0.3,
        effect: 'A_GiveHealth',
        amount: 10,
        limit: 100,
        sound: 'pickup_health_small',

        states: {
            Spawn: [
                { sprite: 'HPDA', tics: 6, next: 'Spawn' }
            ],
            Pickup: {
                sprite: 'HPEC',
                tics: 1,
                action: 'A_Remove'
            }
        }
    },

    // --- AMMO ---

    // 3. ENERGY CELL PACK (For Laser Pistol and Pulse Laser)
    EnergyCellPack: {
        radius: 0.2,
        height: 0.5,
        effect: 'A_GiveAmmo',
        ammoType: 'Energy Cell',
        amount: 50,
        sound: 'pickup_ammo',

        states: {
            Spawn: [
                { sprite: 'ECPA', tics: 5 },
                { sprite: 'ECPB', tics: 5, next: 'Spawn' }
            ],
            Pickup: {
                sprite: 'ECPC',
                tics: 1,
                action: 'A_Remove'
            }
        }
    },

    // 4. ROCKET AMMO Crate (For Rocket Launcher)
    RocketAmmoCrate: {
        radius: 0.3,
        height: 0.6,
        effect: 'A_GiveAmmo',
        ammoType: 'Rocket Ammo',
        amount: 5,
        sound: 'pickup_ammo_heavy',

        states: {
            Spawn: {
                sprite: 'RACA', tics: -1, // Static sprite
                next: 'Spawn'
            },
            Pickup: {
                sprite: 'RACD',
                tics: 1,
                action: 'A_Remove'
            }
        }
    },

    // 5. FLAMER FUEL TANK (For Flame Thrower)
    FlamerFuelTank: {
        radius: 0.25,
        height: 0.55,
        effect: 'A_GiveAmmo',
        ammoType: 'Flamer Fuel',
        amount: 100, // Fuel is consumed continuously, so a large amount
        sound: 'pickup_fuel',

        states: {
            Spawn: [
                { sprite: 'FFTA', tics: 8, next: 'Spawn' }
            ],
            Pickup: {
                sprite: 'FFTD',
                tics: 1,
                action: 'A_Remove'
            }
        }
    },

    // 6. STRATEGIC MINES (For Mine Dispenser)
    StrategicMine: {
        radius: 0.15,
        height: 0.2,
        effect: 'A_GiveAmmo',
        ammoType: 'Strategic Mine',
        amount: 1,
        sound: 'pickup_mine',

        states: {
            Spawn: {
                sprite: 'SMNA', tics: -1,
                next: 'Spawn'
            },
            Pickup: {
                sprite: 'SMNB',
                tics: 1,
                action: 'A_Remove'
            }
        }
    },

    // --- KEYS ---

    // 7. BLUE KEYCARD
    BlueKeycard: {
        radius: 0.1,
        height: 0.1,
        effect: 'A_GiveKey',
        keyType: 'Blue Keycard',
        sound: 'pickup_key',

        states: {
            Spawn: [
                { sprite: 'KYCA', tics: 4 },
                { sprite: 'KYCB', tics: 4, next: 'Spawn' } // Rotating/hovering animation
            ],
            Pickup: {
                sprite: 'KYCC',
                tics: 1,
                action: 'A_Remove'
            }
        }
    },
};

// --- Example of Engine Pickup Logic (Conceptual) ---
class PickupHandler {
    constructor(playerState) {
        this.playerState = playerState;
    }

    handlePickup(itemName) {
        const item = DEPTH_DWELLERS_PICKUPS[itemName];
        if (!item) {
            console.error(`Unknown item: ${itemName}`);
            return;
        }

        console.log(`Player collected: ${itemName}`);

        switch (item.effect) {
            case 'A_GiveHealth':
                this.playerState.health = Math.min(item.limit, this.playerState.health + item.amount);
                console.log(`+${item.amount} Health. Current: ${this.playerState.health}`);
                break;

            case 'A_GiveAmmo':
                this.playerState.ammo[item.ammoType] = (this.playerState.ammo[item.ammoType] || 0) + item.amount;
                console.log(`+${item.amount} ${item.ammoType}. Current: ${this.playerState.ammo[item.ammoType]}`);
                break;

            case 'A_GiveKey':
                this.playerState.keys[item.keyType] = true;
                console.log(`Picked up ${item.keyType}!`);
                break;

            default:
                console.warn(`Item ${itemName} has an unhandled effect: ${item.effect}`);
        }

        // In the game engine, the item would transition to the 'Pickup' state
        // and be visually removed from the map.
    }
}

// --- Demo ---
const mockPlayerState = {
    health: 75,
    ammo: {
        'Energy Cell': 100,
        'Rocket Ammo': 0
    },
    keys: {}
};

const handler = new PickupHandler(mockPlayerState);
handler.handlePickup('Medkit');
handler.handlePickup('EnergyCellPack');
handler.handlePickup('RocketAmmoCrate');
handler.handlePickup('BlueKeycard');

console.log("\nFinal Player State:", mockPlayerState);
