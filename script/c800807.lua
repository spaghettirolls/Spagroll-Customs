
--Nebulamia - Wormhole

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local params = {nil,nil,function(e,tp,mg) return nil,s.fcheck end}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.fscost)
	e2:SetTarget(Fusion.SummonEffTG(fusparam))
	e2:SetOperation(Fusion.SummonEffOP(fusparam))
	c:RegisterEffect(e2)
end

-- BANISH SUMMON

function s.spcostfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(0x3A5) and Duel.GetMZoneCount(tp,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3A5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--FUSION SUMMON COST

function s.fsfilter(c)
	return c:IsMonster() and c:IsSetCard(0x3A5) and c:IsAbleToDeckAsCost()
end

function s.fscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() and Duel.IsExistingMatchingCard(s.fsfilter,tp,LOCATION_REMOVED,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.fsfilter,tp,LOCATION_REMOVED,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end

function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard(0x3A5),1,nil)
end