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
			-- Animations [Done]
			-- Collision detection on blocks / walls
		-- Firing
			-- Hit detection on walls / blocks
		-- Swapping
			-- Switch position with selected block [Done]
			-- Mouse control [Done]

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


	--Enemy Type - 1
	enemyType1 = {
					upsprites = extractSprites(16,18,16,16),
					downsprites = extractSprites(10,12,16,16),
					leftsprites = extractSprites(13,15,16,16),
					rightsprites = extractSprites(13,15,16,16),
					movespeed = 20,
					health = 1
				}

	--Enemy Type - 2
	enemyType2 = {
					upsprites = extractSprites(25,27,16,16),
					downsprites = extractSprites(19,21,16,16),
					leftsprites = extractSprites(22,24,16,16),
					rightsprites = extractSprites(22,24,16,16),
					movespeed = 20,
					health = 2
				}


	testsprites = extractSprites(8,10,16,16)

	--Player
	Player = {
				xpos = 50,
				ypos = 50,
				health = 3,
				xspeed = 0,
				yspeed = 0,
				movespeed = 15,
				firespeed = 50,
				maxshots = 3,
			 	score = 0,
			 	magic = 3,
			 	upsprites = extractSprites(7,9,16,16),
			 	downsprites = extractSprites(1,3,16,16),
			 	leftsprites = extractSprites(4,6,16,16),
			 	rightsprites = extractSprites(4,6,16,16),
			 	currentsprites = extractSprites(1,1,16,16),
			 	shotsprite = extractSprites(29,29,16,16),
			 	spriteindex = 1,
			 	flip = 1,
			 	moving = {up = false, down = false, left = false, up = false},
			 	rad = 4
			 }

	--Arena
	Arena = {wallsprites = extractSprites(49,56,16,16),
			 floorsprite = extractSprites(40,40,16,16),
			 obstacles = createObstacles(25)
			}	

	--Interface
	Interface = {
					lifesprite = extractSprites(31,31,16,16),
					magicsprite = extractSprites(32,32,16,16),
					scoresprite = extractSprites(30,30,16,16)
				}


	--Projectiles
	Projectiles = {}

	--Enemies
	EnemyTable = {
		maxEnemies = 1000,
		Enemies = {}
	}

	--Timer
	min_dt = 1/60
	next_time = love.timer.getTime()


end


function love.update(dt)


	next_time = next_time + min_dt


	if(not playerHitDetection(dt)) then
		Player.xpos = Player.xpos + (dt * Player.xspeed)
		Player.ypos = Player.ypos + (dt * Player.yspeed)
	end
	animatePlayer()

	updateProjectiles(dt)
	projectileHitDetection()
	cleanupProjectiles(dt)
	updateEnemies(dt)

end


function love.keypressed(key, isrepeat)

	if key == "w" then
		Player.flip = 1
		Player.yspeed = -Player.movespeed
		Player.moving.up = true
	end

	if key == "s" then
		Player.flip = 1
		Player.yspeed = Player.movespeed
		Player.moving.down = true
	end

	if key == "a" then
		Player.flip = -1
		Player.xspeed = -Player.movespeed
		Player.moving.left = true
	end

	if key == "d" then
		Player.flip = 1
		Player.xspeed = Player.movespeed
		Player.moving.right = true
	end

	determinePlayerSprites()


end

function love.keyreleased(key)

	if key == "w" then
		Player.yspeed = 0
		Player.moving.up = false
	end

	if key == "s" then
		Player.yspeed = 0
		Player.moving.down = false
	end

	if key == "a" then
		Player.xspeed = 0
		Player.moving.left = false
	end

	if key == "d" then
		Player.xspeed = 0
		Player.moving.right = false
	end

	determinePlayerSprites()


end

function love.mousereleased(x,y, button)

	--Fire
	if button == 'l' then
		createBullet(x,y)
	end

	--Swap
	if button == 'r' then
		swapBlock(x,y)
	end


