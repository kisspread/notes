// Copy Right ZeroSoul

#pragma once

#include "CoreMinimal.h"
#include "CommonListView.h"
#include "SCommonButtonTableRow.h"
#include "Aura/Aura.h"
#include "Aura/AuraLogChannel.h"
#include "ULeftClickScrollListView.generated.h"

template <typename ItemType>
class SLeftClickScrollView : public SCommonListView<ItemType>
{
public:
	void SetEnableLeftClickScrolling(bool bEnable)
	{
		bEnableLeftClickScrolling = bEnable;
	}

protected:
	virtual FReply OnPreviewMouseButtonDown(const FGeometry& MyGeometry, const FPointerEvent& MouseEvent) override
	{
		AURA_W("func: {0}, event:{1}", __FUNCTION__, *MouseEvent.ToText().ToString())
		if (bEnableLeftClickScrolling && MouseEvent.GetEffectingButton() == EKeys::LeftMouseButton)
		{
			// Clear any inertia
			this->InertialScrollManager.ClearScrollVelocity();
			AmountScrolledWhileLeftMouseDown = 0;
			bStartedLeftClickInteraction = true;

			return FReply::Unhandled();
		}
		return SCommonListView<ItemType>::OnPreviewMouseButtonDown(MyGeometry, MouseEvent);
	}

	virtual FReply OnMouseButtonDown(const FGeometry& MyGeometry, const FPointerEvent& MouseEvent) override
	{
		AURA_W("func: {0}, event:{1}", __FUNCTION__, *MouseEvent.ToText().ToString())
		return SCommonListView<ItemType>::OnMouseButtonDown(MyGeometry, MouseEvent);
	}
	virtual FReply OnMouseButtonUp(const FGeometry& MyGeometry, const FPointerEvent& MouseEvent) override
	{
		AURA_W("func: {0}, event:{1}", __FUNCTION__, *MouseEvent.ToText().ToString())
		if (MouseEvent.GetEffectingButton() == EKeys::LeftMouseButton)
		{
			bStartedLeftClickInteraction = false;
			AmountScrolledWhileLeftMouseDown = 0.f;
			if (this->HasMouseCapture())
			{
				return FReply::Unhandled().ReleaseMouseCapture();
			}
		}
		return SCommonListView<ItemType>::OnMouseButtonUp(MyGeometry, MouseEvent);
	}

