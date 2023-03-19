VEHICLE_PREVIEW_POSITION = Vector3( -2425.9851074219, -613.6572265625, 132.55892944336 )
VEHICLE_ROTATION = 70
VEHICLE_QUIT_POSITION = Vector3( -2428.7470703125, -604.11358642578, 132.5625 )

CAMERA_POSITION = { -2433.0283203125, -613.51550292969, 134.04359436035, -2432.0612792969, -613.47973632812, 133.6918548584, 0, 70 }

SHOP_MARKER_POSITION = Vector3( -2421.7041015625, -595.70428466797, 131.61769104004 )
VEHICLE_SELL_POSITION = Vector3( -2425.9895019531, -600.83868408203, 131.5625 )
NUMBERPLATE_CHANGE_POSITION = Vector3( -2430.1208496094, -604.22943115234, 131.55473327637 )

_VEHICLES = {
	[ 429 ] = {
		name = "Тачка с 429 ID",
		cost = 500000,
		properties = {
			speed = 150,
			acceleration = 200,
		},
	},

	[ 430 ] = {
		name = "Тачка с 430 ID",
		cost = 600000,
		properties = {
			speed = 155,
			acceleration = 200,
		},
	},

	[ 431 ] = {
		name = "Тачка с 431 ID",
		cost = 700000,
		properties = {
			speed = 150,
			acceleration = 200,
		},
	},

	[ 432 ] = {
		name = "Тачка с 432 ID",
		cost = 800000,
		properties = {
			speed = 150,
			acceleration = 200,
		},
	},

	[ 433 ] = {
		name = "Тачка с 433 ID",
		cost = 900000,
		properties = {
			speed = 150,
			acceleration = 200,
		},
	},

	[ 434 ] = {
		name = "Тачка с 434 ID",
		cost = 100000,
		properties = {
			speed = 150,
			acceleration = 200,
		},
	},

	[ 435 ] = {
		name = "Тачка с 435 ID",
		cost = 1100000,
		properties = {
			speed = 150,
			acceleration = 200,
		},
	},

	[ 436 ] = {
		name = "Тачка с 436 ID",
		cost = 120000,
		properties = {
			speed = 150,
			acceleration = 200,
		},
	},

	[ 437 ] = {
		name = "Тачка с 437 ID",
		cost = 150000,
		properties = {
			speed = 150,
			acceleration = 200,
		},
	},

	[ 438 ] = {
		name = "Тачка с 438 ID",
		cost = 500000,
		properties = {
			speed = 150,
			acceleration = 200,
		},
	},

	[ 439 ] = {
		name = "Тачка с 439 ID",
		cost = 500000,
		properties = {
			speed = 150,
			acceleration = 200,
		},
	},
}

_VEHICLES_LIST = { }

for i, v in pairs( _VEHICLES ) do
	v.id = i
	table.insert( _VEHICLES_LIST, v )
end


NUMBERPLATE_STRINGS = { "а", "в", "е", "к", "м", "н", "о", "р", "с", "т", "у", "х" }
NUMBERPLATE_NUMBERS = { "0", "9", "8", "7", "6", "5", "4", "3", "2", "1" }

_NUMBERPLATE_STRINGS = { }
_NUMBERPLATE_NUMBERS = { }

for i, v in pairs( NUMBERPLATE_STRINGS ) do
	_NUMBERPLATE_STRINGS[ v ] = true
end

for i, v in pairs( NUMBERPLATE_NUMBERS ) do
	_NUMBERPLATE_NUMBERS[ v ] = true
end