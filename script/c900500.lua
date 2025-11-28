--Fisherman of the Deepest Blue
--scripted by beanbag

local s,id=GetID()
function s.initial_effect(c)
    -----------------------------
    -- Always treated as "The Legendary Fisherman"
    -----------------------------
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetRange(LOCATION_ALL)
    e0:SetCode(EFFECT_ADD_CODE)
    e0:SetValue(24452200)
    c:RegisterEffect(e0)

    -----------------------------
    -- Place Umi & Special Summon this card
    -----------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.umi_tg)
    e1:SetOperation(s.umi_op)
    c:RegisterEffect(e1)

    -----------------------------
    -- Untargetable while Umi exists
    -----------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2:SetCondition(s.umicond)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.umicond)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)

    -----------------------------
    -- Quick Effect: Special Summon Fish
    -----------------------------
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetTarget(s.fish_tg)
    e4:SetOperation(s.fish_op)
    c:RegisterEffect(e4)

    -----------------------------
    -- End Phase: Recycle & Summon Fish
    -----------------------------
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_PHASE+PHASE_END)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,{id,2})
    e5:SetTarget(s.end_tg)
    e5:SetOperation(s.end_op)
    c:RegisterEffect(e5)
end

----------------------------------------------------------
-- Shared Umi Check
----------------------------------------------------------
function s.umicond(e)
    return Duel.IsEnvironment(22702055)
end

----------------------------------------------------------
-- First Effect: Place Umi + SS itself
----------------------------------------------------------
function s.umifilter(c)
    return c:IsCode(22702055) and c:IsFieldSpell()
end

function s.umi_tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        local g=Duel.IsExistingMatchingCard(s.umifilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        local can1=Duel.GetLocationCount(tp,LOCATION_FZONE)>0
        local can2=Duel.GetLocationCount(1-tp,LOCATION_FZONE)>0
        return g and (can1 or can2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
end

function s.umi_op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    
    -- Choose Umi
    local g=Duel.SelectMatchingCard(tp,s.umifilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g==0 then return end
    local umi=g:GetFirst()

    -- Choose field to place it
    local can1=Duel.GetLocationCount(tp,LOCATION_FZONE)>0
    local can2=Duel.GetLocationCount(1-tp,LOCATION_FZONE)>0
    local fp=nil

    if can1 and can2 then
        -- 0 = your field, 1 = opponent field
        local sel=Duel.SelectOption(tp,"Place on your field","Place on opponent's field")
        fp = (sel==0) and tp or (1-tp)
    elseif can1 then
        fp=tp
    else
        fp=1-tp
    end

    -- Place Umi
    Duel.MoveToField(umi,tp,fp,LOCATION_FZONE,POS_FACEUP,true)

    -- Special Summon this card
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

----------------------------------------------------------
-- Second Effect: Quick Summon Fish Monster(s)
----------------------------------------------------------
function s.fishfilter(c,e,tp,p)
    return c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end

function s.fish_tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct = Duel.IsEnvironment(22702055) and 2 or 1
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.fishfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,ct,nil,e,tp,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.fish_op(e,tp,eg,ep,ev,re,r,rp)
    local ct = Duel.IsEnvironment(22702055) and 2 or 1
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end

    local g=Duel.SelectMatchingCard(tp,s.fishfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,ct,ct,nil,e,tp,tp)
    if #g>0 then
        for tc in aux.Next(g) do
            -- choose field owner for summon
            local sel = Duel.SelectOption(tp,"Your field","Opponent's field")
            local fp = (sel==0) and tp or (1-tp)
            if Duel.GetLocationCount(fp,LOCATION_MZONE)>0 then
                Duel.SpecialSummonStep(tc,0,tp,fp,false,false,POS_FACEUP)
            end
        end
        Duel.SpecialSummonComplete()
    end

    -- Lock to Fish only
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return not c:IsRace(RACE_FISH) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

----------------------------------------------------------
-- Third Effect: End Phase – Recycle & Summon
----------------------------------------------------------
function s.recyclefilter(c)
    return c:IsRace(RACE_FISH) and c:IsAbleToDeck()
end

function s.end_tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.end_op(e,tp,eg,ep,ev,re,r,rp)
    local p=tp
    -- Recycle 1 Fish
    local g=Duel.SelectMatchingCard(p,s.recyclefilter,p,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end

    -- Special Summon 1 Fish to either field
    if Duel.GetLocationCount(p,LOCATION_MZONE)+Duel.GetLocationCount(1-p,LOCATION_MZONE)==0 then return end

    local g2=Duel.SelectMatchingCard(p,s.fishfilter,p,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,tp)
    if #g2>0 then
        local sel=Duel.SelectOption(tp,"Your field","Opponent's field")
        local fp=(sel==0) and tp or (1-tp)
        if Duel.GetLocationCount(fp,LOCATION_MZONE)>0 then
            Duel.SpecialSummon(g2:GetFirst(),0,tp,fp,false,false,POS_FACEUP)
        end
    end
end