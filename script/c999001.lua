--Holysphere Congregation
--Scripted by Beanbag (Aimer was here)

local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Ritual.AddProcGreater{handler=c,filter=s.ritualfil,matfilter=s.matfilter,extrafil=s.extragroup,extraop=s.extraop,location=LOCATION_HAND|LOCATION_GRAVE,forcedselection=s.tributelimit,stage2=s.stage2}
    e1:SetCost(s.spcost)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
    --Return to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.spcon)
    e2:SetCost(s.spcost)    
    e2:SetTarget(s.rthtg)
    e2:SetOperation(s.rthop)
    c:RegisterEffect(e2)
end

s.listed_series={0x270F}
s.listed_names={999000}

--Cannot Special Cost
function s.counterfilter(c)
    return c:IsSetCard(0x270F)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,999000),tp,LOCATION_ONFIELD,0,1,nil)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetLabelObject(e)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1,tp)
    aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsSetCard(0x270F)
end


--Material Filters
function s.ritualfil(c)
    return c:IsSetCard(0x270F) and c:IsRitualMonster()
end
function s.matfilter(c)
    return c:IsReleasableByEffect() and c:IsMonster() and c:IsCanBeRitualMaterial() and ((c:IsSetCard(0x270F) and c:IsLocation(LOCATION_DECK)) or (c:IsLocation(LOCATION_HAND|LOCATION_MZONE)))
end
function s.deckmatfilter(c)
    return c:IsSetCard(0x270F) and c:IsReleasableByEffect() and c:IsCanBeRitualMaterial()
end

--Return Handlimit is above 0/Different name check function
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
    local handlim=6
    local hls=Duel.GetPlayerEffect(tp,EFFECT_HAND_LIMIT)
    if hls then
        local value=hls:GetValue()
        if type(value)=="function" then
            handlim=value(hls,e,tp,sc)
        else
            handlim=value
        end
    end
    if handlim<=0 or Duel.GetFlagEffect(tp,id)>0 then return end
    local g=Duel.GetMatchingGroup(s.deckmatfilter,tp,LOCATION_DECK,0,nil)
    local newgroup=Group.CreateGroup()
    local nametable={}
    for tc in aux.Next(g) do
        local name=tc:GetCode()
        if not nametable[name] then
            nametable[name]=true
            newgroup:AddCard(tc)
        end
    end
    return newgroup
end

--Release Extra Group from Deck
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
    mat:Sub(mat2)
    Duel.ReleaseRitualMaterial(mat)
    Duel.SendtoGrave(mat2,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL|REASON_RELEASE)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end


--Force Allow Deck Materials up to your Handlimit Size
function s.tributelimit(e,tp,g,sc)
    -- Get the hand limit or set it to 6 by default
    local handlim=6
    local hls={Duel.GetPlayerEffect(tp,EFFECT_HAND_LIMIT)}
    for _,eff in ipairs(hls) do
        if eff~=e then
            local value=eff:GetValue()
            if type(value)=="function" then
                value=value(eff,e,tp,c) -- Call the function to get the value
            end
            if type(value)=="number" then
                handlim=value --Become the value
            end
        end
    end
    -- Calculate deck material and compare to hand limit
    local deckmat=g:Filter(Card.IsLocation,nil,LOCATION_DECK)
    return #deckmat<=handlim,#deckmat>handlim
end


--Lose LP equal to # Sent from Deck*500
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,sc)
    -- Get the hand limit or set it to 6 by default
    local c=e:GetHandler()
    local handlim=6
    local hls={Duel.GetPlayerEffect(tp,EFFECT_HAND_LIMIT)}
    for _,eff in ipairs(hls) do
        if eff~=e then
            local value=eff:GetValue()
            if type(value)=="function" then
                value=value(eff,e,tp,c) -- Call the function to get the value
            end
            if type(value)=="number" then
                handlim=value -- Become the value
            end
        end
    end
    local ct=mg:FilterCount(Card.IsPreviousLocation,nil,LOCATION_DECK)
    if ct>0 then 
        Duel.SetLP(tp,Duel.GetLP(tp)-(ct*500))
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_HAND_LIMIT)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetValue(handlim-ct)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_ADJUST)
        e2:SetCondition(s.adjcon)
        e2:SetOperation(s.adjop)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)
        -- Init internal state
        local state={presence={[999000]=true,[999011]=true},triggered=false}
        e2:SetLabelObject(state)
    end
end

function s.adjcon(e,tp,eg,ev,ep,re,r,rp)
    return true
end

function s.adjop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local state=e:GetLabelObject()
    if not state.prevFaceupCount then state.prevFaceupCount=0 end
    if state.triggered then return end
    local g999000=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,999000),tp,LOCATION_MZONE,0,nil)
    local g999011=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,999011),tp,LOCATION_FZONE,0,nil)
    local faceup999000=g999000
    local faceup999011=g999011
    local prevFaceup999000=state.prevFaceupCount
    local prevHad999011=state.presence[999011]
    local card1=g999000:GetFirst()
    local card2=g999011:GetFirst()
    -- Check if all 999000s left field
    local leftAll999000=(prevFaceup999000>0 and g999000:GetCount()==0)
    -- Check if any were flipped facedown
    local facedown999000=(prevFaceup999000>0 and faceup999000:GetCount()<prevFaceup999000)
    -- Check for 999011 leaving/flipping
    local left999011=prevHad999011 and g999011:GetCount()==0
    local facedown999011=card2 and prevHad999011==true and not card2:IsFaceup()
    if leftAll999000 or facedown999000 or left999011 or facedown999011 then
        state.triggered=true
        local handlim=6
        local hls={Duel.GetPlayerEffect(tp,EFFECT_HAND_LIMIT)}
        for _,eff in ipairs(hls) do
            if eff~=e then
                local value=eff:GetValue()
                if type(value)=="function" then value=value(eff,e,tp,c) end
                if type(value)=="number" then handlim=value end
            end
        end
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_HAND_LIMIT)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetValue(handlim-2)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
    -- Update state
    state.prevFaceupCount=faceup999000:GetCount()
    state.presence[999000]=card1 and card1:IsFaceup() or false
    state.presence[999011]=card2 and card2:IsFaceup() or false
end




--Return to hand
function s.rthfilter(c)
    return c:IsSetCard(0x270F) and c:IsMonster() and c:IsAbleToDeck()
end


function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.rthfilter,tp,LOCATION_GRAVE,0,c,e,tp)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.rthfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingMatchingCard(s.rthfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
    local tg=aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,1,tp,HINTMSG_TODECK)
    Duel.SetTargetCard(tg)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

function s.rthop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetTargetCards(e)
    local sg=g:Filter(Card.IsRelateToEffect,nil,e)
    if #sg>0 and Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end