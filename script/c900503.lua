local s,id=GetID()
function s.initial_effect(c)
    -- Single continuous effect handling both flag + limit
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.umicon)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)
end

-- condition: while "Umi" is in your opponent's Field Zone
function s.umicon(e)
    local tp=e:GetHandlerPlayer()
    local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
    return fc and (fc:IsCode(22702055) or fc:IsCode(14087893) or fc:IsCode(72302403) or (fc:IsSetCard(0x760) and fc:IsType(TYPE_FIELD)))
end

-- operation: register flag & apply temporary summon limit effect
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=eg:GetFirst()
    local pl={}
    while tc do
        local sp=tc:GetSummonPlayer()
        if not tc:IsRace(RACE_FISH) and Duel.GetFlagEffect(sp,id)==0 then
            Duel.RegisterFlagEffect(sp,id,RESET_PHASE+PHASE_END,0,1)

            -- create the lock only when first non-Fish was summoned
            local e0=Effect.CreateEffect(c)
            e0:SetType(EFFECT_TYPE_FIELD)
            e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e0:SetTargetRange(1,1)
            e0:SetTarget(function(e,c,sump) return sump==sp and not c:IsRace(RACE_FISH) end)
            e0:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e0,sp)
        end
        tc=eg:GetNext()
    end
end