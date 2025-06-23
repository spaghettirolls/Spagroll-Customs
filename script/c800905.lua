--Toon Rose Dragon
--Scripted by Beanbag

local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,s.tfilter,1,1,Synchro.NonTunerEx(Card.IsSetCard,SET_TOON),1,99)
	c:EnableReviveLimit()
end

function s.tfilter(c,lc,stype,tp)
	return c:IsSummonCode(lc,stype,tp,800900) or c:IsHasEffect(20932152)
end