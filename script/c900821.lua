local s,id=GetID()
function s.initial_effect(c)
	--discard to send 1 "Poltiquette" Spell/trap from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsSpellTrap() and c:IsSetCard(0x3D4) and c:IsAbleToGrave()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x3D4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
		Duel.BreakEffect()
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if Duel.SendtoGrave(g,REASON_EFFECT) and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
end