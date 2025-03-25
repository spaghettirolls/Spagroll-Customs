
-- Nebulamia - Hive Sentry Xivutrei


local s,id=GetID()
function s.initial_effect(c)
local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.bcost)
	e1:SetOperation(s.bop)
c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.fcon)
    e2:SetTarget(s.ftg)
    e2:SetOperation(s.fop)
c:RegisterEffect(e2)
end

--BANISH TOP 2 DECK

function s.bfilter(c)
	return c:IsSetCard(0x3A5) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function s.bcostfilter(c)
	return s.bfilter(c) and c:IsAbleToRemoveAsCost()
end

function s.bcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.bcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.bcostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.bop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetDecktopGroup(tp,2)
    local tc=g:GetFirst()
    if chk==0 then return tc and tc:IsAbleToRemove() end
    Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    e:SetLabelObject(tc)
end

-- FUSION SENT EFFECT:

function s.fcon(e,tp,eg,ep,ev,re,r,rp)
 return r==REASON_FUSION and e:GetHandler():IsLocation(LOCATION_GRAVE)
end

function s.ffilter(c)
	return c:IsSetCard(0x3A5) and c:IsMonster() and not c:IsCode(800803) and c:IsAbleToHand()
end
function s.ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.fop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
