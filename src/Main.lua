	-- 25/5/15

	--Theme: Swap
	--
	-- Idea One:
	-- Simultaneous "running" game - ie cannabalt
	-- Screen split into three sections
	-- Each character running  along
	-- Obstacles appear in same space in each section
	-- Correct (colour) character needed to jump/clear
	--
	-- This covers theme but not the swappable sprite-sheets
	--	

	-- Idea Two:
	-- Arena game 
	-- Use blocks to create walls / cover / buildings
	-- Player controls player character
	-- Two types of enemies attack red/yellow
	-- Player can fire projectiles to kill - black/red circles
	-- Kill enemies for points
	-- Collect coints for points
	-- Collect hearts to restore health
	-- Collect potion to restore swap ability
		-- Player can swap positions with any tile (wall/window) to help escape from enemies (?)
		--  Except encircling wall
		--
		--	[][][][][][][][][]			[] - Encircling wall
		--	[]  g  g  g  g  []			 @ - Player
		--  []              []			() - Swappable tile
		--  []      @       []
		--  []  ()          []
		--  []           () []
		--  [][][][][][][][][]

	-- Enemies will chase player, if they touch he loses health
	-- Slow / Fast variations



	--TODO
	--Generate Arena (25/5/15)
		-- 800 x 640 [DONE]
			-- 50 Tiles horizontal [DONE]
			-- 40 Tiles Vertical [DONE]	
		-- Encircling Wall [DONE]
		-- Block placement	[DONE]
			-- Will need to keep track of each blocks location [DONE]
		-- Draw floor tiles [DONE]

	-- Player (26/5/15 - 28/5/15)
		-- Attributes
			-- Position [Done]
			-- Health (bars) [Done]
			-- Speed [Done]
			-- Firing speed [Done]
			-- Max shots on screen [Done]
			-- Score [Done]
			-- Magic (bars) [Done]
		-- Movement
			-- Animations 
		-- Firing
			-- Hit detection on walls / blocks
		-- Swapping
			-- Switch position with selected block
			-- Mouse control


	-- Health / Score / Magic Display
		-- Use provided sprites + text


	-- Enemies
		-- Attributes
			-- Position
			-- Sprite 1/2
			-- Health 1/2
			-- Speed 1/2
		-- Spawning
			-- Timer system - longer game -> more enemies
			-- Max limit?
		-- Pathing towards playing
			-- Simple Greedy, A* might be more fun
		-- Hit Detection
			-- On player
			-- On shots
		-- Clean up
			-- Add point


	-- Extra (If time available)
		-- Upgrade system based on score
			-- 100 points, faster firing
			-- 200 points, extra health bar
			-- 300 points, extra magic

function love.conf(t)

	t.window.width = 800
	t.window.height = 640
	t.console = true

end

function love.load()

love.keyboard.setKeyRepeat(false)

	--Code to load spritesheet from website through api


	--Individual sprites - 16x16 
	spritesheet = love.graphics.newImage("spritesheet.png")

	--Player
	playersprite = love.graphics.newQuad(0,0,16,16, spritesheet:getDimensions())

	--Enemy Type - 1
	enemy1sprite = love.graphics.newQuad(16,16,16,16, spritesheet:getDimensions())

	--Enemy Type - 2
	enemy2sprite = love.graphics.newQuad(32,32,16,16, spritesheet:getDimensions())

	testsprites = extractSprites(8,10,16,16)

	--Player
	Player = {
				xpos = 50,
				ypos = 50,
				health = 3,
				xspeed = 0,
				yspeed = 0,
				movespeed = 15,
				firespeed = 1,
				maxshots = 1,
			 	score = 0,
			 	magic = 3,
			 	upsprites = extractSprites(7,9,16,16),
			 	downsprites = extractSprites(1,3,16,16),
			 	leftsprites = extractSprites(4,6,16,16),
			 	rightsprites = extractSprites(4,6,16,16),
			 	currentsprites = extractSprites(1,1,16,16),
			 	spriteindex = 1,
			 	flip = 1,
			 	moving = false
			 }




	--Arena
	Arena = {wallsprites = extractSprites(49,56,16,16),
			 floorsprite = extractSprites(40,40,16,16),
			 obstacles = createObstacles()
			}
	


	--Timer
	min_dt = 1/10
	next_time = love.timer.getTime()


end


