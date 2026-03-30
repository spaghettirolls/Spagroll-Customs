--Psychic Rose Dragon
--Scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
    --Also treated as Psychic
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_RACE)
    e0:SetValue(RACE_PSYCHIC)
    c:RegisterEffect(e0)

    --(Quick Effect) Discard to copy Synchro effect
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.copycost)
    e1:SetTarget(s.copytg)
    e1:SetOperation(s.copyop)
    c:RegisterEffect(e1)

    --Protection effect
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.indtg)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    --Add from GY
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

--Cost: discard itself
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

--Target Psychic/Plant Synchro
function s.copyfilter(c)
    return c:IsType(TYPE_SYNCHRO) and (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT))
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.copyfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.SelectTarget(tp,s.copyfilter,tp,LOCATION_MZONE,0,1,1,nil)
end

--Operation: copy effect (approximation)
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc then return end

    --Copy card effects (approximation)
    local c=e:GetHandler()
    c:CopyEffect(tc:GetOriginalCode(),RESET_PHASE+PHASE_END,1)
      s.applylock(e,tp)
end

--========================
-- KONAMI SUMMON LOCK CORE
--========================
Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c)
    return c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT)
end)

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end

function s.applylock(e,tp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return not (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT)) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
            -- Client hint (THIS is what shows under the username)
    aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,
        aux.Stringid(id,0),
        nil)
end

--Protection filter
function s.indtg(e,c)
    return c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT)
end

--GY add condition
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():IsType(TYPE_SYNCHRO)
        and (re:GetHandler():IsRace(RACE_PSYCHIC) or re:GetHandler():IsRace(RACE_PLANT))
        and rp==tp
end

--Target add
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

--Operation add
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,tp,REASON_EFFECT)
          s.applylock(e,tp)
    end
end
