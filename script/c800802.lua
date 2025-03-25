
-- Nebulamia - Cataclysm

local s,id=GetID()
function s.initial_effect(c)
local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.bcost)
	e2:SetTarget(s.btg)
	e2:SetOperation(s.bop)
	c:RegisterEffect(e2)
	local params={fusfilter=s.fusfilter,matfilter=Card.IsAbleToRemove,extrafil=s.fextra,extraop=Fusion.BanishMaterial,extratg=s.extratg}
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCost(s.fscost)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(Fusion.SummonEffTG(params))
	e4:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e4)
end

-- ACTIVATION EFFECT:

	s.listed_series={0x3A5}

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3A5) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsType(TYPE_FUSION+TYPE_XYZ)
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,nil,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
		end


-- IGNITION BANISH/TOPDECK EFFECT:

s.listed_series={0x3A5}
function s.bcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    if chk==0 then return tc and tc:IsAbleToRemoveAsCost() end
    Duel.Remove(tc,POS_FACEUP,REASON_COST)
    e:SetLabelObject(tc)
end

function s.banfilter(c)
	return c:IsSetCard(0x3A5) and c:IsMonster()
end

function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.bop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
	end
end


-- FUSION SHUFFLE EFFECT:

function s.fusfilter(c)
	return c:IsType(TYPE_FUSION)
end

function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToDeckAsCost()
end

function s.fscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_REMOVED,0,2,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_REMOVED,0,2,2,c)
	g:AddCard(c)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end

function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE)
end