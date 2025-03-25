--Magmalith Nephenilite
--scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
	--Xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ROCK),3,2)
	c:EnableReviveLimit()
	--Add from GY to hand
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
	--Change a monster effect to "Tribute 1" monster they control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.dxmcostgen(2,2,nil))
	e2:SetCondition(s.chcon)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
    --Tributed = Special Summon 2 
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

--EFF1

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
function s.xfilter2(c)
	return c:IsSetCard(0x385) and c:IsMonster() and c:IsAbleToHand()
end
function s.xtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.xfilter2,tp,LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,LOCATION_GRAVE)
end
function s.xop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.xfilter2,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end

-- EFF 2

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return Duel.IsChainNegatable(ev) and Duel.GetTurnPlayer()~=tp
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_MZONE,0,1,nil) end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.Release(g,REASON_EFFECT)
	end
end

-- EFF 3

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
