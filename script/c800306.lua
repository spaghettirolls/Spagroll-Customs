--F.A. Whiplash Skimmer
--Scripted by ChatGPT
local s,id=GetID()
function s.initial_effect(c)
    --Synchro Summon procedure: 1 "F.A." Tuner + 1+ non-Tuner "F.A." monsters
 	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_FA),1,1,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_FA),1,99)
    c:EnableReviveLimit()

    --ATK gain: Level x 300
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    --Level adjustment when a "F.A." Spell/Trap or effect is activated
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id) -- once per chain
    e2:SetCondition(s.lvcon)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)

    --Special Summon 1 "F.A." monster from GY when Synchro Summoned
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0)) -- "Special Summon 1 'F.A.' monster from GY"
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,0})
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.sccon)
	e4:SetTarget(s.sctarg)
	e4:SetOperation(s.scop)
	c:RegisterEffect(e4)
end

--ATK value: Level x 300
function s.atkval(e,c)
    return c:GetLevel()*300
end

--Level adjustment filter: "F.A." Spell/Trap or effect activated
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActivated() and re:GetHandler():IsSetCard(SET_FA)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- 2: Increase, 3: Decrease
    if op==0 then
        c:UpdateLevel(1)
    else
        c:UpdateLevel(-1)
    end
end

--Special Summon from GY when Synchro Summoned
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_FA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
            local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- Level +/-1
            if op==0 then
                tc:UpdateLevel(1)
            else
                tc:UpdateLevel(-1)
            end
        end
    end
end
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and (Duel.IsMainPhase())
end
function s.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0
		and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c) end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end