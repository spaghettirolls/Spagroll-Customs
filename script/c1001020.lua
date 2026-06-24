--Maelstrom Dragon - Depthkraken
local s,id=GetID()

function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),12,3)

    --Alternative Xyz Summon Procedure
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.xyzcon)
    e0:SetOperation(s.xyzop)
    e0:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e0)

    --If Xyz Summoned: Detach 1; destroy all opponent's monsters
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.descon)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    --Quick Effect: Shuffle into Extra Deck; SS up to 3 Warrior/Fish Maelstrom monsters
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.spcon)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

--Archetype filter
function s.maelstromfilter(c)
    return c:IsSetCard(0x2B67)
end

--Alternative Xyz Material
function s.ovfilter(c,tp,xyzc)
    return c:IsFaceup()
        and c:IsType(TYPE_SYNCHRO)
        and c:IsLevel(12)
        and c:IsSetCard(0x2B67)
        and c:IsCanBeXyzMaterial(xyzc,tp)
end

--Alternative Xyz Summon Condition
function s.xyzcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()

    return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,1,nil,tp,c)
        and Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x2B67)>=5
end

--Alternative Xyz Summon Operation
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x2B67)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local rg=g:Select(tp,5,5,nil)
    Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_MATERIAL+REASON_XYZ)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local mg=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
    local tc=mg:GetFirst()

    local og=tc:GetOverlayGroup()
    if #og>0 then
        Duel.Overlay(c,og)
    end

    c:SetMaterial(Group.FromCards(tc))
    Duel.Overlay(c,Group.FromCards(tc))
end

--Xyz Summoned
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

--Destroy Target
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
    if chk==0 then
        return #g>0
            and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

--Destroy Operation
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)

    if #g==0 then return end
    if not c:IsRelateToEffect(e)
        or not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then
        return
    end

    c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
    Duel.Destroy(g,REASON_EFFECT)
end

--Quick Effect only if Xyz Summoned
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

--Cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsAbleToExtra()
    end
    Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

--Revival Filter
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x2B67)
        and (c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_FISH))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end

    ft=math.min(ft,3)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)

    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end