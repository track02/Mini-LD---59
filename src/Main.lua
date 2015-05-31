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
			-- Collision detection on blocks / walls [Done]
		-- Firing
			-- Hit detection on walls / blocks [Done]
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

	--Fallback spritesheet if loading doesnt work
	spritesheet = love.graphics.newImage("defaultsheet.png")


	fire = love.audio.newSource("Shoot.wav", "static")
	spawnenemy = love.audio.newSource("Spawn.wav", "static")
	explode = love.audio.newSource("Explosion.wav", "static")
	pickupgrab = love.audio.newSource("Pickup_grab.wav", "static")
	pickupspawn = love.audio.newSource("Pickup_spawn.wav", "static")
	magic = love.audio.newSource("Magic.wav", "static")
	swap = love.audio.newSource("Swap.wav", "static")
	playerhit = love.audio.newSource("PlayerHit.wav", "static")

	--Enemy Type - 1
	enemyType1 = {
					upsprites = extractSprites(16,18,16,16),
					downsprites = extractSprites(10,12,16,16),
					leftsprites = extractSprites(13,15,16,16),
					rightsprites = extractSprites(13,15,16,16),
					destroysprite = extractSprites(64,64,16,16),
					movespeed = 20,
					hit = false
				}

	--Enemy Type - 2
	enemyType2 = {
					upsprites = extractSprites(25,27,16,16),
					downsprites = extractSprites(19,21,16,16),
					leftsprites = extractSprites(22,24,16,16),
					rightsprites = extractSprites(22,24,16,16),
					destroysprite = extractSprites(64,64,16,16),
					movespeed = 30,
					hit = false
				}


	--Player
	Player = {
				xpos = 450,
				ypos = 610,
				health = 3,
				xspeed = 0,
				yspeed = 0,
				movespeed = 50,
				firespeed = 100,
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
			 	move = false,
			 	rad = 4,
			 	life = 3,
			 	scount = 0,
			 	casting = false
			 }

	--Arena
	Arena = {wallsprites = extractSprites(49,56,16,16),
			 floorsprite = extractSprites(40,40,16,16),
			 obstacles = createObstacles(150)
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
		maxEnemies = 100,
		enemyCount = 0,
		spawnable = 1,
		scatter = 1,
		Enemies = {}
	}

	vecA = {x = 0, y = 0}	-- Vector for each rule of boid algorithm 
	vecB = {x = 0, y = 0}	-- Center Mass / Distancing / Velocity matching
	vecC = {x = 0, y = 0}
	vecD = {x = 0, y = 0}

	--Timer - FPS
	min_dt = 1/60
	next_time = love.timer.getTime()

	--Timer - Enemy Spawning
	enemy_timer = love.timer.getTime()


	--Pickup Spawning
	pickup_spawn = love.timer.getTime()

	pickup_magic = {x = 0, y = 0, time = 100, active = 5, spawned = false, cx = 0 , cy = 0}
	pickup_coin = {x = 0, y = 0, time = 10, spawned = false, cx = 0, cy = 0}

	scatter_time = 0

	--Score
	score = 0

	--Start / Game Over pause
	start = false
	gameover = false


end


function love.update(dt)

	if(start and (not gameover)) then

		enemyHitDetection(dt)
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
		pickUps()

	end
end


