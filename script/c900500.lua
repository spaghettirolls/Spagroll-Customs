--Fisherman of the Deepest Blue
--scripted by beanbag

local s,id=GetID()
function s.initial_effect(c)
	--Always treated as "The Legendary Fisherman"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetRange(LOCATION_ALL)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetValue(3643300) -- The Legendary Fisherman
	c:RegisterEffect(e0)

	--Place Umi & Special Summon itself (from hand)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.umicon)
	e1:SetTarget(s.umitarget)
	e1:SetOperation(s.umiop)
	c:RegisterEffect(e1)

	--Cannot be targeted for attacks or opponent's effects while Umi is on field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetCondition(s.umiconfield)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.umiconfield)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

	--Quick Effect: Special Summon Fish monster(s)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,0})
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)

	--End Phase: Both players recycle 1 Fish and then Special Summon 1 Fish
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.endtg)
	e5:SetOperation(s.endop)
	c:RegisterEffect(e5)
end

-----------------------------------
-- Umi Check
-----------------------------------
function s.umicon(e,tp,eg,ep,ev,re,r,rp)
	return true
end
function s.umifilter(c)
	return c:IsCode(22702055) and c:IsFieldSpell()
end
function s.umitarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false)
	end
end
function s.umiop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Place Umi from hand, Deck, or GY
	local g=Duel.SelectMatchingCard(tp,s.umifilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
	end
	--Special Summon this card
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end

-----------------------------------
-- While Umi is on field
-----------------------------------
function s.umiconfield(e)
	return Duel.IsEnvironment(22702055)
end

-----------------------------------
-- Quick Effect: Fish Summon
-----------------------------------
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct = Duel.IsEnvironment(22702055) and 2 or 1
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,ct,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct = Duel.IsEnvironment(22702055) and 2 or 1
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<ct then return end
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,ct,ct,nil,e,tp)
	if #g>0 then
		for tc in aux.Next(g) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	end

	--Lock non-Fish summon for rest of turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsRace(RACE_FISH) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-----------------------------------
-- End Phase effect for both players
-----------------------------------
function s.endfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToDeckAsCost()
end
function s.spfilter2(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.endtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.endop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		--Recycle 1 Fish
		local g=Duel.SelectMatchingCard(p,s.endfilter,p,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end

	--Then each player Special Summons 1 Fish
	for p=0,1 do
		if Duel.GetLocationCount(p,LOCATION_MZONE)>0 then
			local g=Duel.SelectMatchingCard(p,s.spfilter2,p,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,p)
			if #g>0 then
				Duel.SpecialSummon(g:GetFirst(),0,p,p,false,false,POS_FACEUP)
			end
		end
	end
end