	virtual FReply OnMouseMove(const FGeometry& MyGeometry, const FPointerEvent& MouseEvent) override
	{
		if (bEnableLeftClickScrolling && MouseEvent.IsMouseButtonDown(EKeys::LeftMouseButton) && bStartedLeftClickInteraction)
		{
			AURA_W("func: {0}, event:{1}", __FUNCTION__, *MouseEvent.ToText().ToString())
			FTableViewDimensions CursorDeltaDimensions(this->Orientation, MouseEvent.GetCursorDelta());
			CursorDeltaDimensions.LineAxis = 0.f;
			const float ScrollByAmount = CursorDeltaDimensions.ScrollAxis / MyGeometry.Scale;
		
			AmountScrolledWhileLeftMouseDown += FMath::Abs(ScrollByAmount);

			if (IsLeftClickScrolling())
			{
				// Make sure the active timer is registered to update the inertial scroll
				if (!this->bIsScrollingActiveTimerRegistered)
				{
					this->bIsScrollingActiveTimerRegistered = true;
					this->RegisterActiveTimer(0.f, FWidgetActiveTimerDelegate::CreateSP(this, &SLeftClickScrollView::UpdateLeftClickInertialScroll));
				}
		
		
				this->TickScrollDelta -= ScrollByAmount;
		
				const float AmountScrolled = this->ScrollBy(MyGeometry, -ScrollByAmount, this->AllowOverscroll);
		
				FReply Reply = FReply::Unhandled();
		
				if (this->HasMouseCapture() == false)
				{
					Reply.UseHighPrecisionMouseMovement(this->AsShared());
				
		
				return Reply;
			}
			
		}
		return SCommonListView<ItemType>::OnMouseMove(MyGeometry, MouseEvent);
	}

	virtual void OnMouseLeave(const FPointerEvent& MouseEvent) override
	{
		// bStartedLeftClickInteraction = true;
		// if (this->HasMouseCapture())
		// {
		//     AmountScrolledWhileLeftMouseDown = 0.f;
		// }
		return SCommonListView<ItemType>::OnMouseLeave(MouseEvent);
	}

private:

	bool IsLeftClickScrolling() const
	{
		return AmountScrolledWhileLeftMouseDown >= FSlateApplication::Get().GetDragTriggerDistance() &&
			(this->ScrollBar->IsNeeded() || this->AllowOverscroll == EAllowOverscroll::Yes);
	}
	
	EActiveTimerReturnType UpdateLeftClickInertialScroll(double InCurrentTime, float InDeltaTime)
	{
		bool bKeepTicking = false;
		if (this->ItemsPanel.IsValid())
		{
			if (bStartedLeftClickInteraction)
			{
				bKeepTicking = true;

				if (this->CanUseInertialScroll(this->TickScrollDelta))
				{
					this->InertialScrollManager.AddScrollSample(this->TickScrollDelta, InCurrentTime);
				}
			}
			else
			{
				this->InertialScrollManager.UpdateScrollVelocity(InDeltaTime);
				const float ScrollVelocity = this->InertialScrollManager.GetScrollVelocity();

				if (ScrollVelocity != 0.f)
				{
					if (this->CanUseInertialScroll(ScrollVelocity))
					{
						bKeepTicking = true;
						this->ScrollBy(this->GetTickSpaceGeometry(), ScrollVelocity * InDeltaTime, this->AllowOverscroll);
					}
					else
					{
						this->InertialScrollManager.ClearScrollVelocity();
					}
				}

				if (this->AllowOverscroll == EAllowOverscroll::Yes)
				{
					if (this->Overscroll.GetOverscroll(this->GetTickSpaceGeometry()) != 0.0f)
					{
						bKeepTicking = true;
						this->RequestLayoutRefresh();
					}

					this->Overscroll.UpdateOverscroll(InDeltaTime);
				}
			}

			this->TickScrollDelta = 0.f;
		}

		this->bIsScrollingActiveTimerRegistered = bKeepTicking;
		return bKeepTicking ? EActiveTimerReturnType::Continue : EActiveTimerReturnType::Stop;
	}

	bool bEnableLeftClickScrolling = false;
	bool bStartedLeftClickInteraction = false;
	float AmountScrolledWhileLeftMouseDown = 0.f;
};

template <typename ItemType>
class SSingleSelectSObjectTableRow : public SObjectTableRow<ItemType>
{
public:
	virtual FReply OnMouseButtonDown(const FGeometry& MyGeometry, const FPointerEvent& MouseEvent) override
	{
		AURA_W("func: {0}", __FUNCTION__)
		FReply Reply = SObjectWidget::OnMouseButtonDown(MyGeometry, MouseEvent);
		return Reply;
	}

	// remove most steps in Parent Class, this only handle the SelectionMode::Single
	virtual FReply OnMouseButtonUp(const FGeometry& MyGeometry, const FPointerEvent& MouseEvent) override
	{
		AURA_W("func: {0}", __FUNCTION__)
		FReply Reply = SObjectWidget::OnMouseButtonUp(MyGeometry, MouseEvent);
		if (!Reply.IsEventHandled())
		{
			TSharedPtr<ITypedTableView<ItemType>> OwnerTable = this->OwnerTablePtr.Pin();
			const TObjectPtrWrapTypeOf<ItemType>* MyItemPtr = OwnerTable ? this->GetItemForThis(OwnerTable.ToSharedRef()) : nullptr;
			if (MyItemPtr)
			{
				const ESelectionMode::Type SelectionMode = this->GetSelectionMode();
				if (MouseEvent.GetEffectingButton() == EKeys::LeftMouseButton )
				{
					bool bSignalSelectionChanged = false; 
					const ItemType& MyItem = *MyItemPtr;
					if ( this->IsItemSelectable() && MyGeometry.IsUnderLocation(MouseEvent.GetScreenSpacePosition()))
					{
						if (SelectionMode == ESelectionMode::Single)
						{
 							bSignalSelectionChanged = true;
						}
					}

					if (bSignalSelectionChanged)
					{
						OwnerTable->Private_ClearSelection();
						OwnerTable->Private_SetItemSelection(MyItem, true, true);
						OwnerTable->Private_SignalSelectionChanged(ESelectInfo::OnMouseClick);
						Reply = FReply::Handled();
					}

					if (OwnerTable->Private_OnItemClicked(*MyItemPtr))
					{
						Reply = FReply::Handled();
					}

					Reply = Reply.ReleaseMouseCapture();
				}
				
			}
		}

		return Reply;
	}

 };

/**
 * 
 */
UCLASS()
class AURA_API UULeftClickScrollListView : public UCommonListView
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Scroll")
	bool bEnableLeftClickScrolling = true;

	virtual TSharedRef<STableViewBase> RebuildListWidget() override;
	
	virtual UUserWidget& OnGenerateEntryWidgetInternal(UObject* Item, TSubclassOf<UUserWidget> DesiredEntryClass, const TSharedRef<STableViewBase>& OwnerTable) override;

};
