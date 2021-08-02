import gfx.managers.FocusHandler;
import gfx.io.GameDelegate;
import Shared.GlobalFunc;

class CraftingMenu extends MovieClip
{
	static var MT_SINGLE_PANEL: Number = 0;
	static var MT_DOUBLE_PANEL: Number = 1;
	static var LIST_OFFSET: Number = 20;
	static var SELECT_BUTTON: Number = 0;
	static var EXIT_BUTTON: Number = 1;
	static var AUX_BUTTON: Number = 2;
	static var CRAFT_BUTTON: Number = 3;
	
	var AdditionalDescription: TextField;
	var AdditionalDescriptionHolder: MovieClip;
	var BottomBarInfo: MovieClip;
	var ButtonText: Array;
	var CategoryList: MovieClip;
	var ExitMenuRect: MovieClip;
	var InventoryLists: MovieClip;
	var ItemInfo: MovieClip;
	var ItemInfoHolder: MovieClip;
	var ItemList: MovieClip;
	var ItemListTweener: MovieClip;
	var ItemsListInputCatcher: MovieClip;
	var MenuDescription: TextField;
	var MenuDescriptionHolder: MovieClip;
	var MenuName: TextField;
	var MenuNameHolder: MovieClip;
	var MenuType: Number;
	var MouseRotationRect: MovieClip;
	var Platform: Number;
	var RestoreCategoryRect: MovieClip;
	var SavedCategoryCenterText: String;
	var SavedCategoryScrollRatio: Number;
	var SavedCategorySelectedText: String;
	var _bCanCraft: Boolean;
	var _bCanFadeItemInfo: Boolean;
	var _bItemCardAdditionalDescription: Boolean;
	var bCanExpandPanel: Boolean;
	var bHideAdditionalDescription: Boolean;

	function CraftingMenu()
	{
		super();
		_bCanCraft = false;
		bCanExpandPanel = true;
		_bCanFadeItemInfo = true;
		bHideAdditionalDescription = false;
		_bItemCardAdditionalDescription = false;
		ButtonText = new Array("", "", "", "");
		Platform = 0;
		CategoryList = InventoryLists;
		ItemInfo = ItemInfoHolder.ItemInfo;
		Mouse.addListener(this);
	}

