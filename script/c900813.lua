--Poltiquette Etherealier
--Scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,s.matfilter,3,99)
local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.sucop)
	c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(s.tgval)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
function s.tgval(e,c)
	return c:IsFaceup() and c:IsContinuousTrap() and c:IsSetCard(0x3D4)
end
function s.matfilter(c,fc,sumtype,tp)
	return c:IsSpellTrap(fc,sumtype,tp) and c:IsSetCard(0x3D4,fc,sumtype,tp)
end
function s.sucop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_FUSION) then return end
	--Its original ATK/DEF become the number of Fusion Materials x 500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(c:GetMaterialCount()*500)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.desfilter(c)
	return c:IsSetCard(0x3D4) and c:IsTrap() and c:IsType(TYPE_CONTINUOUS)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,nil):GetClassCount(Card.GetCode)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.setfilter(c)
	return c:IsSetCard(0x3D4) and c:IsContinuousTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>=2
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,2,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,2,2,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end