local s,id=GetID()
function s.initial_effect(c)
local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(s.xyzcost)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end

function s.thfilter(c)
	return c:IsSetCard(0x3A5) and c:IsAbleToHand() and not c:IsCode(800804)
end

function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3A5) and c:IsMonster() and c:IsAbleToRemove()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED+LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x3A5)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED+LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
		local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=g:Select(tp,1,1,nil)
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)

	end
end
end


-- XYZ SUMMON EFFECT:

function s.xfilter(c)
	return c:IsMonster() and c:IsAbleToDeckAsCost()
end


function s.xyzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() and Duel.IsExistingMatchingCard(s.xfilter,tp,LOCATION_REMOVED,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.xfilter,tp,LOCATION_REMOVED,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end

function s.xyzfilter(c)
	return c:IsSetCard(0x3A5) and c:IsXyzSummonable()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=g:Select(tp,1,1,nil)
		Duel.XyzSummon(tp,tg:GetFirst())
	end
end