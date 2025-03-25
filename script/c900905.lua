--Solunaris Purifyre
--Scripted by BeanBag
local s,id=GetID()
function s.initial_effect(c)
Gemini.AddProcedure(c)
c:EnableReviveLimit()
local e4=Ritual.CreateProc(c,RITPROC_GREATER,aux.FilterBoolFunction(Card.IsSetCard,0x4D3),nil,aux.Stringid(id,2),nil,nil,nil,nil,nil,function(e,tp,g,sc)return not g:IsContains(e:GetHandler()), g:IsContains(e:GetHandler())  end)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_HAND)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.scost)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_GEMINI_STATUS)
    e5:SetCondition(Gemini.EffectStatusCondition)
	e5:SetCost(s.acost)
	e5:SetTarget(s.atg)
	e5:SetOperation(s.aop)
	e5:SetCountLimit(1,{id,1})
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetCondition(Gemini.EffectStatusCondition)
	e6:SetCost(s.spsumcost)
	e6:SetTarget(s.spsumtg)
	e6:SetOperation(s.spsumop)
	e6:SetCountLimit(1,{id,2})
	e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e6)
end


--HAND TRIGGER EFFECT:

function s.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.sfilter(c)
	return c:IsCode(900901) and c:IsAbleToGraveAsCost()
end

--GEMINI EFFECT 1:

function s.acost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.addfilter(c)
	return c:IsCode(900901) and c:IsAbleToDeckAsCost()
end
function s.addingfilter(c)
	return c:IsSetCard(0x4D3) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.atg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addingfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.aop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addingfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--SHUFFLE SPECIAL

function s.spfilter(c)
	return c:IsCode(900901) and c:IsAbleToDeckAsCost()
end

function s.spsumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end

function s.spsumfilter(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_RITUAL)
	return #pg<=0 and c:IsSetCard(0x4D3) and c:IsRitualMonster() and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false,POS_FACEUP)
end
function s.spsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spsumfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spsumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spsumfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end