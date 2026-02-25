--Necroidian Grimalsveil
--Scripted by Beanbag
local s,id=GetID()
Duel.LoadScript('BeanbagsAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[Fusion.AddProcMixRep(c,true,true,s.ffilter,4,99,aux.FilterBoolFunction(Card.IsCode,999103))--]]
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_FUSION_MATERIAL)
	e0:SetDescription(aux.Stringid(id,3))
	e0:SetCondition(Fusion.ConditionMixRep(true,true,s.ffilter1,4,4,aux.FilterBoolFunction(Card.IsCode,999103)))
	e0:SetOperation(Fusion.OperationMixRep(true,true,s.ffilter1,4,4,aux.FilterBoolFunction(Card.IsCode,999103)))
	c:RegisterEffect(e0)
	local e0a=e0:Clone()
	e0a:SetDescription(aux.Stringid(id,4))
	e0a:SetCondition(Fusion.ConditionMixRep(true,true,s.ffilter1,5,5,aux.FilterBoolFunction(Card.IsCode,999103)))
	e0a:SetOperation(Fusion.OperationMixRep(true,true,s.ffilter1,5,5,aux.FilterBoolFunction(Card.IsCode,999103)))
	c:RegisterEffect(e0a)
	local e0b=e0:Clone()
	e0b:SetDescription(aux.Stringid(id,5))
	e0b:SetCondition(Fusion.ConditionMixRep(true,true,s.ffilter1,6,6,aux.FilterBoolFunction(Card.IsCode,999103)))
	e0b:SetOperation(Fusion.OperationMixRep(true,true,s.ffilter1,6,6,aux.FilterBoolFunction(Card.IsCode,999103)))
	c:RegisterEffect(e0b)
	local e0c=e0:Clone()
	e0c:SetDescription(aux.Stringid(id,6))
	e0c:SetCondition(Fusion.ConditionMixRep(true,true,s.ffilter1,7,7,aux.FilterBoolFunction(Card.IsCode,999103)))
	e0c:SetOperation(Fusion.OperationMixRep(true,true,s.ffilter1,7,7,aux.FilterBoolFunction(Card.IsCode,999103)))
	c:RegisterEffect(e0c)
	local e0d=e0:Clone()
	e0d:SetDescription(aux.Stringid(id,7))
	e0d:SetCondition(Fusion.ConditionMixRep(true,true,s.ffilter1,8,8,aux.FilterBoolFunction(Card.IsCode,999103)))
	e0d:SetOperation(Fusion.OperationMixRep(true,true,s.ffilter1,8,8,aux.FilterBoolFunction(Card.IsCode,999103)))
	c:RegisterEffect(e0d)
	--Set its original ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.sucop)
	c:RegisterEffect(e1)
	--Unaffected by your opponent's activated monster effects, unless they target this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	--If a monster(s) is Tributed: Banish
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3:SetLabelObject(g)
	--Keep track of monsters sent to your opponent's GY
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3a:SetCode(EVENT_RELEASE)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetLabelObject(e3)
	e3a:SetOperation(s.regop)
	c:RegisterEffect(e3a)
	--Draw 1 card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.drwcost)
	e4:SetTarget(s.drwtg)
	e4:SetOperation(s.drwop)
	c:RegisterEffect(e4)
end

--Fusion Materials
--[[function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
    return c:IsSetCard(SET_NECROIDIA,fc,sumtype,tp) and c:IsMonster() and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,code,fc,sumtype,tp)
    return c:IsSummonCode(fc,sumtype,tp,code) and not c:IsHasEffect(511002961)
end--]]

function s.ffilter1(c,fc,sumtype,sub,mg,sg)
    local tp=fc:GetControler()
    local code=c:GetCode(fc,SUMMON_TYPE_FUSION,tp)
    return c:IsSetCard(SET_NECROIDIA,fc,SUMMON_TYPE_FUSION,tp) and code>0 and (not sg or (#sg>0 and not sg:IsExists(s.fusfilter,1,c,code,fc,tp)))
end

function s.fusfilter(c,code,fc,tp)
    return c:IsSummonCode(fc,SUMMON_TYPE_FUSION,tp,code) and not c:IsHasEffect(511002961)
end


--Contact Fusion
function s.cfilter(c)
	if c:IsLocation(LOCATION_REMOVED) and not c:IsFaceup() then return false end
    if c:IsCode(999103) then
        return c:IsReleasable() and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
    end
    return c:IsAbleToDeckOrExtraAsCost() and c:IsMonster()
end

function s.contactfil(tp)
    return Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
end

function s.contactop(g,tp)
    local tg=g:Filter(Card.IsCode,nil,999103)
    if #tg>0 then
        local tc=tg:Select(tp,1,1,nil):GetFirst()
        g:RemoveCard(tc)
        if tc:IsFacedown() then Duel.ConfirmCards(1-tp,tc) end
        Duel.Release(tc,REASON_COST|REASON_MATERIAL)
    end
    if #g==0 then return end
    local fu,fd=g:Split(Card.IsFaceup,nil)
    if #fu>0 then Duel.HintSelection(fu,true) end
    if #fd>0 then Duel.ConfirmCards(1-tp,fd) end
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end

--Apply ATK/DEF
function s.sucop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsSpecialSummoned() then return end
    local mats=c:GetMaterial()
    local deck_mats=mats:Filter(function(tc) return tc:IsLocation(LOCATION_DECK) end, nil)
    local val=deck_mats:GetCount()*1000
    -- Set ATK
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetValue(val)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
    c:RegisterEffect(e1)
    -- Set DEF
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_BASE_DEFENSE)
    c:RegisterEffect(e2)
end

--Unless target
function s.immval(e,re)
	local c=e:GetHandler()
	if not (re:IsActivated() and re:IsActiveType(TYPE_MONSTER) and e:GetOwnerPlayer()==1-re:GetOwnerPlayer()) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(c)
end

--Cards are Tributed
function s.tribfilter(c)
	return c:IsReason(REASON_RELEASE)
end
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=e:GetLabelObject():Filter(s.tribfilter,nil)
	local rm=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if chk==0 then return not c:HasFlagEffect(id-1) and #g>0 and #rm>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rm,1,PLAYER_ALL,LOCATION_GRAVE)
	c:RegisterFlagEffect(id-1,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ct=e:GetLabelObject()
	local rm=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if #ct==0 or #rm==0 then return end
	local sg=rm:Select(tp,1,#ct,nil)
	if #sg>0 then
		Duel.HintSelection(sg)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.tribfilter,nil)
	if #tg>0 then
		for tc in tg:Iter() do
				tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
			end
			local g=e:GetLabelObject():GetLabelObject()
			if Duel.GetCurrentChain()==0 then g:Clear() end
			g:Merge(tg)
			g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
			e:GetLabelObject():SetLabelObject(g)
			if #g>0 and not Duel.HasFlagEffect(tp,id) then
				Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
				Duel.RaiseEvent(g,EVENT_CUSTOM+id,re,r,tp,ep,ev)
		end
	end
end


--Tribute and Draw
function s.drwfilter(c)
    return c:IsMonster() and c:IsReleasable()
end
function s.drwcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.drwfilter,tp,LOCATION_MZONE|LOCATION_HAND,LOCATION_MZONE,nil)
    if chk==0 then return #mg>0 and aux.SelectUnselectGroup(mg,e,tp,1,1,nil,0) end
    local g=aux.SelectUnselectGroup(mg,e,tp,1,1,nil,1,tp,HINTMSG_RELEASE,nil,nil,true)
    Duel.Release(g,REASON_COST)
end

function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end