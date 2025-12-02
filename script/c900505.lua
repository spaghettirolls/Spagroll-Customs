local s,id=GetID()
function s.initial_effect(c)
-- Link Summon: 1 Fish or WATER monster
Link.AddProcedure(c, s.matfilter, 1, 1)
c:EnableReviveLimit()


-- Name change while on the field (MZONE)
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e1:SetCode(EFFECT_CHANGE_CODE)
e1:SetRange(LOCATION_MZONE)
-- Use the target card's code here. If an engine constant exists, use it (e.g. CARD_PHANTASM_SPIRAL_DRAGON)
-- Otherwise replace the value with the numeric card ID: e1:SetValue(12345678)
e1:SetValue(CARD_PHANTASM_SPIRAL_DRAGON)
c:RegisterEffect(e1)


-- Name change while in the GY
local e2=e1:Clone()
e2:SetRange(LOCATION_GRAVE)
c:RegisterEffect(e2)
end


-- material filter: accepts a monster that is either Fish-type OR WATER attribute
function s.matfilter(c,lc,sumtype,tp)
return c:IsRace(RACE_FISH) or c:IsAttribute(ATTRIBUTE_WATER)
end