--Magmalith Eruption
--scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCondition(s.con)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.bantg)
	e2:SetOperation(s.banop)
	e2:SetCost(aux.bfgcost)
    c:RegisterEffect(e2)
end
function s.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x385) and c:IsType(TYPE_XYZ)
end
function s.filter2(c)
	return c:IsFaceup() and c:IsCode(900110)
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,2,nil)
	or Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	Duel.Release(g,REASON_EFFECT)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x385) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE|LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.trfilter(c)
	return c:IsSetCard(0x385) and c:IsMonster() and c:IsReleasableByEffect()
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.trfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,1,1,nil)
	if #g>0 then
	Duel.BreakEffect()
	Duel.Release(g,REASON_EFFECT)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		end
	end
end