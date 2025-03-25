
-- Nebulamia - Hive Seer Caitloruz

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
		local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.fcon)
	e3:SetTarget(s.ftg)
	e3:SetOperation(s.fop)
	c:RegisterEffect(e3)
end

-- SUMMON ADD

function s.filter(c)
	return c:IsSetCard(0x3A5) and not c:IsCode(800806) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- FUSION MATERIAL

function s.fcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_FUSION
end

function s.thfilter(c)
	return c:IsSetCard(0x3A5)
end

function s.ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.fop(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	local b1=tc:IsAbleToGrave()
	local b2=true
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	if op==2 then return end
	if op==0 then
		Duel.DisableShuffleCheck()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		Duel.SendtoGrave(tc,REASON_EFFECT)
	else
		Duel.DisableShuffleCheck()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
	end
end