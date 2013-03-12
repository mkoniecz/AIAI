class AIAI extends AIInfo {
  function GetAuthor()      { return "Kogut"; }
  function GetName()        { return "AIAI"; }
  function GetDescription() { return "Automatic Idiot AI Version beta."; }
  function GetVersion()     { return 3; }
  function GetDate()        { return "2010-02-14"; }
  function CreateInstance() { return "AIAI"; }
  function GetShortName()   { return "AIAI"; }
  function MinVersionToLoad() { return 0; } 
  function GetURL() {return "http://www.tt-forums.net/viewtopic.php?f=65&t=47298";}

	function GetSettings() {

	AddSetting( {
		name = "use_trucks",
		description = "Trucks allowed",
		easy_value = 1,
		medium_value = 1,
		hard_value = 1,
		custom_value = 1,
		flags = AICONFIG_BOOLEAN + AICONFIG_INGAME
	});
	
	AddSetting( {
		name = "use_planes",
		description = "Planes allowed",
		easy_value = 1,
		medium_value = 1,
		hard_value = 1,
		custom_value = 1,
		flags = AICONFIG_BOOLEAN + AICONFIG_INGAME
	});

	AddSetting( {
		name = "clear_signs",
		description = "Clear company signs",
		easy_value = 0,
		medium_value = 0,
		hard_value = 0,
		custom_value = 0,
		flags = AICONFIG_BOOLEAN + AICONFIG_INGAME
	});

	AddSetting( {
		name = "debug_signs_for_planned_route",
		description = "Build debug signs for planned route",
		easy_value = 0,
		medium_value = 0,
		hard_value = 0,
		custom_value = 0,
		flags = AICONFIG_BOOLEAN + AICONFIG_INGAME
	});
  
	AddSetting( {
		name = "debug_signs_for_airports_load",
		description = "Build debug signs for airports load",
		easy_value = 0,
		medium_value = 0,
		hard_value = 0,
		custom_value = 0,
		flags = AICONFIG_BOOLEAN + AICONFIG_INGAME
	});

	AddSetting( {
		name = "other_debug_signs",
		description = "Build other debug signs",
		easy_value = 0,
		medium_value = 0,
		hard_value = 0,
		custom_value = 0,
		flags = AICONFIG_BOOLEAN + AICONFIG_INGAME
	});
	}
}

RegisterAI(AIAI());