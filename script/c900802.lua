--Poltiquette Fusion
--Scripted by Aimer
local s,id=GetID()
function s.initial_effect(c)
	Duel.LoadScript('AimersAux.lua')
	--Activate
	local fusfilter,matfilter,extrafil,extraop,nosummoncheck,location,extratg=aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),s.matfilter,s.fextra,s.extraop,true,LOCATION_GRAVE|LOCATION_EXTRA,s.extratg
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1170)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:GetLabel(100)
	e1:SetTarget(s.fustg(fusfilter,matfilter,extrafil,extraop,gc,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos))
	e1:SetOperation(s.fusop(fusfilter,matfilter,extrafil,extraop,gc,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

--Banish cost
function s.rmfilter(c,tp)
	return c:IsSpellTrap() and c:IsAbleToRemoveAsCost()
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,e:GetHandler(),tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
--Return to hand
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end

--
function s.matfilter(c)
	return c:IsAbleToDeckOrExtraAsCost() and not c:IsCode(id)
end


function s.tdcfilter(c)
	return ((c:IsFaceup() and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)) or (c:IsSpellTrap() and c:IsSetCard(0x3D4) and c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD))) and c:IsAbleToDeckOrExtraAsCost() and not c:IsCode(id)
end

function s.fextra(e,tp,mg)
    if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
        local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdcfilter),tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
        return mg,nil
    end
    return nil,nil
end


function s.settofieldfilter(c)
	return c:IsSSetable() and ((c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_OVERLAY)) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
end
function s.extraop(e,tc,tp,sg)
    local rg=sg:Filter(aux.NecroValleyFilter(s.settofieldfilter),nil)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or Duel.GetFlagEffect(tp,id)>0 then return end
    local ct=1
    if Duel.GetFlagEffect(tp,900821)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 then ct=2 end
    if #rg>0 and ((ct==1 and Duel.SelectYesNo(tp,aux.Stringid(id,1))) or (ct==2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)))) then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        local dg=rg:Select(tp,1,ct,nil)
        if #dg>1 then
        for tc in aux.Next(dg) do
 			Duel.HintSelection(tc)
	        Duel.SSet(tp,tc)
	        Duel.RaiseSingleEvent(tc,EVENT_SSET,e,REASON_EFFECT+REASON_FUSION+REASON_MATERIAL,tp,tp,0)
	        Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT+REASON_FUSION+REASON_MATERIAL,tp,tp,0)
	        sg:Sub(tc)
	        end
	    else
	        local tc=dg:GetFirst()
	        Duel.HintSelection(tc)
	        Duel.SSet(tp,tc)
	        Duel.RaiseSingleEvent(tc,EVENT_SSET,e,REASON_EFFECT+REASON_FUSION+REASON_MATERIAL,tp,tp,0)
	        Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT+REASON_FUSION+REASON_MATERIAL,tp,tp,0)
	        sg:Sub(tc)
	    end
	end
    if #sg<=0 then return end
    Duel.SendtoDeck(sg,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
    e:GetHandler():ResetFlagEffect(900821)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_PUBLIC)
end




function s.SummonEffFilter(c,fusfilter,e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,sumpos,efmg)
	if efmg and #efmg>0 then
		if #(efmg:Match(s.GetExtraMatEff,nil,c))>0 then
			mg:Merge(efmg)
		end
	end
	return c:IsType(TYPE_FUSION) and (not fusfilter or fusfilter(c,tp)) and (nosummoncheck or c:IsCanBeSpecialSummoned(e,value,tp,sumlimit,false,sumpos))
			and c:CheckFusionMaterial(mg,gc,chkf)
end


function s.GetExtraMatEff(c,summon_card)
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

function s.ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
	local extra_feff_mg=mg1:Filter(s.GetExtraMatEff,nil)
	if #extra_feff_mg>0 then
		local extra_feff=s.GetExtraMatEff(extra_feff_mg:GetFirst())
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
		local extra_feff=s.GetExtraMatEff(efmg:GetFirst())
		if extra_feff and not extra_feff:CheckCountLimit(tp) then
			efmg:Clear()
		end
	end
	return mg1,efmg
end




