--F.A. Ace Driver
local s,id=GetID()
function s.initial_effect(c)
	--Effect 1: Treat as non-Tuner for Machine Synchro
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(function(e,sc)
		return sc and sc:IsType(TYPE_SYNCHRO) and sc:IsRace(RACE_MACHINE)
	end)
	c:RegisterEffect(e1)

	--Effect 2: Special Summon from hand if "F.A." Field Spell exists
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	--Effect 3: Special Summon "F.A." monster from Deck when destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end

--======== Effect 2 Helpers ========

--Check for "F.A." Field Spell
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_FA),tp,LOCATION_FZONE,0,1,nil)
end

--Hand Special Summon target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

--Filter for F.A. card to destroy (exclude itself)
function s.fa_destroy_filter(c)
	return c:IsSetCard(SET_FA) and c:IsDestructable() and not c:IsCode(id)
end

--Hand Special Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end

	if Duel.IsExistingMatchingCard(s.fa_destroy_filter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,s.fa_destroy_filter,tp,LOCATION_ONFIELD,0,1,1,nil)
		if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
			local op=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
			local lvchange=Effect.CreateEffect(c)
			lvchange:SetType(EFFECT_TYPE_SINGLE)
			lvchange:SetCode(EFFECT_UPDATE_LEVEL)
			lvchange:SetValue(op==0 and 1 or -1)
			lvchange:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(lvchange)
		end
	end
end

--======== Effect 3 Helpers ========

--Trigger only if destroyed from field
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and (r&REASON_BATTLE~=0 or r&REASON_EFFECT~=0)
end

--Filter for "F.A." monster in Deck excluding itself
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_FA) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--Target for Deck Special Summon
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

--Operation for Deck Special Summon
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			local lvchange=Effect.CreateEffect(e:GetHandler())
			lvchange:SetType(EFFECT_TYPE_SINGLE)
			lvchange:SetCode(EFFECT_UPDATE_LEVEL)
			lvchange:SetValue(2)
			lvchange:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(lvchange)
		end
	end
end