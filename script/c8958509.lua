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
e2:SetCode(EFFECT_LPCOST_CHANGE)
e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
e2:SetRange(LOCATION_MZONE)
e2:SetTargetRange(1,0)
e2:SetValue(s.costchange)
c:RegisterEffect(e2)
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
    Duel.Equip(tp,tc,c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
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
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_ADD_SETCODE)
	e4:SetValue(0x30) -- Vylon setcode
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e4)
end
function s.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp)
end

function s.costchange(e,re,rp,val)
    local c=e:GetHandler()
    -- If the effect belongs to a Vylon card
    if re:GetHandler():IsSetCard(SET_VYLON) then
        -- Gain LP equal to the cost we would have paid

        return 0
    else
        -- Pay normally otherwise
        return val
    end
    Duel.Recover(rp,math.abs(val),REASON_EFFECT)
end


--[[function s.costchange(e,re,rp,val)
    if re:GetHandler():IsSetCard(SET_VYLON) then
        return -val
    else
        return val
    end
end]]