--Necroidia Pandemic
--Scripted by Beanbag
local s,id=GetID()
Duel.LoadScript('BeanbagsAux.lua')
function s.initial_effect(c)
	-- Activate: Tribute 1 "Necroidia" monster from hand or field to flip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Negate effect that targets "Necroidia" monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.discon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.distg)
	e2:SetOperation(function(_,_,_,_,ev) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e2)
end

-- Filter for your Necroidia monsters that can be tributed to flip at least 1 opponent monster
function s.costfilter(c,opmonsters)
	if not c:IsSetCard(SET_NECROIDIA) or not c:IsMonster() then return false end
	if c:IsLocation(LOCATION_MZONE) and not c:IsFaceup() then return false end
	for oc in aux.Next(opmonsters) do
		if oc:IsFaceup() and (c:GetAttack()>oc:GetAttack() or c:GetDefense()>oc:GetDefense()) then
			return true
		end
	end
	return false
end


-- Target: check opponent monsters and valid tributes
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local opmonsters=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #opmonsters>0 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,opmonsters) end
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,opmonsters)
	local trib=g:GetFirst()
	if not trib then return end
	Duel.Release(trib,REASON_COST)
	e:SetLabelObject(trib)
	-- Determine which opponent monsters are weaker than tributed monster
	local atkdef=math.max(trib:GetAttack(),trib:GetDefense())
	local tg=opmonsters:Filter(function(c) return c:GetAttack()<atkdef end,nil)
	if #tg>0 then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,tg,#tg,0,0)
	end
end

-- Operation: flip all with lower ATK or DEF
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local trib=e:GetLabelObject()
	if not trib then return end
	local atkdef=math.max(trib:GetAttack(),trib:GetDefense())
	local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:GetAttack()<atkdef end,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end

--Negate target effect
function s.smfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsSetCard(SET_NECROIDIA)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg:IsExists(s.smfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end