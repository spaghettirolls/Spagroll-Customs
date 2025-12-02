--Phantasm of the Deepest Blue
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    --Negate effects of opponent's Fish monsters while you control Umi
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetTarget(s.distg)
    c:RegisterEffect(e1)
    
    --Send this card + Umi to GY; banish all opponent's S/Ts in GY, then opponent special summons a Fish from either GY to their field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
    
    --Banish this card from GY; add 1 "Umi"-related S/T from deck, except itself
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

--Filter for disabling opponent's Fish monsters
function s.distg(e,c)
    return c:IsRace(RACE_FISH) and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,22702055),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end

--Target for sending to GY + banishing
function s.umifilter(c)
    return c:IsFaceup() and c:IsCode(22702055) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGrave()
        and Duel.IsExistingMatchingCard(s.umifilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)>0
        and Duel.IsExistingMatchingCard(Card.IsRace,tp,0,LOCATION_GRAVE,1,nil,RACE_FISH) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.umifilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    if c:IsRelateToEffect(e) and #g>0 then
        g:AddCard(c)
        if Duel.SendtoGrave(g,REASON_EFFECT)==2 then
            local rm=Duel.GetMatchingGroup(Card.IsType,1-tp,LOCATION_GRAVE,0,nil,TYPE_SPELL+TYPE_TRAP)
            if #rm>0 then
                Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)
            end
            local sg=Duel.SelectMatchingCard(1-tp,Card.IsRace,1,1,nil,RACE_FISH)
            if #sg>0 then
                Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP) -- now explicitly to opponent's field
            end
        end
    end
end

--Filter for "Umi"-related Spell/Trap, excluding itself
function s.thfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:ListsCode(22702055) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
