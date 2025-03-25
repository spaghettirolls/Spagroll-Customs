--Solunaris Pyrewalker
--Scripted by BeanBag
local s,id=GetID()
function s.initial_effect(c)
Gemini.AddProcedure(c)
c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.scost)
	e1:SetTarget(s.stg)
	e1:SetOperation(s.sop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_GEMINI_STATUS)
    e2:SetCondition(Gemini.EffectStatusCondition)
	e2:SetCost(s.gycost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	e2:SetCountLimit(1,{id,1})
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(Gemini.EffectStatusCondition)
	e3:SetCost(s.spsumcost)
	e3:SetTarget(s.spsumtg)
	e3:SetOperation(s.spsumop)
	e3:SetCountLimit(1,{id,2})
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e3)
end
---------------------------------------------------------------------------------------------------------------------------------------
-- HAND TRIGGER COST--
---------------------------------------------------------------------------------------------------------------------------------------
function s.sfilter(c)
	return c:IsCode(900901) and c:IsAbleToGraveAsCost()
end
function s.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST)
end
---------------------------------------------------------------------------------------------------------------------------------------
-- HAND TRIGGER TARGET --
---------------------------------------------------------------------------------------------------------------------------------------
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4D3) and c:IsType(TYPE_GEMINI) and not c:IsGeminiStatus()
end
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsSpellTrap() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
---------------------------------------------------------------------------------------------------------------------------------------
-- HAND TRIGGER OPERATION --
---------------------------------------------------------------------------------------------------------------------------------------
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------
-- GEMINI EFFECT SPECIAL SUMMON FROM GY COST --
---------------------------------------------------------------------------------------------------------------------------------------
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.shufflefilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.shufflefilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.shufflefilter(c)
	return c:IsCode(900901) and c:IsAbleToDeckAsCost()
end
---------------------------------------------------------------------------------------------------------------------------------------
-- GEMINI EFFECT SPECIAL SUMMON FROM GY TARGET --
---------------------------------------------------------------------------------------------------------------------------------------
function s.gyfilter(c,e,tp)
	return c:IsSetCard(0x4D3) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
---------------------------------------------------------------------------------------------------------------------------------------
-- GEMINI EFFECT SPECIAL SUMMON FROM GY OPERATION --
---------------------------------------------------------------------------------------------------------------------------------------
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------
-- GEMINI EFFECT SPECIAL SUMMON FROM DECK COST --
---------------------------------------------------------------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------------------------------------------------------------
-- GEMINI EFFECT SPECIAL SUMMON FROM DECK TARGET --
---------------------------------------------------------------------------------------------------------------------------------------
function s.spsumfilter(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_RITUAL)
	return #pg<=0 and c:IsSetCard(0x4D3) and c:IsRitualMonster() --[[and not c:IsCode(id)]]
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false,POS_FACEUP)
end
function s.spsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spsumfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
---------------------------------------------------------------------------------------------------------------------------------------
-- GEMINI EFFECT SPECIAL SUMMON FROM DECK OPERATION --
---------------------------------------------------------------------------------------------------------------------------------------
function s.spsumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spsumfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end