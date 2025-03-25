--Solunaris Ceremony
--scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.tkcost)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,5))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.addcon)
	e3:SetTarget(s.addtg)
	e3:SetOperation(s.addop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4)
end

function s.thdesfilter(c)
	return c:IsCode(900901)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.thdesfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if not sc then return end
		aux.ToHandOrElse(sc,tp)
	end
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tkfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tkfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tkfilter(c)
	return c:IsSetCard(0x4D3) and c:IsRitualMonster() and c:IsAbleToGraveAsCost()
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,id+12,0x4D3,TYPES_TOKEN,0,0,4,RACE_PYRO,ATTRIBUTE_LIGHT) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+12,0x4D3,TYPES_TOKEN,0,0,4,RACE_PYRO,ATTRIBUTE_LIGHT) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local fid=c:GetFieldID()
	local g=Group.CreateGroup()
	for i=1,ft do
		local token=Duel.CreateToken(tp,id+12)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		token:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		g:AddCard(token)
	end
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	Duel.RegisterEffect(e1,tp)
end
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tc=g:Filter(s.desfilter,nil,e:GetLabel())
	Duel.Destroy(tc,REASON_EFFECT)
end


function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	return rp~=tp and e:GetHandler():IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousPosition(POS_FACEUP)
end

function s.filter1(c)
	return c:IsRitualMonster() and c:IsSetCard(0x4D3) and c:IsLevelBelow(6) and c:IsAbleToHand()
end
function s.filter2(c)
	return c:IsCode(900901) and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	g1=g1+g2
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,2,0,0)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
