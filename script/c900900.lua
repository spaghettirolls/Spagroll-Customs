--Solunaris Starborne
--Scripted by BeanBag
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Gemini.AddProcedure(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
	    s[0] = true
	    s[1] = true
	    local ge1 = Effect.CreateEffect(c)
	    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	    ge1:SetCode(EVENT_SUMMON_SUCCESS)
	    ge1:SetOperation(s.checkop)
	    Duel.RegisterEffect(ge1,0)
	    aux.AddValuesReset(function()
	        s[0] = true
	        s[1] = true
	    end)
	    -- Additional global check for card activation
		local ge2 = Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAINING)
		ge2:SetOperation(s.resetreg)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.resetreg(e, tp, eg, ep, ev, re, r, rp)
    local tc = re:GetHandler()
    if tc and tc:GetOriginalCode() == 43422537 then

        Duel.ResetFlagEffect(tp,id)

        local resetNeeded = false
        for i = 0, 1 do
            if not s[i] then
                resetNeeded = true
                break
            end
        end
        -- Reset the tables if needed
        if resetNeeded then
            s[0] = true
            s[1] = true
        end
    end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	s[ep]=false
end

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return s[tp]
end

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
 	if c:IsType(TYPE_EFFECT) then return false end
	if chk==0 then return c:IsFaceup() end
	Duel.SetChainLimit(aux.FALSE)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if not c then return end
    --activate
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EVENT_CHAIN_END)
    e1:SetCountLimit(1)
    e1:SetLabelObject(c)
    e1:SetOperation(s.faop)
    Duel.RegisterEffect(e1,tp)
    c:RegisterFlagEffect(900900,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,0)
end
function s.faop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc then return end
	local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_SUMMON)}
	if pre[1] then
		for i,eff in ipairs(pre) do
			local prev=eff:GetValue()
			if type(prev)~='function' or prev(eff) then return end
		end
	end
	if tc:GetFlagEffect(900900)==0 then return false end
	if tc and tc:IsFaceup() then
        tc:EnableGeminiStatus()
        Duel.BreakEffect()
        Duel.Hint(HINT_CARD,0,id)
        local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(s.flagcon)
		e1:SetTargetRange(1,0)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESET_PHASE+PHASE_END,0,1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_MSET)
		Duel.RegisterEffect(e2,tp)
        Duel.RaiseEvent(Group.CreateGroup(tc),EVENT_SUMMON,e,0,tp,tp,Duel.GetCurrentChain())
        tc:ResetFlagEffect(900900)
    end
    e:Reset()
end

function s.flagcon(e,c)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end

