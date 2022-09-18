class XComGameState_HeadquartersProjectTEMSoldier  extends XComGameState_HeadquartersProjectTrainRookie;

function int CalculatePointsToTrain()
{
	// How should we setup duration?
}

function OnProjectCompleted()
{
	local HeadquartersOrderInputContext OrderInput;
	local XComHeadquartersCheatManager CheatMgr;	
	local int i;

	OrderInput.OrderType = eHeadquartersOrderType_TrainRookieCompleted;
	OrderInput.AcquireObjectReference = self.GetReference();

	class'XComGameStateContext_HeadquartersOrderTEM'.static.IssueHeadquartersOrderTEM(OrderInput);

	// Build localisation for popup
	// Show popup

	// CheatMgr = XComHeadquartersCheatManager(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().CheatManager);
	// if (CheatMgr == none || !CheatMgr.bGamesComDemo)
	// {					
	// 	for(i = 0; i < GrantedAbilities.Length; i++)
	// 	{			
	// 		if(i == 0) ExtraInfo = "+";
	// 		ExtraInfo $= "<font color='#3ABD23'>" $class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(GrantedAbilities[i]).LocFriendlyName;			
	// 		if (i == GrantedAbilities.Length - 1) ExtraInfo $= "</font>"; else ExtraInfo $= "</font>, ";
	// 	}
	// 	if(GrantedAbilities.Length > 0)
	// 		if(GrantedAbilities.Length > 1) ExtraInfo @= m_strAbilities $"\n"; else ExtraInfo @= m_strAbility $"\n";

	// 	ExtraInfo $= "+<font color='#3ABD23'>" $StatBonus $"</font>" @class'X2TacticalGameRulesetDataStructures'.default.m_aCharStatLabels[ConditionStat]
	// 				@"\n+<font color='#3ABD23'>" $AbilityPointsGranted $"</font>" @m_strAbilityPoints;
		
	// 	class'XComHQPresentationLayer_CS'.static.UICSTrainingComplete(ProjectFocus, AbilityTemplate, ExtraInfo, class'X2TacticalGameRulesetDataStructures'.default.m_aCharStatLabels[ConditionStat]);
	// }
}