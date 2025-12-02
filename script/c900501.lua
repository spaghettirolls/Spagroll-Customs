--Charybdis of the Deepest Blue
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    --Cannot destroy other Fish monsters by battle
     local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetCondition(s.umicon)
    e1:SetTarget(s.indesfilter)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    --Destroy 1 Fish monster, then optionally 1 other card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
    --Special Summon Fish with higher Level when destroyed
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_names={CARD_UMI}
function s.umicon(e)
    return Duel.IsEnvironment(22702055) 
end

-- Target: other Fish monsters you control
function s.indesfilter(e,c)
    return c:IsRace(RACE_FISH) and not c~=e:GetHandler()
end
--Destroy Fish and optionally 1 other card
function s.filter(c)
    return c:IsFaceup() and c:IsRace(RACE_FISH)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
    if #g1>0 and Duel.Destroy(g1,REASON_EFFECT)~=0 then
        local g2=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=g2:Select(tp,1,1,nil)
            Duel.Destroy(sg,REASON_EFFECT)
        end
    end
end

--e3: Special Summon higher Level Fish
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
end

function s.spfilter(c,lv,e,tp)
    return c:IsRace(RACE_FISH) and c:GetLevel()>lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local lv=e:GetHandler():GetLevel()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,lv,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local lv=e:GetHandler():GetLevel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,lv,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        --Restriction: only Fish monsters for the rest of the turn

        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(aux.Stringid(id,5))
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.splimit(e,c)
    return not c:IsRace(RACE_FISH)
end