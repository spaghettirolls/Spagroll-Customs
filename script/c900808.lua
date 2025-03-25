--Poltiquette Cryptimmode
--Scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp)
	return c:IsSetCard(0x3D4) and c:IsType(TYPE_FUSION|TYPE_LINK) and c:IsControler(tp)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
		--Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x21,0,2000,4,RACE_FIEND,ATTRIBUTE_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x21,0,2000,4,RACE_FIEND,ATTRIBUTE_WATER) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
	c:AddMonsterAttributeComplete()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(s.btarget)
	e2:SetOperation(s.boperation)
	c:RegisterEffect(e2)
	Duel.SpecialSummonComplete()
	Duel.BreakEffect()
    if Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceUp,Card.IsCanChangePosition),tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local posg=Duel.SelectMatchingCard(tp,aux.AND(Card.IsAttackPos,Card.IsCanChangePosition),tp,0,LOCATION_MZONE,1,1,nil)
		if #posg==0 then return end
		Duel.HintSelection(posg,true)
		Duel.BreakEffect()
		Duel.ChangePosition(posg,POS_FACEDOWN_DEFENSE)
	end
end

function s.btarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetAttackTarget()==c or (Duel.GetAttacker()==c and Duel.GetAttackTarget()~=nil) end
	local g=Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.boperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local c=Duel.GetAttacker()
	if c:IsRelateToBattle() then g:AddCard(c) end
	c=Duel.GetAttackTarget()
	if c~=nil and c:IsRelateToBattle() then g:AddCard(c) end
	if #g>0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
	end
end