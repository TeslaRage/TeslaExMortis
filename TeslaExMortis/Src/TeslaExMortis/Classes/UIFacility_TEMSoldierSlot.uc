class UIFacility_TEMSoldierSlot extends UIFacility_AcademySlot dependson(UIPersonnel);

var localized string m_strStopTEMDialogText;
var localized string m_strStopTEMDialogTitle;
var localized string m_strTEMDialogTitle;
var localized string m_strTEMDialogText;

simulated function ShowDropDown()
{
	local XComGameState_StaffSlot StaffSlot;
	local XComGameState_Unit UnitState;
	local string StopTrainingText;

	StaffSlot = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(StaffSlotRef.ObjectID));

	if (StaffSlot.IsSlotEmpty())
	{
		OnSlotSelected();
	}
	else // Ask the user to confirm that they want to empty the slot and stop training
	{		
		UnitState = StaffSlot.GetAssignedStaff();
		StopTrainingText = m_strStopTEMDialogText;
		StopTrainingText = Repl(StopTrainingText, "%UNITNAME", UnitState.GetName(eNameType_RankFull));

		ConfirmEmptyProjectSlotPopup(m_strStopTEMDialogTitle, StopTrainingText);
	}
}

simulated function OnSlotSelected()
{
	if(IsDisabled)
		return;

	ShowSoldierList(eUIAction_Accept, none);
}

simulated function ShowSoldierList(eUIAction eAction, UICallbackData xUserData)
{
	local UIPersonnel_TeslaExMortis kPersonnelList;
	local XComHQPresentationLayer HQPres;
	local XComGameState_StaffSlot StaffSlotState;
	
	if (eAction == eUIAction_Accept)
	{
		HQPres = `HQPRES;
		StaffSlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(StaffSlotRef.ObjectID));

		//Don't allow clicking of Personnel List is active or if staffslot is filled
		if(HQPres.ScreenStack.IsNotInStack(class'UIPersonnel') && !StaffSlotState.IsSlotFilled())
		{
			kPersonnelList = Spawn( class'UIPersonnel_TeslaExMortis', HQPres);
			kPersonnelList.m_eListType = eUIPersonnel_Soldiers;
			kPersonnelList.onSelectedDelegate = OnSoldierSelected;
			kPersonnelList.m_bRemoveWhenUnitSelected = true;
			kPersonnelList.SlotRef = StaffSlotRef;
			HQPres.ScreenStack.Push( kPersonnelList );
		}
	}
}

simulated function OnSoldierSelected(StateObjectReference UnitRef)
{
	local XComGameStateHistory History;	
	local XGParamTag LocTag;
	local TDialogueBoxData DialogData;
	local XComGameState_Unit Unit;
	local UICallbackData_StateObjectReference CallbackData;

	History = `XCOMHISTORY;
	Unit = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));	

	LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	LocTag.StrValue0 = Unit.GetName(eNameType_RankFull);	
	LocTag.StrValue1 = "StrValue1";

	CallbackData = new class'UICallbackData_StateObjectReference';
	CallbackData.ObjectRef = Unit.GetReference();
	DialogData.xUserData = CallbackData;
	DialogData.fnCallbackEx = TEMDialogCallback;

	DialogData.eType = eDialog_Alert;
	DialogData.strTitle = m_strTEMDialogTitle;
	DialogData.strText = `XEXPAND.ExpandString(m_strTEMDialogText);
	DialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericYes;
	DialogData.strCancel = class'UIUtilities_Text'.default.m_strGenericNo;

	Movie.Pres.UIRaiseDialog(DialogData);
}

simulated function TEMDialogCallback(Name eAction, UICallbackData xUserData)
{
	local UICallbackData_StateObjectReference CallbackData;
	local XComHQPresentationLayer HQPres;
	// local UIChooseClass_ConditionSoldier ChooseClassScreen;
		
	CallbackData = UICallbackData_StateObjectReference(xUserData);
	
	if (eAction == 'eUIAction_Accept')
	{
		HQPres = `HQPRES;

		// How should we do this?
		// if (HQPres.ScreenStack.IsNotInStack(class'UIChooseClass_ConditionSoldier'))
		// {
		// 	ChooseClassScreen = Spawn(class'UIChooseClass_ConditionSoldier', self);
		// 	ChooseClassScreen.m_UnitRef = CallbackData.ObjectRef;
		// 	HQPres.ScreenStack.Push(ChooseClassScreen);
		// }
	}
}

defaultproperties
{
	width = 370;
	height = 65;
}
