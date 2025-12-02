function s.initial_effect(c)
    --Lose ATK based on opponent's Fish monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
end

function s.atkfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_FISH)
end

function s.atkval(e,c)
    local tp=e:GetHandlerPlayer()
    local count=Duel.GetMatchingGroupCount(s.atkfilter,tp,0,LOCATION_MZONE,nil)
    return -1000 * count
end