	function Initialize(): Void
	{
		ItemInfoHolder = ItemInfoHolder;
		ItemInfoHolder.gotoAndStop("default");
		ItemInfo.addEventListener("endEditItemName", this, "OnEndEditItemName");
		ItemInfo.addEventListener("subMenuAction", this, "OnSubMenuAction");
		BottomBarInfo = BottomBarInfo;
		AdditionalDescriptionHolder = ItemInfoHolder.AdditionalDescriptionHolder;
		AdditionalDescription = AdditionalDescriptionHolder.AdditionalDescription;
		AdditionalDescription.textAutoSize = "shrink";
		MenuName = CategoryList.CategoriesList._parent.CategoryLabel;
		MenuName.autoSize = "left";
		MenuNameHolder._visible = false;
		MenuDescription = MenuDescriptionHolder.MenuDescription;
		MenuDescription.autoSize = "center";
		BottomBarInfo.SetButtonsArt([{PCArt: "E", XBoxArt: "360_A", PS3Art: "PS3_A"}, {PCArt: "Tab", XBoxArt: "360_B", PS3Art: "PS3_B"}, {PCArt: "F", XBoxArt: "360_Y", PS3Art: "PS3_Y"}, {PCArt: "R", XBoxArt: "360_X", PS3Art: "PS3_X"}]);
		if (ItemListTweener == undefined) {
			if (CategoryList != undefined) {
				MenuType = CraftingMenu.MT_DOUBLE_PANEL;
				FocusHandler.instance.setFocus(CategoryList, 0);
				CategoryList.ShowCategoriesList();
				CategoryList.addEventListener("itemHighlightChange", this, "OnItemHighlightChange");
				CategoryList.addEventListener("showItemsList", this, "OnShowItemsList");
				CategoryList.addEventListener("hideItemsList", this, "OnHideItemsList");
				CategoryList.addEventListener("categoryChange", this, "OnCategoryListChange");
				ItemList = CategoryList.ItemsList;
				ItemList.addEventListener("itemPress", this, "OnItemSelect");
			}
		} else {
			MenuType = CraftingMenu.MT_SINGLE_PANEL;
			ItemList = ItemListTweener.List_mc;
			ItemListTweener.gotoAndPlay("showList");
			FocusHandler.instance.setFocus(ItemList, 0);
			ItemList.addEventListener("listMovedUp", this, "OnItemListMovedUp");
			ItemList.addEventListener("listMovedDown", this, "OnItemListMovedDown");
			ItemList.addEventListener("itemPress", this, "OnItemListPressed");
		}
		BottomBarInfo["Button" + CraftingMenu.CRAFT_BUTTON].addEventListener("press", this, "onCraftButtonPress");
		BottomBarInfo["Button" + CraftingMenu.EXIT_BUTTON].addEventListener("click", this, "onExitButtonPress");
		BottomBarInfo["Button" + CraftingMenu.EXIT_BUTTON].disabled = false;
		BottomBarInfo["Button" + CraftingMenu.AUX_BUTTON].addEventListener("click", this, "onAuxButtonPress");
		BottomBarInfo["Button" + CraftingMenu.AUX_BUTTON].disabled = false;
		ItemsListInputCatcher.onMouseDown = function ()
		{
			if (Mouse.getTopMostEntity() == this) {
				_parent.onItemsListInputCatcherClick();
			}
		};
		RestoreCategoryRect.onRollOver = function ()
		{
			if (_parent.CategoryList.currentState == InventoryLists.TWO_PANELS) {
				_parent.CategoryList.RestoreCategoryIndex();
			}
		};
		ExitMenuRect.onPress = function ()
		{
			GameDelegate.call("CloseMenu", []);
		};
		bCanCraft = false;
		PositionElements();
		SetPlatform(Platform);
	}

	function get bCanCraft(): Boolean
	{
		return _bCanCraft;
	}

	function set bCanCraft(abCanCraft: Boolean): Void
	{
		_bCanCraft = abCanCraft;
		UpdateButtonText();
	}

	function onCraftButtonPress(): Void
	{
		if (bCanCraft) {
			GameDelegate.call("CraftButtonPress", []);
		}
	}

	function onExitButtonPress(): Void
	{
		GameDelegate.call("CloseMenu", []);
	}

	function onAuxButtonPress(): Void
	{
		GameDelegate.call("AuxButtonPress", []);
	}

	function get bCanFadeItemInfo(): Boolean
	{
		GameDelegate.call("CanFadeItemInfo", [], this, "SetCanFadeItemInfo");
		return _bCanFadeItemInfo;
	}

	function SetCanFadeItemInfo(abCanFade: Boolean): Void
	{
		_bCanFadeItemInfo = abCanFade;
	}

	function get bItemCardAdditionalDescription(): Boolean
	{
		return _bItemCardAdditionalDescription;
	}

	function set bItemCardAdditionalDescription(abItemCardDesc: Boolean): Void
	{
		_bItemCardAdditionalDescription = abItemCardDesc;
		if (abItemCardDesc) {
			AdditionalDescription.text = "";
		}
	}

	function SetPartitionedFilterMode(abPartitioned: Boolean): Void
	{
		CategoryList.ItemsList.filterer.SetPartitionedFilterMode(abPartitioned);
	}

	function GetItemShown(): Boolean
	{
		return ItemList.selectedIndex >= 0 && (CategoryList == undefined || CategoryList.currentState == InventoryLists.TWO_PANELS || CategoryList.currentState == InventoryLists.TRANSITIONING_TO_TWO_PANELS);
	}

	function GetNumCategories(): Boolean
	{
		return CategoryList != undefined && CategoryList.CategoriesList != undefined ? CategoryList.CategoriesList.entryList.length : 0;
	}

