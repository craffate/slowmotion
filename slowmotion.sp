#pragma newdecls required
#pragma semicolon 1
#pragma tabsize 4

#include <sourcemod>
#include "slowmotion"
#undef REQUIRE_PLUGIN
#include <gamespeed>

public Plugin		myinfo =
{
	name = "Slow motion",
	author = "exha",
	description = "Enables users to slow down time.",
	version = SLOWMOTION_VERSION,
	url = ""
};

GlobalForward		g_SlowMotionEnableForward;
GlobalForward		g_SlowMotionDisableForward;

public void			OnPluginStart()
{
	RegConsoleCmd("+slowmotion", Command_EnableSlowMotion);
	RegConsoleCmd("-slowmotion", Command_DisableSlowMotion);
	g_SlowMotionEnableForward = CreateGlobalForward("OnSlowMotionEnable", ET_Ignore, Param_Cell);
	g_SlowMotionDisableForward = CreateGlobalForward("OnSlowMotionDisable", ET_Ignore, Param_Cell);
}

public void			OnAllPluginsLoaded()
{
	if (!LibraryExists("gamespeed"))
	{
		SetFailState("Could not load gamespeed library.");
	}
}

public APLRes		AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary(SLOWMOTION_LIBRARY_NAME);
	CreateNative("DisableSlowMotion", Native_DisableSlowMotion);
	CreateNative("EnableSlowMotion", Native_EnableSlowMotion);

	return (APLRes_Success);
}

any					Native_DisableSlowMotion(Handle plugin, int numParams)
{
	return (SetGameSpeed(SLOWMOTION_DEFAULT_TIMESCALE_OFF));
}

any					Native_EnableSlowMotion(Handle plugin, int numParams)
{
	return (SetGameSpeed(SLOWMOTION_DEFAULT_TIMESCALE_ON));
}

/**
 * Enable slow motion and fire an event.
 * @param client	Client index.
 * @param args		Arguments (unused).
 */
public Action		Command_EnableSlowMotion(const int client, const int args)
{
	SetGameSpeed(SLOWMOTION_DEFAULT_TIMESCALE_ON);
	Call_StartForward(g_SlowMotionEnableForward);
	Call_PushCell(client);
	Call_Finish();

	return (Plugin_Handled);
}

/**
 * Disable slow motion and fire an event.
 * @param client	Client index.
 * @param args		Arguments (unused).
 */
public Action		Command_DisableSlowMotion(const int client, const int args)
{
	SetGameSpeed(SLOWMOTION_DEFAULT_TIMESCALE_OFF);
	Call_StartForward(g_SlowMotionDisableForward);
	Call_PushCell(client);
	Call_Finish();

	return (Plugin_Handled);
}