--Poltiquette Mesmirage
--Scripted by Aimer
local s,id=GetID()
function s.initial_effect(c)
	local e0=aux.AddEquipProcedure(c,1,nil,s.eqlimit)
	e0:SetCountLimit(1,id)
	--Gain control of the monster while you control a "Poltiquette" Continuos Trap
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SET_CONTROL)
	e1:SetValue(function(e) return e:GetHandlerPlayer() end)
	e1:SetCondition(s.contcond)
	c:RegisterEffect(e1)
	--Equipped monsters effects are negated
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e3)
	--Equipped monster is treated as a "Poltiquette" monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_ADD_SETCODE)
	e4:SetValue(0x3D4)
	c:RegisterEffect(e4)
	--Banish to Fusion
	local fusfilter,matfilter,extrafil,extraop,nosummoncheck,location,extratg=
	aux.FilterBoolFunction(Card.IsSetCard,0x3D4),s.matfilter,s.fextra,s.extraop,true,LOCATION_EXTRA,s.extratg,Fusion.BanishMaterial
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(1170)
	e5:GetLabel(100)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE+LOCATION_SZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCost(aux.bfgcost)
	e5:SetTarget(s.fustg(fusfilter,matfilter,extrafil,extraop,gc,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos))
	e5:SetOperation(s.fusop(fusfilter,matfilter,extrafil,extraop,gc,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos))
	c:RegisterEffect(e5)
end

function s.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or e:GetHandlerPlayer()~=c:GetControler()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsContinuousTrap() and c:IsSetCard(0x3D4)
end
function s.contcond(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end

function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end

function s.matfilter(c)
	return c:IsAbleToRemove() and c:IsLocation(LOCATION_ONFIELD) and not c:IsCode(id)
end
function s.checkmat(tp,sg,fc)
	return fc:IsSetCard(0x3D4) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD+LOCATION_GRAVE)
end

function s.tdcfilter(c)
	return ((c:IsLocation(LOCATION_GRAVE)) or (c:IsSpellTrap() and c:IsSetCard(0x3D4) and c:IsLocation(LOCATION_ONFIELD))) and c:IsAbleToRemove() and not c:IsCode(id)
end

function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdcfilter),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil),s.checkmat
	end
	return nil,s.checkmat
end

function s.extraop(e,tc,tp,sg)
    if #sg>0 then
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
    end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end






