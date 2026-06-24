--Maelstrom Admiral - Ansgar
local s,id=GetID()

function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),10,2)
    c:EnableReviveLimit()

    --Alternative Xyz Summon
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.xyzcon)
    e0:SetOperation(s.xyzop)
    e0:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e0)

    --Detach -> send random card from opponent Extra Deck to GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.xycon)
    e1:SetCost(s.xyzcost)
    e1:SetTarget(s.xytg)
    e1:SetOperation(s.xyop)
    c:RegisterEffect(e1)

    --Negate + shuffle + optional Synchro Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

---------------------------------------------------
-- Xyz Summon check
function s.xycon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.xyzcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
    end
    c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.xytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_EXTRA)
end

function s.xyop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
    if #g==0 then return end

    local tc=g:RandomSelect(tp,1):GetFirst()
    if tc then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end

---------------------------------------------------
-- Negation condition
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and Duel.IsChainNegatable(ev)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end

    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)

    if re:GetHandler():IsDestructable() then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

---------------------------------------------------
-- Maelstrom Synchro filters
function s.synchrofilter(c,e,tp,mg)
    return c:IsSetCard(0x2B67)
        and c:IsType(TYPE_SYNCHRO)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
        and c:IsSynchroSummonable(nil,mg)
end

function s.matfilter(c)
    return c:IsSetCard(0x2B67)
        and c:IsFaceup()
        and c:IsType(TYPE_MONSTER)
end

---------------------------------------------------
-- Negate + shuffle + optional Synchro Summon
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    if Duel.NegateActivation(ev) then
        if re:GetHandler():IsRelateToEffect(re) then
            Duel.Destroy(eg,REASON_EFFECT)
        end
    end

    if c:IsRelateToEffect(e) and c:IsFaceup() then
        Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end

    Duel.BreakEffect()

    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
    if #mg==0 then return end

    local sg=Duel.GetMatchingGroup(
        s.synchrofilter,
        tp,
        LOCATION_EXTRA,
        0,
        nil,
        e,
        tp,
        mg
    )

    if #sg==0 then return end

    if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=sg:Select(tp,1,1,nil):GetFirst()

    if sc then
        Duel.SynchroSummon(tp,sc,nil,mg)
    end
end

---------------------------------------------------
-- "Maelstrom" card
function s.maelstromfilter(c)
    return c:IsSetCard(0x2B67) and c:IsAbleToDeck()
end

---------------------------------------------------
-- Level 10 Maelstrom Synchro
function s.xyzmatfilter(c)
    return c:IsFaceup()
        and c:IsSetCard(0x2B67)
        and c:IsType(TYPE_SYNCHRO)
        and c:IsLevel(10)
end

function s.xyzcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()

    return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        and Duel.IsExistingMatchingCard(s.xyzmatfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.maelstromfilter,tp,LOCATION_GRAVE,0,3,nil)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectMatchingCard(tp,s.maelstromfilter,tp,LOCATION_GRAVE,0,3,3,nil)
    if #g~=3 then return end

    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local mg=Duel.SelectMatchingCard(tp,s.xyzmatfilter,tp,LOCATION_MZONE,0,1,1,nil)

    c:SetMaterial(mg)
    Duel.Overlay(c,mg)
end