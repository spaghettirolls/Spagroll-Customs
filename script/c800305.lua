-- F.A. Lightspeed Drifter
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()
    
    -- Gains ATK equal to its Level x 300
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
    -- Level change when "F.A." Spell/Trap or effect is activated
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.lvcon)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)
    -- Search "F.A." Spell/Trap when Synchro Summoned
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
    
    -- Gains effects based on current Level
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetValue(s.extra_atk)
    c:RegisterEffect(e4)
    
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_IMMUNE_EFFECT)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetValue(s.efilter)
    c:RegisterEffect(e5)
end

-- ATK = Level x 300
function s.atkval(e,c)
    return c:GetLevel()*300
end

-- Condition: an "F.A." Spell/Trap or effect is activated
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc:IsSetCard(SET_FA) and rc:IsType(TYPE_SPELL+TYPE_TRAP)
end

-- Target: choose increase or decrease
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    -- hint message
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPTION)
end

-- Operation: apply level change
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
    local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_LEVEL)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    if op==0 then
        e1:SetValue(1)
    else
        e1:SetValue(-1)
    end
    c:RegisterEffect(e1)
end

-- Synchro Summon trigger condition
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- Search "F.A." Spell/Trap target
function s.thfilter(c)
    return c:IsSetCard(SET_FA) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Extra ATK based on Level (Level 8+)
function s.extra_atk(e,c)
    local lvl=c:GetLevel()
    if lvl>=8 then
        return lvl*200
    else
        return 0
    end
end

-- Immune to opponent's monster effects at Level 11+
function s.efilter(e,re)
    local c=e:GetHandler()
    local lvl=c:GetLevel()
    return lvl>=11 and re:IsActiveType(TYPE_MONSTER) and re:GetOwnerPlayer()~=c:GetControler()
end