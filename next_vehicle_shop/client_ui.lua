local ui = { }
local selected_item = 1

function PlayerWantEnter( )
	fadeCamera( true, 0.4 )
	Timer( CreateUI, 50, 1 )
	setCameraMatrix( unpack( CAMERA_POSITION ) )
	
	local unique_dimension = math.random( ) * 6000
	localPlayer.dimension = unique_dimension
	localPlayer.frozen = true
	bindKey( "backspace", "up", PlayerWantQuit )
end

function PlayerWantQuit( )
	unbindKey( "backspace", "up", PlayerWantQuit )
	DestroyUI( )
	setCameraTarget( localPlayer )
	localPlayer.dimension = 0
	localPlayer.frozen = false
	selected_item = 1
end
addEvent( "g_PlayerWantQuit", true )
addEventHandler( "g_PlayerWantQuit", resourceRoot, PlayerWantQuit )

function ChangeVehicle( )
	local conf = _VEHICLES_LIST[ selected_item ] or false
	if conf then
		dgsSetProperty( ui.vehicle_name, "text", conf.name )
		dgsSetProperty( ui.cost_lbl, "text", splitWithPoints( conf.cost or 100000 ).."$" )

		local stats = {
			speed 			= { title = "Скорость", value = conf.properties.speed.." км/ч" },
			acceleration 	= { title = "Ускорение", value = conf.properties.acceleration },

		}

		dgsSetProperty( ui.speed_lbl, "text", stats.speed.title..": "..( stats.speed.value or "0" ) )
		dgsSetProperty( ui.acceleration_lbl, "text", stats.acceleration.title..": "..( stats.acceleration.value or "0" ) )

		local vehicle = ui.fake_vehicle
		if isElement( vehicle ) then
			vehicle.model = conf.id
			vehicle.position = VEHICLE_PREVIEW_POSITION
		end
	end
end

function CreateNumberSelectWindow( callback )
	ui._input = _Input( {
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

			triggerServerEvent( callback or "PlayerWantBuyVehicle", resourceRoot, selected_item, number )
		end,
	} )
end
addEvent( "CreateNumberSelectWindow", true )
addEventHandler( "CreateNumberSelectWindow", resourceRoot, CreateNumberSelectWindow )

