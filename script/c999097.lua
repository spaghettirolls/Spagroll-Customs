--Necroidia Charge - Wrath of the Decayed
--Scripted by Beanbag
local s,id=GetID()
Duel.LoadScript('BeanbagsAux.lua')
function s.initial_effect(c)
	--Activate turn Set
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetCondition(function(e,c) return Duel.HasFlagEffect(e:GetHandlerPlayer(),id) end)
	c:RegisterEffect(e0)
	--Negate Spell/Trap or effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DRAW+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Banish and Special Summon
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Register Tributed this turn
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_RELEASE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousSetCard(SET_NECROIDIA) or (c:IsMonster() and not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsSetCard(SET_NECROIDIA))
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.checkfilter,nil)
	if g:IsExists(Card.IsPreviousControler,1,nil,0) then
		Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
	end
	if g:IsExists(Card.IsPreviousControler,1,nil,1) then
		Duel.RegisterFlagEffect(1,id,RESET_PHASE|PHASE_END,0,1)
	end
end

--Negate S/T Effects
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) or re:IsMonsterEffect() or re:IsSpellTraprEffect()) and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,SET_NECROIDIA)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tribfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,nil)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE|LOCATION_HAND)
end
function s.tribfilter(c)
	return c:IsSetCard(SET_NECROIDIA) and c:IsMonster() and c:IsReleasableByEffect()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tribfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,nil)
	if Duel.NegateActivation(ev) then
		if Duel.Draw(tp,1,REASON_EFFECT)>0 and #g>0 then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local rg=Duel.SelectMatchingCard(tp,tribfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,1,1,nil)
			if #rg>0 then
				Duel.BreakEffect()
				Duel.Release(rg,REASON_EFFECT)
			end
		end
	end
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NECROIDIA) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end