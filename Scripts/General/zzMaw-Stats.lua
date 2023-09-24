function events.CalcDamageToMonster(t)
	local data = WhoHitMonster()	
	--luck/accuracy bonus
	if data and data.Player and t.DamageKind==4 then
		if data.Object==nil or data.Object.Spell==133 then
			luck=data.Player:GetLuck()/15
			accuracy=data.Player:GetAccuracy()*3/2
			critDamage=accuracy/500
			critChance=50+luck*4/3
			roll=math.random(1, 1000)
			if roll <= critChance then
				t.Result=t.Result*(1.5+critDamage)
			end
	--might bonus
			might=data.Player:GetMight()
			damageBonus=might/1000
			t.Result=t.Result*(1+damageBonus)
		end
	end
end

--speed
function events.CalcDamageToPlayer(t)
	speed=t.Player:GetSpeed()
	speedEffect=speed/10
	dodgeChance=(1-0.995^speedEffect)*100
	roll=math.random(1, 100)
	if roll<=dodgeChance then
		t.Result=0
		--Game.ShowStatusText("Evaded")
		evt.FaceExpression{Player = t.PlayerIndex, Frame = 33}
	end
end

--intellect/personality
function events.CalcSpellDamage(t)
	local data = WhoHitMonster()
	if data and data.Player then
		intellect=data.Player:GetIntellect()	
		personality=data.Player:GetPersonality()
		luck=data.Player:GetLuck()
		bonus=math.max(intellect,personality)
		critDamage=bonus/1000
		t.Result=t.Result*(1+bonus/1000*3/2) 
		critChance=50+luck*4/3
		roll=math.random(1, 1000)
		if roll <= critChance then
			t.Result=t.Result*(1.5+critDamage)
		end
	end
end
--AC 
function events.CalcDamageToPlayer(t)
	if t.DamageKind==4 then 
	AC=t.Player:GetArmorClass()
	t.Result=t.Result/(AC/300+1)
	end
end
--endurance
fullHP2={}
for i =0,300 do
fullHP2[i]=0
end

function events.CalcStatBonusByItems(t)
  if t.Stat == const.Stats.HP then
	endurance=t.Player:GetEndurance()/1000
	index2=t.PlayerIndex
	local skill=t.Player.Skills[const.Skills.Bodybuilding]
	local s,m=SplitSkill(skill)
	t.Result=t.Result+math.round(fullHP2[index2]*endurance)+s^2
  end
end

function events.Tick()
	for i=0,Party.High do
		endurance2=Party[i]:GetEndurance()
		if endurance2<=21 then
		endEff2=(endurance2-13)/2
		else
			endEff2=math.floor(endurance2/5)
		end
		local skill=Party[i].Skills[const.Skills.Bodybuilding]
		local s,m=SplitSkill(skill)
		if m==4 then
			m=5
		end
		BBHP=s*m
		index3=Party[i]:GetIndex()
		fullHP2[index3]=Game.Classes.HPFactor[Party[i].Class]*(Party[i]:GetLevel()+endEff2+BBHP)+Game.Classes.HPBase[Party[i].Class]+s^2
	end
end
--body building description
function events.GameInitialized2()
	Game.SkillDescriptions[27]=Game.SkillDescriptions[24] .. "\n\nHit Points are also increased by an amount equal to Skill^2"
end

