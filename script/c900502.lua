local s,id=GetID()
function s.initial_effect(c)
    -- Prevent activation of monster effects in GY (except original-type Fish)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)          -- apply while this Field Spell is face-up
    e1:SetTargetRange(1,1)              -- affects both players
    e1:SetValue(s.aclimit)
    c:RegisterEffect(e1)
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