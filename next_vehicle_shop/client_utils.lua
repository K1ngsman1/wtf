scx, scy = guiGetScreenSize( )
_FONTS_CACHE = { }

loadstring( exports.dgs:dgsImportFunction( ) )( )
if not dgsEasingFunctionExists( "colorChange" ) then
	dgsAddEasingFunction( "colorChange", [[
		local _b,_g,_r,_a = bitExtract( setting[ 3 ], 0, 8 ), bitExtract( setting[ 3 ], 8, 8 ), bitExtract(setting[ 3 ], 16, 8 ), bitExtract( setting[ 3 ], 24, 8 )
		local b,g,r,a = bitExtract( setting[ 2 ], 0, 8 ), bitExtract( setting[ 2 ], 8, 8 ), bitExtract(setting[ 2 ], 16, 8 ), bitExtract( setting[ 2 ], 24, 8 )
		return tocolor( _r + ( r - _r ) * progress, _g + ( g - _g) * progress, _b + ( b - _b ) * progress, _a + ( a - _a) * progress )
	]])
end

function onClientResourceStart_( )

	local shop_marker = Marker( SHOP_MARKER_POSITION, "cylinder", 1.5, 255, 0, 0 )
	addEventHandler( "onClientMarkerHit", shop_marker, function( el, dim ) 
		if el == localPlayer and dim then

			if localPlayer.vehicle then
				return false
			end

			fadeCamera( false, 0.4 )
			Timer( PlayerWantEnter, 1000, 1 )
		end
	end)

	local sell_marker = Marker( VEHICLE_SELL_POSITION, "cylinder", 1.5, 0, 255, 0 )
	addEventHandler( "onClientMarkerHit", sell_marker, function( el, dim ) 
		if el == localPlayer and dim then

			if not localPlayer.vehicle then 
				return false
			end

			if localPlayer.vehicle.occupants[ 0 ] ~= localPlayer then
				return false
			end

			local conf = _VEHICLES[ localPlayer.vehicle.model ]
			if conf then
				if SELL_CONFIRM then
					SELL_CONFIRM:DestroyThis( )
				end
				showCursor( true )

				SELL_CONFIRM = _Confirm( {
					text = "Хочешь продать '"..conf.name.."' за "..splitWithPoints( math.floor( conf.cost / 2 ) ).."$ ?",
					callback = function( self )
						self:DestroyThis( )
						showCursor( false )
						triggerServerEvent( "PlayerWantSellVehicle", resourceRoot )
					end,
					callback_close = function( )
						showCursor( false )
					end
				} )
			end
		end
	end)

	local numberchange_marker = Marker( NUMBERPLATE_CHANGE_POSITION, "cylinder", 1.5, 0, 0, 255 )

	addEventHandler( "onClientMarkerHit", numberchange_marker, function( el, dim ) 
		if el == localPlayer and dim then

			if not localPlayer.vehicle then 
				return false
			end

			if localPlayer.vehicle.occupants[ 0 ] ~= localPlayer then
				return false
			end

			local conf = _VEHICLES[ localPlayer.vehicle.model ]
			if conf then
				if SELL_INPUT then
					SELL_INPUT:DestroyThis( )
				end
				showCursor( true )

				SELL_INPUT = _Input( {
					text = "Введи желаемый номер в формате х000хх000",
					placeholder = "х000хх000",
					callback = function( self )
						local text = self:GetText( )
						local unformat_text = "Неправильный формат номера, пример:\nх000хх000, где х - любая буква, 0 - любая цифра"

						if text == "" or utf8.len( text ) <= 0 then
							outputChatBox( "Введи желаемый номер" )
							error( "Введи желаемый номер" )
							return
						end

						local char, numbers = GetCharacters( text, true )

						if #char < 3 then
							outputChatBox( unformat_text )
							error( unformat_text )
							return
						end

						for i, v in pairs( char ) do
							if not _NUMBERPLATE_STRINGS[ utf8.lower( v ) ] then
								outputChatBox( unformat_text )
								error( unformat_text )
								return
							end
						end

						if #numbers < 5 or #numbers > 6 then
							outputChatBox( unformat_text )
							error( unformat_text )
							return
						end

						for i, v in pairs( numbers ) do
							if not _NUMBERPLATE_NUMBERS[ v ] then
								outputChatBox( unformat_text )
								error( unformat_text )
								return
							end
						end

						local number = char[ 1 ]..numbers[ 1 ]..numbers[ 2 ]..numbers[ 3 ]..char[ 2 ]..char[ 3 ]..numbers[ 4 ]..numbers[ 5 ]
						if numbers[ 6 ] then number = number..numbers[ 6 ] end

						triggerServerEvent( "PlayerWantChangeVehicleNumber", resourceRoot, number )
						self:DestroyThis( )
						showCursor( false )
					end,
					callback_close = function( )
						showCursor( false )
					end,
				} )
			end
		end
	end)
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_ )

