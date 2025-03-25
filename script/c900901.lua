local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
	Ritual.AddProcGreater({handler=c,filter=s.ritualfil,lvtype=RITPROC_GREATER,sumpos=POS_FACEUP,location=LOCATION_HAND+LOCATION_GRAVE})
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_GEMINI))
	e1:SetCode(EFFECT_GEMINI_STATUS)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spsumcost)
	e2:SetTarget(s.spsumtg)
	e2:SetOperation(s.spsumop)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
end

function s.ritualfil(c)
	return c:IsSetCard(0x4D3) and c:IsRitualMonster() 
end

--SHUFFLE TO SPECIAL

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,900902),tp,LOCATION_ONFIELD,0,1,nil)
end

function s.spfilter(c)
	return c:IsSetCard(0x4D3) and c:IsRitualMonster() and c:IsAbleToDeckAsCost()
end

function s.spsumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end

function s.spsumfilter(c,e,tp)
	return c:IsSetCard(0x4D3) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false,POS_FACEUP)
end
function s.spsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spsumfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x4D3)
end
function s.spsumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spsumfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)>0 then
	tc:CompleteProcedure()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
    end
end

