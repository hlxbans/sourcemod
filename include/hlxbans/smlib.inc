// stocks taken from SMLIB <http://www.sourcemodplugins.org/pages/smlib/>

#define MAX_STEAMAUTH_LENGTH 21

/**
* Finds a player by his SteamID
*
* @param auth			SteamID to search for
* @return				Client Index or -1
*/
stock Client_FindBySteamId(const String:auth[])
{
	new String:clientAuth[MAX_STEAMAUTH_LENGTH];
	for (new client=1; client <= MaxClients; client++) {
		if (!IsClientAuthorized(client)) {
			continue;
		}
		
		GetClientAuthString(client, clientAuth, sizeof(clientAuth));

		if (StrEqual(auth, clientAuth)) {
			return client;
		}
	}
	
	return -1;
}

/**
* Finds a player by his name.
* Only returns the first matching player.
*
* @param name			Name to search for.
* @param partOfName		Whether to search for the part of a name or compare the full name.
* @param caseSensitive	If true, comparison is case sensitive. If false (default), comparison is case insensitive.
* @return				Client Index or -1
*/
stock Client_FindByName(const String:name[], bool:partOfName=true, bool:caseSensitive=false)
{
	new String:clientName[MAX_STEAMAUTH_LENGTH];
	for (new client=1; client <= MaxClients; client++) {
		if (!IsClientAuthorized(client)) {
			continue;
		}
		
		GetClientName(client, clientName, sizeof(clientName));

		if (partOfName) {
			if (StrContains(clientName, name, caseSensitive) != -1) {
				return client;
			}
		}
		else if (StrEqual(name, clientName, caseSensitive)) {
			return client;
		}
	}
	
	return -1;
}
