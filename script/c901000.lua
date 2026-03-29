--Psychic Rose Seed
--Scripted by Beanbag
local s,id=GetID()

function s.initial_effect(c)
    --Also treated as Psychic
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_RACE)
    e0:SetValue(RACE_PSYCHIC)
    c:RegisterEffect(e0)

    --Track non-Psychic/Plant Special Summons
    if not s.global_check then
        s.global_check=true
        local ge=Effect.CreateEffect(c)
        ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge:SetCode(EVENT_SPSUMMON_SUCCESS)
        ge:SetOperation(s.checkop)
        Duel.RegisterEffect(ge,0)
    end

    --Quick Effect: Discard to SS
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.actcon)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --On summon: send to GY
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.actcon)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
    local e2x=e2:Clone()
    e2x:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2x)

    --GY revive on Synchro
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+200)
    e3:SetCondition(s.revcon)
    e3:SetTarget(s.revtg)
    e3:SetOperation(s.revop)
    c:RegisterEffect(e3)
end

--Track illegal summons
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    for tc in aux.Next(eg) do
        local p=tc:GetSummonPlayer()
        if not (tc:IsRace(RACE_PSYCHIC) or tc:IsRace(RACE_PLANT)) then
            Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
        end
    end
end

--Activation condition (no illegal summons this turn)
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end

--Summon restriction
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT))
end

function s.applylock(tp)
    --Mark that effect was used
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)

    --Apply summon restriction
    local e1=Effect.CreateEffect(nil)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

--Discard cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

--SS filter
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x1A0A) and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
    s.applylock(tp)
end

--Send to GY filter
function s.tgfilter(c)
    return c:IsSetCard(0x1A0A) and not c:IsCode(id) and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
    s.applylock(tp)
end

--Synchro trigger
function s.revfilter(c,tp)
    return c:IsSummonPlayer(tp)
        and c:IsType(TYPE_SYNCHRO)
        and (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT))
end

function s.revcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.revfilter,1,nil,tp)
end

function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.revop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1)
    end
    s.applylock(tp)
end