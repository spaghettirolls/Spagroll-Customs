--Necroidia Dread Magi
--Scripted by Beanbag

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.rfilter(c,tp)
	return c:IsSetCard(0x238C) and (c:IsControler(tp) or c:IsFaceup())
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.rfilter,2,false,aux.ReleaseCheckMMZ,nil,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.rfilter,2,2,false,aux.ReleaseCheckMMZ,nil,tp)
	Duel.Release(g,REASON_COST)
end
function s.setfilter(c)
	return c:IsSetCard(0x238C) and c:IsSpellTrap() and c:IsSSetable() and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>=2
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,2,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,2,2,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end