--Poltiquette Bansheedle
--Scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,0})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.actcost)
    e3:SetTarget(s.acttg)
    e3:SetOperation(s.actop)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,{id,2})
    e4:SetCost(aux.bfgcost)
    e4:SetTarget(s.atg)
    e4:SetOperation(s.aop)
    c:RegisterEffect(e4)
end

function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
    Duel.SendtoGrave(c,REASON_COST)
end

--activate from the hand as new chain
function s.actfilter(c,e,tp)
    if not c:IsContinuousTrap() then return end
    return c:IsSetCard(0x3D4) and c:CheckActivateEffect(false,false,false)~=nil and c:IsContinuousTrap()
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.actfilter,tp,LOCATION_HAND,0,nil,e,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if not sc then return end
    --activate
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EVENT_CHAIN_END)
    e1:SetCountLimit(1)
    e1:SetLabelObject(sc)
    e1:SetOperation(s.faop)
    Duel.RegisterEffect(e1,tp)
    sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,0)
end

function s.faop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc then return end
    local te=tc:GetActivateEffect()
    local tep=tc:GetControler()
    if not te then return end
    local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
    if pre[1] then
        for i,eff in ipairs(pre) do
            local prev=eff:GetValue()
            if type(prev)~='function' or prev(eff,te,tep) then return end
        end
    end
    if tc:GetFlagEffect(id)==0 then return false end
    Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
    if te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep) then
        Duel.BreakEffect()
        Duel.Activate(te)
        Duel.BreakEffect()
        tc:ResetFlagEffect(id)
    end
    e:Reset()
end

function s.tdfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x3D4) and c:IsSpellTrap() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil)
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
    Duel.ShuffleDeck(tp)
    Duel.BreakEffect()
    Duel.Draw(tp,1,REASON_EFFECT)
    end
end
function s.afilter(c)
    return c:IsSetCard(0x3D4) and c:IsContinuousTrap() and c:IsFaceup() and c:IsAbleToHand()
end
function s.atg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED+LOCATION_GRAVE)
end
function s.aop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.afilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end