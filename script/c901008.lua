--Psychic Rose's Poison
local s,id=GetID()
function s.initial_effect(c)
	--Activate (condition: "Psychic Rose" monster in MZONE or GY)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(s.actcon)
	c:RegisterEffect(e0)

	--Unaffected by opponent hand/GY effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.immtg)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)

	--Negate effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	--Synchro Summon (LEGAL)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE+LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.syncon)
	e3:SetCost(s.syncost)
	e3:SetTarget(s.syntg)
	e3:SetOperation(s.synop)
	c:RegisterEffect(e3)
end

--"Psychic Rose" check
function s.rosefilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1A0A)
end

--Activation condition
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.rosefilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end

--Immunity target
function s.immtg(e,c)
	return c:IsFaceup() and (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT)) and c:IsType(TYPE_SYNCHRO)
end

--Immune to opponent hand/GY effects
function s.immval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
		and (re:GetActivateLocation()==LOCATION_HAND or re:GetActivateLocation()==LOCATION_GRAVE)
end

--Negate condition
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

--Tribute cost
function s.cfilter(c)
	return c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end

--Target negate
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsNegatable),tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsNegatable),tp,0,LOCATION_ONFIELD,1,1,nil)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end

--Synchro condition
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

--Banish as cost
function s.syncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

--Synchro Target
function s.synfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO)
		and (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT))
		and c:IsSynchroSummonable()
end

function s.matfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsMonster()
end

function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
			and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

--Synchro Operation (LEGAL)
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) then return end

	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:Select(tp,1,99,nil)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local sc=sg:Select(tp,1,1,nil):GetFirst()

	if sc then
		Duel.SendtoGrave(tg,REASON_EFFECT+REASON_MATERIAL+REASON_SYNCHRO)
		Duel.BreakEffect()
		Duel.SynchroSummon(tp,sc,tg)
	end
end