--Psychic Rose Witch
--Scripted by Beanbag
local s,id=GetID()

function s.initial_effect(c)
    --Also treated as Psychic
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_RACE)
    e0:SetValue(RACE_PSYCHIC)
    c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)
    --On summon: search
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.actcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    local e2x=e2:Clone()
    e2x:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2x)

--GY Synchro Material (banish, hard OPT)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_SYNCHRO_MAT_FROM_HAND)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetValue(s.synval)
	c:RegisterEffect(e3)
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
end

--========================
-- SPECIAL SUMMON CONDITION
--========================
function s.cfilter(c)
    return not (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT))
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and (#g==0 or not g:IsExists(s.cfilter,1,nil))
end

--========================
-- SEARCH EFFECT
--========================
function s.thfilter(c)
    return c:IsSetCard(0x1A0A) and c:IsType(TYPE_MONSTER)
        and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    s.applylock(e,tp)
end

function s.synval(e,mc,sc) --this effect, this card and the monster to be summoned
	return sc:IsType(TYPE_SYNCHRO) and sc:IsRace(RACE_PSYCHIC+RACE_PLANT)
end