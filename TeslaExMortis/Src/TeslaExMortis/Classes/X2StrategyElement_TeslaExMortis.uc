class X2StrategyElement_TeslaExMortis extends X2StrategyElement_DefaultStaffSlots config(TEM);

var config array<name> ExcludedClassesFromSlot;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> StaffSlots;

	StaffSlots.AddItem(CreateTEMSlotTemplate());

	return StaffSlots;
}

static function X2DataTemplate CreateTEMSlotTemplate()
{
	local X2StaffSlotTemplate Template;
	local int i;

	Template = CreateStaffSlotTemplate('TEMSoldierSlot');
	Template.bSoldierSlot = true;
	Template.bRequireConfirmToEmpty = true;
	Template.bPreventFilledPopup = true;
	Template.UIStaffSlotClass = class'UIFacility_TEMSoldierSlot';
	Template.AssociatedProjectClass = class'XComGameState_HeadquartersProjectTEMSoldier';
	Template.FillFn = FillFn;
	Template.EmptyStopProjectFn = EmptyStopProjectFn;
	Template.ShouldDisplayToDoWarningFn = ShouldDisplayToDoWarningFn;
	Template.GetSkillDisplayStringFn = "";
	Template.GetBonusDisplayStringFn = GetBonusDisplayStringFn;
	Template.IsUnitValidForSlotFn = IsUnitValidForSlotFn;
	Template.MatineeSlotName = "Soldier";

	for (i = 0; i < default.ExcludedClassesFromSlot.length; i++)
	{	
		Template.ExcludeClasses.AddItem(default.ExcludedClassesFromSlot[i]);
	}
	
	return Template;
}

static function FillFn(XComGameState NewGameState, StateObjectReference SlotRef, StaffUnitInfo UnitInfo, optional bool bTemporary = false)
{
	local XComGameState_Unit NewUnitState;
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_HeadquartersXCom NewXComHQ;	
	local XComGameState_HeadquartersProjectTEMSoldier ProjectState;
	local StateObjectReference EmptyRef;
	local int SquadIndex;

	FillSlot(NewGameState, SlotRef, UnitInfo, NewSlotState, NewUnitState);
	NewXComHQ = GetNewXComHQState(NewGameState);	
	
	ProjectState = XComGameState_HeadquartersProjectTEMSoldier(NewGameState.CreateNewStateObject(class'XComGameState_HeadquartersProjectTEMSoldier'));
	ProjectState.SetProjectFocus(UnitInfo.UnitRef, NewGameState, NewSlotState.Facility);

	NewUnitState.SetStatus(eStatus_Training);
	NewXComHQ.Projects.AddItem(ProjectState.GetReference());

	// Remove their gear
	NewUnitState.MakeItemsAvailable(NewGameState, false);
	
	// Ain't possible with a dead unit, but leaving this in
	// If the unit undergoing training is in the squad, remove them
	SquadIndex = NewXComHQ.Squad.Find('ObjectID', UnitInfo.UnitRef.ObjectID);
	if (SquadIndex != INDEX_NONE)
	{
		// Remove them from the squad
		NewXComHQ.Squad[SquadIndex] = EmptyRef;
	}
}

static function EmptyStopProjectFn(StateObjectReference SlotRef)
{
	local HeadquartersOrderInputContext OrderInput;
	local XComGameState_StaffSlot SlotState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersProjectTEMSoldier ProjectState;	

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	SlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(SlotRef.ObjectID));

	ProjectState = GetTrainProject(XComHQ, SlotState.GetAssignedStaffRef());	
	if (ProjectState != none)
	{		
		OrderInput.OrderType = eHeadquartersOrderType_CancelTrainRookie;
		OrderInput.AcquireObjectReference = ProjectState.GetReference();
		
		class'XComGameStateContext_HeadquartersOrderTEM'.static.IssueHeadquartersOrderTEM(OrderInput);
	}
}

static function bool ShouldDisplayToDoWarningFn(StateObjectReference SlotRef)
{
	return false;
}

static function string GetBonusDisplayStringFn(XComGameState_StaffSlot SlotState, optional bool bPreview)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersProjectTEMSoldier ProjectState;
	local string Contribution;

	if (SlotState.IsSlotFilled())
	{
		XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
		ProjectState = GetTrainProject(XComHQ, SlotState.GetAssignedStaffRef());

		if (ProjectState.GetTrainingClassTemplate().DisplayName != "")
			Contribution = Caps(ProjectState.GetTrainingClassTemplate().DisplayName);
		else
			Contribution = SlotState.GetMyTemplate().BonusDefaultText;
	}

	// return GetBonusDisplayString(SlotState, "%SKILL", Contribution);
	return "GetBonusDisplayStringFn";
}

static function bool IsUnitValidForSlotFn(XComGameState_StaffSlot SlotState, StaffUnitInfo UnitInfo)
{
	local XComGameState_Unit Unit;
	local UnitValue kUnitValue;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitInfo.UnitRef.ObjectID));

	if (Unit.IsSoldier()
		&& Unit.bBodyRecovered
		&& SlotState.GetMyTemplate().ExcludeClasses.Find(Unit.GetSoldierClassTemplateName()) == INDEX_NONE) // Certain we don't allow rez
	{
		return true;
	}

	return false;
}

static function XComGameState_HeadquartersProjectTEMSoldier GetTrainProject(XComGameState_HeadquartersXCom XComHQ, StateObjectReference UnitRef)
{
	local int idx;
	local XComGameState_HeadquartersProjectTEMSoldier ProjectState;

	for (idx = 0; idx < XComHQ.Projects.Length; idx++)
	{
		ProjectState = XComGameState_HeadquartersProjectTEMSoldier(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.Projects[idx].ObjectID));

		if (ProjectState != none)
		{
			if (UnitRef == ProjectState.ProjectFocus)
			{
				return ProjectState;
			}
		}
	}

	return none;
}