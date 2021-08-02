import gfx.controls.RadioButton;
import gfx.controls.ButtonGroup;
import gfx.io.GameDelegate;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;

class Quest_Journal extends MovieClip
{
	var bTabsDisabled: Boolean;
	
	var iCurrentTab: Number;
	
	var BottomBar: MovieClip;
	var BottomBar_mc: MovieClip;
	
	var PageArray: Array;
	
	var TabButtonHelp: MovieClip;
	var TopmostPage: MovieClip;	
	var QuestsFader: MovieClip;
	var StatsFader: MovieClip;
	var SystemFader: MovieClip;
	
	var QuestsTab: RadioButton;
	var StatsTab: RadioButton;
	var SystemTab: RadioButton;
	var TabButtonGroup: ButtonGroup;

	function Quest_Journal()
	{
		super();
		BottomBar_mc = BottomBar;
		PageArray = new Array(QuestsFader.Page_mc, StatsFader.Page_mc, SystemFader.Page_mc);
		TopmostPage = QuestsFader;
		bTabsDisabled = false;
	}

	function InitExtensions()
	{
		GlobalFunc.SetLockFunction();
		MovieClip(BottomBar_mc).Lock("B");
		
		QuestsTab.disableFocus = true;
		StatsTab.disableFocus = true;
		SystemTab.disableFocus = true;
		
		TabButtonGroup = ButtonGroup(QuestsTab.group);
		TabButtonGroup.addEventListener("itemClick", this, "onTabClick");
		TabButtonGroup.addEventListener("change", this, "onTabChange");
		
		GameDelegate.addCallBack("RestoreSavedSettings", this, "RestoreSavedSettings");
		GameDelegate.addCallBack("onRightStickInput", this, "onRightStickInput");
		GameDelegate.addCallBack("HideMenu", this, "DoHideMenu");
		GameDelegate.addCallBack("ShowMenu", this, "DoShowMenu");
		GameDelegate.addCallBack("StartCloseMenu", this, "CloseMenu");
		
		BottomBar_mc.InitBar();
	}

	function RestoreSavedSettings(aiSavedTab: Number, abTabsDisabled: Boolean): Void
	{
		iCurrentTab = Math.min(Math.max(aiSavedTab, 0), TabButtonGroup.length - 1);
		bTabsDisabled = abTabsDisabled;
		if (bTabsDisabled) {
			iCurrentTab = TabButtonGroup.length - 1;
			QuestsTab.disabled = true;
			StatsTab.disabled = true;
		}
		SwitchPageToFront(iCurrentTab, true);
		TabButtonGroup.setSelectedButton(TabButtonGroup.getButtonAt(iCurrentTab));
	}

	function SwitchPageToFront(aiTab: Number, abForceFade: Boolean): Void
	{
		if (TopmostPage != PageArray[iCurrentTab]._parent) 
		{
			TopmostPage.gotoAndStop("hide");
			PageArray[iCurrentTab]._parent.swapDepths(TopmostPage);
			TopmostPage = PageArray[iCurrentTab]._parent;
		}
		TopmostPage.gotoAndPlay(abForceFade ? "ForceFade" : "fadeIn");
		BottomBar_mc.SetMode(iCurrentTab);
	}

	function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bHandledInput: Boolean = false;
		if (pathToFocus != undefined && pathToFocus.length > 0) {
			bHandledInput = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		if (!bHandledInput && GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent === NavigationCode.TAB) {
				CloseMenu();
			} else if (details.navEquivalent === NavigationCode.GAMEPAD_L2) {
				if (!bTabsDisabled) {
					PageArray[iCurrentTab].endPage();
					iCurrentTab = iCurrentTab + (details.navEquivalent == NavigationCode.GAMEPAD_L2 ? -1 : 1);
					if (iCurrentTab == -1) {
						iCurrentTab = TabButtonGroup.length - 1;
					}
					if (iCurrentTab == TabButtonGroup.length) {
						iCurrentTab = 0;
					}
					SwitchPageToFront(iCurrentTab, false);
					TabButtonGroup.setSelectedButton(TabButtonGroup.getButtonAt(iCurrentTab));
				}
			} else if (details.navEquivalent === NavigationCode.GAMEPAD_R2) {
				if (!bTabsDisabled) {
					PageArray[iCurrentTab].endPage();
					iCurrentTab = iCurrentTab + (details.navEquivalent == NavigationCode.GAMEPAD_L2 ? -1 : 1);
					if (iCurrentTab == -1) {
						iCurrentTab = TabButtonGroup.length - 1;
					}
					if (iCurrentTab == TabButtonGroup.length) {
						iCurrentTab = 0;
					}
					SwitchPageToFront(iCurrentTab, false);
					TabButtonGroup.setSelectedButton(TabButtonGroup.getButtonAt(iCurrentTab));
				}
			}
		}
		return true;
	}

	function CloseMenu(abForceClose: Boolean): Void
	{
		if (abForceClose != true) {
			GameDelegate.call("PlaySound", ["UIJournalClose"]);
		}
		GameDelegate.call("CloseMenu", [iCurrentTab, QuestsFader.Page_mc.selectedQuestID, QuestsFader.Page_mc.selectedQuestInstance]);
	}

	function onTabClick(event: Object): Void
	{
		if (bTabsDisabled) {
			return;
		}
		
		var iOldTab: Number = iCurrentTab;
		
		if (event.item == QuestsTab) {
			iCurrentTab = 0;
		} else if (event.item == StatsTab) {
			iCurrentTab = 1;
		} else if (event.item == SystemTab) {
			iCurrentTab = 2;
		}
		if (iOldTab != iCurrentTab) {
			PageArray[iOldTab].endPage();
		}
		
		SwitchPageToFront(iCurrentTab, false);
	}

	function onTabChange(event: Object): Void
	{
		event.item.gotoAndPlay("selecting");
		PageArray[iCurrentTab].startPage();
		GameDelegate.call("PlaySound", ["UIJournalTabsSD"]);
	}

	function onRightStickInput(afX: Number, afY: Number): Void
	{
		if (PageArray[iCurrentTab].onRightStickInput != undefined) {
			PageArray[iCurrentTab].onRightStickInput(afX, afY);
		}
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean): Void
	{
		for (var i: String in PageArray) {
			if (PageArray[i].SetPlatform != undefined) 
			{
				PageArray[i].SetPlatform(aiPlatform, abPS3Switch);
			}
		}
		BottomBar_mc.SetPlatform(aiPlatform, abPS3Switch);
		TabButtonHelp.gotoAndStop(aiPlatform + 1);
	}

	function DoHideMenu(): Void
	{
		_parent.gotoAndPlay("fadeOut");
	}

	function DoShowMenu(): Void
	{
		_parent.gotoAndPlay("fadeIn");
	}

}
