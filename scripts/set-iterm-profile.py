#!/usr/bin/env python3

import iterm2

async def switch_profile(connection):
    app = await iterm2.async_get_app(connection)

    # Prompt the user to select a profile.
    alert = iterm2.TextInputAlert("Select a profile", "enter either Light or Dark", "Dark", "Dark")
    profile_name = await alert.async_run(connection)

    # Query for the list of profiles so we can search by name. This returns a
    # subset of the full profiles so it's fast.
    partialProfiles = await iterm2.PartialProfile.async_query(connection)
    # Iterate over each partial profile
    for partial in partialProfiles:
        if partial.name == profile_name:
            # This is the one we're looking for. Change the current session's
            # profile.
            full = await partial.async_get_full_profile()
            await app.current_terminal_window.current_tab.current_session.async_set_profile(full)
            return




iterm2.run_until_complete(switch_profile)
