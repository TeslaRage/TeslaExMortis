class UIPersonnel_TeslaExMortis extends UIPersonnel;

simulated function UpdateData()
{
	local int i;
	local XComGameState_Unit Unit;
	local XComGameStateHistory History;
	local XComGameState_StaffSlot SlotState;
	local StaffUnitInfo SlotUnitInfo;

	History = `XCOMHISTORY;
	SlotState = XComGameState_StaffSlot(History.GetGameStateForObjectID(SlotRef.ObjectID));

	// Destroy old data
	m_arrSoldiers.Length = 0;
	m_arrScientists.Length = 0;
	m_arrEngineers.Length = 0;
	m_arrDeceased.Length = 0;

	//Need to get the latest state here, else you may have old data in the list upon refreshing at OnReceiveFocus, such as still showing dismissed soldiers. 
	HQState = class'UIUtilities_Strategy'.static.GetXComHQ();
	
	for(i = 0; i < HQState.DeadCrew.Length; i++)
	{
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(HQState.DeadCrew[i].ObjectID));
		SlotUnitInfo.UnitRef = Unit.GetReference();

		if(Unit.IsDead() && Unit.bBodyRecovered)
		{
			//Check StaffSlot Validation function
			if (SlotState.ValidUnitForSlot(SlotUnitInfo))
			{
				if (m_arrNeededTabs.Find(eUIPersonnel_Soldiers) != INDEX_NONE)
				{
					m_arrSoldiers.AddItem(Unit.GetReference());
				}
			}
		}
	}
}

defaultproperties
{
	m_eListType = eUIPersonnel_Soldiers;
	m_bRemoveWhenUnitSelected = true;
}