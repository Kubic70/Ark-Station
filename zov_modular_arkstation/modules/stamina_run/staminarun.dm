/mob/living/carbon
	var/stamina_run
	var/stamina_run_max = 100
	var/stamina_run_regen_start_time

/mob/living/carbon/Initialize()
	..()
	stamina_run = stamina_run_max
	stamina_run_regen_start_time = 0

// we not need stamina loss on some type speed modifier
GLOBAL_LIST_INIT(blackListMovespeedModifier, list(
	/datum/movespeed_modifier/jetpack/cybernetic,
	/datum/movespeed_modifier/jetpack/fullspeed
))

/mob/living/carbon/Move()
	..()

	if(move_intent == MOVE_INTENT_RUN)

		if(!moving_from_pull || !pulledby || !move_packet) // && !LAZYFIND(movespeed_modification, /datum/movespeed_modifier/jetpack/)) // && !(movement_type & FLOATING)

			var/speedmod = FALSE
			for(var/key in get_movespeed_modifiers())
				var/datum/movespeed_modifier/M = movespeed_modification[key]
				to_chat(world, LAZYFIND(GLOB.blackListMovespeedModifier, M)) // я хуй его знает почему там всегда нголь, я спать
				//if(SM == /datum/movespeed_modifier/jetpack/cybernetic || SM == /datum/movespeed_modifier/jetpack/fullspeed)
				if(LAZYFIND(GLOB.blackListMovespeedModifier, M) != 0)
					speedmod = TRUE
					break

			if(!speedmod)
				if(stamina_run > 0)
					stamina_run -= 1
					stamina_run_regen_start_time = world.time + STAMINA_REGEN_BLOCK_TIME
				else
					adjustStaminaLoss(1)

/mob/living/carbon/adjustStaminaLoss(amount, updating_stamina, forced, required_biotype = ALL)
	..()
	if(amount > 0)
		stamina_run_regen_start_time = world.time + STAMINA_REGEN_BLOCK_TIME

/mob/living/carbon/Life()
	..()
	if(stat != DEAD)
		if(stamina_run < stamina_run_max && stamina_run_regen_start_time <= world.time)
			stamina_run = stamina_run_max