end

function love.draw()

	love.graphics.print(#obstacles, 50,50)

	drawArenaWalls()
	drawArenaFloor()

	drawArenaObstacles()

	love.graphics.draw(spritesheet, Player.currentsprites[Player.spriteindex], Player.xpos, Player.ypos, 0, Player.flip, 1, 8, 8)

	drawProjectiles();
	love.graphics.circle( "fill", Player.xpos, Player.ypos, Player.rad, 5)

	drawEnemies()

   local cur_time = love.timer.getTime() 
   if next_time <= cur_time then
      next_time = cur_time
      return
   end

  love.timer.sleep(next_time - cur_time)

end



function determinePlayerSprites()

	if(Player.moving.left) then
		Player.currentsprites = Player.leftsprites
	elseif(Player.moving.right) then
		Player.currentsprites = Player.rightsprites
	elseif(Player.moving.up) then
		Player.currentsprites = Player.upsprites
	elseif (Player.moving.down) then
		Player.currentsprites = Player.downsprites
	end

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
		love.graphics.circle( "fill", Arena.obstacles[i].cx, Arena.obstacles[i].cy, Arena.obstacles[i].rad, 5)
	end 

end


function createObstacles(obs)

	-- Arena Obstacles - Rows 5/6, skip last entry - used for floor tile
	obstaclesprites = extractSprites(33,39,16,16)
	obstaclesprites2 = extractSprites(41,47,16,16)

	for _,v in ipairs(obstaclesprites2) do
		table.insert(obstaclesprites, v)
	end


	--Create obstacles
	obstacles = {}
	for i = 1, obs, 1 do

		--Create x/y coordinates
		xpos = math.random(16, 768)
		ypos = math.random(16, 608)

		--Randomise tile
		tileind = math.random(1, #obstaclesprites)

		table.insert(obstacles, {x = xpos, y = ypos, sprite = obstaclesprites[tileind], rad = 8, cx = xpos + 8, cy = ypos + 8})

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

function drawProjectiles()

	for i = 1, #Projectiles, 1 do
		love.graphics.draw(spritesheet, Projectiles[i].sprite, Projectiles[i].xpos, Projectiles[i].ypos)
		love.graphics.circle( "fill", Projectiles[i].cx, Projectiles[i].cy, Projectiles[i].rad, 5)

	end

end 


function updateProjectiles(dt)

	for i = 1, #Projectiles, 1 do 

			Projectiles[i].ypos = Projectiles[i].ypos + (dt * Player.firespeed * Projectiles[i].yinc)
			Projectiles[i].xpos = Projectiles[i].xpos + (dt * Player.firespeed * Projectiles[i].xinc)

			Projectiles[i].cy = Projectiles[i].cy + (dt * Player.firespeed * Projectiles[i].yinc)
			Projectiles[i].cx = Projectiles[i].cx + (dt * Player.firespeed * Projectiles[i].xinc)
	end


end

function projectileHitDetection()

	for i = 1, #Projectiles, 1 do

		for b = 1, #Arena.obstacles, 1 do

			px = Projectiles[i].cx
			py = Projectiles[i].cy
			prad = Projectiles[i].rad

			bx = Arena.obstacles[b].cx
			by = Arena.obstacles[b].cy
			brad = Arena.obstacles[b].rad

			dx = px - bx
			dy = py - by
			distance = math.sqrt((dx*dx) + (dy * dy))

			if(distance < (prad + brad)) then
				Projectiles[1].hit = true
			end

		end
	end
end

function playerHitDetection(dt)

	for b = 1, #Arena.obstacles, 1 do

		--Where player will be next frame
		px = Player.xpos + (Player.xspeed * dt)
		py = Player.ypos + (Player.yspeed * dt) 
		prad = Player.rad

		bx = Arena.obstacles[b].cx
		by = Arena.obstacles[b].cy
		brad = Arena.obstacles[b].rad

		dx = px - bx
		dy = py - by
		distance = math.sqrt((dx*dx) + (dy * dy))

		if(distance < (prad + brad)) then
			return true
		end

	end

	return false

end




function animatePlayer()

	if (Player.moving and Player.spriteindex == #Player.currentsprites) then 
		Player.spriteindex = 1
	elseif (Player.moving) then
		Player.spriteindex = Player.spriteindex + 1
	end

end


function updateEnemies(dt)

	spawnEnemy()

	for i = 1, #EnemyTable.Enemies, 1 do

		--Treat as triangle
		xlen = ((EnemyTable.Enemies[i].x - Player.xpos)) -- X (Adjacent) 
		ylen = ((EnemyTable.Enemies[i].y - Player.ypos)) -- Y (Opposite)

		r = math.sqrt((xlen * xlen) + (ylen * ylen)) -- R (Hypotenuse)

		xratio = xlen / r -- Ratio of x to r (Sin[theta]), value to increase x coordinate by each dt
		yratio = ylen / r -- Ratio of y to r (Cos[theta]), value to increase y coordinate by each dt

		EnemyTable.Enemies[i].xinc = xratio
		EnemyTable.Enemies[i].yinc = yratio		
		
		EnemyTable.Enemies[i].x = EnemyTable.Enemies[i].x - (EnemyTable.Enemies[i].movespeed * EnemyTable.Enemies[i].xinc * dt)
		EnemyTable.Enemies[i].y = EnemyTable.Enemies[i].y - (EnemyTable.Enemies[i].movespeed * EnemyTable.Enemies[i].yinc * dt)

		if(EnemyTable.Enemies[i].xinc > EnemyTable.Enemies[i].yinc) then 
			if(EnemyTable.Enemies[i].yinc < 0) then
				EnemyTable.Enemies[i].currentsprites = EnemyTable.Enemies[i].upsprites
				EnemyTable.Enemies[i].flip = 1
			else
				EnemyTable.Enemies[i].currentsprites = EnemyTable.Enemies[i].downsprites
				EnemyTable.Enemies[i].flip = 1
			end
		else
			if(EnemyTable.Enemies[i].xinc < 0) then
				EnemyTable.Enemies[i].currentsprites = EnemyTable.Enemies[i].leftsprites
				EnemyTable.Enemies[i].flip = -1
			else
				EnemyTable.Enemies[i].currentsprites = EnemyTable.Enemies[i].rightsprites
				EnemyTable.Enemies[i].flip = 1
			end
		end
	end

	animateEnemies()

end


function animateEnemies()


	for i = 1, #EnemyTable.Enemies, 1 do

		if(EnemyTable.Enemies[i].spriteindex == #EnemyTable.Enemies[i].currentsprites) then
			EnemyTable.Enemies[i].spriteindex = 1
		else
			EnemyTable.Enemies[i].spriteindex = EnemyTable.Enemies[i].spriteindex + 1
		end


	end
end

function drawEnemies()

	for i = 1, #EnemyTable.Enemies, 1 do

		index =  EnemyTable.Enemies[i].spriteindex

		love.graphics.draw(spritesheet, EnemyTable.Enemies[i].currentsprites[index], EnemyTable.Enemies[i].x, EnemyTable.Enemies[i].y)
		fps = love.timer.getFPS( )
		love.graphics.print(fps, 300, 300)
	end


end


function spawnEnemy()

	if(#EnemyTable.Enemies < EnemyTable.maxEnemies) then

		xpos = math.random(16, 768);
		ypos = math.random(16, 608);
		enemytype = math.random()

		if(enemytype < 0.5) then
			table.insert(EnemyTable.Enemies, {x = xpos, y = ypos, 
				upsprites = enemyType1.upsprites, downsprites = enemyType1.downsprites, 
				leftsprites = enemyType1.leftsprites,  rightsprites = enemyType1.rightsprites, 
				currentsprites = enemyType1.downsprites,
				health = enemyType1.health,
				movespeed = enemyType1.movespeed,
				targetx = Player.x, targety = Player.y,
				xinc = 0, yinc = 0, flip = 1, spriteindex = 1})
		else
				table.insert(EnemyTable.Enemies, {x = xpos, y = ypos, 
				rad = 8, cx = xpos + 8, cy = ypos + 8,	
				upsprites = enemyType2.upsprites, downsprites = enemyType2.downsprites, 
				leftsprites = enemyType2.leftsprites,  rightsprites = enemyType2.rightsprites, 
				currentsprites = enemyType2.downsprites,
				health = enemyType2.health,
				movespeed = enemyType2.movespeed,
				targetx = Player.x, targety = Player.y,
				xinc = 0, yinc = 0, flip = 1, spriteindex = 1})
		end




	end

end




function cleanupProjectiles()

	toremove = {}

	for i = #Projectiles, 1, -1 do

		passedx = false
		passedy = false

		if(Projectiles[i].xdist and Projectiles[i].xpos >= Projectiles[i].targetx) then
			passedx = true
		end

		if(not Projectiles[i].xdist and Projectiles[i].xpos <= Projectiles[i].targetx) then
			passedx = true
		end

		if(Projectiles[i].ydist and Projectiles[i].ypos >= Projectiles[i].targety) then
			passedy = true
		end

		if(not Projectiles[i].ydist and Projectiles[i].ypos <= Projectiles[i].targety) then
			passedy = true
		end



		if(passedx and passedy or Projectiles[i].hit) then
			table.insert(toremove, i)
		end

	end

	if #toremove >= 1 then
		for j = 1, #toremove, 1 do
			table.remove(Projectiles, toremove[j])
		end
	end


	function createBullet(x,y) 


		if(#Projectiles < Player.maxshots) then

				--Treat as triangle
				xlen = ((x - Player.xpos)) -- X (Adjacent) 
				ylen = ((y - Player.ypos)) -- Y (Opposite)

				r = math.sqrt((xlen * xlen) + (ylen * ylen)) -- R (Hypotenuse)

				xratio = xlen / r -- Ratio of x to r (Sin[theta]), value to increase x coordinate by each dt
				yratio = ylen / r -- Ratio of y to r (Cos[theta]), value to increase y coordinate by each dt

				xd = true
				yd = true

				if(xlen < 0) then
					xd = false
				end

				if(ylen < 0) then
					yd = false
				end

				shot = {xpos = Player.xpos - 8, ypos = Player.ypos - 8,
						targetx = x, targety = y, 
						sprite = Player.shotsprite[1], 
						xinc = xratio, yinc = yratio, 
						xdist = xd, ydist = yd,
						hit = false, rad = 8,
						cx = Player.xpos, cy = Player.ypos}

				table.insert(Projectiles, shot)

			end
	end


	function swapBlock(x,y)

		-- Check if any blocks are selected
		for i = 1, #Arena.obstacles, 1 do

			--Four corners of block
			blockx1 = Arena.obstacles[i].x
			blockx2 = blockx1 + (Arena.obstacles[i].rad * 2)
			blocky1 = Arena.obstacles[i].y
			blocky2 = blocky1 + (Arena.obstacles[i].rad * 2)


			if((x >= blockx1 and x <= blockx2) and (y >= blocky1 and y <= blocky2) ) then

				Arena.obstacles[i].x = Player.xpos
				Arena.obstacles[i].y = Player.ypos
				Arena.obstacles[i].cx = Arena.obstacles[i].x + Arena.obstacles[i].rad
				Arena.obstacles[i].cy = Arena.obstacles[i].y + Arena.obstacles[i].rad


				Player.xpos = x - Player.rad / 2
				Player.ypos = y - Player.rad / 2

				return	
			end

		end
	end

end