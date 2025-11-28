local s,id=GetID()
function s.initial_effect(c)
    --Special Summon + place "Umi"
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.mspcon)
    e2:SetTarget(s.msptg)
    e2:SetOperation(s.mspop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
    --Cannot be targeted for attacks or by opponent's card effects while "Umi" is on the field
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e4:SetCondition(s.atkcon)
    e4:SetValue(aux.imval1) -- cannot be chosen as attack target
    c:RegisterEffect(e4)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e5:SetCondition(s.atkcon)
    e5:SetValue(aux.tgoval) -- cannot be targeted by effects
    c:RegisterEffect(e5)
end
s.listed_names={CARD_UMI}

-- FIRST EFFECT --

-- There must be space to Special Summon from hand
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function s.umifilter(c,tp)
    return c:IsCode(22702055) -- "Umi"
        and (c:IsAbleToGrave() or c:IsAbleToHand() or c:IsAbleToDeck())
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.umifilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
            and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Pick Umi from hand/Deck/GY
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.umifilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
    if not tc then return end
    
    -- Choose which Field Zone to place it to
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1)) 
    local fz=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)) -- 0 = yours, 1 = opponent's
    local p=(fz==0 and tp or 1-tp)
    
    -- Clear existing Field Spell on that side
    local fc=Duel.GetFieldCard(p,LOCATION_FZONE,0)
    if fc then
        Duel.SendtoGrave(fc,REASON_RULE)
    end

    -- Move Umi to chosen Field Zone
    Duel.MoveToField(tc,tp,p,LOCATION_FZONE,POS_FACEUP,true)

    -- Special Summon this card
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- SECOND EFFECT --

--Condition: Must be Main Phase
function s.mspcon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end

--Filter for Fish monsters
function s.mspfilter(c,e,tp)
    return c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--Target function
function s.msptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
    if chk==0 then
        local maxsummon=1
        if Duel.IsEnvironment(22702055) then 
            maxsummon=2
        end
        return (Duel.IsExistingMatchingCard(s.mspfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) and ft1>0) 
            or (Duel.IsExistingMatchingCard(s.mspfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,1-tp) and ft2>0)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_GRAVE)
end

--Operation
function s.mspop(e,tp,eg,ep,ev,re,r,rp)
    local maxsummon=1
    if Duel.IsEnvironment(22702055) then -- "Umi" field spell ID
        maxsummon=2
    end

    for i=1,maxsummon do
        local g1=Duel.GetMatchingGroup(s.mspfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
        local g2=Duel.GetMatchingGroup(s.mspfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,1-tp)
        local options={}
        if #g1>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then table.insert(options,tp) end
        if #g2>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then table.insert(options,1-tp) end
        if #options==0 then break end
        local sel=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        local p=options[sel+1]
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.mspfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,p)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,p,p,false,false,POS_FACEUP)
        end
    end

    --Apply restriction: only Fish monsters can be Special Summoned for rest of turn
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

--Special summon limit
function s.splimit(e,c)
    return not c:IsRace(RACE_FISH)
end


-- THIRD EFFECT--

--Filter: Fish monsters in GY or banished
function s.thfilter(c)
    return c:IsRace(RACE_FISH) and c:IsAbleToHand()
end

--Target function with Necrovalley protection
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

--Operation function with Necrovalley protection
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
--Condition: "Umi" is on the field
function s.atkcon(e)
    return Duel.IsEnvironment(22702055)
end