function events.BuildStatInformationBox(t)
	if t.Stat==0 then
	i=Game.CurrentPlayer
	might=Party[i]:GetMight()
	t.Text=string.format("%s\n\nBonus Meele/Bow Damage: %s%s",Game.StatsDescriptions[0],might/10,"%")
	end
	if t.Stat==1 then
	i=Game.CurrentPlayer
	meditation=Party[i].Skills[25]%64
	fullSP=Party[i]:GetFullSP()
	personality=Party[i]:GetPersonality()
	intellect=Party[i]:GetIntellect()
	t.Text=string.format("%s\n\nBonus magic damage/healing: %s%s\n\nCritical spell strike damage/healing: %s%s",Game.StatsDescriptions[1],intellect/10,"%",intellect/10*3/2+50,"%")
	end
	if t.Stat==2 then
	i=Game.CurrentPlayer
	personality=Party[i]:GetPersonality()
	t.Text=string.format("%s\n\nBonus magic damage/healing: %s%s\n\nCritical spell strike damage/healing bonus: %s%s",Game.StatsDescriptions[2],personality/10,"%",personality/10*3/2+50,"%")
	end
	if t.Stat==3 then
	i=Game.CurrentPlayer
	endurance=Party[i]:GetEndurance()
	HPScaling=Game.Classes.HPFactor[Party[i].Class]
	level=Party[i]:GetLevel()
	t.Text=string.format("%s\n\nHealth bonus from Endurance: %s%s\n\nFlat HP bonus from Endurance: %s",Game.StatsDescriptions[3],endurance/10,"%",math.floor(endurance/5)*HPScaling)
	end
	if t.Stat==4 then
	i=Game.CurrentPlayer
	accuracy=Party[i]:GetAccuracy()
	t.Text=string.format("%s\n\nCritical melee and bow strike damage bonus: %s%s",Game.StatsDescriptions[4],accuracy/5*3/2+50,"%")
	end
	if t.Stat==5 then
	i=Game.CurrentPlayer
	speed=Party[i]:GetSpeed()
	t.Text=string.format("%s\n\nDodge chance: %s%s",Game.StatsDescriptions[5],math.floor(1000-0.995^(speed/10)*1000)/10	,"%")
	end
	if t.Stat==6 then
	i=Game.CurrentPlayer
	luck=Party[i]:GetLuck()
	t.Text=string.format("%s\n\nCritical strike chance: %s%s",Game.StatsDescriptions[6],math.round((luck/20*4/3+5)*100)/100,"%")
	end
	if t.Stat==7 then
	local index=Game.CurrentPlayer
	endurance2=Party[index]:GetEndurance()
	if endurance2<=21 then
		endEff=(endurance2-13)/2
	else
		endEff=math.floor(endurance2/5)
	end
	HPScaling=Game.Classes.HPFactor[Party[index].Class]
	skill=Party[index].Skills[const.Skills.Bodybuilding]
	s,m=SplitSkill(skill)
	if m==4 then
		m=5
	end
	BBHP=HPScaling*s*m+s^2
	fullHP=Party[index]:GetFullHP()
	enduranceTotalBonus=math.round(fullHP-fullHP/(1+endurance2/1000))+endEff*HPScaling
	level=Party[index]:GetLevel()
	BASEHP=Game.Classes.HPBase[Party[index].Class]+level*HPScaling
	t.Text=string.format("%s\n\nHP bonus from Endurance: %s\n\nHP bonus from Body building: %s\n\nHP bonus from items: %s\n\nBase HP: %s",t.Text,StrColor(0,255,0,enduranceTotalBonus), StrColor(0,255,0,BBHP),StrColor(0,255,0,math.round(fullHP-enduranceTotalBonus-BBHP-BASEHP)),StrColor(0,255,0,BASEHP))
	end
	if t.Stat==8 then
	local i=Game.CurrentPlayer
	local fullSP=Party[i]:GetFullSP()
	local skill=Party[i].Skills[const.Skills.Meditation]
	local s,m=SplitSkill(skill)
	if m==4 then
		m=5
	end
	local medRegen = math.round(fullSP^0.5*s^0.7*((m+5)/50))
	local SPregenItem=0
	local bonusregen=0
	for it in Party[i]:EnumActiveItems() do
		if it.Bonus2 == 38 or it.Bonus2==47 or it.Bonus2==55 then		
			SPregenItem=SPregenItem+1
			bonusregen=1
		end
	end
	SPregenItem=SPregenItem+bonusregen
	regen=math.ceil(fullSP*SPregenItem*0.005)+medRegen
	t.Text=string.format("%s\n\nSpell point regen per 10 seconds: %s",t.Text,StrColor(40,100,255,regen))
	end
	if t.Stat==9 then
	i=Game.CurrentPlayer
	ac=Party[i]:GetArmorClass()
	acReduction=math.round(1000-1000/(ac/300+1))/10
	t.Text=string.format("%s\n\nPhysical damage reduction from AC: %s%s",t.Text,StrColor(255,255,100,acReduction),StrColor(255,255,100,"%"))
	end
	if t.Stat==13 or t.Stat==14 then
		bolsterLevel8=vars.MM7LVL+vars.MM6LVL
		bolsterLevel7=vars.MM8LVL+vars.MM6LVL
		bolsterLevel6=vars.MM8LVL+vars.MM7LVL
		bolsterLevel8=math.max(bolsterLevel8*0.95-4,0)
		if bolsterLevel8>=120 then 
			bolsterLevel8=120+(bolsterLevel-120)/2
		end
		bolsterLevel7=math.max(bolsterLevel7*0.95-4,0)
		if bolsterLevel7>=120 then 
			bolsterLevel7=120+(bolsterLevel-120)/2
		end
		bolsterLevel6=math.max(bolsterLevel6*0.95-4,0)
		if bolsterLevel6>=120 then 
			bolsterLevel6=120+(bolsterLevel-120)/2
		end
		t.Text=t.Text .."\n\nLevels gained in MM6: " .. StrColor(255,255,153,math.round(vars.MM6LVL*100)/100) .. "\nLevels gained in MM7: " .. StrColor(255,255,153,math.round(vars.MM7LVL*100)/100) .. "\nLevels gained in MM8: " .. StrColor(255,255,153,math.round(vars.MM8LVL*100)/100) .. "\n\nBolster Level in MM6: " .. StrColor(255,255,153,math.round(bolsterLevel6)) .."\nBolster Level in MM7: " .. StrColor(255,255,153,math.round(bolsterLevel7)) .."\nBolster Level in MM8: " .. StrColor(255,255,153,math.round(bolsterLevel8))
	end
	if t.Stat>=19 and t.Stat<=24 then
		t.Text=t.Text .. "\n\nDamage is reduced by an amount equal to % shown above.\nMax resistance is 75%(beside immune status) and can be increased with some special enchants\n\nLight resistance is equal to the lowest between Mind and Body resistances.\nDark resistance is equal to the lowest between elemental resistances\nEnergy resistance is equal to the lowest resistance"
	end
