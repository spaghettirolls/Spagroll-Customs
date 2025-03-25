--Solunaris Tribunal
--Scripted by BeanBag
local s,id=GetID()
function s.initial_effect(c)
Gemini.AddProcedure(c)
c:EnableReviveLimit()
local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.dcost)
	e2:SetTarget(s.dtg)
	e2:SetOperation(s.dop)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

function s.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.shuflfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,s.shuflfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,s.shoflfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g1:Merge(g2)
	Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.shuflfilter(c)
	return c:IsCode(900901) and c:IsAbleToDeckAsCost()
end
function s.shoflfilter(c)
	return c:IsSetCard(0x4D3) and c:IsRitualMonster() and c:IsAbleToDeckAsCost()
end

function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsMonster()
end
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	Duel.Destroy(g,REASON_EFFECT)
end

function s.spcfilter(c)
	return c:IsCode(900901) and c:IsAbleToGraveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
		and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.spfilter(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_RITUAL)
	return #pg<=0 and c:IsSetCard(0x4D3) and c:IsRitualMonster() and c:IsLevelBelow(6)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end
