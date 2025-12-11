/**
 * SHADOWCASTER PLAYER ACTOR DEFINITION
 *
 * This TypeScript structure defines the core states and properties for the
 * player character, morphs, and weapons in the Shadowcaster module,
 * following a DECORATE-like syntax for compatibility with the OmniWolf/Raven Engine structure.
 *
 * Sprites: PLY[Frame][Rotation]
 * Rotation is generally 0 for the player actor itself.
 */

// --- TYPE DEFINITIONS for DECORATE-like Structure ---

type Action = string; // Engine function call (e.g., 'A_FireWeapon', 'A_Warp')
type StateName = string;

interface ActorState {
    sprite: string;
    tics: number; // Tics to hold the frame (35 tics = 1 second)
    action?: Action;
    next?: StateName;
}

interface ActorDefinition {
    health: number;
    speed: number;
    radius: number;
    height: number;
    type: 'player' | 'morph'; // Expanded type for morph tracking
    // Base states are an array to allow for simple animation loops
    states: { [key: string]: ActorState | ActorState[] };
}

interface WeaponState {
    sprite: string;
    tics: number;
    action?: Action;
    next?: StateName;
}

interface WeaponDefinition {
    ammoType: string;
    damage: number;
    fireRate: number; // ms delay between shots
    isMelee?: boolean;
    states: { [key: string]: WeaponState | WeaponState[] };
}

// --- ACTOR DATA (Player and Morphs) ---

const SHADOWCASTER_ACTORS: { [key: string]: ActorDefinition } = {

    // --- 1. BASE PLAYER ACTOR (Human Form) ---
    ShadowcasterPlayer: {
        health: 100,
        speed: 15,              // Base movement speed
        radius: 0.3,            // Player collision radius
        height: 1.8,            // Player visual height
        type: 'player',

        states: {
            Spawn: {
                sprite: 'PLYRA0', // Default spawn pose
                tics: 1,
                action: 'A_GiveDefaultWeapon', // Ensure player has a weapon
                next: 'Ready',
            },
            Ready: { // Idle state (Player standing still, weapon visible)
                sprite: 'PLYRA0',
                tics: 1,
                action: 'A_WeaponReady', // Engine draws the weapon sprite
                next: 'Ready',
            },
            Walk: [ // Walking/Moving animation loop
                { sprite: 'PLYRB0', tics: 4, action: 'A_WeaponBob' },
                { sprite: 'PLYRC0', tics: 4, action: 'A_WeaponBob' },
                { sprite: 'PLYRD0', tics: 4, action: 'A_WeaponBob' },
                { sprite: 'PLYRE0', tics: 4, action: 'A_WeaponBob', next: 'Walk' }
            ],
            Pain: { // When the player takes damage
                sprite: 'PLYRF0',
                tics: 5,
                action: 'A_Pain', // Engine applies screen flash/recoil effect
                next: 'Ready',
            },
            Attack: { // Generic attack state (used by the engine if a weapon is fired)
                sprite: 'PLYRG0',
                tics: 6,
                action: 'A_StartWeaponFire',
                next: 'Ready',
            },
            Death: [ // Player death sequence
                { sprite: 'PLYRH0', tics: 8, action: 'A_Scream' },
                { sprite: 'PLYRI0', tics: 8 },
                { sprite: 'PLYRJ0', tics: 8 },
                { sprite: 'PLYRK0', tics: 10, action: 'A_Fall' }, // Player hits the ground
                { sprite: 'PLYRL0', tics: -1, next: 'FinalDeath' } // Hold last frame
            ],
            FinalDeath: {
                sprite: 'PLYRL0', // Hold the final death pose
                tics: -1,
                action: 'A_PlayerKilled' // Engine displays death screen
            },
            // --- Raven Engine additions (Conceptual) ---
            Jump: {
                sprite: 'PLYRM0',
                tics: 10,
                action: 'A_JumpMomentum', // Add vertical momentum
                next: 'Walk', // Return to walk state after the jump impulse
            },
        }
    },

    // --- 2. MORPH ACTOR: KALLIGOR (Speed/Agility Form) ---
    KalligorMorph: {
        health: 75,             // Lower health
        speed: 25,              // High speed
        radius: 0.3,
        height: 1.8,
        type: 'morph',

        states: {
            Spawn: { sprite: 'KLGRA0', tics: 1, action: 'A_MorphSetup', next: 'Ready' },
            Ready: { sprite: 'KLGRA0', tics: 1, action: 'A_WeaponReady', next: 'Ready' },
            Walk: [
                { sprite: 'KLGRB0', tics: 3, action: 'A_WeaponBob' },
                { sprite: 'KLGRC0', tics: 3, action: 'A_WeaponBob' },
                { sprite: 'KLGRD0', tics: 3, action: 'A_WeaponBob' },
                { sprite: 'KLGRE0', tics: 3, action: 'A_WeaponBob', next: 'Walk' }
            ],
            Pain: { sprite: 'KLGRF0', tics: 4, action: 'A_Pain', next: 'Ready' },
            Attack: { // Morph attack (uses gauntlet stats but unique animation)
                sprite: 'KLGRG0',
                tics: 8,
                action: 'A_MeleeStrike',
                next: 'Ready'
            },
            Death: [
                { sprite: 'KLGRH0', tics: 6, action: 'A_MorphFail' }, // Return to human form or die
                { sprite: 'KLGRI0', tics: -1, next: 'FinalDeath' }
            ],
        }
    },

    // --- 3. MORPH ACTOR: SHRYAK (Strength/Tank Form) ---
    ShryakMorph: {
        health: 200,            // High health
        speed: 10,              // Low speed
        radius: 0.5,            // Larger collision box
        height: 2.5,
        type: 'morph',

        states: {
            Spawn: { sprite: 'SHRKA0', tics: 1, action: 'A_MorphSetup', next: 'Ready' },
            Ready: { sprite: 'SHRKA0', tics: 1, action: 'A_WeaponReady', next: 'Ready' },
            Walk: [
                { sprite: 'SHRKB0', tics: 6, action: 'A_WeaponBob' },
                { sprite: 'SHRKC0', tics: 6, action: 'A_WeaponBob', next: 'Walk' }
            ],
            Pain: { sprite: 'SHRKD0', tics: 8, action: 'A_Pain', next: 'Ready' },
            Attack: { // Powerful morph attack
                sprite: 'SHRKE0',
                tics: 12,
                action: 'A_ChargePunch',
                next: 'Ready'
            },
            Death: [
                { sprite: 'SHRKF0', tics: 10, action: 'A_MorphFail' },
                { sprite: 'SHRKG0', tics: -1, next: 'FinalDeath' }
            ],
        }
    }
};