function love.update(dt)


	next_time = next_time + min_dt

	Player.xpos = Player.xpos + (dt * Player.xspeed)
	Player.ypos = Player.ypos + (dt * Player.yspeed)

	if (Player.moving and Player.spriteindex == #Player.currentsprites) then 
		Player.spriteindex = 1
	elseif (Player.moving) then
		Player.spriteindex = Player.spriteindex + 1
	end



end


function love.keypressed(key, isrepeat)

	if key == "w" then
		Player.flip = 1
		Player.currentsprites = Player.upsprites
		Player.yspeed = -Player.movespeed
		Player.moving = true
		Player.currentsprites = Player.upsprites

	end

	if key == "s" then
		Player.flip = 1
		Player.yspeed = Player.movespeed
		Player.moving = true
		Player.currentsprites = Player.downsprites

	end

	if key == "a" then
		Player.flip = -1
		Player.xspeed = -Player.movespeed
		Player.moving = true
		Player.currentsprites = Player.leftsprites
		

	end

	if key == "d" then
		Player.flip = 1
		Player.currentsprites = Player.rightsprites
		Player.xspeed = Player.movespeed
		Player.moving = true
		Player.currentsprites = Player.rightsprites

	end






end

function love.keyreleased(key)

	if key == "w" then
		Player.yspeed = 0
		Player.moving = false

	end

	if key == "s" then
		Player.yspeed = 0
		Player.moving = false

	end

	if key == "a" then
		Player.xspeed = 0
		Player.moving = false

	end

	if key == "d" then
		Player.xspeed = 0
		Player.moving = false

	end

end


function love.draw()


	love.graphics.print(#obstacles, 50,50)

	drawArenaWalls()
	drawArenaFloor()

	drawArenaObstacles()

	love.graphics.draw(spritesheet, Player.currentsprites[Player.spriteindex], Player.xpos, Player.ypos, 0, Player.flip, 1, 8, 8)


   local cur_time = love.timer.getTime() 
   if next_time <= cur_time then
      next_time = cur_time
      return
   end

  love.timer.sleep(next_time - cur_time)

end


function drawArenaWalls()

	rowind = math.random(1, #Arena.wallsprites)
	colind = math.random(1, #Arena.wallsprites)

	toprowy = 0
	btmrowy = 624 --640 - 16

	lftcolx = 0
	rhtcolx = 784


	-- Top/Bottom Rows
	for row = 0, 49, 1 do
		love.graphics.draw(spritesheet, Arena.wallsprites[6], row*16, toprowy)
		love.graphics.draw(spritesheet, Arena.wallsprites[6], row*16, btmrowy)
	end

	-- L/R Columns
	for col = 0, 39, 1 do
		love.graphics.draw(spritesheet, Arena.wallsprites[6], lftcolx, col*16)
		love.graphics.draw(spritesheet, Arena.wallsprites[6], rhtcolx, col*16)
	end

end

function drawArenaFloor()

	--Inside outer wall
	-- 48 tiles across
	-- 38 tiles down
	for x = 1, 48, 1 do

		for y = 1, 38, 1 do 

			love.graphics.draw(spritesheet, Arena.floorsprite[1], x*16, y*16)

		end
	end

end


function drawArenaObstacles()


	for i = 1, #Arena.obstacles, 1 do
		love.graphics.draw(spritesheet, Arena.obstacles[i].sprite, Arena.obstacles[i].x, Arena.obstacles[i].y)
	end 

end


function createObstacles()

	-- Arena Obstacles - Rows 5/6, skip last entry - used for floor tile
	obstaclesprites = extractSprites(33,39,16,16)
	obstaclesprites2 = extractSprites(41,47,16,16)

	for _,v in ipairs(obstaclesprites2) do
		table.insert(obstaclesprites, v)
	end


	--Create obstacles
	obstacles = {}
	for i = 1, 25, 1 do

		--Create x/y coordinates
		xpos = math.random(16, 768)
		ypos = math.random(16, 608)

		--Randomise tile
		tileind = math.random(1, #obstaclesprites)

		table.insert(obstacles, {x = xpos, y = ypos, sprite = obstaclesprites[tileind]})

	end 

	return obstacles;

end

function extractSprites(startsprite, endsprite, spritesizex, spritesizey)

	x = 0
	y = 0

	spritetable = {}

	sprites_per_row = spritesheet:getWidth() / spritesizex

	x = 0
	y = 0

	for i = startsprite, endsprite, 1 do

		y = 0		
		spriteno = i

		while spriteno  > sprites_per_row do

			spriteno = spriteno - sprites_per_row
			y = y + 1

		end

		x = spriteno - 1

		table.insert(spritetable, love.graphics.newQuad(x*spritesizex, y*spritesizey,spritesizex,spritesizey,spritesheet:getDimensions()))

	end

	return spritetable

end




