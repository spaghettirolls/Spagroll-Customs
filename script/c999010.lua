--Holysphere Kindred
--scripted by Beanbag

local s,id=GetID()
function s.initial_effect(c)
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetCountLimit(1,id)
e1:SetTarget(s.thtg)
e1:SetOperation(s.thop)
c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
e2:SetDescription(aux.Stringid(id,0))
e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
e2:SetType(EFFECT_TYPE_IGNITION)
e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
e2:SetRange(LOCATION_GRAVE)
e2:SetCountLimit(1,{id,1})
e2:SetCost(aux.SelfBanishCost)
e2:SetTarget(s.sptg)
e2:SetOperation(s.spop)
c:RegisterEffect(e2)
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x270F) and (c:IsMonster() or c:IsSpell() and not c:IsCode(id)) 
end
function s.rescon(sg)
	return sg:FilterCount(Card.IsMonster,nil)==1
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g<2 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #rg>0 then
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,rg)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x270F) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.rescon2(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==2
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,e,tp)
	if #g<2 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon2,1,tp,HINTMSG_SPSUMMON)
	if #sg==2 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end