function table.destroy( tbl )
	for i, v in pairs( tbl ) do
		if isElement( v ) then
			v:destroy( )
		end
		if isTimer( v ) then
			killTimer( v )
		end
		if type( v ) == "table" then table.destroy( v ) end
	end
end

function Font( font_name, font_size )
	if _FONTS_CACHE[ font_name ] and _FONTS_CACHE[ font_name ].font_size == font_size then
		return _FONTS_CACHE[ font_name ].font
	end

	local path = string.format( "fonts/%s.ttf", font_name )
	if not fileExists( path ) then
		path = "fonts/hb.ttf"
	end

	local font = dxCreateFont( path, font_size )
	_FONTS_CACHE[ font_name ] = {
		font_size = font_size,
		font = font
	}

	return font
end

function splitWithPoints( number, splstr )
    number = tostring( number )
    local k
    repeat
        number, k = string.gsub( number, "^(-?%d+)(%d%d%d)", '%1'..( splstr or '.' )..'%2' )
    until ( k == 0 )    -- true - выход из цикла
    return number
end

function _Confirm( _data )
	local self = _data or { }

	local _properties = {
		sx 					= self.sx or 500,
		sy 					= self.sy or 250,
		main_text 			= self.main_text or "Information",
		text 				= self.text or "Тут текст какбыТут текст какбыТут текст  текст какбыТут текст какбыТут текст какбы",
		animation 			= self.animation or "OutQuad",
		animation_duration 	= self.animation_duration or 500,
	}

	for key, value in pairs( _properties ) do
		self[ key ] = value
	end

	self.background = dgsCreateImage( 0, 0, scx, scy, false, false, false, tocolor( 0, 0, 0, 240 ) )
	dgsSetAlpha( self.background, 0 )
	dgsAlphaTo( self.background, 1, self.animation, self.animation_duration )

	self.bg = dgsCreateImage( ( scx - self.sx ) / 2, 200, self.sx, self.sy, false, false, self.background, tocolor( 33, 55, 71 ) )
	dgsMoveTo( self.bg, ( scx - self.sx ) / 2, ( scy - self.sy ) / 2, false, self.animation, self.animation_duration )

	local font = self.font or Font( "hb_medium", 15 )
	self.title = dgsCreateLabel( 0, 10, self.sx, 0, self.main_text, false, self.bg, _, _, _, _, _, _, "center" )
	dgsSetFont( self.title, font )
	dgsSetEnabled( self.title, false )

	self.text = dgsCreateLabel( 0, - ( utf8.len( self.text ) > 50 and 20 or 25 ), self.sx, self.sy, self.text, false, self.bg, _, 1.5, 1.5, _, _, _, "center", "center" )
	dgsSetFont( self.text, "default-bold" )
	dgsSetProperty( self.text, "wordBreak", true )
	dgsSetEnabled( self.text, false )

	local btn_sx, btn_sy = 135, 54
	self.btn_accept = dgsCreateImage( 95, self.sy - btn_sy - 30, btn_sx, btn_sy, false, false, self.bg, tocolor( 0, 0, 0 ) )
	self.btn_close = dgsCreateImage( 120 + btn_sx, self.sy - btn_sy - 30, btn_sx, btn_sy, false, false, self.bg, tocolor( 0, 0, 0 ) )

	local btn_accept_lbl = dgsCreateLabel( 0, 0, btn_sx, btn_sy, "Подтвердить", false, self.btn_accept, _, _, _, _, _, _, "center", "center" )
	dgsSetFont( btn_accept_lbl, Font( "hb_medium", 10 ) )
	dgsSetEnabled( btn_accept_lbl, false )

	local btn_close_lbl = dgsCreateLabel( 0, 0, btn_sx, btn_sy, "Отмена", false, self.btn_close, _, _, _, _, _, _, "center", "center" )
	dgsSetFont( btn_close_lbl, Font( "hb_medium", 12 ) )
	dgsSetEnabled( btn_close_lbl, false )

	addEventHandler( "onDgsMouseEnter", self.btn_accept, function( ) 
		dgsAnimTo( self.btn_accept, "color", tocolor( 77, 130, 214 ), "colorChange", 500 )
	end, false)

	addEventHandler( "onDgsMouseLeave", self.btn_accept, function( ) 
		dgsAnimTo( self.btn_accept, "color", tocolor( 0, 0, 0 ), "colorChange", 500 )
	end, false)

	addEventHandler( "onDgsMouseEnter", self.btn_close, function( ) 
		dgsAnimTo( self.btn_close, "color", tocolor( 77, 130, 214 ), "colorChange", 500 )
	end, false)

	addEventHandler( "onDgsMouseLeave", self.btn_close, function( ) 
		dgsAnimTo( self.btn_close, "color", tocolor( 0, 0, 0 ), "colorChange", 500 )
	end, false)


	self.DestroyThis = function( self )
		table.destroy( self )
		setmetatable( self, nil )
	end

	addEventHandler( "onDgsMouseClick", self.btn_accept, function( key, state ) 
		if key == "left" and state == "up" then
			if self.callback then
				self:callback( )
			end
		end
	end, false)

	addEventHandler( "onDgsMouseClick", self.btn_close, function( key, state ) 
		if key == "left" and state == "up" then
			if self.callback_close then
				self:callback_close( )
			end
			self:DestroyThis( )
		end
	end, false)

	return self
