--[[
#########################################################################################################
#	@mod:		Horizon Clock Mod			                                                            #
#	@author: 	Kees Bekkema AKA TurboTuTone                                                            #
#	@notes:		Horizon Clock mod by Thutzor (concept + art) and TurboTuTone (code)     	 			#
#	@link: 		http://theindiestone.com/forums/index.php/topic/5445-natural-clock-mod-v01/				#
#########################################################################################################
--]]

NaturalClock 			= {};
NaturalClock.instance	= false;
-- day cycle colors:
NaturalClock.dawn		= { r = 170, g =  30, b =   0 };
NaturalClock.day		= { r = 152, g = 203, b = 244 };
NaturalClock.dusk		= { r = 170, g =  30, b =   0 };
NaturalClock.night		= { r = 109, g =  86, b = 146 };


function NaturalClock.init()
	local this = {}
	
	this_tex 		= {};
	this_back 		= false;
	this_fore 		= false;
	this_star 		= false;
	this_fade 		= false;
	this_stars 		= {};
	this_moon 		= false;
	this_sun 		= false;
	this_period 	= "";
	this_instance 	= false;
	this_colors		= {};

	local function this_lerp(_t,_a,_b) 		return _a+_t*(_b-_a);							end
	
	local function this_lerpColor( _t, _colorA, _colorB )
		local R = this_lerp( _t, _colorA.r, _colorB.r );
		local G = this_lerp( _t, _colorA.g, _colorB.g );
		local B = this_lerp( _t, _colorA.b, _colorB.b );
		local A = this_lerp( _t, _colorA.a, _colorB.a );
		return R, G, B, A;
	end
	-- gets time step of current time between to points on 24 hour clock, for example ( 1, 23, 3) = 0.5 or ( 6 , 4, 12 ) = 0.25
	local function this_getTimeStep(_x, _min, _max)
		return ( _x < _min and (24 + _x) - _min or _x - _min ) / ( _min > _max and 24 + (_max - _min) or _max - _min );
	end

	function this_addPeriod( _period, _time, _r, _g, _b, _a )
		table.insert( this_colors, { period=_period, r=_r/255, g=_g/255, b=_b/255, a=_a/255, time=_time } );
	end		
	
	local function this_AddTex( _name )
		local tex = getTexture( "media/textures/" .. _name .. ".png" );
		if not this_tex[ _name ] then
			this_tex[ _name ] = tex;
		end
	end	
	
	local function this_LoadTex()
		this_AddTex("clock_border");
		this_AddTex("clock_grey_background");
		this_AddTex("clock_grey_foreground");
		this_AddTex("clock_fader");
		this_AddTex("clock_foreground");	
		this_AddTex("clock_moon_full");
		this_AddTex("clock_sun");
		for i = 1, 12, 1 do
			this_AddTex("clock_stars_" .. tostring(i) );
		end
	end		
	
	function this.Update()
		local time = getGameTime():getTimeOfDay();
		
		for k,v in ipairs( this_colors ) do
			local nextK = k + 1 <= #this_colors and k + 1 or 1;
			local tStep = this_getTimeStep(time, v.time, this_colors[nextK].time);
			if tStep <= 1 then
				local r,g,b,a = this_lerpColor( tStep, v, this_colors[nextK] )
				--this_back:setColor(r,g,b,a) -- <- bug in java
				--this_fore:setColor(r,g,b,a)
				this_back:setColor(r,b,g,a); --temp fix
				this_fore:setColor(r,b,g,a);
				this_period = v.period;		
				break;
			end
		end	
		
		if this_period == "night" then
			local alpha = 1;
			if time >= 5 and time < 7 then
				alpha = 1 - ( (time - 5) / 2);
			elseif time >= 21 and time < 23 then
				alpha = (time - 21) / 2;
			end		
			for i = 1, 12, 1 do
				local x = this_stars[i]:getX() + 1 > 120 and 0 or this_stars[i]:getX() + 1;
				this_stars[i]:setX( x );
				this_stars[i]:setColor(1,1,1,alpha);
				this_fade:setColor(1,1,1,alpha);
				this_stars[i]:setVisible( true );				
			end
			this_fade:setVisible( true );
			this_moon:setVisible( true );
			this_sun:setVisible( false );
		else
			for i = 1, 12, 1 do
				this_stars[i]:setVisible( false );
			end
			this_fade:setVisible( false );
			this_moon:setVisible( false );
			this_sun:setVisible( true );
		end			

		local time_adj = false;
		if time >= 7 and time < 21 then
			time_adj = ( 1 / 14 ) * (time - 7);
		else
			if time >= 22 then
				time_adj = ( 1 / 8 ) * (time - 22);
			elseif time < 6 then
				time_adj = ( 1 / 8 ) * (time + 2 );
			end
		end
		
		local x,y = this_instance:getMoveablePos( time_adj );
		if x then
			this_moon:setX( x - this_moon:getWidth() );
			this_moon:setY( y - this_moon:getHeight() );
			this_sun:setX( x - this_sun:getWidth()  );
			this_sun:setY( y - this_sun:getHeight() );
		end	
	end
	
	function this.Initialise()
		this_LoadTex();
		
		local dw,da,du,ng = NaturalClock.dawn, NaturalClock.day, NaturalClock.dusk, NaturalClock.night;
		this_addPeriod("night",	2,  ng.r, ng.g, ng.b, 255);
		this_addPeriod("dawn",	7,  ng.r, ng.g, ng.b, 255);
		this_addPeriod("dawn",	8,  dw.r, dw.g, dw.b, 255);
		this_addPeriod("day",	9,  da.r, da.g, da.b, 255);
		this_addPeriod("day",	14, da.r, da.g, da.b, 255);
		this_addPeriod("dusk",	19, da.r, da.g, da.b, 255);
		this_addPeriod("dusk",	20, du.r, du.g, du.b, 255);
		this_addPeriod("night",	21, ng.r, ng.g, ng.b, 255);	
		
		local clock = UIManager.getClock();
		clock:setVisible( false );
		
		local natClock = ISUINatClock:new ( getCore():getScreenWidth() - (130+10), 10, 130, 40);	
		natClock:addToUIManager();
		this_instance = natClock;

		local elem;
		elem = ISUISimpleImg:new(-3, -3, 134, 44, this_tex.clock_border );
		elem:initialise();
		natClock:addChild( elem );	
		
		elem = ISUISimpleImg:new(0, 0, 130, 40, this_tex.clock_grey_background );
		elem:initialise();
		natClock:addChild( elem );
		this_back = elem;
		
		for i = 1, 12, 1 do
			elem = ISUISimpleImg:new( (i-1)*10, 0, 10, 40, this_tex[ "clock_stars_" .. tostring(i) ] );
			elem:initialise();
			elem:setVisible( false );
			natClock:addChild( elem );
			this_stars[i] = elem;
		end
		
		elem = ISUISimpleImg:new(0, 0, 130, 40, this_tex.clock_fader );
		elem:initialise();
		natClock:addChild( elem );
		this_fade = elem;	

		elem = ISUISimpleImg:new(0, 0, 10, 10, this_tex.clock_moon_full );
		elem:initialise();
		elem:setVisible( false );
		natClock:addChild( elem );
		this_moon = elem;	
		
		elem = ISUISimpleImg:new(0, 0, 16, 16, this_tex.clock_sun );
		elem:initialise();
		elem:setVisible( false );
		natClock:addChild( elem );
		this_sun = elem;	

		elem = ISUISimpleImg:new(0, 0, 130, 40, this_tex.clock_grey_foreground );
		elem:initialise();
		natClock:addChild( elem );
		this_fore = elem;
		
		elem = ISUISimpleImg:new(0, 0, 130, 40, this_tex.clock_foreground );
		elem:initialise();
		natClock:addChild( elem );	
		
		Events.EveryTenMinutes.Add( this.Update );
		
		this.Update()
		
		return this;
	end
	
	NaturalClock.instance = this.Initialise();
end

function NaturalClock.destroy()
	NaturalClock.instance = nil;
end

Events.OnGameStart.Add(NaturalClock.init);