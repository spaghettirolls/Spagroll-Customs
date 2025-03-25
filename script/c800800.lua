

-- Nebulamia -Hive Worker Vexelphis


local s,id=GetID()
function s.initial_effect(c)
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e1:SetCode(EVENT_REMOVE)
e1:SetProperty(EFFECT_FLAG_DELAY)
e1:SetCountLimit(1,id)
e1:SetCost(s.cost)
e1:SetTarget(s.tgtg)
e1:SetOperation(s.tgop)
c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
e2:SetCategory(CATEGORY_REMOVE)
e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e2:SetProperty(EFFECT_FLAG_DELAY)
e2:SetCode(EVENT_BE_MATERIAL)
e2:SetCountLimit(1,{id,1})
e2:SetCondition(s.fcon)
e2:SetTarget(s.ftg)
e2:SetOperation(s.fop)
c:RegisterEffect(e2)
end



-- SELF BANISH EFFECT

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    if chk==0 then return tc and tc:IsAbleToRemoveAsCost() end
    Duel.Remove(tc,POS_FACEUP,REASON_COST)
    e:SetLabelObject(tc)
end


function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=e:GetLabelObject()
	if sg:GetSetCard()~=0x3A5 or sg:IsCode(800800) then return end
	if not c:IsRelateToEffect(e) then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then 
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end

-- FUSION EFFECT

function s.fcon(e,tp,eg,ep,ev,re,r,rp)
 return r==REASON_FUSION and e:GetHandler():IsLocation(LOCATION_GRAVE)
end

function s.ffilter(c)
	return c:IsSetCard(0x3A5) and not c:IsCode(800800) and c:IsAbleToRemove()
end

function s.ftg(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end

function s.fop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and
	 	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
	 Duel.Draw(tp,1,REASON_EFFECT)
    end
end