	function onMouseUp(): Void
	{
		if (ItemInfo.bEditNameMode && !ItemInfo.hitTest(_root._xmouse, _root._ymouse)) {
			OnEndEditItemName({useNewName: false, newName: ""});
		}
	}

	function onMouseWheel(delta: Number): Void
	{
		if (CategoryList.currentState == InventoryLists.TWO_PANELS && !ItemList.disableSelection && !ItemList.disableInput) {
			for (var target: Object = Mouse.getTopMostEntity(); !(target && target != undefined); target = target._parent) {
				if (target == ItemsListInputCatcher || target == MouseRotationRect) {
					if (delta == 1) {
						ItemList.moveSelectionUp();
					} else if (delta == -1) {
						ItemList.moveSelectionDown();
					}
				}
			}
		}
	}

	function onMouseRotationStart(): Void
	{
		GameDelegate.call("StartMouseRotation", []);
		CategoryList.CategoriesList.disableSelection = true;
		ItemList.disableSelection = true;
	}

	function onMouseRotationStop(): Void
	{
		GameDelegate.call("StopMouseRotation", []);
		CategoryList.CategoriesList.disableSelection = false;
		ItemList.disableSelection = false;
	}

	function onItemsListInputCatcherClick(): Void
	{
		if (CategoryList.currentState == InventoryLists.TWO_PANELS && !ItemList.disableSelection && !ItemList.disableInput) {
			OnItemSelect({index: ItemList.selectedIndex});
		}
	}

	function onMouseRotationFastClick(aiMouseButton: Number): Void
	{
		if (aiMouseButton == 0) {
			onItemsListInputCatcherClick();
		}
	}

	function UpdateButtonText(): Void
	{
		var buttonText: Array = ButtonText.concat();
		if (!bCanCraft) {
			buttonText[CraftingMenu.CRAFT_BUTTON] = "";
		}
		if (!GetItemShown()) {
			buttonText[CraftingMenu.SELECT_BUTTON] = "";
		}
		BottomBarInfo.SetButtonsText.apply(BottomBarInfo, buttonText);
	}

	function UpdateItemList(abFullRebuild: Boolean): Void
	{
		if (abFullRebuild == true) {
			CategoryList.InvalidateListData();
		} else {
			ItemList.UpdateList();
		}
		if (MenuType == CraftingMenu.MT_SINGLE_PANEL) {
			FadeInfoCard(ItemList.entryList.length == 0);
		}
	}

	function UpdateItemDisplay(): Void
	{
		var itemShown: Boolean = GetItemShown();
		FadeInfoCard(!itemShown);
		SetSelectedItem(ItemList.selectedIndex);
		GameDelegate.call("ShowItem3D", [itemShown]);
	}

	function FadeInfoCard(abFadeOut: Boolean): Void
	{
		if (abFadeOut && bCanFadeItemInfo) {
			ItemInfo.FadeOutCard();
			if (bHideAdditionalDescription) {
				AdditionalDescriptionHolder._visible = false;
			}
			return;
		}
		if (abFadeOut) {
			return;
		}
		ItemInfo.FadeInCard();
		if (bHideAdditionalDescription) {
			AdditionalDescriptionHolder._visible = true;
		}
	}

	function PositionElements(): Void
	{
		GlobalFunc.SetLockFunction();
		if (MenuType == CraftingMenu.MT_SINGLE_PANEL) {
			ItemListTweener.Lock("L");
			ItemListTweener._x = ItemListTweener._x - CraftingMenu.LIST_OFFSET;
		} else if (MenuType == CraftingMenu.MT_DOUBLE_PANEL) {
			MovieClip(CategoryList).Lock("L");
			CategoryList._x = CategoryList._x - CraftingMenu.LIST_OFFSET;
		}
		MenuNameHolder.Lock("L");
		MenuNameHolder._x = MenuNameHolder._x - CraftingMenu.LIST_OFFSET;
		MenuDescriptionHolder.Lock("TR");
		var leftOffset: Number = Stage.visibleRect.x + Stage.safeRect.x;
		var rightOffset: Number = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		BottomBarInfo.PositionElements(leftOffset, rightOffset);
		MovieClip(ExitMenuRect).Lock("TL");
		ExitMenuRect._x = ExitMenuRect._x - (Stage.safeRect.x + 10);
		ExitMenuRect._y = ExitMenuRect._y - Stage.safeRect.y;
		RestoreCategoryRect._x = ExitMenuRect._x + CategoryList.CategoriesList._parent._width + 25;
		ItemsListInputCatcher._x = RestoreCategoryRect._x + RestoreCategoryRect._width;
		ItemsListInputCatcher._width = _root._width - ItemsListInputCatcher._x;
		MovieClip(MouseRotationRect).Lock("T");
		MouseRotationRect._x = ItemInfo._parent._x;
		MouseRotationRect._width = ItemInfo._parent._width;
		MouseRotationRect._height = 0.55 * Stage.visibleRect.height;
	}

