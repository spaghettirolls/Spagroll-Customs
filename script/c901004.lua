--Psychic Rose Dragon
local s,id=GetID()
function s.initial_effect(c)
    --Also treated as Psychic
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_RACE)
    e0:SetValue(RACE_PSYCHIC)
    c:RegisterEffect(e0)
    -- (Quick Effect): Apply its Summon Effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(aux.AND(Cost.SelfDiscard,s.copycost))
    e1:SetTarget(s.synctg)
    e1:SetOperation(s.syncop)
    c:RegisterEffect(e1)
    -- Protection
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.indtg)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    -- Add from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.copycost)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
    return c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT)
end

function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return not (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT)) end)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.indtg(e,c)
    return c:IsControler(e:GetHandlerPlayer()) 
        and (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_PLANT))
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():IsType(TYPE_SYNCHRO) and (re:GetHandler():IsRace(RACE_PSYCHIC) or re:GetHandler():IsRace(RACE_PLANT)) and rp==tp
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,tp,REASON_EFFECT)
    end
end


----------------------------------------------
function s.syncfilter(c)
    return c:IsType(TYPE_SYNCHRO) and (c:IsRace(RACE_PLANT) or c:IsRace(RACE_PSYCHIC)) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.GetValidSyncEffectsFromCard(c,e,tp,eg,ep,ev,re,r,rp)
    local effs={}
    local teffs={c:GetOwnEffects()}
    for _,te in ipairs(teffs) do
        local et=te:GetType()
        if te:GetCode()==EVENT_SPSUMMON_SUCCESS
            and (et & EFFECT_TYPE_SINGLE)~=0
            and ((et & EFFECT_TYPE_TRIGGER_O)~=0 or (et & EFFECT_TYPE_TRIGGER_F)~=0) then
            local tg=te:GetTarget()
            if not tg or tg(e,tp,eg,ep,ev,re,r,rp,0) then
                table.insert(effs,te)
            end
        end
    end
    return effs
end

-- Target function
function s.synctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Duel.GetMatchingGroup(s.syncfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
    -- Proper chkc handling
    if chkc then
        local tc=e:GetLabelObject()
        if not tc or not g:IsContains(tc) then return false end
        local fid=e:GetLabel()
        local effs=s.GetValidSyncEffectsFromCard(tc,e,tp,eg,ep,ev,re,r,rp)
        for _,te in ipairs(effs) do
            if te:GetFieldID()==fid then
                local tg=te:GetTarget()
                return tg and tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
            end
        end
        return false
    end
    if chk==0 then
        return g:IsExists(function(c)
            return #s.GetValidSyncEffectsFromCard(c,e,tp,eg,ep,ev,re,r,rp)>0
        end,1,nil)
    end
    -- Select 1 monster
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local sg=g:FilterSelect(tp,function(c)
        return #s.GetValidSyncEffectsFromCard(c,e,tp,eg,ep,ev,re,r,rp)>0
    end,1,1,nil)
    local tc=sg:GetFirst()
    if not tc then return end
    -- Get that monster's valid effects
    local effs=s.GetValidSyncEffectsFromCard(tc,e,tp,eg,ep,ev,re,r,rp)
    if #effs==0 then return end
    -- Select 1 effect from that monster
    local ops={}
    for _,te in ipairs(effs) do
        table.insert(ops,{true,te:GetDescription()})
    end
    local sel=#ops==1 and 1 or Duel.SelectEffect(tp,table.unpack(ops))
    local te=effs[sel]
    if not te then return end
    -- Store selected monster + effect
    e:SetLabelObject(tc)
    e:SetLabel(te:GetFieldID())
    e:SetCategory(te:GetCategory())
    e:SetProperty(te:GetProperty())
    local tg=te:GetTarget()
    if tg then
        tg(e,tp,eg,ep,ev,re,r,rp,1)
    end
    e:SetOperation(s.syncop(te:GetOperation(),tc))
end

-- Operation wrapper
function s.syncop(fn,tc)
    return function(e,tp,eg,ep,ev,re,r,rp)
        if fn then fn(e,tp,eg,ep,ev,re,r,rp) end
        e:Reset()
    end
end