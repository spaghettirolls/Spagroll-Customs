local s,id=GetID()
function s.initial_effect(c)
        c:SetUniqueOnField(1,0,id)
    -- Single continuous effect handling both flag + limit
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.umicon)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
   local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.condition)
    e3:SetTarget(s.starget)
    e3:SetOperation(s.soperation)
    c:RegisterEffect(e3)
end
s.listed_names={CARD_UMI}
--Condition: "Umi" must be on the field
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsEnvironment(22702055)
end

--Special Summon filter: Fish monsters in either GY, excluding itself
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_FISH) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--Target: 1 card on the field
function s.starget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
    if chk==0 then 
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        return ft>0 
            and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

--Operation: Remove target, then Special Summon 1 Fish from either GY
function s.soperation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and ft>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

--Cost: discard this card
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

--Filter for Level 5+ Fish or WATER Warrior
function s.filter(c,e,tp)
    return c:IsLevelAbove(5) and (c:IsRace(RACE_FISH) or (c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_WARRIOR)))
        and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end

--Target: check if you can add or summon
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

--Operation: add to hand or Special Summon ignoring conditions
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end
    local canAdd=tc:IsAbleToHand()
    local canSS=tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
    
    local choice
    if canAdd and canSS then
        -- Use aux.Stringid for localized option text
        choice=Duel.SelectOption(tp, aux.Stringid(id,1), aux.Stringid(id,2))
    elseif canAdd then
        choice=0
    else
        choice=1
    end

    if choice==0 then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    else
        Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
    end
end

-- condition: while "Umi" is in your opponent's Field Zone
function s.umicon(e)
    local tp=e:GetHandlerPlayer()
    local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
    return fc and (fc:IsCode(22702055) or fc:IsCode(14087893) or fc:IsCode(72302403) or (fc:IsSetCard(0x760) and fc:IsType(TYPE_FIELD)))
end

-- operation: register flag & apply temporary summon limit effect
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=eg:GetFirst()
    local pl={}
    while tc do
        local sp=tc:GetSummonPlayer()
        if not tc:IsRace(RACE_FISH) and Duel.GetFlagEffect(sp,id)==0 then
            Duel.RegisterFlagEffect(sp,id,RESET_PHASE+PHASE_END,0,1)

            -- create the lock only when first non-Fish was summoned
            local e0=Effect.CreateEffect(c)
            e0:SetType(EFFECT_TYPE_FIELD)
            e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e0:SetTargetRange(1,1)
            e0:SetTarget(function(e,c,sump) return sump==sp and not c:IsRace(RACE_FISH) end)
            e0:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e0,sp)
        end
        tc=eg:GetNext()
    end
end