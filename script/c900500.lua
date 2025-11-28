local s,id=GetID()
function s.initial_effect(c)
    --Special Summon + place "Umi"
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
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