function love.keypressed(key, isrepeat)

	if key == "w" then
		Player.flip = 1
		Player.yspeed = -Player.movespeed
		Player.moving.up = true
		Player.move = true
	end

	if key == "s" then
		Player.flip = 1
		Player.yspeed = Player.movespeed
		Player.moving.down = true
		Player.move = true
	end

	if key == "a" then
		Player.flip = -1
		Player.xspeed = -Player.movespeed
		Player.moving.left = true
		Player.move = true
	end

	if key == "d" then
		Player.flip = 1
		Player.xspeed = Player.movespeed
		Player.moving.right = true
		Player.move = true
	end

	if key == " " and start and Player.magic > 0 then
		EnemyTable.scatter = -1
		Player.casting = true
		magic:play()
	end

	if key == "z" then
		start = true		
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

	if key == " " then
		EnemyTable.scatter = 1
		Player.magic = Player.magic - 1
		Player.casting = false
	end

	if key == "r" and not start then

		local http=require'socket.http'
		local b,c,h = http.request("http://swapshop.pixelsyntax.com/api/randomImage")
		love.filesystem.write("randomsheet.png",b)

		if(love.filesystem.exists("randomsheet.png")) then	
			spritesheet = love.graphics.newImage("randomsheet.png")
		else
			spritesheet = love.graphics.newImage("defaultsheet.png")
		end

		love.filesystem.remove("randomsheet.png")

	end

	if key == "q" and gameover then
		love.event.quit()
	end 

	if(Player.moving.right == false and Player.moving.left == false and Player.moving.up == false and Player.moving.down == false) then
		Player.move = false
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


	drawArenaWalls()
	drawArenaFloor()

	drawArenaObstacles()

	love.graphics.draw(spritesheet, Player.currentsprites[Player.spriteindex], Player.xpos, Player.ypos, 0, Player.flip, 1, 8, 8)

	drawProjectiles();
	--love.graphics.circle( "fill", Player.xpos, Player.ypos, Player.rad, 5)

	noEnemies = #EnemyTable.Enemies

	drawPickup()

	drawEnemies()

	drawInterface()

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

	local rowind = math.random(1, #Arena.wallsprites)
	local colind = math.random(1, #Arena.wallsprites)

	local toprowy = 0
	local btmrowy = 624 --640 - 16

	local lftcolx = 0
	local rhtcolx = 784

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
		--love.graphics.circle( "fill", Arena.obstacles[i].cx, Arena.obstacles[i].cy, Arena.obstacles[i].rad, 5)
	end 

end


function createObstacles(obs)

	-- Arena Obstacles - Rows 5/6, skip last entry - used for floor tile
	local obstaclesprites = extractSprites(33,39,16,16)
	local obstaclesprites2 = extractSprites(41,47,16,16)

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

	local x = 0
	local y = 0

	spritetable = {}

	sprites_per_row = spritesheet:getWidth() / spritesizex

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
		--love.graphics.circle( "fill", Projectiles[i].cx, Projectiles[i].cy, Projectiles[i].rad, 5)

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

			local px = Projectiles[i].cx
			local py = Projectiles[i].cy
			local prad = Projectiles[i].rad

			if(px <= 16) then
				Projectiles[1].hit = true
			elseif(px >= 784) then
				Projectiles[1].hit = true
			end

			if(py <= 16) then
				Projectiles[1].hit = true
			elseif(py >= 624) then
				Projectiles[1].hit = true	
			end



		for b = 1, #Arena.obstacles, 1 do

			local bx = Arena.obstacles[b].cx
			local by = Arena.obstacles[b].cy
			local brad = Arena.obstacles[b].rad

			local dx = px - bx
			local dy = py - by
			local dist = math.sqrt((dx*dx) + (dy * dy))

			if(dist < (prad + brad)) then
				Projectiles[i].hit = true
			end
		end

		--Enemy hit detection
		for e = 1, #EnemyTable.Enemies, 1 do

			local ex = EnemyTable.Enemies[e].cx
			local ey = EnemyTable.Enemies[e].cy

			local dist = math.sqrt(math.pow(ex-px,2) + math.pow(ey-py,2))

			if(dist < 16) then
				Projectiles[i].hit = true
				EnemyTable.Enemies[e].hit = true
			end


		end



	end
end

function playerHitDetection(dt)

	--0 to 624 (Y) 
	--0 to 784 (X)
	local px = Player.xpos + (Player.xspeed * dt)
	local py = Player.ypos + (Player.yspeed * dt) 
	local prad = Player.rad

	if(px <= 16) then
		return true
	elseif(px >= 784) then
		return true
	end

	if(py <= 16) then
		return true
	elseif(py >= 624) then
		return true	
	end


	for b = 1, #Arena.obstacles, 1 do

		--Where player will be next frame
		local bx = Arena.obstacles[b].cx
		local by = Arena.obstacles[b].cy
		local brad = Arena.obstacles[b].rad

		local dx = px - bx
		local dy = py - by
		local distance = math.sqrt((dx*dx) + (dy * dy))

		if(distance < (prad + brad)) then
			return true
		end

	end

	--For each enemy
	for e = 1, #EnemyTable.Enemies, 1 do

		ex = EnemyTable.Enemies[e].x
		ey = EnemyTable.Enemies[e].y
		px = Player.xpos
		py = Player.ypos

		dist = math.sqrt(math.pow(ex-px,2) + math.pow(ey-py,2))
	
		--if hit, swap places with random block + reduce hp
		if(dist < 8) then

			b = math.random(#Arena.obstacles)

			Player.life = Player.life - 1

			playerhit:play()

			if(Player.life <= 0) then
				gameover = true
				start = false
			end
	
			x = Arena.obstacles[b].x
			y = Arena.obstacles[b].y

			Arena.obstacles[b].x = Player.xpos
			Arena.obstacles[b].y = Player.ypos
			Arena.obstacles[b].cx = Arena.obstacles[b].x + Arena.obstacles[b].rad
			Arena.obstacles[b].cy = Arena.obstacles[b].y + Arena.obstacles[b].rad

			Player.xpos = x - Player.rad / 2
			Player.ypos = y - Player.rad / 2

		end



	

	end

	return false

end




function animatePlayer()

	if(Player.scount < 3) then
		Player.scount = Player.scount + 1
	elseif (Player.move and Player.spriteindex == #Player.currentsprites and Player.scount >= 3) then 
		Player.spriteindex = 1
		Player.scount = 0
	elseif (Player.move) then
		Player.spriteindex = Player.spriteindex + 1
		Player.scount = 0
	elseif (not Player.move) then
		Player.spriteindex = Player.spriteindex
		Player.scount = 0
	end


end




function updateEnemies(dt)

	spawnEnemy()

	noEnemies = #EnemyTable.Enemies

	--Scatter if flock is at half strength


	for i = 1, #EnemyTable.Enemies, 1 do

		local xlen = (Player.xpos - EnemyTable.Enemies[i].x) -- X (Adjacent) 
		local ylen = (Player.ypos - EnemyTable.Enemies[i].y) -- Y (Opposite)
		local r = math.sqrt((xlen * xlen) + (ylen * ylen)) -- R (Hypotenuse)

		local xvelocity = xlen / r -- Ratio of x to r (Sin[theta]), value to increase x coordinate by each dt
		local yvelocity = ylen / r -- Ratio of y to r (Cos[theta]), value to increase y coordinate by each dt
		

		boidCollision_Obs(EnemyTable.Enemies[i])
		boidCollision_enemy(EnemyTable.Enemies[i])
		boidGroup(EnemyTable.Enemies[i], EnemyTable.maxEnemies)
		boidSpeed(EnemyTable.Enemies[i])
		boidBounding(EnemyTable.Enemies[i])


		xvelocity = xvelocity + vecB.x + vecC.x + vecA.x + vecD.x
		yvelocity = yvelocity + vecB.y + vecC.y + vecA.y + vecD.y


		EnemyTable.Enemies[i].x = EnemyTable.Enemies[i].x + ((xvelocity) * dt * 20) --Increment position
		EnemyTable.Enemies[i].y = EnemyTable.Enemies[i].y + ((yvelocity) * dt * 20) -- Increment position
		EnemyTable.Enemies[i].cx = EnemyTable.Enemies[i].cx + ((xvelocity) * dt * 20) --Increment position
		EnemyTable.Enemies[i].cy = EnemyTable.Enemies[i].cy + ((yvelocity) * dt * 20) -- Increment position
		EnemyTable.Enemies[i].vx = xvelocity
		EnemyTable.Enemies[i].vy = yvelocity

	end

	animateEnemies()

end


function boidGroup(enemy, enemyno)

		vecA.x = 0
		vecA.y = 0

		local x1 = enemy.x
		local y1 = enemy.y

		for j = 1, #EnemyTable.Enemies, 1 do

			if(enemy.id == EnemyTable.Enemies[j].id) then
			
			else
				x2 = EnemyTable.Enemies[j].x 
				y2 = EnemyTable.Enemies[j].y 

				vecA.x = vecA.x + x2
				vecA.y = vecA.y + y2

			end
		end

		vecA.x = vecA.x / (enemyno - 1)
		vecA.y = vecA.y / (enemyno - 1)

		vecA.x = ((vecA.x - x1) / 100) * EnemyTable.scatter
		vecA.y = ((vecA.y - y1) / 100) * EnemyTable.scatter

end

function boidCollision_Obs(enemy)

	vecB.x = 0
	vecB.y = 0

	local x1 = enemy.x
	local y1 = enemy.y

	for o = 1, #Arena.obstacles, 1 do

		x2 = Arena.obstacles[o].cx
		y2 = Arena.obstacles[o].cy

		distance = math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1-y2,2))

			if(distance < 12) then
				vecB.x = vecB.x - (x2 - x1)
				vecB.y = vecB.y - (y2 - y1)
			end
	end


end

function boidCollision_enemy(enemy)

		local x1 = enemy.x
		local y1 = enemy.y

		for j = 1, #EnemyTable.Enemies, 1 do

			if(j == i) then
			
			else

				x2 = EnemyTable.Enemies[j].x
				y2 = EnemyTable.Enemies[j].y

				distance = math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1-y2,2))

				if(distance < 8) then
					vecB.x = vecB.x - (x2 - x1)
					vecB.y = vecB.y - (y2 - y1)
				end

			end
		end


