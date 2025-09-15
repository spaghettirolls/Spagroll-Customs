--Vylon Beta
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x30),1,1,aux.FilterBoolFunctionEx(Card.IsSetCard,0x30),1,99)
	c:EnableReviveLimit()
	--Equip destroyed monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_LPCOST_REPLACE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1,0)
    e2:SetTarget(s.lpcost_tg)
    e2:SetValue(s.lpcost_rep)
    c:RegisterEffect(e2)
    --Fallback: change LP cost to 0 and gain LP if replace was skipped
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_LPCOST_CHANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(1,0)
    e3:SetTarget(s.lpcost_tg)
    e3:SetValue(s.lpcost_change)
    c:RegisterEffect(e3)
end

-- Target: the monster this card destroyed
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chkc then return chkc==tc end
	if chk==0 then
		return tc and tc:IsLocation(LOCATION_GRAVE) and tc:IsType(TYPE_MONSTER)
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and tc:IsCanBeEffectTarget(e)
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,tc,1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c or not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	if not tc or not tc:IsLocation(LOCATION_GRAVE) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end

	-- Equip while ignoring the equip limit (true), then register a proper equip-limit effect.
	if Duel.Equip(tp,tc,c,true)==0 then return end

	-- Equip limit: can only be equipped to 'c'
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(function(e,cc) return cc==c end)
	tc:RegisterEffect(e1)

	-- ATK +500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
	-- DEF +500 (clone)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	tc:RegisterEffect(e3)

	-- Treated as "Vylon"
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_ADD_SETCODE)
	e4:SetValue(0x30) -- Vylon setcode
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e4)
end

--Check if the LP payment comes from a "Vylon" monster effect
function s.lpcost_tg(e,re,rp)
    local rc=re:GetHandler()
    return rc and rc:IsSetCard(0x30) and rc:IsType(TYPE_MONSTER)
end

--Replacement: instead of paying LP, recover that much
function s.lpcost_rep(e,re,rp,val)
    if Duel.GetFlagEffect(rp,id)>0 then return false end
    Duel.RegisterFlagEffect(rp,id,RESET_CHAIN,0,1)
    Duel.Recover(rp,val,REASON_EFFECT)
    return true
end

--Fallback: if replace didn’t trigger (e.g. graveyard activations), set cost to 0 and gain LP
function s.lpcost_change(e,re,rp,val)
    if Duel.GetFlagEffect(rp,id)>0 then
        return 0
    end
    Duel.Recover(rp,val,REASON_EFFECT)
    return 0
end
