--Solunaris Azuranthis
--Scripted by Beanbag	

local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.bcost)
	e1:SetTarget(s.btg)
	e1:SetOperation(s.bop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.negcon,Gemini.EffectStatusCondition)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
		aux.GlobalCheck(s,function()
		s.type_list={}
		s.type_list[0]=0
		s.type_list[1]=0
		aux.AddValuesReset(function()
				s.type_list[0]=0
				s.type_list[1]=0
			end)
		end)
end

--SEND RITUAL SPELL THEN BANISH
function s.bcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.bfilter,tp,LOCATION_DECK,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.bfilter,tp,LOCATION_DECK,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.bfilter(c)
	return c:IsCode(900901) and c:IsAbleToGraveAsCost()
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

-- GEMINI NEGATE EFFECT

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.negfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
 Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and s.type_list[tp]&re:GetActiveType()==0
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.type_list[tp]=s.type_list[tp]|(re:GetActiveType()&(TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP))
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negfilter(c)
	return c:IsCode(900901) and c:IsAbleToDeckAsCost()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
	Duel.Destroy(eg,REASON_EFFECT) 
	end
end