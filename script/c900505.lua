local s,id=GetID()
function s.initial_effect(c)
-- Link Summon: 1 Fish or WATER monster
Link.AddProcedure(c, s.matfilter, 1, 1)
c:EnableReviveLimit()


local PHANTASM_CODE = 566490609 -- numeric card ID for "Phantasm Spiral Dragon"


-- Name change while on the field (MZONE) with hint
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
e1:SetCode(EFFECT_CHANGE_CODE)
e1:SetRange(LOCATION_MZONE)
e1:SetValue(PHANTASM_CODE)
e1:SetDescription(aux.Stringid(id,0)) -- hint message ID
c:RegisterEffect(e1)


-- Name change while in the GY
local e2=e1:Clone()
e2:SetRange(LOCATION_GRAVE)
e2:SetDescription(aux.Stringid(id,1)) -- optional different hint for GY
c:RegisterEffect(e2)
end


-- material filter: accepts a monster that is either Fish-type OR WATER attribute
function s.matfilter(c,lc,sumtype,tp)
return c:IsRace(RACE_FISH) or c:IsAttribute(ATTRIBUTE_WATER)
end