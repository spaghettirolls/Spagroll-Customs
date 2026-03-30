--Psychic Rose Trance Dragon
local s,id=GetID()
function s.initial_effect(c)
    --Synchro Summon
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PLANT),1,1,Synchro.NonTunerEx(s.ntfilter),1,99)
    c:EnableReviveLimit()

    --Also treated as Psychic
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_RACE)
    e0:SetValue(RACE_PSYCHIC)
    c:RegisterEffect(e0)

    --Effect 1: Negate + reduce
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    --Effect 2: Board wipe
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.wipecon)
    e2:SetCost(s.wipecost)
    e2:SetOperation(s.wipeop)
    c:RegisterEffect(e2)
end

--Non-Tuner filter (Plant or Psychic)
function s.ntfilter(c,scard,sumtype,tp)
    return c:IsRace(RACE_PLANT|RACE_PSYCHIC,scard,sumtype,tp)
end

--Must be Synchro Summoned
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.negfilter(c)
    return c:IsFaceup()
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.negfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        --Negate effects
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)

        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e2)

        --Set ATK/DEF to 0
        local e3=e1:Clone()
        e3:SetCode(EFFECT_SET_ATTACK_FINAL)
        e3:SetValue(0)
        tc:RegisterEffect(e3)

        local e4=e1:Clone()
        e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
        e4:SetValue(0)
        tc:RegisterEffect(e4)

        --Cannot be used as material
        local e5=e1:Clone()
        e5:SetCode(EFFECT_CANNOT_BE_MATERIAL)
        e5:SetValue(1)
        tc:RegisterEffect(e5)

        --Summon restriction (lock after effect)
        s.splimit(tp)
    end
end

--Quick effect condition (opponent Extra Deck summon)
function s.wipecon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp and eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_EXTRA)
end

function s.wipecost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

function s.wipeop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
    Duel.Destroy(g,REASON_EFFECT)
    s.splimit(tp)
end

--Summon restriction effect
function s.splimit(tp)
    local e1=Effect.CreateEffect(nil)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return not c:IsRace(RACE_PLANT|RACE_PSYCHIC) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end