	function OnItemListPressed(event: Object): Void
	{
		GameDelegate.call("CraftSelectedItem", [ItemList.selectedIndex]);
		GameDelegate.call("SetSelectedItem", [ItemList.selectedIndex]);
	}

	function OnItemSelect(event: Object): Void
	{
		GameDelegate.call("ChooseItem", [event.index]);
		GameDelegate.call("ShowItem3D", [event.index != -1]);
		UpdateButtonText();
	}

	function OnItemHighlightChange(event: Object): Void
	{
		SetSelectedItem(event.index);
		FadeInfoCard(event.index == -1);
		UpdateButtonText();
		GameDelegate.call("ShowItem3D", [event.index != -1]);
	}

	function OnShowItemsList(event: Object): Void
	{
		if (Platform == 0) {
			GameDelegate.call("SetSelectedCategory", [CategoryList.CategoriesList.selectedIndex]);
		}
		OnItemHighlightChange(event);
	}

	function OnHideItemsList(event: Object): Void
	{
		SetSelectedItem(event.index);
		FadeInfoCard(true);
		UpdateButtonText();
		GameDelegate.call("ShowItem3D", [false]);
	}

	function OnCategoryListChange(event: Object): Void
	{
		if (Platform != 0) 
		{
			GameDelegate.call("SetSelectedCategory", [event.index]);
		}
	}

	function SetSelectedItem(aSelection: Number): Void
	{
		GameDelegate.call("SetSelectedItem", [aSelection]);
	}

	function handleInput(aInputEvent: Object, aPathToFocus: Array): Boolean
	{
		if (bCanExpandPanel && aPathToFocus.length > 0) {
			aPathToFocus[0].handleInput(aInputEvent, aPathToFocus.slice(1));
		} else if (MenuType == CraftingMenu.MT_DOUBLE_PANEL && aPathToFocus.length > 1) {
			aPathToFocus[1].handleInput(aInputEvent, aPathToFocus.slice(2));
		}
		return true;
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean): Void
	{
		Platform = aiPlatform;
		BottomBarInfo.SetPlatform(aiPlatform, abPS3Switch);
		ItemInfo.SetPlatform(aiPlatform, abPS3Switch);
		CategoryList.SetPlatform(aiPlatform, abPS3Switch);
	}

	function UpdateIngredients(aLineTitle: String, aIngredients: Array, abShowPlayerCount: Boolean): Void
	{
		var itemTextField: TextField = bItemCardAdditionalDescription ? ItemInfo.GetItemName() : AdditionalDescription;
		itemTextField.text = aLineTitle != undefined && aLineTitle.length > 0 ? aLineTitle + ": " : "";
		var oldTextFormat: TextFormat = itemTextField.getNewTextFormat();
		var newTextFormat: TextFormat = itemTextField.getNewTextFormat();
		for (var i: Number = 0; i < aIngredients.length; i++) {
			var ingredient: Object = aIngredients[i];
			newTextFormat.color = ingredient.PlayerCount < ingredient.RequiredCount ? 0x777777 : 0xFFFFFF;
			itemTextField.setNewTextFormat(newTextFormat);
			var requiredCount = "";
			if (ingredient.RequiredCount > 1) {
				requiredCount = ingredient.RequiredCount + " ";
			}
			var itemCount: String = "";
			if (abShowPlayerCount && ingredient.PlayerCount >= 1) {
				itemCount = " (" + ingredient.PlayerCount + ")";
			}
			var ingredientString: String = requiredCount + ingredient.Name + itemCount + (i >= aIngredients.length - 1 ? "" : ", ");
			itemTextField.replaceText(itemTextField.length, itemTextField.length + 1, ingredientString);
		}
		itemTextField.setNewTextFormat(oldTextFormat);
	}

