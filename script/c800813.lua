    local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1)
    e1:SetCost(s.rcost)
    e1:SetCondition(s.rcon)
    e1:SetTarget(s.rtg)
    e1:SetOperation(s.rop)
    c:RegisterEffect(e1)
    local params = {nil,nil,function(e,tp,mg) return nil,s.fcheck end}
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_REMOVED)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.fscost)
    e2:SetTarget(Fusion.SummonEffTG(fusparam))
    e2:SetOperation(Fusion.SummonEffOP(fusparam))
    c:RegisterEffect(e2)
end

--NEGATE BANISH ATTACH

function s.xyzfilter(c)
    return c:IsType(TYPE_XYZ) and c:IsSetCard(0x3A5) and c:IsFaceup()
end

function s.rcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local g=Group.CreateGroup()
    local mg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(mg) do
        if --[[tc:IsSetCard(0x3A5) and]] tc:IsAbleToRemoveAsCost() then 
            g:Merge(tc:GetOverlayGroup())
        end
    end
    if chk==0 then return #g>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
    local sg=g:Select(tp,1,1,nil)
    Duel.Remove(sg,POS_FACEUP,REASON_COST)
    Duel.RaiseSingleEvent(sg:GetFirst(),EVENT_DETACH_MATERIAL,e,0,0,0,0)
end

function s.filter(c)
    return c:IsType(TYPE_XYZ) and c:IsSetCard(0x3A5) and c:IsFaceup()
end

function s.rcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_MONSTER)
end
function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=re:GetHandler()
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
    if Duel.NegateEffect(ev) and #g>0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
        local dg=g:Select(tp,1,1,nil)
        Duel.HintSelection(dg)
        rc:CancelToGrave()
        Duel.Overlay(dg:GetFirst(),rc,true)
      
    end
end

-- FUSION SUMMON COST

function s.fsfilter(c)
    return c:IsMonster() and c:IsSetCard(0x3A5) and c:IsAbleToDeckAsCost()
end

function s.fscost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToDeckAsCost() and Duel.IsExistingMatchingCard(s.fsfilter,tp,LOCATION_REMOVED,0,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.fsfilter,tp,LOCATION_REMOVED,0,1,1,c)
    g:AddCard(c)
    Duel.SendtoDeck(g,nil,2,REASON_COST)
end

function s.fcheck(tp,sg,fc)
    return sg:IsExists(Card.IsSetCard(0x3A5),1,nil)
end