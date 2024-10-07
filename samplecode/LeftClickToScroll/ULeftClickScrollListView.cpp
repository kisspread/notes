// Copy Right ZeroSoul


#include "UI/Widget/ListView/ULeftClickScrollListView.h"

TSharedRef<STableViewBase> UULeftClickScrollListView::RebuildListWidget()
{
	TSharedRef<SLeftClickScrollView<UObject*>> ListView = ConstructListView<SLeftClickScrollView>();
	ListView->SetEnableLeftClickScrolling(bEnableLeftClickScrolling);
	return ListView;
}

UUserWidget& UULeftClickScrollListView::OnGenerateEntryWidgetInternal(UObject* Item, TSubclassOf<UUserWidget> DesiredEntryClass, const TSharedRef<STableViewBase>& OwnerTable)
{
	if (bEnableLeftClickScrolling)
	{
		return GenerateTypedEntry<UUserWidget, SSingleSelectSObjectTableRow<UObject*>>(DesiredEntryClass, OwnerTable);
	}
	return Super::OnGenerateEntryWidgetInternal(Item, DesiredEntryClass, OwnerTable);
}
