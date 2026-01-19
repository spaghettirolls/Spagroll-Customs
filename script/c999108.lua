--Necroidia War - Epilogue of the Vile
--Scripted by Beanbag
local s,id=GetID()
Duel.LoadScript('BeanbagsAux.lua')
function s.initial_effect(c)
	--Send 1 monster to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If you would Tribute a monster(s) to activate an "Necrooidia" monster's effect, you can banish this card from your GY instead
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(CARD_URSARCTIC_BIG_DIPPER)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(1,0)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsAbleToRemoveAsCost() end)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end

-- Hand filter: checks for monsters in hand that can be Special Summoned
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_NECROIDIA) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false) 
        and Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_DECK,0,1,nil,c)
end

-- Deck filter: checks for monsters in deck with a different name than the given card
function s.sendfilter(c,code)
    return c:IsSetCard(SET_NECROIDIA) and c:IsMonster() and c:GetCode()~=code:GetCode()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.handfilter(c,e,tp)
	return c:IsSetCard(SET_NECROIDIA) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.deckfilter(c)
	return c:IsSetCard(SET_NECROIDIA) and c:IsMonster()
end

function s.spselcheck(g,e,tp)
	local ct=#g
	local used={}
	for tc in g:Iter() do used[tc:GetCode()]=true end
	local dg=Duel.GetMatchingGroup(s.deckfilter,tp,LOCATION_DECK,0,nil)
	local valid=0
	local check={}
	for dc in dg:Iter() do
		local code=dc:GetCode()
		if not used[code] and not check[code] then check[code]=true valid=valid+1 end
	end
	return valid>=ct
end


function s.deckselcheck(g,e,tp)
	local used=e:GetLabelObject()
	local names={}
	for tc in g:Iter() do
		local code=tc:GetCode()
		if used[code] or names[code] then return false end
		names[code]=true
	end
	return true
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local hg=Duel.GetMatchingGroup(s.handfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if #hg==0 then return end
	local sg=aux.SelectUnselectGroup(hg,e,tp,1,ft,s.spselcheck,1,tp,HINTMSG_SPSUMMON,nil,nil,true)
	if not sg or #sg==0 then return end
	if Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)==0 then return end
	local used={}
	for tc in sg:Iter() do used[tc:GetCode()]=true end
	e:SetLabel(#sg)
	e:SetLabelObject(used)
	local dg=Duel.GetMatchingGroup(s.deckfilter,tp,LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=aux.SelectUnselectGroup(dg,e,tp,#sg,#sg,s.deckselcheck,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if tg then Duel.SendtoGrave(tg,REASON_EFFECT) end
end



function s.repval(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
	local c=e:GetHandler()
	return c:IsSetCard(SET_NECROIDIA) and c:IsMonster() and (extracon==nil or extracon(base,e,tp,eg,ep,ev,re,r,rp))
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Remove(base:GetHandler(),POS_FACEUP,REASON_COST|REASON_REPLACE)
end