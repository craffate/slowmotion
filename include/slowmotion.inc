#pragma newdecls required
#pragma semicolon 1
#pragma tabsize 4
#if !defined SLOWMOTION_INC
	#define SLOWMOTION_INC

	#define SLOWMOTION_VERSION "1.0.0"
	#define SLOWMOTION_LIBRARY_NAME "slowmotion"
	#define SLOWMOTION_FILE_NAME "slowmotion.smx"

	#define CVAR_PHYS_TIMESCALE_NAME "phys_timescale"

	#define SLOWMOTION_DEFAULT_TIMESCALE_ON 0.3

public SharedPlugin		__pl_slowmotion =
{
	name = SLOWMOTION_LIBRARY_NAME,
	file = SLOWMOTION_FILE_NAME,
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

/**
 * Called when a player enables slow motion.
 * @param client	Client index.
 */
forward void		OnSlowMotionEnable(const int client);

/**
 * Called when a player disables slow motion.
 * @param client	Client index.
 */
forward void		OnSlowMotionDisable(const int client);

/**
 * Enable slow motion.
 * @return Non-zero on error.
 */
native int			EnableSlowMotion();

/**
 * Disable slow motion.
 * @return Non-zero on error.
 */
native int			DisableSlowMotion();

	#if !defined REQUIRE_PLUGIN
public void			__pl_slowmotion_SetNTVOptional()
{
	MarkNativeAsOptional("EnableSlowMotion");
	MarkNativeAsOptional("DisableSlowMotion");
}
	#endif

#endif