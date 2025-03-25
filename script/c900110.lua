--Magmalith Volcanthis
--scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(s.matfilter),2,aux.FilterBoolFunctionEx(s.matfilter2),1)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,0})
	e3:SetTarget(s.addtg)
	e3:SetOperation(s.addop)
	c:RegisterEffect(e3)
end

--MATERIALS

function s.matfilter(c,fc,st,tp)
	return c:IsSetCard(0x385) and not c:IsType(TYPE_XYZ)
end
function s.matfilter2(c,fc,st,tp)
	return c:IsRace(RACE_ROCK) and c:IsType(TYPE_XYZ)
end
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end

--TRIBUTE EFFECT

function s.thcfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(0x385) and c:IsType(TYPE_XYZ) and c:IsReleasable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.thcfilter,1,true,nil,nil,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.thcfilter,1,1,true,nil,nil,tp)
	Duel.Release(g,REASON_COST)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(s.tgfilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetValue(aux.tgoval)
	Duel.RegisterEffect(e2,tp)
end
function s.tgfilter(e,c)
	return c:IsFaceup() and c:IsSetCard(0x385)
end

--TRIBUTED EFFECT

function s.addfilter(c)
	return c:IsSetCard(0x385) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.addfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.addfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,re,r,rp,0,0)
		end
	end
end