	function EditItemName(aInitialText: String, aMaxChars: Number): Void
	{
		ItemInfo.StartEditName(aInitialText, aMaxChars);
	}

	function OnEndEditItemName(event: Object): Void
	{
		ItemInfo.EndEditName();
		GameDelegate.call("EndItemRename", [event.useNewName, event.newName]);
	}

	function ShowSlider(aiMaxValue: Number, aiMinValue: Number, aiCurrentValue: Number, aiSnapInterval: Number): Void
	{
		ItemInfo.ShowEnchantingSlider(aiMaxValue, aiMinValue, aiCurrentValue);
		ItemInfo.quantitySlider.snapping = true;
		ItemInfo.quantitySlider.snapInterval = aiSnapInterval;
		ItemInfo.quantitySlider.addEventListener("change", this, "OnSliderChanged");
		OnSliderChanged();
	}

	function OnSliderChanged(event: Object): Void
	{
		GameDelegate.call("CalculateCharge", [ItemInfo.quantitySlider.value], this, "SetChargeValues");
	}

	function SetSliderValue(aValue: Number): Void
	{
		ItemInfo.quantitySlider.value = aValue;
	}

	function OnSubMenuAction(event: Object): Void
	{
		if (event.opening == true) {
			ItemList.disableSelection = true;
			ItemList.disableInput = true;
			CategoryList.CategoriesList.disableSelection = true;
			CategoryList.CategoriesList.disableInput = true;
		} else if (event.opening == false) {
			ItemList.disableSelection = false;
			ItemList.disableInput = false;
			CategoryList.CategoriesList.disableSelection = false;
			CategoryList.CategoriesList.disableInput = false;
		}
		if (event.menu == "quantity") {
			if (event.opening) {
				return;
			}
			GameDelegate.call("SliderClose", [!event.canceled, event.value]);
		}
	}

	function PreRebuildList(): Void
	{
		SavedCategoryCenterText = CategoryList.CategoriesList.centeredEntry.text;
		SavedCategorySelectedText = CategoryList.CategoriesList.selectedEntry.text;
		SavedCategoryScrollRatio = CategoryList.CategoriesList.maxScrollPosition <= 0 ? 0 : CategoryList.CategoriesList.scrollPosition / CategoryList.CategoriesList.maxScrollPosition;
	}

	function PostRebuildList(abRestoreSelection: Boolean): Void
	{
		if (abRestoreSelection) {
			var entryList: Array = CategoryList.CategoriesList.entryList;
			var centerIndex: Number = -1;
			var selectedIndex: Number = -1;
			for (var i: Number = 0; i < entryList.length; i++) {
				if (SavedCategoryCenterText == entryList[i].text) {
					centerIndex = i;
				}
				if (SavedCategorySelectedText == entryList[i].text) {
					selectedIndex = i;
				}
			}
			if (centerIndex == -1) {
				centerIndex = Math.floor(SavedCategoryScrollRatio * entryList.length);
			}
			centerIndex = Math.max(0, centerIndex);
			CategoryList.CategoriesList.RestoreScrollPosition(centerIndex, false);
			if (selectedIndex != -1) {
				CategoryList.CategoriesList.selectedIndex = selectedIndex;
			}
			CategoryList.CategoriesList.UpdateList();
			CategoryList.ItemsList.filterer.itemFilter = CategoryList.CategoriesList.selectedEntry.flag;
			CategoryList.ItemsList.UpdateList();
		}
	}

}
