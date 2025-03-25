local s,id=GetID()
    function s.initial_effect(c)
	c:EnableReviveLimit()
    Xyz.AddProcedure(c,s.mfilter,6,2,nil,nil,99)
    c:SetUniqueOnField(1,0,id)
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
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.rcost)
    e2:SetCondition(s.rcon)
    e2:SetTarget(s.rtg)
    e2:SetOperation(s.rop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_REMOVED)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCost(s.fcost)
    e3:SetTarget(s.ftg)
    e3:SetOperation(s.fop)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_SZONE,0)
	e4:SetCondition(s.ftcon)
	e4:SetTarget(s.fttg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end

--XYZ SUMMON POP

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.mfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_SEASERPENT,lc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,lc,sumtype,tp)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local numxyz=e:GetHandler():GetOverlayCount()
	if chk==0 then return numxyz>0 and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_SZONE,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_SZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,math.min(#g,numxyz),tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local numxyz=e:GetHandler():GetOverlayCount()
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_SZONE,nil)
	if #g>1 and numxyz>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,numxyz,nil)
		Duel.HintSelection(sg,true)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

--NEGATE AND ATTACH

function s.zfilter(c)
    return c:IsType(TYPE_XYZ) and c:IsSetCard(0x3A5) and c:IsFaceup()
end

function s.rcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local g=Group.CreateGroup()
    local mg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(mg) do
        if tc:IsSetCard(0x3A5) and tc:IsAbleToRemoveAsCost() then 
            g:Merge(tc:GetOverlayGroup())
        end
    end
    if chk==0 then return #g>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
    local sg=g:Select(tp,1,1,nil)
    Duel.Remove(sg,POS_FACEUP,REASON_COST)
    Duel.RaiseSingleEvent(sg:GetFirst(),EVENT_DETACH_MATERIAL,e,0,0,0,0)
end

function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev) 
end

function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.zfilter,tp,LOCATION_MZONE,0,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.rop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=re:GetHandler()
    local g=Duel.GetMatchingGroup(s.zfilter,tp,LOCATION_MZONE,0,nil)
    if Duel.NegateEffect(ev) and #g>0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
        local dg=g:Select(tp,1,1,nil)
        Duel.HintSelection(dg)
        rc:CancelToGrave()
        Duel.Overlay(dg:GetFirst(),rc,true)
      
    end
end

--SHUFFLE TO FUSION SUMMON

function s.fsfilter(c)
    return c:IsMonster() and c:IsSetCard(0x3A5) and c:IsAbleToDeckAsCost()
end

function s.fcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.fsfilter,tp,LOCATION_REMOVED,0,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.fsfilter,tp,LOCATION_REMOVED,0,1,1,c)
    g:AddCard(c)
    Duel.SendtoDeck(g,nil,2,REASON_COST)
end

function s.filter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x3A5) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
end
function s.ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end

--XYZ SUMMONED PROTECTION:

function s.ftcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ)
end

function s.fttg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x3A5) and c:IsSpellTrap()
end