end

function _Input( _data )
	local self = _data or { }

	local _properties = {
		sx 					= self.sx or 500,
		sy 					= self.sy or 250,
		main_text 			= self.main_text or "Information",
		placeholder 		= self.placeholder or "Чето надо ввести",
		text 				= self.text or "Введи что-то",
		animation 			= self.animation or "OutQuad",
		animation_duration 	= self.animation_duration or 500,
	}

	for key, value in pairs( _properties ) do
		self[ key ] = value
	end

	self.background = dgsCreateImage( 0, 0, scx, scy, false, false, false, tocolor( 0, 0, 0, 240 ) )
	dgsSetAlpha( self.background, 0 )
	dgsAlphaTo( self.background, 1, self.animation, self.animation_duration )

	self.bg = dgsCreateImage( ( scx - self.sx ) / 2, 200, self.sx, self.sy, false, false, self.background, tocolor( 33, 55, 71 ) )
	dgsMoveTo( self.bg, ( scx - self.sx ) / 2, ( scy - self.sy ) / 2, false, self.animation, self.animation_duration )

	local font = self.font or Font( "hb_medium", 15 )
	self.title = dgsCreateLabel( 0, 10, self.sx, 0, self.main_text, false, self.bg, _, _, _, _, _, _, "center" )
	dgsSetFont( self.title, font )
	dgsSetEnabled( self.title, false )

	local edit_sx, edit_sy = 330, 50
	self.edit = dgsCreateEdit( ( self.sx - edit_sx ) / 2, ( self.sy - edit_sy ) / 2, edit_sx, edit_sy, "", false, self.bg )
	dgsSetFont( self.edit, Font( "hb_medium", 11 ) )

	dgsSetProperty( self.edit, "placeHolderFont", Font( "hb_medium", 10 ) )
	dgsSetProperty( self.edit, "placeHolder", self.placeholder )

	local edit_px, edit_py = dgsGetPosition( self.edit )
	self.text = dgsCreateLabel( edit_px, edit_py - 25, 0, 0, self.text, false, self.bg, _, 1.1, 1.1 )
	dgsSetFont( self.text, "default-bold" )

	local btn_sx, btn_sy = 135, 54
	self.btn_accept = dgsCreateImage( 95, self.sy - btn_sy - 30, btn_sx, btn_sy, false, false, self.bg, tocolor( 0, 0, 0 ) )
	self.btn_close = dgsCreateImage( 120 + btn_sx, self.sy - btn_sy - 30, btn_sx, btn_sy, false, false, self.bg, tocolor( 0, 0, 0 ) )

	local btn_accept_lbl = dgsCreateLabel( 0, 0, btn_sx, btn_sy, "Подтвердить", false, self.btn_accept, _, _, _, _, _, _, "center", "center" )
	dgsSetFont( btn_accept_lbl, Font( "hb_medium", 10 ) )
	dgsSetEnabled( btn_accept_lbl, false )

	local btn_close_lbl = dgsCreateLabel( 0, 0, btn_sx, btn_sy, "Отмена", false, self.btn_close, _, _, _, _, _, _, "center", "center" )
	dgsSetFont( btn_close_lbl, Font( "hb_medium", 12 ) )
	dgsSetEnabled( btn_close_lbl, false )

	addEventHandler( "onDgsMouseEnter", self.btn_accept, function( ) 
		dgsAnimTo( self.btn_accept, "color", tocolor( 77, 130, 214 ), "colorChange", 500 )
	end, false)

	addEventHandler( "onDgsMouseLeave", self.btn_accept, function( ) 
		dgsAnimTo( self.btn_accept, "color", tocolor( 0, 0, 0 ), "colorChange", 500 )
	end, false)

	addEventHandler( "onDgsMouseEnter", self.btn_close, function( ) 
		dgsAnimTo( self.btn_close, "color", tocolor( 77, 130, 214 ), "colorChange", 500 )
	end, false)

	addEventHandler( "onDgsMouseLeave", self.btn_close, function( ) 
		dgsAnimTo( self.btn_close, "color", tocolor( 0, 0, 0 ), "colorChange", 500 )
	end, false)


	self.DestroyThis = function( self )
		table.destroy( self )
		setmetatable( self, nil )
	end

	self.GetText = function( self )
		return dgsGetText( self.edit )
	end

	addEventHandler( "onDgsMouseClick", self.btn_accept, function( key, state ) 
		if key == "left" and state == "up" then
			if self.callback then
				self:callback( )
			end
		end
	end, false)

	addEventHandler( "onDgsMouseClick", self.btn_close, function( key, state ) 
		if key == "left" and state == "up" then
			if self.callback_close then
				self:callback_close( )
			end
			self:DestroyThis( )
		end
	end, false)

	return self
end

function GetCharacters( str, by_type )
	if by_type then
		local chars, numbers = {}, {}

		for i = 1, utfLen( str ) do
			local symbol = utf8.sub( str, i, i )
			
			if tonumber(symbol) then
				table.insert(numbers, symbol)
			else
				table.insert(chars, symbol)
			end
		end

		return chars, numbers
	else
		local chars = {}

		for i = 1, utfLen( str ) do
			table.insert(chars, utf8.sub( str, i, i ))
		end

		return chars
	end
end

addCommandHandler( "cm", function( ) 
	setClipboard( inspect( { getCameraMatrix ( ) } ) )
end)

addCommandHandler( "pos", function( ) 
	local x, y, z = getElementPosition( getLocalPlayer( ) )
	setClipboard( string.format( "Vector3( %s, %s, %s )", x, y, z ) )
end)