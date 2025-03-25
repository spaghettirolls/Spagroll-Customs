
-- Nebulamia - Hive Leech Zelphios

local s,id=GetID()
    function s.initial_effect(c)
	c:EnableReviveLimit()
    Xyz.AddProcedure(c,s.mfilter,4,2)
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
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.bcost)
	e2:SetTarget(s.btg)
	e2:SetOperation(s.bop)
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
end

-- XYZ POP S/T

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.mfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_SEASERPENT,lc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,lc,sumtype,tp)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_SZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--BANISH MATERIAL

function s.xyzfilter(c)
    return c:IsType(TYPE_XYZ) and c:IsSetCard(0x3A5) and c:IsFaceup()
end

function s.bcost(e,tp,eg,ep,ev,re,r,rp,chk)
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

function s.banfilter(c)
	return c:IsSetCard(0x3A5) and c:IsSpell() or c:IsTrap()
end

function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
	if chk==0 then return ft>=2 and tc and tc:IsAbleToRemove() and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,tp,LOCATION_DECK)
end

function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    if tc:IsAbleToRemove() and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.BreakEffect()
	local dg=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tg=dg:GetFirst()
	if tg then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tg,0)
		Duel.ConfirmDecktop(tp,1)
	    end
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
