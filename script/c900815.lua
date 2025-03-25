--The Scourge of Geas-Atma
--Scripted by Aimer
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Banish and target
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end

--Send to Grave Cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsContinuousSpellTrap,Card.IsAbleToGraveAsCost),tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsContinuousSpellTrap,Card.IsAbleToGraveAsCost),tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

--Apply Continuous
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetCountLimit(1,{id,2})
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--To Hand/Else
	if Duel.GetFlagEffect(tp,id+1)>0 then return end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1,{id,3})
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
end



function s.discon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
    local ec=re:GetHandler()
    return loc==LOCATION_GRAVE or ec:IsLocation(LOCATION_GRAVE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id)>0 then return end
    local ec=re:GetHandler()
    Duel.Hint(HINT_CARD,0,id)
    Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESET_PHASE+PHASE_END,0,0)
    if Duel.NegateEffect(ev) then
        Duel.Remove(ec,POS_FACEDOWN,REASON_EFFECT)
    end
end

-- To Hand/or Else
function s.setfilter(c)
	return c:IsFaceup() and c:IsSpellTrap() and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0x3D4) and (c:IsAbleToHand() or c:IsSSetable())
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(tp,id+1)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if not tc then return end
	aux.ToHandOrElse(tc,tp,
		Card.IsSSetable,
		function(c)
			Duel.SSet(tp,tc)
		end,
		aux.Stringid(id,1)
	)
end

--Atk/Def Change
function s.atkfilter(c)
	return c:IsAttackAbove(1000) and c:IsDefenseAbove(1000) and c:IsFaceup() and c:IsType(RACE_FIEND) and c:IsType(TYPE_FUSION)
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end

-- Incremental change
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc:IsFaceup() and tc:IsRelateToEffect(e) then
        -- Get the current attack and defense of the target monster
        local currentATK = tc:GetAttack()
        local currentDEF = tc:GetDefense() 
        -- Calculate the maximum number of increments allowed based on the current ATK and DEF
        local maxIncrementsATK = math.floor(currentATK / 1000)
        local maxIncrementsDEF = math.floor(currentDEF / 1000)
        local maxIncrements = math.min(3, maxIncrementsATK, maxIncrementsDEF)  
        -- Check if there are enough cards in the deck to send
        local numCardsDeck = Duel.GetFieldGroupCount(tp,LOCATION_DECK,0) 
        -- Adjust the maximum number of increments if necessary based on the number of cards in the deck
        maxIncrements = math.min(maxIncrements, numCardsDeck)
        if maxIncrements > 0 then
            -- Prompt user for the number of increments (max 3)
            local increments = Duel.AnnounceNumber(tp,1,maxIncrements)
            -- Reduce attack and defense in increments of 1000
            for i=1,increments do
                if tc:IsFaceup() and tc:IsRelateToEffect(e) then
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_UPDATE_ATTACK)
                    e1:SetValue(-1000)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    tc:RegisterEffect(e1)
                    local e2=e1:Clone()
                    e2:SetCode(EFFECT_UPDATE_DEFENSE)
                    tc:RegisterEffect(e2)
                    Duel.AdjustInstantly(tc)
                end
            end
            if currentATK>tc:GetAttack() and currentDEF>tc:GetDefense() then
				Duel.BreakEffect()
				Duel.DiscardDeck(tp,increments,REASON_EFFECT)
			end
        end
    end
end
