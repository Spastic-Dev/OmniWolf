/**
 * DEPTH DWELLERS DECORATIONS DATA
 *
 * This object defines all static and non-interactive environmental sprites,
 * using the DECORATE-like state format for visual representation.
 *
 * Key:
 * Tics: Game frames (35 tics = 1 second)
 * isSolid: Determines if the player or entities can pass through it.
 */

const DEPTH_DWELLERS_DECORATIONS = {

    // --- 1. LARGE STORAGE CRATE (Solid Obstacle) ---
    LargeCrate: {
        health: 200,            // Can be destroyed
        radius: 0.45,
        height: 1.5,
        isSolid: true,
        isDestructible: true,
        sound: 'crate_break',

        states: {
            Spawn: {
                sprite: 'CRTA',
                tics: -1,       // Static
                next: 'Spawn',
            },
            Death: [
                { sprite: 'CRTB', tics: 5, action: 'A_Shatter' },
                { sprite: 'CRTC', tics: 5 },
                { sprite: 'CRTD', tics: -1, action: 'A_Remove' }
            ]
        }
    },

    // --- 2. SCI-FI BARREL (Explosive Hazard) ---
    ExplosiveBarrel: {
        health: 50,             // Easily destroyed
        radius: 0.3,
        height: 1.2,
        isSolid: true,
        isDestructible: true,
        isExplosive: true,
        explosionDamage: 150,   // High damage radius
        explosionRadius: 3,

        states: {
            Spawn: {
                sprite: 'BARA',
                tics: -1,
                next: 'Spawn',
            },
            Death: [ // Explosion sequence
                { sprite: 'BARB', tics: 4, action: 'A_ExplosionSound' },
                { sprite: 'BARC', tics: 4, action: 'A_ExplodeDamage' },
                { sprite: 'BARD', tics: 4 },
                { sprite: 'BARE', tics: 4 },
                { sprite: 'BARF', tics: -1, action: 'A_Remove' }
            ]
        }
    },

    // --- 3. FLOOR-STANDING MONITOR CONSOLE (Scenery) ---
    MonitorConsole: {
        health: 1,              // Undestroyable scenery (or low health for visual break)
        radius: 0.25,
        height: 1.6,
        isSolid: false,         // Player can walk through the base, but not the screen
        isDestructible: false,
        
        states: {
            Spawn: [
                { sprite: 'MONA', tics: 8 }, // Screen flickers slightly
                { sprite: 'MONB', tics: 8, next: 'Spawn' }
            ],
            Death: { // Placeholder for cleanup if health is non-zero
                sprite: 'MONC',
                tics: 1,
                action: 'A_Remove'
            }
        }
    },

    // --- 4. FLICKERING CEILING LAMP (Ambient Light/Animation) ---
    CeilingLamp: {
        health: 1,
        radius: 0.1,
        height: 0.2,
        isSolid: false,
        isLightSource: true,
        
        states: {
            Spawn: [
                { sprite: 'LUPA', tics: 4 },
                { sprite: 'LUPB', tics: 4 },
                { sprite: 'LUPC', tics: 4, next: 'Spawn' } // Flickering effect
            ],
            Death: { // When the lamp is shot out
                sprite: 'LUPD',
                tics: -1,
                action: 'A_RemoveLight' // Engine removes light source
            }
        }
    },

    // --- 5. VISCERAL DEBRIS PILE (Non-Solid Gore) ---
    DebrisPile: {
        health: 1,
        radius: 0.2,
        height: 0.1,
        isSolid: false,         // Scenery, no collision
        isDestructible: false,

        states: {
            Spawn: {
                sprite: 'GOR1',
                tics: -1,
                next: 'Spawn',
            },
            Death: { // Just a cleanup state
                sprite: 'GOR1',
                tics: 1,
                action: 'A_Remove'
            }
        }
    }
};

// Example access:
// console.log("Explosive Barrel Explosion Frame:", DEPTH_DWELLERS_DECORATIONS.ExplosiveBarrel.states.Death[2].sprite);
