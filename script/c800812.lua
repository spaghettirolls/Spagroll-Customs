local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3A5))
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
    local e4=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x3A5),nil,nil,nil)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,1})
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_GRAVE,0)
	e5:SetTarget(function(e,c) return c:IsSetCard(0x3A5) and c:IsAbleToRemove() and c:IsMonster() end)
	e5:SetOperation(Fusion.BanishMaterial)
	e5:SetValue(function(_,c) return c and c:IsSetCard(0x3A5) end)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_NO_TURN_RESET)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(3,{id,2})
	e6:SetCondition(s.condition)
	e6:SetTarget(s.target)
	e6:SetOperation(s.activate)
	c:RegisterEffect(e6)
end


--UPDATE ATK/DEF:

function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3A5)
end

function s.value(e,c)
	return Duel.GetMatchingGroupCount(s.filter,0,LOCATION_REMOVED,0,nil)*100
end

-- FUSION SUB

function s.mtval(e,c)
	if not c then return false end
	return c:IsSetCard(0x3A5) and c:IsMonster() and c:IsControler(e:GetHandlerPlayer())
end

-- BANISH TOP DECK

function s.cfilter(c,tp)
	return c:IsSetCard(0x3A5) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup() and c:IsControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetDecktopGroup(tp,1)
		local tc=g:GetFirst()
		return tc and tc:IsAbleToRemove()
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(tp,1)
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end