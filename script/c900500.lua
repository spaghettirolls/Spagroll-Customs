local s,id=GetID()
function s.initial_effect(c)
    --Special Summon + place "Umi"
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
   local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,{id,0})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Quick only during Main Phase
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

function s.fishfilter(c,e,tp)
    return c:IsRace(RACE_FISH)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Is Umi on the field?
function s.umi_check()
    return Duel.IsExistingMatchingCard(Card.IsCode,0,LOCATION_FZONE+LOCATION_ONFIELD,LOCATION_FZONE+LOCATION_ONFIELD,1,nil,22702055)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct = s.umi_check() and 2 or 1
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.fishfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local ct = s.umi_check() and 2 or 1
    local g=Duel.GetMatchingGroup(s.fishfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
    if #g==0 then return end

    local c=e:GetHandler()

    -- Apply Special Summon lock (Only Fish)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return not c:IsRace(RACE_FISH) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    for i=1,ct do
        if #g==0 then return end

        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg = g:Select(tp,1,1,nil)
        local sc = sg:GetFirst()
        if not sc then return end

        -- Choose field to summon to
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
        local opt = Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)) 
        local p = (opt==0 and tp or 1-tp)

        -- Check there is space on chosen player's field
        if Duel.GetLocationCount(p,LOCATION_MZONE)<=0 then return end

        Duel.SpecialSummon(sc,0,tp,p,false,false,POS_FACEUP)
        g:RemoveCard(sc)
    end
end
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