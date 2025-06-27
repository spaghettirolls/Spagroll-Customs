--Toon Recovery
--Scipted by Beanbag

local s,id=GetID()
function s.initial_effect(c)
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetCountLimit(1,{id,1})
e1:SetCost(s.cost)
e1:SetTarget(s.addtg)
e1:SetOperation(s.addop)
c:RegisterEffect(e1)
local params = {fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_TOON),matfilter=aux.FALSE,extrafil=s.fextra,
extraop=Fusion.BanishMaterial,gc=Fusion.ForcedHandler,extratg=s.extratarget}
local e2=Effect.CreateEffect(c)
e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
e2:SetType(EFFECT_TYPE_IGNITION)
e2:SetRange(LOCATION_GRAVE)
e2:SetCountLimit(1,id)
e2:SetTarget(Fusion.SummonEffTG(params))
e2:SetOperation(Fusion.SummonEffOP(params))
c:RegisterEffect(e2)
end
s.listed_series={SET_TOON}

function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),0,tp,LOCATION_GRAVE)
end

function s.addfilter(c)
	return c:IsSetCard(0x98) and c:IsMonster() and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.addfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(s.addfilter,tp,LOCATION_GRAVE,0,nil)
		if #g<2 then return end
		local thg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
		if #thg>0 then
			Duel.SendtoHand(thg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,thg)
	end
end