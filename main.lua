Class = require "hump.class"
vector = require "hump.vector"
Timer = require "hump.timer"
List = Class{}

math.randomseed(os.time())
math.randomseed(os.time())
math.randomseed(os.time())

function List:init(items)
	self.items = items or {}
end

function List:add(item)
	table.insert(self.items, item)
end

function List:remove(item)
	for i = #self.items, 1, -1 do
		if self.items[i] == item then
			table.remove(self.items, i)
		end
	end
end

function List:call(f, ...)
	for i,v in ipairs(self.items) do
		if v[f] then
			v[f](v, ...)
		end
	end
end

function List:update(dt)
	self:call("update", dt)
end

function List:draw()
	self:call("draw")
end

Queue = Class{}

function Queue:init(pos, spacing)
	self.pos = pos
	self.spacing = ((Bubble.bgHeight*Bubble.scale) + spacing)
	self.items = {}
end

function Queue:add(bubble)
	bubble.pos = self.pos - vector(0, Bubble.bgHeight)
	table.insert(self.items, bubble)
	Timer.tween(0.5, bubble.pos, {y = (#self.items - 1) * self.spacing})
end

function getIndex(t, i)
	for j = 1, #t do
		if t[j] == i then return j end
	end
end

function Queue:remove(bubble)
	local index = getIndex(self.items, bubble)
	
	table.remove(self.items, index)
	
	for i = index, #self.items do
		Timer.tween(0.5, self.items[i].pos, {y = self.items[i].pos.y - self.spacing})
	end
end

function Queue:draw()
	for i = #self.items,1,-1 do
		self.items[i]:draw()
	end
end

Bubble = Class{}

function format(num)
	local s = tostring(num)
	if num < 10000 then
		return s
	elseif num < 1000000 then
		return string.format("", num/1000).."K"
	elseif num < 1000000000 then
		return tostring(num/1000000).."M"
	end
end


function Bubble:init(pos, name, img, followers)
	self.pos = pos
	self.img = img
	
	self.followers = "Followers: "..format(followers)
	
	self.a = 255
	
	self.imgWidth = img:getWidth()
	
	self.width = math.ceil( (math.max(self.font:getWidth(name), self.font:getWidth(self.followers))/self.scale) + (self.img:getWidth()/self.scale) + 4) --buffer
	self.name = name
end

function Bubble:draw()
	--love.graphics.push()
	--love.graphics.scale(self.scale)
	love.graphics.setColor(255,255,255,self.a)
	
	
	
	for i = self.width,1,-1 do
		--love.graphics.setColor(255, i*20, 0)
		love.graphics.draw(self.bg, self.pos.x + (i*self.scale), self.pos.y, 0, self.scale, self.scale)
	end
	
	love.graphics.draw(self.bg,self.pos.x+((self.width+self.bgWidth+2)*self.scale),self.pos.y, 0, -self.scale, self.scale)
	
	
	
	love.graphics.draw(self.img, self.pos.x + (self.scale*4), self.pos.y+self.scale*2, 0, ((self.bgHeight-4)/self.imgWidth)*self.scale)
	
	local imgOff = (self.scale*9)
	
	love.graphics.setColor(0,0,0,self.a)
	love.graphics.setFont(self.font)
	love.graphics.print(self.name, self.pos.x + (imgOff), self.pos.y+(self.scale))
	love.graphics.print(self.followers, self.pos.x + imgOff, self.pos.y+self.scale*3)
	
	--love.graphics.pop()
end

function love.load()
	love.graphics.setBackgroundColor(255,255,255)
	love.graphics.setDefaultFilter("nearest", "nearest")
	Bubble.bg = love.graphics.newImage("assets/img/Bubble.png")
	Bubble.bgHeight = Bubble.bg:getHeight()
	Bubble.bgWidth = Bubble.bg:getWidth()
	Bubble.scale=8
	Bubble.font = love.graphics.newFont(20)
	
	objects = List()
	
	testIcon = love.graphics.newImage("assets/img/test.png")
	
	queue = Queue(vector(200,0), 15)
	
	queue:add(Bubble(vector(50,50), "@test", testIcon, 50))
	queue:add(Bubble(vector(50,200), "@testTestTestTest", testIcon, 20000))
	queue:add(Bubble(vector(50,350), "@slimShadyTheRealSlimShadyPleaseStandUp", testIcon, 200000000))
	
	objects:add(queue)
	
	names = {"John", "Kevin", "Shady", "Slim", "Hicks", "Jordan", "Edgy", "Naruto", "Real", "Davito"}
	
	inputText = ""
	
end

function love.textinput(t)
	if t == " " then return end
	inputText = inputText .. t
end

function love.keypressed(key)
	if key == "return" then
		--follow logic
		
		for i, v in ipairs(queue.items) do
			if v.name == inputText then
				queue:remove(v)
				objects:add(v)
				Timer.tween(0.5, v.pos, {y = -queue.spacing}, "linear",function() objects:remove(v) end)
				Timer.tween(0.4, v, {a = 0})
				break
			end
		end
		
		inputText = ""
	elseif key == "backspace" then
		inputText = inputText:sub(1, #inputText - 1)
	elseif key == "space" then
		local name = ""
		for i = 1,math.random(1,5) do
			name = name .. names[math.random(1, #names)]
		end
		queue:add(Bubble(nil, "@"..name, testIcon, math.random(500,50000)))
	end
end

function love.update(dt)
	Timer.update(dt)
end

function love.draw()
	objects:draw()
	
	love.graphics.print(inputText, 50, 500)
	
	love.graphics.print(love.mouse.getX().." , "..love.mouse.getY(), 0,0)
end