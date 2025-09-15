--Vylon Beta
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x30),1,1,aux.FilterBoolFunctionEx(Card.IsSetCard,0x30),1,99)
	c:EnableReviveLimit()
local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,function(ec,_,tp) return ec:GetOriginalType()&TYPE_MONSTER>0 end,Card.EquipByEffectAndLimitRegister,e1)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	if bc then
		Duel.SetTargetCard(bc)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,bc,1,0,0)
		if bc:IsLocation(LOCATION_GRAVE) then
			Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,bc,1,0,0)
		end
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not bc or c:IsStatus(STATUS_BATTLE_DESTROYED) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and bc and bc:IsRelateToEffect(e) and bc:IsLocation(LOCATION_SZONE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED) then
		c:EquipByEffectAndLimitRegister(e,tp,bc)
	end
end
function s.eqcheck(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject() then e:GetLabelObject():DeleteGroup() end
	local g=e:GetHandler():GetEquipGroup()
	g:KeepAlive()
	e:SetLabelObject(g)
end