end

function events.Regeneration(t)
	--HP
	if t.PlayerIndex<=Party.High then
		totHP=Party[t.PlayerIndex]:GetFullHP()
			for it in Party[t.PlayerIndex]:EnumActiveItems() do
				if it.Bonus2 == 37 or it.Bonus2==44 or it.Bonus2==50 or it.Bonus2==54 then			
					t.HP=t.HP+math.max(totHP*0.01-1,0)
				end
			end
		t.HP=math.round(t.HP)
		--SP
		totSP=Party[t.PlayerIndex]:GetFullSP()
			for it in Party[t.PlayerIndex]:EnumActiveItems() do
				if it.Bonus2 == 38 or it.Bonus2==47 or it.Bonus2==55 then		
					t.SP=t.SP+math.max(totSP*0.01-1,0)
				end
			end
		t.SP=math.round(t.SP)
	end
end


--resistance map
damageKindToMaxResistanceEnchant={
	[0] = 74,
	[1] = 75,
	[2] = 76,
	[3] = 77,
	[7] = 78,
	[8] = 79,
}

--reduce damage by %
function events.CalcDamageToPlayer(t)
	if t.DamageKind==0 or t.DamageKind==1 or t.DamageKind==2 or t.DamageKind==3 or t.DamageKind==7 or t.DamageKind==8 or t.DamageKind==9 or t.DamageKind==10 or t.DamageKind==12 then
		covered=false
		--check for shield
		local it=t.Player:GetActiveItem(0)
		local shield=t.Player.Skills[const.Skills.Shield]
		local s,m=SplitSkill(shield)
		if it and Game.ItemsTxt[it.Number].Skill~=8 and m<4 then
			local magicCoverChance={}
			local coverIndex=1
			--iterate for players to build cover dictionary
			for i=0,Party.High do
				if Party[i].Dead==0 and Party[i].Paralyzed==0 and Party[i].Unconscious==0 and Party[i].Stoned==0 and Party[i].Eradicated==0 then
					local it=Party[i]:GetActiveItem(0)
					if it and Game.ItemsTxt[it.Number].Skill==8 then 
						local shield=Party[i].Skills[const.Skills.Shield]
						local s,m=SplitSkill(shield)
						if m==4 then
							magicCoverChance[coverIndex]={p=0.15,index=i}
							coverIndex=coverIndex+1
						end
					end
				end
			end
			--roll once per player with player and pick the one with max hp
			coverPlayerIndex=-1
			if magicCoverChance[1] then
				lastMaxHp=0
				for i=1,#magicCoverChance do
					if Party[magicCoverChance[i].index].HP>lastMaxHp then
						local index=magicCoverChance[i]["index"]
						local p=magicCoverChance[i]["p"]
						if math.random()<p then
							lastMaxHp=Party[index].HP
							coverPlayerIndex=index
							covered=true
						end
					end
				end
			end
		end
			
		
		if not covered then
			for i=0,Party.High do
				if Party[i]:GetIndex()==t.Player:GetIndex() then
					coverPlayerIndex=i
				end
			end
		end
		--get resistances
		if t.DamageKind==0 then
			res=Party[coverPlayerIndex]:GetResistance(10)/4
		end
		if t.DamageKind==1 then
			res=Party[coverPlayerIndex]:GetResistance(11)/4
		end
		if t.DamageKind==2 then
			res=Party[coverPlayerIndex]:GetResistance(12)/4
			res2=0
		end
		if t.DamageKind==3 then
			res=Party[coverPlayerIndex]:GetResistance(13)/4
		end
		if t.DamageKind==7 then
			res=Party[coverPlayerIndex]:GetResistance(14)/4
		end
		if t.DamageKind==8 then
			res=Party[coverPlayerIndex]:GetResistance(15)/4
		end
		if t.DamageKind==9 then
			res=math.min(Party[coverPlayerIndex]:GetResistance(14),Party[coverPlayerIndex]:GetResistance(15))/4
		end
		if t.DamageKind==10 then
			res=math.min(Party[coverPlayerIndex]:GetResistance(10),Party[coverPlayerIndex]:GetResistance(11),Party[coverPlayerIndex]:GetResistance(12),Party[coverPlayerIndex]:GetResistance(13))/4
		end
		if t.DamageKind==12 then
			res=math.min(Party[coverPlayerIndex]:GetResistance(10),Party[coverPlayerIndex]:GetResistance(11),Party[coverPlayerIndex]:GetResistance(12),Party[coverPlayerIndex]:GetResistance(13),Party[coverPlayerIndex]:GetResistance(14),Party[coverPlayerIndex]:GetResistance(15))/4
		end
		--put here code to change max res
		maxres=75
		for it in Party[coverPlayerIndex]:EnumActiveItems() do
			if it.Bonus2==damageKindToMaxResistanceEnchant[t.DamageKind] then
				maxres=maxres+5+math.round(it.MaxCharges/8)
			elseif it.Bonus2==80 then
				maxres=maxres+2+math.round(it.MaxCharges/20)
			end
		end
		local it=Party[coverPlayerIndex]:GetActiveItem(0)
		if it and Game.ItemsTxt[it.Number].Skill==8 then 
			local shield=Party[coverPlayerIndex].Skills[const.Skills.Shield]
			local s,m=SplitSkill(shield)
			if m==4 then 
				maxres=maxres+0.25*s
			end
		end
		maxres=math.min(maxres,90)
		res=math.min(res,maxres)/100
		
		--fix for multiplayer
		local REMOTE_OWNER_BIT = 0x800
		local source = WhoHitPlayer()
		if source then
		local obj = source.Object
			if obj and bit.And(obj.Bits, REMOTE_OWNER_BIT) > 0 then
				return
			end
		end
		
		--randomize resistance
		local roll=(math.random()+math.random())/2
		if roll<0.5 then
			res=math.max(res-((1-res)*roll*2),0)
		else
			res=res+(1-res)/(roll*2)
		end
		
		--apply Damage
		t.Result = t.Damage * (1-res)
		data=WhoHitPlayer()
		if data and data.Monster and data.Object and data.Object.Spell<100 and data.Object.Spell>0 then
			dmgMult=(data.Monster.Level/15+1.5)*((data.Monster.Level^1.3-1)/1000+1)^2
			t.Result=t.Result*dmgMult
		end
		--actually substitute damage
		if covered then
			Party[coverPlayerIndex].HP=Party[coverPlayerIndex].HP-t.Result
			Game.ShowStatusText(string.format("%s protects %s",Party[coverPlayerIndex].Name,t.Player.Name))
			Party[coverPlayerIndex]:ShowFaceAnimation(24)
			t.Result=0
		end			
	end
