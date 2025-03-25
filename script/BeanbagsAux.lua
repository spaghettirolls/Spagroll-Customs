--Beanbags Auxillary Functions

if not aux.BeanbagsAux then
    aux.BeanbagsAux = {}
    Beanbag = aux.BeanbagsAux
end

if not Beanbag then
    Beanbag = aux.BeanbagsAux
end

--Common used cards


--Common Setcards
SET_POLTI = 0x3D4
SET_NECROID = 0x238C

--Voltaic face-down Pendulum Summon
function Beanbag.AddFusionSpellProcMST(c,fusfilter,matfilter,extrafil,extraop,gc,stage2,exactcount,value,location,chkf,desc,preselect,nosummoncheck,extratg,mincount,maxcount,sumpos)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    if desc then
        e1:SetDescription(desc)
    else
        e1:SetDescription(1170)
    end
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(Beanbag.SummonEffTG(fusfilter,matfilter,extrafil,extraop,gc,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,extratg,mincount,maxcount,sumpos))
    e1:SetOperation(Beanbag.SummonEffOP(fusfilter,matfilter,extrafil,extraop,gc,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos))
    c:RegisterEffect(e1)
end


function Beanbag.SummonEffFilter(c,fusfilter,e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,sumpos,efmg)
    if efmg and #efmg>0 then
        if #(efmg:Match(Beanbag.GetExtraMatEff,nil,c))>0 then
            mg:Merge(efmg)
        end
    end
    return c:IsType(TYPE_FUSION) and (not fusfilter or fusfilter(c,tp)) and (nosummoncheck or c:IsCanBeSpecialSummoned(e,value,tp,sumlimit,false,sumpos))
            and c:CheckFusionMaterial(mg,gc,chkf)
end


function Beanbag.GetExtraMatEff(c,summon_card)
    local effs={c:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL)}
    for _,eff in ipairs(effs) do
        if eff~=geff then
            if not summon_card then
                return eff
            end
            local val=eff:GetValue()
            if (type(val)=="function" and val(eff,summon_card)) or val==1 then
                return eff
            end
        end
    end
end

function Beanbag.ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
    local extra_feff_mg=mg1:Filter(Beanbag.GetExtraMatEff,nil)
    if #extra_feff_mg>0 then
        local extra_feff=Beanbag.GetExtraMatEff(extra_feff_mg:GetFirst())
        --Check if you need to remove materials from the pool if count limit has been used
        if extra_feff and not extra_feff:CheckCountLimit(tp) then
            local extra_feff_loc=extra_feff:GetTargetRange()
            if extrafil then
                local extrafil_g=extrafil(e,tp,mg1)
                if extrafil_g and #extrafil_g>0 and not extrafil_g:IsExists(Card.IsLocation,1,nil,extra_feff_loc) then
                    mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
                    efmg:Clear()
                elseif not extrafil_g then
                    mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
                    efmg:Clear()
                end
            else
                mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
                efmg:Clear()
            end
        end
    elseif #efmg>0 then
        local extra_feff=Beanbag.GetExtraMatEff(efmg:GetFirst())
        if extra_feff and not extra_feff:CheckCountLimit(tp) then
            efmg:Clear()
        end
    end
    return mg1,efmg
end


