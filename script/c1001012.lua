--Maelstrom Vigilance
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--All opponent monsters lose 100 ATK/DEF per different Maelstrom in GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)

--Main Phase effect: destroy + mill (works both turns)
local e3=Effect.CreateEffect(c)
e3:SetDescription(aux.Stringid(id,0))
e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DECKDES)
e3:SetType(EFFECT_TYPE_QUICK_O)
e3:SetCode(EVENT_FREE_CHAIN)
e3:SetRange(LOCATION_SZONE)
e3:SetCountLimit(1,id)
e3:SetHintTiming(TIMING_MAIN_END)
e3:SetCondition(s.mpcon)
e3:SetTarget(s.destg)
e3:SetOperation(s.desop)
c:RegisterEffect(e3)

	--If sent to GY by a different Maelstrom effect: set itself face-up
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end

-- Count different Maelstrom cards in GY
function s.maelstromfilter(c)
	return c:IsSetCard(0x2B67)
end

function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.maelstromfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	local ct=0
	local codes={}
	for tc in aux.Next(g) do
		local code=tc:GetCode()
		if not codes[code] then
			codes[code]=true
			ct=ct+1
		end
	end
	return -100*ct
end

-- Main Phase condition
function s.mpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.dfilter(c)
	return c:IsSetCard(0x2B67) and c:IsDestructable()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_ONFIELD,0,1,nil)
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			and Duel.IsPlayerCanDiscardDeck(tp,3)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,0,LOCATION_ONFIELD+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	if #g1>0 then
		if Duel.Destroy(g1,REASON_EFFECT)==2 then
			Duel.DiscardDeck(tp,3,REASON_EFFECT)
		end
	end
end

-- Sent by Maelstrom effect condition (not itself)
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
		and re
		and re:GetHandler()
		and re:GetHandler():IsSetCard(0x2B67)
		and re:GetHandler():GetCode()~=c:GetCode()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end