function s.spelltrapfilter(c)
    return c:IsCanBeFusionMaterial() or (c:IsSpellTrap() and c:IsAbleToDeckOrExtraAsCost() and c:IsSetCard(0x3D4))
end

function s.fustg(fusfilter,matfilter,extrafil,extraop,gc2,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos)
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
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
					--Both will be passed to s.SummonEffFilter later.
					local fmg_all=Duel.GetFusionMaterial(tp)
					local mg1=fmg_all:Filter(matfilter,nil,e,tp,0)
					local efmg=fmg_all:Filter(s.GetExtraMatEff,nil)
					local checkAddition=nil
					local repl_flag=false
					if #efmg>0 then
						local extra_feff=s.GetExtraMatEff(efmg:GetFirst())
						if extra_feff and extra_feff:GetLabelObject() then
							local repl_function=extra_feff:GetLabelObject()
							repl_flag=true
							-- no extrafil (Poly):
							if not extrafil then
								local ret = {repl_function[1](e,tp,mg1)}
								if ret[1] then
									ret[1]:Match(matfilter,nil,e,tp,0)
									Fusion.ExtraGroup=ret[1]:Filter(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
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
									Fusion.ExtraGroup=ret[1]:Filter(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
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
							Fusion.ExtraGroup=ret[1]:Filter(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
							mg1:Merge(ret[1])
						end
						checkAddition=ret[2]
					end
					if gc and not mg1:Includes(gc) then
						Fusion.ExtraGroup=nil
						return false
					end
					Fusion.CheckAdditional=checkAddition
					mg1:Match(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
					Fusion.CheckExact=exactcount
					Fusion.CheckMin=mincount
					Fusion.CheckMax=maxcount
					mg1,efmg=s.ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
					local res=Duel.IsExistingMatchingCard(s.SummonEffFilter,tp,location,0,1,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos,efmg)
					Fusion.CheckAdditional=nil
					Fusion.ExtraGroup=nil
					if not res and not notfusion then
						for _,ce in ipairs({Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}) do
							local fgroup=ce:GetTarget()
							local mg=fgroup(ce,e,tp,value)
							if #mg>0 and (not Fusion.CheckExact or #mg==Fusion.CheckExact) and (not Fusion.CheckMin or #mg>=Fusion.CheckMin) then
								local mf=ce:GetValue()
								local fcheck=nil
								if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
								Fusion.CheckAdditional=checkAddition
								if fcheck then
									if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
								end
								Fusion.ExtraGroup=mg
								if Duel.IsExistingMatchingCard(s.SummonEffFilter,tp,location,0,1,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,sumpos) then
									res=true
									Fusion.CheckAdditional=nil
									Fusion.ExtraGroup=nil
									break
								end
								Fusion.CheckAdditional=nil
								Fusion.ExtraGroup=nil
							end
						end
					end
					Fusion.CheckExact=nil
					Fusion.CheckMin=nil
					Fusion.CheckMax=nil
					return res
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
				if extratg then extratg(e,tp,eg,ep,ev,re,r,rp,chk) end
			end
end











function s.fusop(fusfilter,matfilter,extrafil,extraop,gc2,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos)
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp)
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
				local efmg=fmg_all:Filter(s.GetExtraMatEff,nil)
				local extragroup=nil
				local repl_flag=false
				if #efmg>0 then
					local extra_feff=s.GetExtraMatEff(efmg:GetFirst())
					if extra_feff and extra_feff:GetLabelObject() then
						local repl_function=extra_feff:GetLabelObject()
						repl_flag=true
						-- no extrafil (Poly):
						if not extrafil then
							local ret = {repl_function[1](e,tp,mg1)}
							if ret[1] then
								ret[1]:Match(matfilter,nil,e,tp,1)
								Fusion.ExtraGroup=ret[1]:Filter(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
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
								Fusion.ExtraGroup=ret[1]:Filter(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
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
						Fusion.ExtraGroup=ret[1]:Filter(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
						extragroup=ret[1]
						mg1:Merge(ret[1])
					end
					checkAddition=ret[2]
				end
				mg1:Match(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
				if gc and (not mg1:Includes(gc) or gc:IsExists(Fusion.ForcedMatValidity,1,nil,e)) then
					Fusion.ExtraGroup=nil
					return false
				end
				Fusion.CheckExact=exactcount
				Fusion.CheckMin=mincount
				Fusion.CheckMax=maxcount
				Fusion.CheckAdditional=checkAddition
				local effswithgroup={}
				--Same as line 191 above
				mg1,efmg=s.ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
				local sg1=Duel.GetMatchingGroup(s.SummonEffFilter,tp,location,0,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos,efmg)
				if #sg1>0 then
					table.insert(effswithgroup,{e,aux.GrouptoCardid(sg1)})
				end
				Fusion.ExtraGroup=nil
				Fusion.CheckAdditional=nil
				if not notfusion then
					local extraeffs = {Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}
					for _,ce in ipairs(extraeffs) do
						local fgroup=ce:GetTarget()
						local mg2=fgroup(ce,e,tp,value)
						if #mg2>0 and (not Fusion.CheckExact or #mg2==Fusion.CheckExact) and (not Fusion.CheckMin or #mg2>=Fusion.CheckMin) then
							local mf=ce:GetValue()
							local fcheck=nil
							if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
							Fusion.CheckAdditional=checkAddition
							if fcheck then
								if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
							end
							Fusion.ExtraGroup=mg2
							local sg2=Duel.GetMatchingGroup(s.SummonEffFilter,tp,location,0,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg2,gc,chkf,value,sumlimit,nosummoncheck,sumpos)
							if #sg2 > 0 then
								table.insert(effswithgroup,{ce,aux.GrouptoCardid(sg2)})
								sg1:Merge(sg2)
							end
							Fusion.CheckAdditional=nil
							Fusion.ExtraGroup=nil
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
						sel=effswithgroup[Fusion.ChainMaterialPrompt(effswithgroup,tc:GetCardID(),tp,e)]
						if sel[1]==e then
							Fusion.CheckAdditional=checkAddition
							Fusion.ExtraGroup=extragroup
							mat1=Duel.SelectFusionMaterial(tp,tc,mg1,gc,chkf)
						else
							ce=sel[1]
							local fcheck=nil
							if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
							Fusion.CheckAdditional=checkAddition
							if fcheck then
								if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
							end
							Fusion.ExtraGroup=ce:GetTarget()(ce,e,tp,value)
							mat1=Duel.SelectFusionMaterial(tp,tc,Fusion.ExtraGroup,gc,chkf)
						end
					end
					if sel[1]==e then
						Fusion.ExtraGroup=nil
						backupmat=mat1:Clone()
						if not notfusion then
							tc:SetMaterial(mat1)
						end
						--Checks for the case that the Fusion Summoning effect has an "extraop"
						local extra_feff_mg=mat1:Filter(s.GetExtraMatEff,nil,tc)
						if #extra_feff_mg>0 and extraop then
							local extra_feff=s.GetExtraMatEff(extra_feff_mg:GetFirst(),tc)
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
							--EFFECT_EXTRA_FUSION_MATERIAL effect, if it exists.
							--If it doesn't exist then send the extra materials to the GY.
							local extra_feff_mg,normal_mg=mat1:Split(s.GetExtraMatEff,nil,tc)
							local extra_feff
							if #extra_feff_mg>0 then extra_feff=s.GetExtraMatEff(extra_feff_mg:GetFirst(),tc) end
							if #normal_mg>0 then
								normal_mg=normal_mg:AddMaximumCheck()
								Duel.SendtoDeck(normal_mg,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
							end
							if extra_feff then
								local extra_feff_op=extra_feff:GetOperation()
								if extra_feff_op then
									extra_feff_op(e,tc,tp,extra_feff_mg)
								else
									extra_feff_mg=extra_feff_mg:AddMaximumCheck()
									Duel.SendtoDeck(extra_feff_mg,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
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
						Fusion.CheckAdditional=nil
						Fusion.ExtraGroup=nil
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
				Fusion.CheckMin=nil
				Fusion.CheckMax=nil
				Fusion.CheckExact=nil
				Fusion.CheckAdditional=nil
			end
end