function Beanbag.SummonEffTG(fusfilter,matfilter,extrafil,extraop,gc2,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos)
    sumpos = sumpos or POS_FACEUP
    return  function(e,tp,eg,ep,ev,re,r,rp,chk)
                location=location or LOCATION_EXTRA
                if not chkf or ((chkf&PLAYER_NONE)~=PLAYER_NONE) then
                    chkf=chkf and chkf|tp or tp
                end
                local sumlimit=(chkf&(FUSPROC_NOTFUSION|FUSPROC_NOLIMIT))~=0
                local notfusion=(chkf&FUSPROC_NOTFUSION)~=0
                if not value then value=0 end
                value = value|MATERIAL_FUSION
                if not notfusion then
                    value = value|SUMMON_TYPE_FUSION
                end
                local gc=gc2
                gc=type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc
                gc=type(gc)=="Card" and Group.FromCards(gc) or gc
                matfilter=matfilter or Card.IsAbleToGrave
                stage2 = stage2 or aux.TRUE
                if chk==0 then
                    --Separate the Fusion Materials filtered by matfilter
                    --and the ones with an EFFECT_EXTRA_FUSION_MATERIAL effect.
                    --Both will be passed to Beanbag.SummonEffFilter later.
                    local fmg_all=Duel.GetFusionMaterial(tp)
                    local mg1=fmg_all:Filter(matfilter,nil,e,tp,0)
                    local efmg=fmg_all:Filter(Beanbag.GetExtraMatEff,nil)
                    local checkAddition=nil
                    local repl_flag=false
                    local function spelltrapfilter(c)
                        return c:IsCanBeFusionMaterial() or (c:IsSpellTrap() and c:IsAbleToDeck() and c:IsSetCard(SET_POLTI))
                    end
                    if #efmg>0 then
                        local extra_feff=Beanbag.GetExtraMatEff(efmg:GetFirst())
                        if extra_feff and extra_feff:GetLabelObject() then
                            local repl_function=extra_feff:GetLabelObject()
                            repl_flag=true
                            -- no extrafil (Poly):
                            if not extrafil then
                                local ret = {repl_function[1](e,tp,mg1)}
                                if ret[1] then
                                    ret[1]:Match(matfilter,nil,e,tp,0)
                                    Beanbag.ExtraGroup=ret[1]:Filter(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
                                    mg1:Merge(ret[1])
                                end
                                checkAddition=ret[2]
                            -- extrafil but no fcheck (Shaddoll Fusion):
                            elseif extrafil then
                                local ret = {extrafil(e,tp,mg1)}
                                local repl={repl_function[1](e,tp,mg1)}
                                if ret[1] then
                                    repl[1]:Match(matfilter,nil,e,tp,0)
                                    ret[1]:Merge(repl[1])
                                    Beanbag.ExtraGroup=ret[1]:Filter(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
                                    mg1:Merge(ret[1])
                                end
                                if ret[2] then
                                    -- extrafil and fcheck (Cynet Fusion):
                                    checkAddition=aux.AND(ret[2],repl[2])
                                else
                                    checkAddition=repl[2]
                                end
                            end
                        end
                    end
                    if not repl_flag and extrafil then
                        local ret = {extrafil(e,tp,mg1)}
                        if ret[1] then
                            Beanbag.ExtraGroup=ret[1]:Filter(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
                            mg1:Merge(ret[1])
                        end
                        checkAddition=ret[2]
                    end
                    if gc and not mg1:Includes(gc) then
                        Beanbag.ExtraGroup=nil
                        return false
                    end
                    Beanbag.CheckAdditional=checkAddition
                    mg1:Match(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
                    Beanbag.CheckExact=exactcount
                    Beanbag.CheckMin=mincount
                    Beanbag.CheckMax=maxcount
                    mg1,efmg=Beanbag.ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
                    local res=Duel.IsExistingMatchingCard(Beanbag.SummonEffFilter,tp,location,0,1,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos,efmg)
                    Beanbag.CheckAdditional=nil
                    Beanbag.ExtraGroup=nil
                    if not res and not notfusion then
                        for _,ce in ipairs({Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}) do
                            local fgroup=ce:GetTarget()
                            local mg=fgroup(ce,e,tp,value)
                            if #mg>0 and (not Beanbag.CheckExact or #mg==Beanbag.CheckExact) and (not Beanbag.CheckMin or #mg>=Beanbag.CheckMin) then
                                local mf=ce:GetValue()
                                local fcheck=nil
                                if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
                                Beanbag.CheckAdditional=checkAddition
                                if fcheck then
                                    if checkAddition then Beanbag.CheckAdditional=aux.AND(checkAddition,fcheck) else Beanbag.CheckAdditional=fcheck end
                                end
                                Beanbag.ExtraGroup=mg
                                if Duel.IsExistingMatchingCard(Beanbag.SummonEffFilter,tp,location,0,1,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,sumpos) then
                                    res=true
                                    Beanbag.CheckAdditional=nil
                                    Beanbag.ExtraGroup=nil
                                    break
                                end
                                Beanbag.CheckAdditional=nil
                                Beanbag.ExtraGroup=nil
                            end
                        end
                    end
                    Beanbag.CheckExact=nil
                    Beanbag.CheckMin=nil
                    Beanbag.CheckMax=nil
                    return res
                end
                Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
                if extratg then extratg(e,tp,eg,ep,ev,re,r,rp,chk) end
            end
end











function Beanbag.SummonEff(fusfilter,matfilter,extrafil,extraop,gc2,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos)
    sumpos = sumpos or POS_FACEUP
    return  function(e,tp,eg,ep,ev,re,r,rp)
                location=location or LOCATION_EXTRA
                chkf = chkf and chkf|tp or tp
                if not preselect then chkf=chkf|FUSPROC_CANCELABLE end
                local sumlimit=(chkf&(FUSPROC_NOTFUSION|FUSPROC_NOLIMIT))~=0
                local notfusion=(chkf&FUSPROC_NOTFUSION)~=0
                if not value then value=0 end
                if not notfusion then
                    value = value|SUMMON_TYPE_FUSION|MATERIAL_FUSION
                end
                local gc=gc2
                gc=type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc
                gc=type(gc)=="Card" and Group.FromCards(gc) or gc
                matfilter=matfilter or Card.IsAbleToGrave
                stage2 = stage2 or aux.TRUE
                local checkAddition
                --Same as line 167 above
                local fmg_all=Duel.GetFusionMaterial(tp)
                local mg1=fmg_all:Filter(matfilter,nil,e,tp,1)
                local efmg=fmg_all:Filter(Beanbag.GetExtraMatEff,nil)
                local extragroup=nil
                local repl_flag=false
                local function spelltrapfilter(c)
                    return c:IsCanBeFusionMaterial() or (c:IsSpellTrap() and c:IsAbleToDeck() and c:IsSetCard(SET_POLTI))
                end
                if #efmg>0 then
                    local extra_feff=Beanbag.GetExtraMatEff(efmg:GetFirst())
                    if extra_feff and extra_feff:GetLabelObject() then
                        local repl_function=extra_feff:GetLabelObject()
                        repl_flag=true
                        -- no extrafil (Poly):
                        if not extrafil then
                            local ret = {repl_function[1](e,tp,mg1)}
                            if ret[1] then
                                ret[1]:Match(matfilter,nil,e,tp,1)
                                Beanbag.ExtraGroup=ret[1]:Filter(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
                                mg1:Merge(ret[1])
                            end
                            checkAddition=ret[2]
                        -- extrafil but no fcheck (Shaddoll Fusion):
                        elseif extrafil then
                            local ret = {extrafil(e,tp,mg1)}
                            local repl={repl_function[1](e,tp,mg1)}
                            if ret[1] then
                                repl[1]:Match(matfilter,nil,e,tp,1)
                                ret[1]:Merge(repl[1])
                                Beanbag.ExtraGroup=ret[1]:Filter(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
                                mg1:Merge(ret[1])
                            end
                            if ret[2] then
                                -- extrafil and fcheck (Cynet Fusion):
                                checkAddition=aux.AND(ret[2],repl[2])
                            else
                                checkAddition=repl[2]
                            end
                        end
                    end
                end
                if not repl_flag and extrafil then
                    local ret = {extrafil(e,tp,mg1)}
                    if ret[1] then
                        Beanbag.ExtraGroup=ret[1]:Filter(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
                        extragroup=ret[1]
                        mg1:Merge(ret[1])
                    end
                    checkAddition=ret[2]
                end
                mg1:Match(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
                if gc and (not mg1:Includes(gc) or gc:IsExists(Beanbag.ForcedMatValidity,1,nil,e)) then
                    Beanbag.ExtraGroup=nil
                    return false
                end
                Beanbag.CheckExact=exactcount
                Beanbag.CheckMin=mincount
                Beanbag.CheckMax=maxcount
                Beanbag.CheckAdditional=checkAddition
                local effswithgroup={}
                --Same as line 191 above
                mg1,efmg=Beanbag.ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
                local sg1=Duel.GetMatchingGroup(Beanbag.SummonEffFilter,tp,location,0,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos,efmg)
                if #sg1>0 then
                    table.insert(effswithgroup,{e,aux.GrouptoCardid(sg1)})
                end
                Beanbag.ExtraGroup=nil
                Beanbag.CheckAdditional=nil
                if not notfusion then
                    local extraeffs = {Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}
                    for _,ce in ipairs(extraeffs) do
                        local fgroup=ce:GetTarget()
                        local mg2=fgroup(ce,e,tp,value)
                        if #mg2>0 and (not Beanbag.CheckExact or #mg2==Beanbag.CheckExact) and (not Beanbag.CheckMin or #mg2>=Beanbag.CheckMin) then
                            local mf=ce:GetValue()
                            local fcheck=nil
                            if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
                            Beanbag.CheckAdditional=checkAddition
                            if fcheck then
                                if checkAddition then Beanbag.CheckAdditional=aux.AND(checkAddition,fcheck) else Beanbag.CheckAdditional=fcheck end
                            end
                            Beanbag.ExtraGroup=mg2
                            local sg2=Duel.GetMatchingGroup(Beanbag.SummonEffFilter,tp,location,0,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg2,gc,chkf,value,sumlimit,nosummoncheck,sumpos)
                            if #sg2 > 0 then
                                table.insert(effswithgroup,{ce,aux.GrouptoCardid(sg2)})
                                sg1:Merge(sg2)
                            end
                            Beanbag.CheckAdditional=nil
                            Beanbag.ExtraGroup=nil
                        end
                    end
                end
                if #sg1>0 then
                    local sg=sg1:Clone()
                    local mat1=Group.CreateGroup()
                    local sel=nil
                    local backupmat=nil
                    local tc=nil
                    local ce=nil
                    while #mat1==0 do
                        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                        tc=sg:Select(tp,1,1,nil):GetFirst()
                        if preselect and preselect(e,tc)==false then
                            return
                        end
                        sel=effswithgroup[Beanbag.ChainMaterialPrompt(effswithgroup,tc:GetCardID(),tp,e)]
                        if sel[1]==e then
                            Beanbag.CheckAdditional=checkAddition
                            Beanbag.ExtraGroup=extragroup
                            mat1=Duel.SelectFusionMaterial(tp,tc,mg1,gc,chkf)
                        else
                            ce=sel[1]
                            local fcheck=nil
                            if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
                            Beanbag.CheckAdditional=checkAddition
                            if fcheck then
                                if checkAddition then Beanbag.CheckAdditional=aux.AND(checkAddition,fcheck) else Beanbag.CheckAdditional=fcheck end
                            end
                            Beanbag.ExtraGroup=ce:GetTarget()(ce,e,tp,value)
                            mat1=Duel.SelectFusionMaterial(tp,tc,Beanbag.ExtraGroup,gc,chkf)
                        end
                    end
                    if sel[1]==e then
                        Beanbag.ExtraGroup=nil
                        backupmat=mat1:Clone()
                        if not notfusion then
                            tc:SetMaterial(mat1)
                        end
                        --Checks for the case that the Fusion Summoning effect has an "extraop"
                        local extra_feff_mg=mat1:Filter(Beanbag.GetExtraMatEff,nil,tc)
                        if #extra_feff_mg>0 and extraop then
                            local extra_feff=Beanbag.GetExtraMatEff(extra_feff_mg:GetFirst(),tc)
                            if extra_feff then
                                local extra_feff_op=extra_feff:GetOperation()
                                --If the operation of the EFFECT_EXTRA_FUSION_MATERIAL effect is different than "extraop",
                                --it's not OPT or it hasn't been used yet, and the player
                                --chooses to apply the effect, then select which cards
                                --the effect will be applied to and execute its operation.
                                if extra_feff_op and extraop~=extra_feff_op and extra_feff:CheckCountLimit(tp) then
                                    local flag=nil
                                    if extrafil then
                                        local extrafil_g=extrafil(e,tp,mg1)
                                        if #extrafil_g>=0 and not extrafil_g:IsExists(Card.IsLocation,1,nil,extra_feff:GetTargetRange()) then
                                            --The Fusion effect by default does not use the GY
                                            --so the player is forced to apply this effect.
                                            mat1:Sub(extra_feff_mg)
                                            extra_feff_op(e,tc,tp,extra_feff_mg)
                                            flag=true
                                        elseif #extrafil_g>=0 and Duel.SelectEffectYesNo(tp,extra_feff:GetHandler()) then
                                            --Select which cards you'll apply the
                                            --EFFECT_EXTRA_FUSION_MATERIAL effect to
                                            --and execute its operation.
                                            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVECARD)
                                            local g=extra_feff_mg:Select(tp,1,#extra_feff_mg,nil)
                                            if #g>0 then
                                                mat1:Sub(g)
                                                extra_feff_op(e,tc,tp,g)
                                                flag=true
                                            end
                                        end
                                    else
                                        --The Fusion effect by default does not use the GY
                                        --so the player is forced to apply this effect.
                                        mat1:Sub(extra_feff_mg)
                                        extra_feff_op(e,tc,tp,extra_feff_mg)
                                        flag=true
                                    end
                                    --If the EFFECT_EXTRA_FUSION_MATERIAL effect is OPT
                                    --then "use" its count limit.
                                    if flag and extra_feff:CheckCountLimit(tp) then
                                        extra_feff:UseCountLimit(tp,1)
                                    end
                                end
                            end
                        end
                        if extraop then
                            if extraop(e,tc,tp,mat1)==false then return end
                        end
                        if #mat1>0 then
                            --Split the group of selected materials to
                            --"extra_feff_mg" and "normal_mg", send "normal_mg"
                            --to the GY, and execute the operation of the
                            --EFFECT_EXTRA_FUSION_MATERIAL effect, if it existBeanbag.
                            --If it doesn't exist then send the extra materials to the GY.
                            local extra_feff_mg,normal_mg=mat1:Split(Beanbag.GetExtraMatEff,nil,tc)
                            local extra_feff
                            if #extra_feff_mg>0 then extra_feff=Beanbag.GetExtraMatEff(extra_feff_mg:GetFirst(),tc) end
                            if #normal_mg>0 then
                                normal_mg=normal_mg:AddMaximumCheck()
                                Duel.SendtoGrave(normal_mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
                            end
                            if extra_feff then
                                local extra_feff_op=extra_feff:GetOperation()
                                if extra_feff_op then
                                    extra_feff_op(e,tc,tp,extra_feff_mg)
                                else
                                    extra_feff_mg=extra_feff_mg:AddMaximumCheck()
                                    Duel.SendtoGrave(extra_feff_mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
                                end
                                --If the EFFECT_EXTRA_FUSION_MATERIAL effect is OPT
                                --then "use" its count limit.
                                if extra_feff:CheckCountLimit(tp) then
                                    extra_feff:UseCountLimit(tp,1)
                                end
                            end
                        end
                        Duel.BreakEffect()
                        Duel.SpecialSummonStep(tc,value,tp,tp,true,true,sumpos)
                    else
                        Beanbag.CheckAdditional=nil
                        Beanbag.ExtraGroup=nil
                        ce:GetOperation()(sel[1],e,tp,tc,mat1,value,nil,sumpos)
                        backupmat=tc:GetMaterial():Clone()
                    end
                    stage2(e,tc,tp,backupmat,0)
                    Duel.SpecialSummonComplete()
                    stage2(e,tc,tp,backupmat,3)
                    if (chkf&FUSPROC_NOTFUSION)==0 then
                        tc:CompleteProcedure()
                    end
                    stage2(e,tc,tp,backupmat,1)
                end
                stage2(e,nil,tp,nil,2)
                Beanbag.CheckMin=nil
                Beanbag.CheckMax=nil
                Beanbag.CheckExact=nil
                Beanbag.CheckAdditional=nil
            end
end
