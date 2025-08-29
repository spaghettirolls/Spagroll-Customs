local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 "Poltibussy" monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x3D4),2)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Return to hand and Set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Return to hand and Set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--inactivatable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISEFFECT)
	e1:SetValue(s.effectfilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetValue(s.effectfilter)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	--inactivatable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.efftg)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1),nil)
end
function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local tc=te:GetHandler()
	return p==tp and tc:IsSpellTrap() and te:IsActiveType(TYPE_SPELL|TYPE_TRAP) and tc:IsSetCard(0x3D4)
end

--Fusion Summons Cannot be Negated
function s.efftg(e,c)
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsSetCard(0x3D4) and c:IsFusionMonster()
end

function s.thconfilter(c,tp)
	return (c:GetReasonPlayer()==1-tp or c:IsReason(REASON_BATTLE)) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x3D4) and c:IsPreviousTypeOnField(TYPE_FUSION)
	and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thconfilter,1,e:GetHandler(),tp)
end

function s.spconfilter(c)
	return c:IsSetCard(0x3D4) and c:IsFaceup() and c:IsFusionMonster()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil)
end

function s.rthfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3D4) and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToHand()
end

function s.setfilter(c,code)
	return c:IsSetCard(0x3D4) and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and not c:IsCode(code) and c:IsSSetable(true)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rthfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g1=Duel.SelectMatchingCard(tp,s.rthfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	local tc=g1:GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		local g2=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND,0,nil,tc:GetCode())
		if #g2>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:IsLocation(LOCATION_HAND) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g2:Select(tp,1,1,nil)
			Duel.SSet(tp,sg:GetFirst())
		end
	end
end
