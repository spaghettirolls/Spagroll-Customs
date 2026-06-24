--Maelstrom Intel
local s,id=GetID()

function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)

	--Special Summon from hand or face-up banished
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	--Add a Maelstrom Spell/Trap from GY to hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

s.listed_series={0x2B67}

--When activated: Send top 3 cards of your Deck to the GY
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end

--If a Maelstrom card is sent from Deck to GY
function s.cfilter(c,tp)
	return c:IsSetCard(0x2B67)
		and c:IsPreviousLocation(LOCATION_DECK)
		and c:IsControler(tp)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x2B67)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(
				s.spfilter,tp,
				LOCATION_HAND+LOCATION_REMOVED,0,
				1,nil,e,tp
			)
	end
	Duel.SetOperationInfo(
		0,
		CATEGORY_SPECIAL_SUMMON,
		nil,
		1,
		tp,
		LOCATION_HAND+LOCATION_REMOVED
	)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	local g=Duel.GetMatchingGroup(
		s.spfilter,tp,
		LOCATION_HAND+LOCATION_REMOVED,0,
		nil,e,tp
	)

	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

--If sent to GY by a Maelstrom card effect, except itself
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re
		and re:GetHandler():IsSetCard(0x2B67)
		and re:GetHandler():GetCode()~=id
end

function s.thfilter(c)
	return c:IsSetCard(0x2B67)
		and c:IsSpellTrap()
		and not c:IsCode(id)
		and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
			and chkc:IsControler(tp)
			and s.thfilter(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(
			s.thfilter,tp,
			LOCATION_GRAVE,0,
			1,nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(
		tp,s.thfilter,tp,
		LOCATION_GRAVE,0,
		1,1,nil
	)

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end