--[[
#########################################################################################################
#	@mod:		Horizon Clock Mod			                                                            #
#	@author: 	Kees Bekkema AKA TurboTuTone                                                            #
#	@notes:		Horizon Clock mod by Thutzor (concept + art) and TurboTuTone (code)     	 			#
#	@link: 		http://theindiestone.com/forums/index.php/topic/5445-natural-clock-mod-v01/				#
#########################################################################################################
--]]

require "ISUI/ISPanel"

ISUINatClock = ISUIElement:derive("ISUINatClock");


function ISUINatClock:onResize()
	local x = getCore():getScreenWidth();
	self:setX( x - ( self:getWidth() + 10 ) );
end

function ISUINatClock:getMoveablePos( _step )
	if _step then
		local step = 220 + ( _step * 100 );
		local slice = 2 * math.pi / 360;
		local angle = slice * step;
		local x = math.floor( self.universeX + ( self.universeRadius * math.cos( angle ) ) );
		local y = math.floor( self.universeY + ( self.universeRadius * math.sin( angle ) ) );
		return x,y;
	end
	return false;
end

function ISUINatClock:new (x, y, width, height)
	local o = {};
	o = ISUIElement:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.x = x;
	o.y = y;
	o.width = width;
	o.height = height;
	o.universeX = math.floor( o.width / 2 );
	o.universeY = o.y + 70;
	o.universeRadius = 62;
	o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
	o:instantiate();
	o:initialise( o );
	return o
end