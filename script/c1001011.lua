--Maelstrom Bonds
local s,id=GetID()

function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--GY effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end

---------------------------------------------------
-- FILTERS
---------------------------------------------------

function s.deckfilter(c,e,tp)
	return c:IsSetCard(0x2B67)
		and c:IsMonster()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.gyfilter(c,e,tp)
	return c:IsSetCard(0x2B67)
		and c:IsMonster()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

---------------------------------------------------
-- ACTIVATE TARGET
---------------------------------------------------

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local dg=Duel.GetMatchingGroup(s.deckfilter,tp,LOCATION_DECK,0,nil,e,tp)
		local gg=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
			and dg:IsExists(function(dc)
				return gg:IsExists(function(c)
					return not c:IsCode(dc:GetCode())
				end,1,nil)
			end,1,nil)
	end
end

---------------------------------------------------
-- MAIN OPERATION
---------------------------------------------------

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end

	--Deck monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.deckfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc1=g1:GetFirst()
	if not tc1 then return end

	--GY monster (different name)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectMatchingCard(tp,
		function(c,e,tp,code)
			return s.gyfilter(c,e,tp) and not c:IsCode(code)
		end,
		tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tc1:GetCode())

	if #g2==0 then return end

	local sg=g1+g2

	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=2 then return end

	Duel.BreakEffect()

	---------------------------------------------------
	-- MATERIAL POOL (ALL FACE-UP MAELSTROM)
	---------------------------------------------------
	local mg=Duel.GetMatchingGroup(function(c)
		return c:IsFaceup() and c:IsSetCard(0x2B67)
	end,tp,LOCATION_MZONE,0,nil)

	---------------------------------------------------
	-- SYNCHRO LIST
	---------------------------------------------------
	local synchros=Duel.GetMatchingGroup(function(c)
		return c:IsSetCard(0x2B67)
			and c:IsType(TYPE_SYNCHRO)
			and c:IsSynchroSummonable(nil,mg)
	end,tp,LOCATION_EXTRA,0,nil)

	---------------------------------------------------
	-- XYZ LIST
	---------------------------------------------------
	local xyzs=Duel.GetMatchingGroup(function(c)
		return c:IsSetCard(0x2B67)
			and c:IsType(TYPE_XYZ)
			and c:IsXyzSummonable(nil,mg)
	end,tp,LOCATION_EXTRA,0,nil)

	local b1=#synchros>0
	local b2=#xyzs>0

	if not (b1 or b2) then return end

	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end

	local op=0

	if b1 and b2 then
		op=Duel.SelectOption(tp,
			aux.Stringid(id,3),
			aux.Stringid(id,4))
	elseif b2 then
		op=1
	end

	---------------------------------------------------
	-- SYNCHRO
	---------------------------------------------------
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=synchros:Select(tp,1,1,nil):GetFirst()
		if sc then
			Duel.SynchroSummon(tp,sc,nil,mg)
		end
		return
	end

	---------------------------------------------------
	-- XYZ
	---------------------------------------------------
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=xyzs:Select(tp,1,1,nil):GetFirst()
	if sc then
		Duel.XyzSummon(tp,sc,nil,mg)
	end
end

---------------------------------------------------
-- GY EFFECT
---------------------------------------------------

function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if not re then return false end
	if not re:GetHandler() then return false end

	local rc=re:GetHandler()

	return c:IsReason(REASON_EFFECT)
		and rc:IsSetCard(0x2B67)
		and rc~=c
		and rc:GetCode()~=id
end

function s.tdfilter(c)
	return c:IsSetCard(0x2B67)
		and c:IsAbleToDeck()
		and not c:IsCode(id)
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
			and Duel.IsPlayerCanDraw(tp,1)
	end
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)

	if #g==0 then return end

	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if ct>0 then
		Duel.ShuffleDeck(tp)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end