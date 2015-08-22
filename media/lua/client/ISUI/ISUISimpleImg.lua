--[[
#########################################################################################################
#	@mod:		Horizon Clock Mod			                                                            #
#	@author: 	Kees Bekkema AKA TurboTuTone                                                            #
#	@notes:		Natural Clock mod by Thutzor (concept + art) and TurboTuTone (code)     	 			#
#	@link: 		http://theindiestone.com/forums/index.php/topic/5445-natural-clock-mod-v01/				#
#########################################################################################################
--]]

require "ISUI/ISPanel"

ISUISimpleImg = ISPanel:derive("ISUISimpleImg");


function ISUISimpleImg:initialise()
	ISPanel.initialise(self);
end

function ISUISimpleImg:getTexture()
	return self.texture;
end

function ISUISimpleImg:setTexture( _tex )
	self.texture = _tex;
end

function ISUISimpleImg:setMouseOverText(text)
	self.mouseovertext = text;
end

function ISUISimpleImg:setColor(r,g,b,a)
	self.backgroundColor.r = r;
	self.backgroundColor.g = g;
	self.backgroundColor.b = b;
	self.backgroundColor.a = a or 1;
end

function ISUISimpleImg:onMouseMoveOutside(dx, dy)
end

function ISUISimpleImg:onMouseMove(dx, dy)
end

function ISUISimpleImg:prerender()
	self:drawTexture(self.texture, 0, 0, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	if self.mouseover and self.mouseovertext then
		self:drawText(self.mouseovertext, self:getMouseX() - (getTextManager():MeasureStringX(UIFont.Small, self.mouseovertext) / 2), self:getMouseY() - 8, 1,1,1,1, UIFont.Small);
	end
end

function ISUISimpleImg:new (x, y, width, height, texture)
	local o = {};
	o = ISPanel:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self
	o:noBackground();
	o.x = x;
	o.y = y;
	o.texture = texture;
	o.backgroundColor = {r=1, g=1, b=1, a=1};
	o.borderColor = {r=1, g=1, b=1, a=0.7};
	o.width = width;
	o.height = height;
	o.mouseover = false;
	o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
	return o
end
