--Poltiquette Slumberstine
--Scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),4,2,nil,nil,99)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(id)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1,0)
    c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.desreptg)
	e2:SetValue(s.desrepval)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- Allow Fusion material from opp field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_OVERLAY+LOCATION_MZONE,LOCATION_OVERLAY+LOCATION_MZONE)
	e4:SetTarget(function(e,c) return c:IsSetCard(0x3D4) and not c:IsImmuneToEffect(e) end)
	e4:SetValue(s.matval)
	e4:SetLabelObject({s.extrafil_replacement})
	c:RegisterEffect(e4)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:GetFlagEffect(id)>0
end
function s.thfilter(c)
	return c:IsSetCard(0x3D4) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
	end
end
function s.matfilter(c)
	return c:IsContinuousTrap()
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.matfilter,1,nil) then
		local reset=RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END
		c:RegisterFlagEffect(id,reset,0,1)
	end
end
function s.mttg(e,c)
	return e:GetHandler():GetOverlayGroup():IsContains(c)
end
function s.repfilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0x3D4) and (c:IsContinuousTrap() or c:IsType(TYPE_FUSION))
        and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	Duel.Hint(HINT_CARD,0,id)
end

--Material Replacement
function s.matval(e,c)
	return c and c:IsControler(e:GetHandlerPlayer())
end

function s.extrafil_repl_filter(c,e)
	return not c:IsImmuneToEffect(e)
end

function s.extrafil_replacement(e,tp,mg)
    local g=Duel.GetMatchingGroup(s.extrafil_repl_filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
    local og=Group.CreateGroup()
    -- Iterate through monster zone
    if Duel.IsPlayerAffectedByEffect(tp,900817) then
        for i=0,6 do
            local check=Duel.GetFieldCard(tp,LOCATION_MZONE,i)
            if check and check:IsType(TYPE_XYZ) and check:IsCode(900817) then
                -- If the monster with specific ID exists, add its overlay group to og
                local og2=check:GetOverlayGroup()
                og:Merge(og2)
            end
        end
    end
    -- Return false if overlay group is empty
    if og:GetCount()==0 then
        return false
    end
    return og,s.fcheck_replacement
end

function s.fcheck_replacement(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_OVERLAY)<=99
end