end

function boidSpeed(enemy)

		vecC.x = 0
		vecC.y = 0
		
		local vx1 = enemy.vx
		local vy1 = enemy.vy

		for j = 1, #EnemyTable.Enemies, 1 do

			if(j == i) then
			
			else
				vx2 = EnemyTable.Enemies[j].vx 
				vy2 = EnemyTable.Enemies[j].vy 

				vecC.x = vecC.x + vx2
				vecC.y = vecC.y + vy2

			end
		end

		vecC.x = vecC.x / (20 - 1)
		vecC.y = vecC.y / (20 - 1)

		vecC.x = (vecC.x - vx1) / 8
		vecC.y = (vecC.y - vy1) / 8

end

function boidBounding(enemy)

	--0 to 624 (Y) 
	--0 to 784 (X)

	vecD.x = 0
	vecD.y = 0

	if enemy.x < 16 then
		vecD.x = 10
	elseif enemy.x > 784 then
		vecD.x = -10
	end

	if enemy.y < 16 then
		vecD.y = 10
	elseif enemy.y > 624 then
		vecD.y = -10
	end

end


function animateEnemies()

	for i = 1, #EnemyTable.Enemies, 1 do

		local vx = EnemyTable.Enemies[i].vx
		local vy = EnemyTable.Enemies[i].vy

		if(math.abs(vx) > math.abs(vy)) then --Left / Right

			if(vx < 0) then
				EnemyTable.Enemies[i].currentsprites = EnemyTable.Enemies[i].leftsprites
				EnemyTable.Enemies[i].flip = -1
			else
				EnemyTable.Enemies[i].currentsprites = EnemyTable.Enemies[i].rightsprites
				EnemyTable.Enemies[i].flip = 1
			end
		else
			if(vy < 0) then
				EnemyTable.Enemies[i].currentsprites = EnemyTable.Enemies[i].upsprites
				EnemyTable.Enemies[i].flip = 1
			else
				EnemyTable.Enemies[i].currentsprites = EnemyTable.Enemies[i].downsprites
				EnemyTable.Enemies[i].flip = 1
			end
		end



		if(EnemyTable.Enemies[i].scount < 3) then
			EnemyTable.Enemies[i].scount = EnemyTable.Enemies[i].scount + 1
		elseif (EnemyTable.Enemies[i].spriteindex == #EnemyTable.Enemies[i].currentsprites and EnemyTable.Enemies[i].scount >= 3) then 
			EnemyTable.Enemies[i].spriteindex = 1
			EnemyTable.Enemies[i].scount = 0
		else 
			EnemyTable.Enemies[i].spriteindex = EnemyTable.Enemies[i].spriteindex + 1
			EnemyTable.Enemies[i].scount = 0
		end

		if(EnemyTable.Enemies[i].hit) then
			EnemyTable.Enemies[i].currentsprites = EnemyTable.Enemies[i].destroysprite
			EnemyTable.Enemies[i].spriteindex = 1
		end

	end
end

function drawEnemies()

	for i = 1, #EnemyTable.Enemies, 1 do

		local index =  EnemyTable.Enemies[i].spriteindex

		love.graphics.draw(spritesheet, EnemyTable.Enemies[i].currentsprites[index], EnemyTable.Enemies[i].x, EnemyTable.Enemies[i].y, 0, EnemyTable.Enemies[i].flip, 1, 8, 8)
		fps = love.timer.getFPS( )
		--love.graphics.circle( "fill", EnemyTable.Enemies[i].cx, EnemyTable.Enemies[i].cy, EnemyTable.Enemies[i].rad, 5)
	end


end

function spawnEnemy()

	
	spawn = false;

	-- Have 3 seconds passed? Spawn n enemies if possible
	if (love.timer.getTime() - enemy_timer >= 5) then
		spawn = true
	end

	-- Have 10 seconds passed? Increase enemy count
	if (love.timer.getTime() - enemy_timer >= 7) then
		EnemyTable.maxEnemies = EnemyTable.maxEnemies + 1
		enemy_timer = love.timer.getTime()
	end



	for s = 0, EnemyTable.spawnable, 1 do

		if(#EnemyTable.Enemies < EnemyTable.maxEnemies and spawn) then

			spawnenemy:play()

			xpos = math.random(16, 768);
			ypos = math.random(16, 608);
			enemytype = math.random()

			if(enemytype < 0.5) then
				table.insert(EnemyTable.Enemies, {x = xpos, y = ypos, 
					cx = xpos + 8, cy = ypos + 8,
					upsprites = enemyType1.upsprites, downsprites = enemyType1.downsprites, 
					leftsprites = enemyType1.leftsprites,  rightsprites = enemyType1.rightsprites, 
					destroysprite = enemyType1.destroysprite,
					currentsprites = enemyType1.downsprites,
					spriteindex = 1, id = EnemyTable.enemyCount,
					vx = 0, vy = 0, scount = 0})
			else
					table.insert(EnemyTable.Enemies, {x = xpos, y = ypos, 
					rad = 10, cx = xpos + 8, cy = ypos + 8,	
					upsprites = enemyType2.upsprites, downsprites = enemyType2.downsprites, 
					leftsprites = enemyType2.leftsprites,  rightsprites = enemyType2.rightsprites, 
					destroysprite = enemyType1.destroysprite,
					currentsprites = enemyType2.downsprites,
					spriteindex = 1, id = EnemyTable.enemyCount,
					vx = 0, vy = 0, scount = 0})
			end

			EnemyTable.enemyCount = EnemyTable.enemyCount + 1
		end

	end



end


function enemyHitDetection(dt)

	local toremove = {}

	for i = 1, #EnemyTable.Enemies, 1 do
		if EnemyTable.Enemies[i].hit then
			table.insert(toremove, i)
			score = score + 1
		end
	end

	if #toremove >= 1 then
		for j = 1, #toremove, 1 do
			table.remove(EnemyTable.Enemies, toremove[j])
			explode:play()
		end
	end

end



function cleanupProjectiles()

	local toremove = {}

	for i = #Projectiles, 1, -1 do

		local passedx = false
		local passedy = false

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
end


function createBullet(x,y) 


	if(#Projectiles < Player.maxshots and start and not Player.casting) then

		fire:play()

		--Treat as triangle
		local xlen = ((x - Player.xpos)) -- X (Adjacent) 
		local ylen = ((y - Player.ypos)) -- Y (Opposite)

		local r = math.sqrt((xlen * xlen) + (ylen * ylen)) -- R (Hypotenuse)

		local xratio = xlen / r -- Ratio of x to r (Sin[theta]), value to increase x coordinate by each dt
		local yratio = ylen / r -- Ratio of y to r (Cos[theta]), value to increase y coordinate by each dt

		local xd = true
		local yd = true

		if(xlen < 0) then
			xd = false
		end

		if(ylen < 0) then
			yd = false
		end

		local shot = {xpos = Player.xpos - 8, ypos = Player.ypos - 8,
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

	if(start) then

		for i = 1, #Arena.obstacles, 1 do

			--Four corners of block
			local blockx1 = Arena.obstacles[i].x
			local blockx2 = blockx1 + (Arena.obstacles[i].rad * 2)
			local blocky1 = Arena.obstacles[i].y
			local blocky2 = blocky1 + (Arena.obstacles[i].rad * 2)


			if((x >= blockx1 and x <= blockx2) and (y >= blocky1 and y <= blocky2) ) then

				Arena.obstacles[i].x = Player.xpos
				Arena.obstacles[i].y = Player.ypos
				Arena.obstacles[i].cx = Arena.obstacles[i].x + Arena.obstacles[i].rad
				Arena.obstacles[i].cy = Arena.obstacles[i].y + Arena.obstacles[i].rad


				Player.xpos = x - Player.rad / 2
				Player.ypos = y - Player.rad / 2

				swap:play()

				return	
			end

		end
	end
end

function drawInterface()

		x = 0
		y = 0

		for i = 1, Player.life, 1 do
			love.graphics.draw(spritesheet, Interface.lifesprite[1], x, y)
			x = x + 16			
		end

		x = 700

		for i = 0, Player.magic, 1 do
			love.graphics.draw(spritesheet, Interface.magicsprite[1], x, y)
			x = x + 16			
		end

		love.graphics.print("Score: ", 400, 0)
		love.graphics.print(score, 450, 0)

		if(not start and not gameover) then

			love.graphics.print("Controls\nMovement: WASD\nAiming: Mouse\nFire: Left Mouse Button\nSwap Player w/ Block: Right Mouse Button when cursor is over block\nScatter Swarm: Hold Spacebar (uses magic, cannot shoot)\n\n\nStart Game: Z\n\nSwap Spritesheet: R (try before starting game)\n\n\nHealth is displayed top left, when hit player swaps places with random block\nMagic charges displayed top right, refill from pickups\nTotal score displayed top center, increase by killing enemies and gather coins\n\nNo limit on block swaps, so use if you get stuck due to random block placement!", 100, 200, 0, 1.2 ,1.2)

		end

		if(gameover and not start) then

			love.graphics.print("Final Score: " .. score,300,300, 0, 2, 2)
			love.graphics.print("Press Q to quit", 300,350, 0, 2, 2)

		end


end


function pickUps()

	now_time = love.timer.getTime()

	if(now_time - pickup_spawn >= pickup_coin.time and not pickup_coin.spawn) then

		--Coin position within boundaries, player can swap blocks to reach
		pickup_coin.x = math.random(16, 768)
		pickup_coin.y = math.random(16, 608)
		pickup_coin.cx = pickup_coin.x  + 8
		pickup_coin.cy = pickup_coin.y  + 8

		pickup_coin.spawn = true
		pickupspawn:play()




	end


	if(now_time - pickup_spawn >= pickup_magic.time and not pickup_magic.spawn) then
		
		--Generate a position for the potion
		pickup_magic.x = math.random(16, 768)
		pickup_magic.y = math.random(16, 608)
		pickup_magic.cx = pickup_magic.x  + 8
		pickup_magic.cy = pickup_magic.y  + 8

		pickup_magic.spawn = true

		--activate timer for crowd scatter
		pickup_spawn = now_time
		pickupspawn:play()


	end

	--Check if player has picked up
	x1 = Player.xpos + 8
	y1 = Player.ypos + 8

	x2 = pickup_coin.cx
	y2 = pickup_coin.cy

	x3 = pickup_magic.cx
	y3 = pickup_magic.cy


	coindist = math.sqrt(math.pow(x1-x2,2) + math.pow(y1-y2, 2))
	magdist = math.sqrt(math.pow(x1-x3,2) + math.pow(y1-y3,2))

	if(magdist < 16 and pickup_magic.spawn == true) then

		pickup_magic.spawn = false
		Player.magic = Player.magic + 1
		pickupgrab:play()
	end

	if(coindist < 16 and pickup_coin.spawn == true) then
		score = score + 10
		pickup_coin.spawn = false
		pickupgrab:play()
	end

end

function drawPickup()

	if(pickup_coin.spawn) then

		love.graphics.draw(spritesheet, Interface.scoresprite[1], pickup_coin.x, pickup_coin.y)

	end

	if(pickup_magic.spawn) then

		love.graphics.draw(spritesheet, Interface.magicsprite[1], pickup_magic.x, pickup_magic.y)

	end



end
