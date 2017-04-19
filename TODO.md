[x] Render some kind of background on a grid of tiles, maybe 16x16 to start.
[x] find a "wall" sprite, maybe bricks or similar
[x] find a tank sprite that can be made into several colors (8 would be ideal)
[x] render an area around the play board that is ringed by walls
[x] render a tank on a random square on startup
[x] Make the tank a random bot that just moves one direction (or does nothing)
[x] prevent moving through fences
[x] rotate the image with respect to whatever direction it was facing last
[x] find a sprite to represent a laser beam
[x] add shoot as a possible action
[x] when tank chooses shoot, add a laser beam to the game state
[x] laser beam needs key and direction in a seperate hash
[x] make laser beam move 1 cell per tick
[x] collision detection
[x] Give each tank a name at start time
[x] Start each tank with 100.0 energy
[x] Display energy at the bottom of the screen by label for each
[x] When only one tank is untagged, mark game ended, show message "[Name] Wins!" (http://www.rubydoc.info/github/gosu/gosu/Gosu/Font)
[ ] moving should consume 0.1 energy
[ ] shooting should consume 1 energy
[ ] fix bug where you can tag yourself by shooting and then walking forward into your shot
[ ] getting hit by a laser should drain 25 energy
[ ] when energy is <= 0, tank is "tagged"
[ ] find a sprite for a battery
[ ] on each frame, if there is no battery, randomly generate one and draw it
[ ] if a tank moves onto the battery, the battery disappears and the tank gets +40 energy
[ ] make sure that if 2 lasers run into each other they both disappear
[ ] pass lasers state and battery state into each bot for decision making
[ ] Build a bot that just holds still (BoringBot)
[ ] Build a bot that conservatively just dodges (DodgeBot), using as little energy as possible
[ ] Build a bot that focuses on moving towards the battery and never shoots (BatteryBot)
[ ] Build a bot that spins and shoots (BattleBot)
[ ] Build a bot that prioritizes targeted shooting (HunterBot)
[ ] work with bella to come up with strategic ideas for defeating each of these
    that can be made into helper methods on the TankBot base class.
[ ] Build a Q-Learning Bot??
     (66 self positions * 66 other-tank positions * 66 battery positions * 5 actions)