function CreateUI( )
	DestroyUI( )
	showCursor( true )
	showChat( false )

	ui.fake_vehicle = Vehicle( _VEHICLES_LIST[ selected_item ].id, VEHICLE_PREVIEW_POSITION, 0, 0, VEHICLE_ROTATION )
	ui.fake_vehicle.dimension = localPlayer.dimension

	ui.bg = dgsCreateDetectArea( 0, 0, scx, scy )
	dgsSetAlpha( ui.bg, 0 )
	dgsAlphaTo( ui.bg, 1, "OutQuad", 880 )

	ui.stats_bg = dgsCreateImage( 10, 50, 350, 300, false, false, ui.bg, tocolor( 0, 0, 0, 155 ) )

	local vehicle_name_font = Font( "hb", 15 )
	ui.vehicle_name = dgsCreateLabel( 0, 20, 350, 0, "", false, ui.stats_bg, _, 1, 1, _, _, _, "center" )
	dgsSetFont( ui.vehicle_name, vehicle_name_font )

	local stat_font = Font( "hb", 11 )

	ui.speed_lbl = dgsCreateLabel( 25, 100, 0, 0, "", false, ui.stats_bg )
	ui.acceleration_lbl = dgsCreateLabel( 25, 127, 0, 0, "", false, ui.stats_bg )

	ui.cost_lbl = dgsCreateLabel( 0, 260, 350, 0, "", false, ui.stats_bg, _, _, _, _, _, _, "center" )

	dgsSetFont( ui.cost_lbl, vehicle_name_font )
	dgsSetFont( ui.speed_lbl, stat_font )
	dgsSetFont( ui.acceleration_lbl, stat_font )
	dgsSetFont( dgsCreateLabel( scx - 270, 20, 0, 0, "BACKSPACE - Выйти", false, ui.bg, tocolor( 0, 0, 0 ) ), Font( "hb_bold", 15 ) )

	ChangeVehicle( )

	ui.list_bg = dgsCreateScrollPane( ( scx - ( scx - 10 ) ) / 2, scy - 190, scx - 10, 170, false, ui.bg )

	local item_sx, item_sy = 250, 150
	local gap = 5

	local _font = Font( "hb_medium", 13 )
	for i, v in ipairs( _VEHICLES_LIST ) do
		ui[ "item_"..i ] = dgsCreateImage( ( item_sx + gap ) * ( i - 1 ), 0, item_sx, item_sy, false, false, ui.list_bg, selected_item == i and tocolor( 77, 130, 214 ) or tocolor( 0, 0, 0 ) )
		dgsSetEnabled( dgsCreateImage( ( item_sx - 200 ) / 2, ( item_sy - 200 ) / 2, 200, 200, "img/vehicle.png", false, ui[ "item_"..i ] ), false )
		dgsSetFont( dgsCreateLabel( 5, 5, 0, 0, v.name, false, ui[ "item_"..i ] ), _font )

		addEventHandler( "onDgsMouseEnter", ui[ "item_"..i ], function( )
			if selected_item ~= i then
				dgsAnimTo( ui[ "item_"..i ], "color", tocolor( 77, 130, 214 ), "colorChange", 500 )
			end
		end, false)

		addEventHandler( "onDgsMouseLeave", ui[ "item_"..i ], function( ) 
			if selected_item ~= i then
				dgsAnimTo( ui[ "item_"..i ], "color", tocolor( 0, 0, 0 ), "colorChange", 500 )
			end
		end, false)

		addEventHandler( "onDgsMouseClick", ui[ "item_"..i ], function( key, state ) 
			if key == "left" and state == "up" then
				if selected_item ~= i then
					dgsAnimTo( ui[ "item_"..selected_item ], "color", tocolor( 0, 0, 0 ), "colorChange", 500 )

					selected_item = i
					dgsAnimTo( ui[ "item_"..selected_item ], "color", tocolor( 77, 130, 214 ), "colorChange", 500 )

					ChangeVehicle( )
				end
			end
		end, false)
	end

	ui.buy_button = dgsCreateImage( 5, scy - 190 - 75, 188, 50, false, false, ui.bg, tocolor( 0, 0, 0 ) )
	local buy_lbl = dgsCreateLabel( 0, 0, 188, 50, "КУПИТЬ", false, ui.buy_button, _, _, _, _, _, _, "center", "center" )
	dgsSetEnabled( buy_lbl, false )
	dgsSetFont( buy_lbl, vehicle_name_font )

	addEventHandler( "onDgsMouseEnter", ui.buy_button, function( ) 
		dgsAnimTo( ui.buy_button, "color", tocolor( 77, 130, 214 ), "colorChange", 500 )
	end, false)

	addEventHandler( "onDgsMouseLeave", ui.buy_button, function( ) 
		dgsAnimTo( ui.buy_button, "color", tocolor( 0, 0, 0 ), "colorChange", 500 )
	end, false)

	addEventHandler( "onDgsMouseClick", ui.buy_button, function( key, state ) 
		if key == "left" and state == "up" then
			local conf = _VEHICLES_LIST[ selected_item ]
			if conf then
				if ui.confirm then ui.confirm:DestroyThis( ) end
				ui.confirm = _Confirm( {
					text = "Хочешь купить '"..conf.name.."' за "..splitWithPoints( conf.cost ).."$ ?",
					callback = function( self )
						triggerServerEvent( "PlayerWantBuyVehicleCheck", resourceRoot, selected_item )
						self:DestroyThis( )
					end,
				} )
			end
		end
	end, false)
end
addEventHandler( "onClientResourceStop", resourceRoot, PlayerWantQuit )
addEventHandler( "onClientPlayerWasted", localPlayer, PlayerWantQuit )

function DestroyUI( )
	table.destroy( ui )
	showCursor( false )
	showChat( true )
end

bindKey( "f2", "down", function( ) 
	if isElement( ui.bg ) then
		PlayerWantQuit( )
	else
		PlayerWantEnter( )
	end
end)