--Holysphere Heaven's Gate
--Scripted by Beanbag

local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_HAND_LIMIT)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(s.hslcon)
    e2:SetTargetRange(1,0)
    e2:SetValue(s.hlsvalue)
    c:RegisterEffect(e2)
    local e3=Ritual.CreateProc(c,RITPROC_GREATER,aux.FilterBoolFunction(Card.IsSetCard,0x270F),nil,aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    c:RegisterEffect(e3)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x270F) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil,e,tp)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end
function s.cfilter1(c)
    return c:IsFaceup() and c:IsCode(999000)
end
function s.hslcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end


function s.hlsvalue(e,c)
    local tp=e:GetHandlerPlayer()
    local handlim=6 -- Default hand limit
    local hls={Duel.GetPlayerEffect(tp,EFFECT_HAND_LIMIT)}
    for _,eff in ipairs(hls) do
        if eff~=e then -- Exclude the current effect
            local value=eff:GetValue()
            if type(value)=="function" then
                value=value(eff,e,tp,c) -- Call the function to get the value
            end
            if type(value)=="number" then
                handlim=value -- Become the value
            end
        end
    end
    return handlim+2 
end