/**
 * DepthDwellersPlayer Class
 *
 * Represents the player character (the trained soldier) for a Depth Dwellers
 * module running on a Wolfenstein-style raycasting engine (like OmniWolf).
 * It manages position, orientation, stats, inventory, and movement logic.
 */
class DepthDwellersPlayer {
    /**
     * @param {number} startX Initial X position (in map units, e.g., tiles).
     * @param {number} startY Initial Y position (in map units, e.g., tiles).
     * @param {number} startAngle Initial viewing angle (in radians).
     */
    constructor(startX, startY, startAngle = Math.PI / 2) {
        // Core Positional Data (Center of the player)
        this.x = startX;
        this.y = startY;
        this.angle = startAngle; // Radians, 0 points East/Right
        this.mapUnitSize = 64; // The size of one map tile in game units (e.g., pixels)

        // Raycasting and Camera Vectors (Determined by the angle)
        this.dirX = Math.cos(this.angle);
        this.dirY = Math.sin(this.angle);
        // The camera plane (perp to direction vector) controls the Field of View (FOV).
        // For a 66-degree FOV (common in W3D clones), the magnitude is about 0.66.
        this.planeX = -this.dirY * 0.66;
        this.planeY = this.dirX * 0.66;

        // Player Stats (Based on typical FPS/Wolf3D mechanics)
        this.health = 100;
        this.maxHealth = 100;
        this.armor = 0;
        this.maxAmmo = 999;
        this.ammo = 50;

        // Depth Dwellers Specific Inventory/Abilities
        this.inventory = {
            keys: {
                red: false, // For locked doors
                blue: false // For other locked doors/exit
            },
            weapons: [
                'Laser Pistol', // Starting weapon
                'Rapid Fire Pulse Laser',
                'Rocket Launcher',
                'Flame Thrower',
                'Mine Dispenser'
            ],
            currentWeaponIndex: 0,
            zendleEnergy: 0, // Resource for special abilities
            // The goal-related item: the advanced beaming transport technology
            hasTransportBeam: true,
            slavesRescued: 0
        };

        // Movement Configuration
        this.moveSpeed = 0.05; // Tiles per frame
        this.rotSpeed = 0.03;  // Radians per frame
    }

    /**
     * Updates the player's direction and camera plane vectors based on the current angle.
     * Must be called whenever this.angle changes.
     */
    updateVectors() {
        this.dirX = Math.cos(this.angle);
        this.dirY = Math.sin(this.angle);
        this.planeX = -this.dirY * 0.66;
        this.planeY = this.dirX * 0.66;
    }

    /**
     * Moves the player forward or backward.
     * @param {number} delta A factor for movement (1.0 for forward, -1.0 for backward).
     * @param {function(x: number, y: number): boolean} isColliding A map collision check function.
     */
    move(delta, isColliding) {
        const moveDist = delta * this.moveSpeed * this.mapUnitSize;

        // Calculate potential new X and Y positions
        const newX = this.x + this.dirX * moveDist;
        const newY = this.y + this.dirY * moveDist;

        // Check for collision before moving (A simple box-check around the player)
        // Move X first, then Y, to prevent sliding along walls
        if (!isColliding(newX, this.y)) {
            this.x = newX;
        }
        if (!isColliding(this.x, newY)) {
            this.y = newY;
        }

        // Note: Collision logic requires an external map function,
        // which is standard in a raycasting engine.
    }

    /**
     * Strafes the player left or right (perpendicular to the current direction).
     * @param {number} delta A factor for strafing (1.0 for right, -1.0 for left).
     * @param {function(x: number, y: number): boolean} isColliding A map collision check function.
     */
    strafe(delta, isColliding) {
        const moveDist = delta * this.moveSpeed * this.mapUnitSize;
        // Strafe direction is the camera plane vector (perp to direction vector)
        const strafeDirX = this.planeX / 0.66; // Normalize plane vector to unit length
        const strafeDirY = this.planeY / 0.66; // Normalize plane vector to unit length

        const newX = this.x + strafeDirX * moveDist;
        const newY = this.y + strafeDirY * moveDist;

        // Check for collision before moving
        if (!isColliding(newX, this.y)) {
            this.x = newX;
        }
        if (!isColliding(this.x, newY)) {
            this.y = newY;
        }
    }

