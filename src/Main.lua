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

	-- Player
		-- Attributes
			-- Position
			-- Health (bars)
			-- Speed
			-- Firing speed
			-- Max shots on screen
			-- Score
			-- Magic (bars)
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

	--Code to load spritesheet from website through api


	--Individual sprites - 16x16 
	spritesheet = love.graphics.newImage("spritesheet.png")

	--Player
	playersprite = love.graphics.newQuad(0,0,16,16, spritesheet:getDimensions())

	--Enemy Type - 1
	enemy1sprite = love.graphics.newQuad(16,16,16,16, spritesheet:getDimensions())

	--Enemy Type - 2
	enemy2sprite = love.graphics.newQuad(32,32,16,16, spritesheet:getDimensions())



	--Player
	Player = {
				xpos = 50,
				ypos = 50,
				health = 3,
				speed = 5,
				firespeed = 1,
				maxshots = 1,
			 	score = 0,
			 	magic = 3,
			 	upsprites = {},
			 	downsprites = {},
			 	leftsprites = {},
			 	rightsprites = {}
			 }


	--Arena
	Arena = {wallsprites = extractWallSprites(),
			 floorsprite = love.graphics.newQuad(112,64, 16,16, spritesheet:getDimensions()),
			 obstacles = createObstacles()
			}
	

end


function love.update(dt)

end


function love.keypressed(key, isrepeat)


end

function love.keyreleased(key)

end


function love.draw()

	love.graphics.print(#obstacles, 50,50)

	drawArenaWalls()
	drawArenaFloor()

	drawArenaObstacles()

end


function drawArenaWalls()

	rowind = math.random(1, #wallsprites)
	colind = math.random(1, #wallsprites)

	toprowy = 0
	btmrowy = 624 --640 - 16

	lftcolx = 0
	rhtcolx = 784


	-- Top/Bottom Rows
	for row = 0, 49, 1 do
		love.graphics.draw(spritesheet, Arena.wallsprites[1], row*16, toprowy)
		love.graphics.draw(spritesheet, Arena.wallsprites[1], row*16, btmrowy)
	end

	-- L/R Columns
	for col = 0, 39, 1 do
		love.graphics.draw(spritesheet, Arena.wallsprites[1], lftcolx, col*16)
		love.graphics.draw(spritesheet, Arena.wallsprites[1], rhtcolx, col*16)
	end

end

function drawArenaFloor()

	--Inside outer wall
	-- 48 tiles across
	-- 38 tiles down
	for x = 1, 48, 1 do

		for y = 1, 38, 1 do 

			love.graphics.draw(spritesheet, Arena.floorsprite, x*16, y*16)

		end
	end

end


function drawArenaObstacles()


	for i = 1, #Arena.obstacles, 1 do
		love.graphics.draw(spritesheet, Arena.obstacles[i].sprite, Arena.obstacles[i].x, Arena.obstacles[i].y)
	end 

end


function extractWallSprites()

	y = 6*16
	wallsprites = {}

	for x=0,112,16 do
		table.insert(wallsprites, love.graphics.newQuad(x,y, 16,16, spritesheet:getDimensions()))
	end

	return wallsprites

end

function createObstacles()

	-- Arena Obstacles - Rows 5/6, skip last entry - used for floor tile
	obstaclesprites	= {}
	y1 = 5 * 16
	y2 = 4 * 16

	for x= 0, 96, 16 do
		table.insert(obstaclesprites, love.graphics.newQuad(x,y1,16,16,spritesheet:getDimensions()))
		table.insert(obstaclesprites, love.graphics.newQuad(x,y2,16,16,spritesheet:getDimensions()))
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

		spriteno = i

		while spriteno  > sprites_per_row

			spriteno - sprites_per_row
			y = y + 1

		end

		x = spriteno

		table.insert(spritetable, love.graphics.newQuad(x*spritesizex, y*spritesizey,spritesizex,spritesizey,spritesheet:getDimensions()))

	end

	return spritetable


end




