--Vylon Beta
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x30),1,1,Synchro.NonTunerEx(Card.IsSetCard,0x30),1,99)
	c:EnableReviveLimit()
	--LP instead of paying cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_LPCOST_CHANGE)
	e2:SetTargetRange(1,0)
	e2:SetValue(function(e,re,rp,val) 
		if re and re:GetHandler():IsSetCard(0x30) then 
			return 0 
		else 
			return val 
		end
	end)
	c:RegisterEffect(e2)
	--Equip destroyed monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	--Destroy replacement
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
end

--Equip destroyed monster
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and bc:IsMonster() and bc:IsFaceup() end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,bc,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetFirstTarget()
	if bc:IsRelateToEffect(e) and bc:IsMonster() and bc:IsFaceup() then
		e:GetHandler():EquipByEffectAndLimitRegister(e,tp,bc,id)
	end
end

--Destruction replacement
function s.repfilter(c,tp)
	return c:IsSetCard(0x30) and c:IsType(TYPE_MONSTER)
		and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.eqfilter(c)
	return c:IsSetCard(0x30) and c:IsType(TYPE_EQUIP) and c:IsAbleToGrave()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) 
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_SZONE,0,1,nil) end
	return Duel.SelectYesNo(tp,aux.Stringid(id,1))
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_SZONE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
	end
end
