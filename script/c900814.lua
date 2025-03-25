--Poltiquette, Accursed Lord
--Scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--fusion material
	Fusion.AddProcMixRep(c,true,true,s.matfilter,3,99)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.sucop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.negcost)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3D4))
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e4:SetTarget(s.fstg)
	e4:SetOperation(s.fsop)
	c:RegisterEffect(e4)
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
	e1:SetValue(c:GetMaterialCount()*1000)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
end


function s.negcostfilter(c,tp)
	return c:IsSetCard(0x3D4) and c:IsTrap() and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToDeckAsCost()
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.negcostfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,c)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
    if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
function s.tdfilter(c)
	return c:IsSetCard(0x3D4) and c:IsSpellTrap() and c:IsAbleToDeck()
end
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		local ct=#Duel.GetOperatedGroup()
		if ct>0 then Duel.ShuffleDeck(tp) end
		if ct==#g then
			Duel.BreakEffect()
			Duel.Draw(tp,ct,REASON_EFFECT)
		end
	end
end