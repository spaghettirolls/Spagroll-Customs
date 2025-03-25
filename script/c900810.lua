--Poltiquette's Invitation
--Scripted by Beanbag
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.gycost)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end
function s.gyfilter(c)
    return c:IsSetCard(0x3D4) and c:IsContinuousTrap() and c:IsAbleToGraveAsCost()
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end
function s.thfilter(c)
    return c:IsSpellTrap() and c:IsSetCard(0x3D4) and (c:IsAbleToGrave() or c:IsSSetable() and not c:IsCode(id))
end
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
    if not tc then return end
    aux.ToHandOrElse(tc,tp,Card.IsAbleToGrave,function(c) Duel.SendtoGrave(tc,REASON_EFFECT) end, aux.Stringid(id,0))
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsSetCard(0x3D4)
end
