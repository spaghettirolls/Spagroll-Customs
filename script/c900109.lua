--Magmalith Pyrochlore
--scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 2 Rank 3 "Magmalith" Xyz Monsters
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false)
	-- Must be Xyz Summoned using the correct materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(s.chcon)
	e1:SetCost(aux.dxmcostgen(2,2,nil))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Negate Special Summon
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsRank(3) and c:IsSetCard(0x385,xyz,sumtype,tp)
end

--NEGATE SUMMON

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentChain()==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end

--IMMUNITY

function s.immval(e,re)
	local c=e:GetHandler()
	if not (re:IsActivated() and c:IsSummonType(SUMMON_TYPE_XYZ) and e:GetOwnerPlayer()==1-re:GetOwnerPlayer()) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(c)
end

--TRIBUTED EFFECT

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RELEASE) and e:GetHandler():GetOverlayCount()>0
end
function s.afilter(c,e,tp)
	return c:IsSetCard(0x385) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.afilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
