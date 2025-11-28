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
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
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

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.plfilter(c)
	return c:IsCode(98715423) and not c:IsForbidden()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.GetLocationCount(tp,LOCATION_FZONE)>0
		and Duel.IsExistingMatchingCard(s.umifilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,s.umifilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND0,1,1,nil):GetFirst()
		if tc then
			Duel.BreakEffect()
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
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