--Returns the first EFFECT_EXTRA_FUSION_MATERIAL applied on Card c.
--If summon_card is provided, it will also check if the effect's value function applies to that card.
--Card.IsHasEffect alone cannot be used because it would return the above effect as well.
local function GetExtraMatEff(c,summon_card)
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
--Once per turn check for EFFECT_EXTRA_FUSION_MATERIAL effects.
--Removes cards from the material pool group if the OPT of the
--EFFECT_EXTRA_FUSION_MATERIAL effect has already been used.
--Returns the main material group and the extra material group separately, both
--of which are then passed to Fusion.SummonEffFilter.
local function ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
	local extra_feff_mg=mg1:Filter(GetExtraMatEff,nil)
	if #extra_feff_mg>0 then
		local extra_feff=GetExtraMatEff(extra_feff_mg:GetFirst())
		--Check if you need to remove materials from the pool if count limit has been used
		if extra_feff and not extra_feff:CheckCountLimit(tp) then
			--If "extrafil" exists and it doesn't return anything in
			--the GY (so that effects like "Dragon's Mirror" are excluded),
			--remove all the EFFECT_EXTRA_FUSION_MATERIAL cards
			--that are in the GY from the material group.
			--Hardcoded to LOCATION_GRAVE since it's currently
			--impossible to get the TargetRange of the
			--EFFECT_EXTRA_FUSION_MATERIAL effect (but the only OPT effect atm uses the GY).
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
			--If "extrafil" doesn't exist then remove all the
			--EFFECT_EXTRA_FUSION_MATERIAL cards from the material group.
			--A more complete implementation would check for cases where the
			--Fusion Summoning effect can use the whole field (including LOCATION_SZONE),
			--but it's currently not possible to know if that is the case
			--(only relevant for "Fullmetalfoes Alkahest" atm, but he's not OPT).
			else
				mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
				efmg:Clear()
			end
		end
	elseif #efmg>0 then
		local extra_feff=GetExtraMatEff(efmg:GetFirst())
		if extra_feff and not extra_feff:CheckCountLimit(tp) then
			efmg:Clear()
		end
	end
	return mg1,efmg
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
					--Both will be passed to Fusion.SummonEffFilter later.
					local fmg_all=Duel.GetFusionMaterial(tp)
					local mg1=fmg_all:Filter(matfilter,nil,e,tp,0)
					local efmg=fmg_all:Filter(GetExtraMatEff,nil)
					local checkAddition=nil
					local repl_flag=false
					-- Check if can be fusion mat "Spell/Trap"
                	local function spelltrapfilter(c)
                    	return c:IsCanBeFusionMaterial() or (c:IsSpellTrap() and c:IsAbleToRemove() and c:IsSetCard(0x3D4))
                	end
					if #efmg>0 then
						local extra_feff=GetExtraMatEff(efmg:GetFirst())
						if extra_feff and extra_feff:GetLabelObject() then
							local repl_function=extra_feff:GetLabelObject()
							repl_flag=true
							-- no extrafil (Poly):
							if not extrafil then
								local ret = {repl_function[1](e,tp,mg1)}
								if ret[1] then
									ret[1]:Match(matfilter,nil,e,tp,0)
									Fusion.ExtraGroup=ret[1]:Filter(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
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
									Fusion.ExtraGroup=ret[1]:Filter(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
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
							Fusion.ExtraGroup=ret[1]:Filter(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
							mg1:Merge(ret[1])
						end
						checkAddition=ret[2]
					end
					if gc and not mg1:Includes(gc) then
						Fusion.ExtraGroup=nil
						return false
					end
					Fusion.CheckAdditional=checkAddition
					mg1:Match(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
					Fusion.CheckExact=exactcount
					Fusion.CheckMin=mincount
					Fusion.CheckMax=maxcount
					--Adjust the main material group and the extra material group accordingly
					--if an OPT EFFECT_EXTRA_FUSION_MATERIAL effect has already been used.
					--Both will be passed to Fusion.SummonEffFilter later.
					mg1,efmg=ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
					local res=Duel.IsExistingMatchingCard(Fusion.SummonEffFilter,tp,location,0,1,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos,efmg)
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
								if Duel.IsExistingMatchingCard(Fusion.SummonEffFilter,tp,location,0,1,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,sumpos) then
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
				local efmg=fmg_all:Filter(GetExtraMatEff,nil)
				local extragroup=nil
				local repl_flag=false
				-- Check if can be fusion mat "Spell/Trap"
                local function spelltrapfilter(c)
                    return c:IsCanBeFusionMaterial() or (c:IsSpellTrap() and c:IsAbleToRemove() and c:IsSetCard(0x3D4))
                end
				if #efmg>0 then
					local extra_feff=GetExtraMatEff(efmg:GetFirst())
					if extra_feff and extra_feff:GetLabelObject() then
						local repl_function=extra_feff:GetLabelObject()
						repl_flag=true
						-- no extrafil (Poly):
						if not extrafil then
							local ret = {repl_function[1](e,tp,mg1)}
							if ret[1] then
								ret[1]:Match(matfilter,nil,e,tp,1)
								Fusion.ExtraGroup=ret[1]:Filter(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
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
								Fusion.ExtraGroup=ret[1]:Filter(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
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
						Fusion.ExtraGroup=ret[1]:Filter(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
						extragroup=ret[1]
						mg1:Merge(ret[1])
					end
					checkAddition=ret[2]
				end
				mg1:Match(spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
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
				mg1,efmg=ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
				local sg1=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,location,0,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos,efmg)
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
							local sg2=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,location,0,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg2,gc,chkf,value,sumlimit,nosummoncheck,sumpos)
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
						local extra_feff_mg=mat1:Filter(GetExtraMatEff,nil,tc)
						if #extra_feff_mg>0 and extraop then
							local extra_feff=GetExtraMatEff(extra_feff_mg:GetFirst(),tc)
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
							local extra_feff_mg,normal_mg=mat1:Split(GetExtraMatEff,nil,tc)
							local extra_feff
							if #extra_feff_mg>0 then extra_feff=GetExtraMatEff(extra_feff_mg:GetFirst(),tc) end
							if #normal_mg>0 then
								normal_mg=normal_mg:AddMaximumCheck()
								Duel.Remove(normal_mg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
							end
							if extra_feff then
								local extra_feff_op=extra_feff:GetOperation()
								if extra_feff_op then
									extra_feff_op(e,tc,tp,extra_feff_mg)
								else
									extra_feff_mg=extra_feff_mg:AddMaximumCheck()
									Duel.Remove(extra_feff_mg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
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