--Necroidian Caprustaur
--Scripted by Beanbag

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- register tribute as cost
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_RELEASE)
	e0:SetCountLimit(1,{id,2})
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(s.necro_reg)
	c:RegisterEffect(e0)
	-- standby phase trigger
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e00:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e00:SetRange(LOCATION_GRAVE)
	e00:SetProperty(EFFECT_FLAG_DELAY)
	e00:SetCountLimit(1,{id,3})
	e00:SetCondition(s.necro_con)
	e00:SetTarget(s.necro_tg)
	e00:SetOperation(s.necro_op)
	c:RegisterEffect(e00)
	--Cannot Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Special Summon itself from the hand or GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(Cost.AND(Cost.SelfTribute,s.cost))
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end

function s.spconfilter(c)
	return c:IsSetCard(0x238C) and c:IsMonster() and c:IsAbleToDeckOrExtraAsCost() and not c:IsCode(id)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.spconfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_TODECK,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
	else
		Duel.HintSelection(g)
	end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end

function s.tribcostfilter(c)
	return c:IsSetCard(0x238C) and c:IsMonster() and c:IsLocation(LOCATION_HAND)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.tribcostfilter,1,true,nil,nil,0x238C) end
	local g=Duel.SelectReleaseGroupCost(tp,s.tribcostfilter,1,1,true,nil,nil,0x238C)
	Duel.Release(g,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_SZONE,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.thcostfilter(c)
	return c:IsSetCard(0x238C) and c:IsMonster() and c:IsAbleToGraveAsCost() and not c:IsCode(id)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_DECK,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_DECK,0,2,2,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end

-- Standby Effects
function s.necro_reg(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not re or not re:IsActivated() then return end
    if (r&REASON_COST)==0 then return end
    if not c:IsPreviousLocation(LOCATION_HAND+LOCATION_MZONE) then return end
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2,Duel.GetTurnCount())
end
function s.necro_con(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=c:GetFlagEffectLabel(id)
    return tc and Duel.GetTurnCount()==tc+1
end
function s.necro_tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) or c:IsAbleToHand()
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.necro_op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local ops={}
    local map={}
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
        ops[#ops+1]=aux.Stringid(id,0)
        map[#ops]=1
    end
    if c:IsAbleToHand() then
        ops[#ops+1]=aux.Stringid(id,1)
        map[#ops]=2
    end
    if #ops==0 then return end
    local sel=map[Duel.SelectOption(tp,table.unpack(ops))+1]
    if sel==1 then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    else
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    end
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.necro_df,tp,LOCATION_DECK,0,1,1,nil,c:GetCode())
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end
function s.necro_df(c,code)
    return c:IsSetCard(0x238C) and not c:IsCode(code) and c:IsAbleToGrave()
end
