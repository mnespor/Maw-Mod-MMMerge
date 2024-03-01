local NUMPAD0 = 96
local ADD= 107
local SUBTRACT= 109
local OEM_PLUS= 187
local OEM_MINUS= 189

local count = 5


function events.KeyDown(t)

    if (Game.CurrentScreen == 7 and Game.CurrentCharScreen == 103) or Game.CurrentScreen==13 then
		me = Party[Game.CurrentPlayer]
		--[[
		if t.Key >= NUMPAD0 and t.Key < NUMPAD0 + 10 then
			mem.dll.Luggage.activate(me ,t.Key - NUMPAD0 )
		end
		]]
		page = mem.dll.Luggage.current(me)
		if t.Key == OEM_MINUS then
		mem.dll.Luggage.activate(me , (page-1)%count)
		end
		if t.Key == OEM_PLUS then
			mem.dll.Luggage.activate(me , (page+1)%count)
		end
		if Party.High==0 then
			if t.Key>=49 and t.Key<=48+count then
				mem.dll.Luggage.activate(me , t.Key-49)
			end
		end		
	end
end

function events.GameInitialized2()
	for i=1,5 do
		CustomUI.CreateButton{
			IconUp = "SlChar" .. i .. "U",
			IconDown = "SlChar" .. i .. "D",
			Screen = 7,
			Layer = 1,
			X =	455+i*30,
			Y =	372,
			Masked = true,
			Action = function() changeBag(Party[Game.CurrentPlayer], i-1) end,
		}
	end
end

function changeBag(pl, bag)
	mem.dll.Luggage.activate(pl , bag)
end