--Holysphere Guardian Saviour

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeRitualSummoned()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(s.descon)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	e3:SetCondition(s.indcon)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.efilter)
	e4:SetCondition(s.immcon)
	c:RegisterEffect(e4)
    local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.fdtg)
	e5:SetOperation(s.fdop)
	c:RegisterEffect(e5)
end
s.listed_names={999001}
function s.mat_filter(c)
	return not c:IsCode(id)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.filter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x270F) and c:IsMonster() and not c:IsCode(999000)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	local c=e:GetHandler()
	local ct=c:IsRitualSummoned() and c:GetMaterialCount() or 0
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
	local ct=e:GetHandler():GetMaterialCount()
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)>=3
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)>=6
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_MONSTER+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.fdfilter(c)
    return c:IsFaceup() and c:IsCanTurnSet()
end
function s.fdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.fdfilter(chkc) end
    local g1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local g2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
    local ct= math.abs(g1-g2)
    if chk==0 then return ct>0 and Duel.IsExistingTarget(s.fdfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.fdfilter,tp,0,LOCATION_MZONE,1,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.fdfilter,nil,e)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end