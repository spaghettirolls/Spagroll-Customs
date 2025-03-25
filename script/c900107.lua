--Magmalith Tephrite
--scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
	--Xyz summon
Xyz.AddProcedure(c,s.matfilter,3,3,nil,nil,nil,nil,true)
	c:EnableReviveLimit()
	--Tribute to banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.xcon1)
    e1:SetCost(s.xcost)
	e1:SetTarget(s.xtg)
	e1:SetOperation(s.xop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.dxmcostgen(2,2,nil))
	e2:SetCondition(s.chcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.matfilter(c,xyz,sumtype,tp)
	return c:IsRace(RACE_ROCK,xyz,sumtype,tp) and c:IsAttribute(ATTRIBUTE_FIRE,xyz,sumtype,tp)
end

--TRIBUTE TO SUMMON

function s.xcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.xfilter(c,tp)
	return c:IsSetCard(0x385) and c:IsMonster() and c:IsReleasable() and not c:IsCode(id)
end
function s.xcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.xfilter,1,true,nil,nil,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.xfilter,1,1,true,nil,nil,tp)
	Duel.Release(g,REASON_COST)
end
function s.xfilter2(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x385) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.xfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.xop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- DETACH EFFECT

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.shfilter(c,tp)
	return c:IsSetCard(0x385) and c:IsMonster() and c:IsReleasable() and not c:IsCode(id)
end

function s.shuffilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToDeck()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,REASON_EFFECT)
	end
end

--TRIBUTED EFFECT

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RELEASE) and e:GetHandler():GetOverlayCount()>0
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x385) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if #g<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,2,2,nil)
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end