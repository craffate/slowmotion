#pragma newdecls required
#pragma semicolon 1
#pragma tabsize 4

#include <sourcemod>
#include "slowmotion"
#undef REQUIRE_PLUGIN
#include <eventqueuefix>

public Plugin		myinfo =
{
	name = "Slow motion",
	author = "exha",
	description = "Enables users to slow down time.",
	version = SLOWMOTION_VERSION,
	url = ""
};

bool				g_bEventQueueFix;
Handle				g_hPhysTimescale;
float				g_fDefaultTimescale;
GlobalForward		g_SlowMotionEnableForward;
GlobalForward		g_SlowMotionDisableForward;

public void			OnPluginStart()
{
	ConVar			hostTimescale;

	g_bEventQueueFix = false;
	g_hPhysTimescale = FindConVar(CVAR_PHYS_TIMESCALE_NAME);
	hostTimescale = FindConVar("host_timescale");
	if (null == hostTimescale)
	{
		SetFailState("Could not find host_timescale cvar.");
	}
	g_fDefaultTimescale = GetConVarFloat(hostTimescale);
	if (null == g_hPhysTimescale)
	{
		SetFailState("Could not get handle for %s.", CVAR_PHYS_TIMESCALE_NAME);
	}
	RegConsoleCmd("+slowmotion", Command_EnableSlowMotion);
	RegConsoleCmd("-slowmotion", Command_DisableSlowMotion);
	g_SlowMotionEnableForward = CreateGlobalForward("OnSlowMotionEnable", ET_Ignore, Param_Cell);
	g_SlowMotionDisableForward = CreateGlobalForward("OnSlowMotionDisable", ET_Ignore, Param_Cell);
}

public void			OnAllPluginsLoaded()
{
	g_bEventQueueFix = LibraryExists("eventqueuefix");
}

public APLRes		AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary(SLOWMOTION_LIBRARY_NAME);
	CreateNative("DisableSlowMotion", Native_DisableSlowMotion);
	CreateNative("EnableSlowMotion", Native_EnableSlowMotion);

	return (APLRes_Success);
}

/**
 * Set slow motion.
 * @param timescale	Timescale to set.
 * @return Non-zero on error.
 */
int				SetTimescale(const float timescale)
{
	int				ret;
	int				idx;

	ret = 0;
	idx = 1;
	SetConVarFloat(g_hPhysTimescale, timescale);
	while (MaxClients >= idx && 0 == ret)
	{
		if (IsClientInGame(idx) && !IsClientSourceTV(idx))
		{
			SetEntPropFloat(idx, Prop_Data, "m_flLaggedMovementValue", timescale);
			if (g_bEventQueueFix)
			{
				ret = SetEventsTimescale(idx, timescale) ? ret : 1;
			}
		}
		idx += 1;
	}
	return (ret);
}

any					Native_DisableSlowMotion(Handle plugin, int numParams)
{
	return SetTimescale(g_fDefaultTimescale);
}

any					Native_EnableSlowMotion(Handle plugin, int numParams)
{
	return SetTimescale(SLOWMOTION_DEFAULT_TIMESCALE_ON);
}

/**
 * Enable slow motion and fire an event.
 * @param client	Client index.
 * @param args		Arguments (unused).
 */
public Action			Command_EnableSlowMotion(const int client, const int args)
{
	SetTimescale(SLOWMOTION_DEFAULT_TIMESCALE_ON);
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
public Action			Command_DisableSlowMotion(const int client, const int args)
{
	SetTimescale(g_fDefaultTimescale);
	Call_StartForward(g_SlowMotionDisableForward);
	Call_PushCell(client);
	Call_Finish();

	return (Plugin_Handled);
}