// --- WEAPON DATA ---

const SHADOWCASTER_WEAPONS: { [key: string]: WeaponDefinition } = {
    // 1. PLAYER WEAPON: GAUNTLET (Default Melee)
    Gauntlet: {
        ammoType: 'None',
        damage: 10,
        fireRate: 300,
        isMelee: true,

        states: {
            Ready: { sprite: 'GNTLA0', tics: 1, action: 'A_WeaponReady', next: 'Ready' },
            Fire: [
                { sprite: 'GNTLB0', tics: 3, action: 'A_GauntletSwing' },
                { sprite: 'GNTLC0', tics: 3 },
                { sprite: 'GNTLD0', tics: 4, action: 'A_ReFire', next: 'Ready' }
            ],
            Deselect: [
                { sprite: 'GNTLE0', tics: 3, action: 'A_Lower', next: 'Down' }
            ],
            Select: [
                { sprite: 'GNTLE0', tics: 3, action: 'A_Raise', next: 'Ready' }
            ],
            Down: { sprite: 'GNTLE0', tics: 1, action: 'A_Lower', next: 'Down' }
        }
    },

    // 2. PLAYER WEAPON: VORTEX (Primary Ranged Weapon)
    Vortex: {
        ammoType: 'VortexCell',
        damage: 30,
        fireRate: 800,
        isMelee: false,

        states: {
            Ready: { sprite: 'VRXEA0', tics: 1, action: 'A_WeaponReady', next: 'Ready' },
            Fire: [
                { sprite: 'VRXEB0', tics: 4, action: 'A_CheckAmmo' },
                { sprite: 'VRXEC0', tics: 4, action: 'A_FireProjectile' }, // Engine spawns VortexBolt
                { sprite: 'VRXED0', tics: 6, action: 'A_ReFire', next: 'Ready' }
            ],
            Deselect: [
                { sprite: 'VRXEE0', tics: 3, action: 'A_Lower', next: 'Down' }
            ],
            Select: [
                { sprite: 'VRXEE0', tics: 3, action: 'A_Raise', next: 'Ready' }
            ],
            Down: { sprite: 'VRXEE0', tics: 1, action: 'A_Lower', next: 'Down' }
        }
    }
};