end

--double resistance from items rating
function events.CalcStatBonusByItems(t)
	for it in t.Player:EnumActiveItems() do
		if t.Stat == const.Stats.FireResistance and it.Bonus==11 then
			t.Result = t.Result+it.BonusStrength
		end
		if t.Stat == const.Stats.AirResistance and it.Bonus==12 then
			t.Result = t.Result+it.BonusStrength
		end
		if t.Stat == const.Stats.WaterResistance and it.Bonus==13 then
			t.Result = t.Result+it.BonusStrength
		end
		if t.Stat == const.Stats.EarthResistance and it.Bonus==14 then
			t.Result = t.Result+it.BonusStrength
		end
		if t.Stat == const.Stats.MindResistance and it.Bonus==15 then
			t.Result = t.Result+it.BonusStrength
		end
		if t.Stat == const.Stats.BodyResistance and it.Bonus==16 then
			t.Result = t.Result+it.BonusStrength
		end
	end
	--add luck to resistances
	if t.Stat>=10 and t.Stat<=15 then
		luck=t.Player:GetLuck()
		if luck<=21 then
			luck=(luck-1)/2-6
		else
			luck=math.floor(luck/5)
		end
		t.Result=t.Result+luck
	end	
end








--TOOLTIPS
function events.Tick()
	if Game.CurrentCharScreen==100 and Game.CurrentScreen==7 then
		local i=Game.CurrentPlayer 
		if i==-1 then return end --prevent bug message
		fireRes=Party[i]:GetResistance(10)/4
		airRes=Party[i]:GetResistance(11)/4
		waterRes=Party[i]:GetResistance(12)/4
		earthRes=Party[i]:GetResistance(13)/4
		mindRes=Party[i]:GetResistance(14)/4
		bodyRes=Party[i]:GetResistance(15)/4

		--add bonus2
		for it in Party[Game.CurrentPlayer]:EnumActiveItems() do
			if it.Bonus2==1 then
				fireRes=fireRes+10/4
				airRes=airRes+10/4
				waterRes=waterRes+10/4
				earthRes=earthRes+10/4
				mindRes=mindRes+10/4
				bodyRes=bodyRes+10/4
			end
			if it.Bonus2==42 then
				fireRes=fireRes+1/4
				airRes=airRes+1/4
				waterRes=waterRes+1/4
				earthRes=earthRes+1/4
				mindRes=mindRes+1/4
				bodyRes=bodyRes+1/4
			end
			if it.Bonus2==50 then
				fireRes=fireRes+30/4
			end
		end
		if fireRes>=75 then
			fireRes=StrColor(0,255,0,"Max")
		end
		if airRes>=75 then
			airRes=StrColor(0,255,0,"Max")
		end
		if waterRes>=75 then
			waterRes=StrColor(0,255,0,"Max")
		end
		if earthRes>=75 then
			earthRes=StrColor(0,255,0,"Max")
		end
		if mindRes>=75 then
			mindRes=StrColor(0,255,0,"Max")
		end
		if bodyRes>=75 then
			bodyRes=StrColor(0,255,0,"Max")
		end		
		Game.GlobalTxt[87]=StrColor(255, 70, 70, string.format("Fire %s%s",fireRes,"%"))
		Game.GlobalTxt[6]=StrColor(173, 216, 230, string.format("Air %s%s",airRes,"%"))
		Game.GlobalTxt[240]=StrColor(100, 180, 255, string.format("Water %s%s",waterRes,"%"))
		Game.GlobalTxt[70]=StrColor(153, 76, 0, string.format("Earth %s%s",earthRes,"%"))
		Game.GlobalTxt[142]=StrColor(200, 200, 255, string.format("Mind %s%s",mindRes,"%"))
		Game.GlobalTxt[29]=StrColor(255, 192, 203, string.format("Body %s%s",bodyRes,"%"))	
		statsChanged=true
	elseif statsChanged and (Game.CurrentCharScreen~=100 or Game.CurrentScreen~=7) then
		Game.GlobalTxt[87]="Fire"
		Game.GlobalTxt[6]="Air"
		Game.GlobalTxt[240]="Water"
		Game.GlobalTxt[70]="Earth"
		Game.GlobalTxt[142]="Mind"
		Game.GlobalTxt[29]="Body"
		statsChanged=false
	end
end

function events.GetStatisticEffect(t)
	if t.Value >=25 then
		t.Result=math.floor(t.Value/5)
	end
end
