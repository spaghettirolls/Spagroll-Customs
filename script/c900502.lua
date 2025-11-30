local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    -- Prevent activation of monster effects in GY (except original-type Fish)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)          -- apply while this Field Spell is face-up
    e1:SetTargetRange(1,1)              -- affects both players
    e1:SetValue(s.aclimit)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_ATTACK)
    e2:SetCondition(function(e)
        return Duel.IsEnvironment(CARD_UMI)
    end)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.cost)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
end

-- cost: destroy this card
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDestructable() end
    Duel.Destroy(c,REASON_COST)
end

-- filter: Level 4 Fish that can be Special Summoned
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_FISH) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return false end
        return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g1==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g2=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g2==0 then return end

    local g=Group.CreateGroup()
    g:Merge(g1)
    g:Merge(g2)
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)

    -- Fish-only summon restriction + visible hint message
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,1)) -- Add message text from string table index 1
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsRace(RACE_FISH)
end

function s.aclimit(e,re,tp)
    local rc=re:GetHandler()
    -- only care about monster effects activated from the Graveyard
    if not re:IsActiveType(TYPE_MONSTER) then return false end
    if not rc:IsLocation(LOCATION_GRAVE) then return false end
    -- allow if the monster's ORIGINAL type includes Fish
    if rc:IsOriginalType(TYPE_FISH) then return false end
    -- otherwise block the activation
    return true
end