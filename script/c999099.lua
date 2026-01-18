--Necroidia Dread Magi
--Scripted by Beanbag

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.setcost1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.setcost2)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

function s.setcost1(e,tp,eg,ep,ev,re,r,rp,chk)
    e:SetLabel(0)
    local c=e:GetHandler()
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if c:IsLocation(LOCATION_HAND+LOCATION_DECK) then
        ft=ft-1
    end
    local fs=1
    if Duel.GetFieldCard(tp,LOCATION_FZONE,0) then
        fs=1
    end
    local maxct=math.min(2,ft+fs)
    if chk==0 then
        return maxct>0 and Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,maxct,true,nil,nil,0x238C)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,maxct,true,nil,nil,0x238C)
    local ct=#g
    Duel.Release(g,REASON_COST)
    e:SetLabel(ct)
end



function s.setfilter(c)
    return c:IsSetCard(0x238C) and c:IsSpellTrap() and c:IsSSetable() and not c:IsCode(id)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
        local fz=0
        if Duel.GetLocationCount(tp,LOCATION_FZONE)>0 then fz=1 end
        local rg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
        return (ft+fz)>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
    end
end

function s.rescon(sg,e,tp,mg)
    local ct=#sg
    if ct<=1 then return true end
    -- Cards must have different names
    if sg:GetClassCount(Card.GetCode)~=ct then
        return false
    end
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    local fz=Duel.GetLocationCount(tp,LOCATION_FZONE)
    -- If only 1 total zone is available
    if ft+fz==1 then
        local fieldct=sg:FilterCount(Card.IsType,nil,TYPE_FIELD)
        -- Exactly one Field Spell, one non-Field
        return fieldct==1
    end
    return true
end


function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    if ct==0 then return end
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    local fsok=false
    local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
    for tc in aux.Next(g) do
        if tc:IsType(TYPE_FIELD) then
            fsok=true
            break
        end
    end
    if ft==0 and not fsok then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,s.rescon,1,tp,HINTMSG_REMOVE,s.rescon)
    if #sg>0 then
        Duel.SSet(tp,sg)
    end
end



function s.cfilter(c,ft,tp)
	return c:IsSetCard(0x238C) and (ft>0 or (c:GetSequence()<5 and c:IsControler(tp))) and (c:IsFaceup() or c:IsControler(tp))
end
function s.setcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,true,nil,e:GetHandler(),0x238C) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,true,nil,e:GetHandler(),0x238C)
	Duel.Release(g,REASON_COST)
	e:SetLabel(#g)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() and Duel.SSet(tp,c)>0 then
		--Banish it when it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		c:RegisterEffect(e1)
	end
end