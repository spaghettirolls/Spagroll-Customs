local s,id=GetID()

function s.initial_effect(c)
    -- Lose ATK based on opponent's Fish monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- Unaffected by opponent's activated effects while "Umi" is on field
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.umi_condition)
    e2:SetValue(s.immval)
    c:RegisterEffect(e2)

    -- Destroy all other Fish and burn on Special Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    -- Opponent can Special Summon a Fish each End Phase
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)

    -- Can only control 1
    c:SetUniqueOnField(1,0,id)
end
s.listed_names={CARD_UMI}
---------------------------------------
-- ATK loss (fixed)
-- While "Umi" (or a treated-as-Umi card) is active this card loses 1000 ATK per Fish your opponent controls.
-- Otherwise it loses 200 ATK per Fish your opponent controls.
---------------------------------------
function s.atkval(e,c)
    local tp=e:GetHandlerPlayer()
    -- count Fish monsters your opponent controls
    local ct=Duel.GetMatchingGroupCount(Card.IsRace, tp, 0, LOCATION_MZONE, nil, RACE_FISH)
    if Duel.IsEnvironment(22702055) then
        return -1000 * ct
    else
        return -200 * ct
    end
end

---------------------------------------
-- Umi immunity
---------------------------------------
function s.umi_condition(e)
    return Duel.IsEnvironment(22702055)
end

function s.immval(e,te)
    if not te or te:GetOwner()==e:GetOwner() then return false end
    if te.IsActivated and te:IsActivated() then return true end
    return te:IsHasType(EFFECT_TYPE_ACTIVATE)
        or te:IsHasType(EFFECT_TYPE_IGNITION)
        or te:IsHasType(EFFECT_TYPE_QUICK_O)
        or te:IsHasType(EFFECT_TYPE_TRIGGER_O)
        or te:IsHasType(EFFECT_TYPE_TRIGGER_F)
end

---------------------------------------
-- Destroy all other Fish + Burn
---------------------------------------
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(c) return c:IsRace(RACE_FISH) and c~=e:GetHandler() and c:IsDestructable() end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,#g*500)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(function(c) return c:IsRace(RACE_FISH) and c~=e:GetHandler() end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    local ct=Duel.Destroy(g,REASON_EFFECT)
    if ct>0 then
        Duel.Damage(tp,ct*500,REASON_EFFECT)
        Duel.Damage(1-tp,ct*500,REASON_EFFECT)
    end
end

---------------------------------------
-- Opponent can SS a Fish from GY (except this card)
---------------------------------------
function s.filter(c,e,tp)
    return c:IsRace(RACE_FISH) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.filter,1-tp,LOCATION_GRAVE,0,1,nil,e,1-tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(1-tp,s.filter,1-tp,LOCATION_GRAVE,0,1,1,nil,e,1-tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,1-tp,1-tp,false,false,POS_FACEUP)
    end
end