    /**
     * Rotates the player's view left or right.
     * @param {number} delta A factor for rotation (1.0 for right turn, -1.0 for left turn).
     */
    rotate(delta) {
        const rot = delta * this.rotSpeed;

        this.angle += rot;
        // Ensure the angle stays within 0 to 2*PI
        if (this.angle < 0) this.angle += 2 * Math.PI;
        if (this.angle >= 2 * Math.PI) this.angle -= 2 * Math.PI;

        this.updateVectors();
    }

    /**
     * Changes the current weapon.
     * @param {number} index The index of the weapon in the inventory array.
     */
    changeWeapon(index) {
        if (index >= 0 && index < this.inventory.weapons.length) {
            this.inventory.currentWeaponIndex = index;
            // Additional logic for changing sprite/stats would go here
            console.log(`Weapon changed to: ${this.inventory.weapons[index]}`);
            return true;
        }
        return false;
    }

    /**
     * Simulates firing the current weapon.
     */
    fireWeapon() {
        const weaponName = this.inventory.weapons[this.inventory.currentWeaponIndex];
        if (this.ammo > 0) {
            this.ammo--;
            console.log(`Firing ${weaponName}. Ammo remaining: ${this.ammo}`);
            // Logic for raycasting hitscan or spawning a projectile would follow.
            return true;
        }
        console.log(`Out of ammo for ${weaponName}!`);
        return false;
    }

    /**
     * Collects a key.
     * @param {'red'|'blue'} keyColor The color of the key collected.
     */
    collectKey(keyColor) {
        if (this.inventory.keys.hasOwnProperty(keyColor)) {
            this.inventory.keys[keyColor] = true;
            console.log(`${keyColor.toUpperCase()} Key collected.`);
            return true;
        }
        return false;
    }

    /**
     * Checks if the player has a required key to open a door.
     * @param {'red'|'blue'} keyColor The required key color.
     * @returns {boolean} True if the key is held.
     */
    hasKey(keyColor) {
        return this.inventory.keys[keyColor] === true;
    }
}

// Example usage (for demonstration purposes, in a real engine this is integrated)
function createMockCollision(map) {
    const tileMap = map.split('\n').map(row => row.trim().split('').map(c => c === 'W' ? 1 : 0));
    const tileSize = 64;

    return (x, y) => {
        // Convert game units (x, y) to map indices (mapX, mapY)
        const mapX = Math.floor(x / tileSize);
        const mapY = Math.floor(y / tileSize);

        // Check if map indices are within bounds and if the tile is a wall (1)
        if (mapY < 0 || mapY >= tileMap.length || mapX < 0 || mapX >= tileMap[0].length) {
            return true; // Treat out-of-bounds as collision
        }

        return tileMap[mapY][mapX] === 1;
    };
}

const mockMap = `
WWWWWWWW
W  W   W
W W W WW
W W   W
WWWWWWWW
`;

// Create a mock collision function based on the map
const isColliding = createMockCollision(mockMap);

// Initialize the player at (1.5, 1.5) on the map grid (inside an open space)
const player = new DepthDwellersPlayer(1.5 * 64, 1.5 * 64);
console.log("--- Player Initialized ---");
console.log(`Initial Position: (${player.x.toFixed(2)}, ${player.y.toFixed(2)})`);
console.log(`Health: ${player.health}`);
console.log(`Current Weapon: ${player.inventory.weapons[player.inventory.currentWeaponIndex]}`);


// Simulation of player actions
player.move(1, isColliding); // Move forward (1.0 delta)
player.rotate(1); // Turn right (1.0 delta)
player.move(-0.5, isColliding); // Move backward
player.fireWeapon();

// Picking up an item
player.collectKey('red');
console.log(`Has Red Key: ${player.hasKey('red')}`);
console.log(`New Position: (${player.x.toFixed(2)}, ${player.y.toFixed(2)})`);
player.fireWeapon();

// Demonstrating state change
player.health -= 15;
console.log(`Health after taking damage: ${player.health}`);
// Simulate collecting Zendle energy
player.inventory.zendleEnergy += 50;
console.log(`Zendle Energy: ${player.inventory.zendleEnergy}`);

// Expose the player class for the larger OmniWolf engine
window.DepthDwellersPlayer = DepthDwellersPlayer;
