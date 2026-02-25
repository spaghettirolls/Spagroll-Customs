--Necroidian Caprustaur
--Scripted by Beanbag
local s,id=GetID()
Duel.LoadScript('BeanbagsAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddNecroidiaTributeEffect(c,id,0,s.destg,s.desop)
	aux.AddNecroidiaStandby(c,id)
	--Cannot Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,3})
	e1:SetCondition(s.spproccon)
	e1:SetTarget(s.spproctg)
	e1:SetOperation(s.spprocop)
	c:RegisterEffect(e1)
	--Register Special Summons from the Extra Deck
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsSummonLocation(LOCATION_EXTRA) then
			local sp=tc:GetSummonPlayer()
			if sp==tp then
			Duel.RegisterFlagEffect(sp,id,RESET_PHASE|PHASE_END,0,1)
			if Duel.HasFlagEffect(sp,id,2) then
				Duel.RegisterFlagEffect(sp,id+15,RESET_PHASE|PHASE_END,0,2)
				end
			end
		end
	end
end

-- Filter for tribute materials
function s.tdfilter(c)
	return c:IsSetCard(SET_NECROIDIA) and c:IsMonster() and c:IsAbleToDeckOrExtraAsCost() and not c:IsCode(id)
end

-- Summon condition: check space, materials, and counter
function s.spproccon(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    local rg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,e:GetHandler())
    return not Duel.HasFlagEffect(tp,id+15) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.dncheck,0)
end

-- Select tribute materials
function s.spproctg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,e:GetHandler())
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.dncheck,1,tp,HINTMSG_TODECK,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

-- Perform the tribute and apply summon lock
function s.spprocop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.HintSelection(g,true)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
	-- Apply summon lock with a dynamic condition
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.HasFlagEffect(tp,id) end)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se) return c:IsLocation(LOCATION_EXTRA) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
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
	return c:IsSetCard(SET_NECROIDIA) and c:IsMonster() and c:IsAbleToGraveAsCost() and not c:IsCode(id)
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
