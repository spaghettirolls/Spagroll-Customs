
-- Nebulamia - Hive Queen Phorusilis

	local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,s.ffilter,2,99)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCondition(s.fscon)
	e2:SetTarget(s.fstg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.xyzcon)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end

s.material_setcode={0x3A5}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x3A5,fc,sumtype,tp) and not c:IsCode(id)
end


--DESTROY OPP MONSTERS:

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and re and re:GetHandler():IsSetCard(0x3A5)
end

function s.desfilter(c)
	return c:IsMonster() and not c:IsSpell() and not c:IsTrap()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetHandler():GetMaterialCount()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end


function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	Duel.Destroy(g,REASON_EFFECT)
end

--FUSION SUMMONED PROTECTION:

function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION)
end

function s.fstg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x3A5) and c:IsSpellTrap()
end


-- XYZ SUMMON PROC:

function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_REMOVED)
end

function s.xyzfilter(c,e,tp)
	return c:IsSetCard(0x3A5) and c:IsType(TYPE_XYZ) and c:IsRank(6) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.Overlay(tc,c)
		end
	end
end