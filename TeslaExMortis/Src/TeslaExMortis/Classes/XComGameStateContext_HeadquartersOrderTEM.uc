class XComGameStateContext_HeadquartersOrderTEM extends XComGameStateContext_HeadquartersOrder;

static function CompleteTrainRookie(XComGameState AddToGameState, StateObjectReference ProjectRef)
{
	// Resurrect here
	// Do stuff to unit
}

static function IssueHeadquartersOrderTEM(const out HeadquartersOrderInputContext UseInputContext)
{
	local XComGameStateContext_HeadquartersOrder NewOrderContext;

	NewOrderContext = XComGameStateContext_HeadquartersOrder(class'XComGameStateContext_HeadquartersOrderTEM'.static.CreateXComGameStateContext());
	NewOrderContext.InputContext = UseInputContext;

	`GAMERULES.SubmitGameStateContext(NewOrderContext);
}