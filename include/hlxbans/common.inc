/**
 * vim: set ts=4 :
 * =============================================================================
 * HLXBans SourceMod Plugin
 * Implements advanced ban and admin management.
 *
 * HLXBans Copyright 2010-2012 HLXBans.net. All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in <http://www.sourcemod.net/license.php> (as of this
 * writing, version JULY-31-2007).
 *
 */

#if defined _hlxbans_common_included_
  #endinput
#endif
#define _hlxbans_common_included_

#include <sourcemod>

#include "hlxbans/smlib"

new const String:hlx_version[] = "1.0";
new const String:hlx_chatPrefix[] = "[HLXBans] ";

/**
 * Parses a target string, putting the resulting authid
 * in `target' and returning the client index, -1 if
 * the client is not in the server, or -2 if the input
 * string is invalid.
 *
 * Accepted format for input is: #userid|steamid|name
 */
stock hlx_ParseTarget(const String:input[], String:target[32])
{
	if (input[0] == '#') { // this is a userid
		new userid = StringToInt(input[1]);
		if (!userid)
			return -2;
		
		new client = GetClientOfUserId(userid);
		if (!client)
			return -2;
		
		GetClientAuthString(client, target, sizeof target);
		return client;
	} else { // try steamid, IP, then name
		if (StrContains(input, "STEAM_") == 0) { // starts with
			strcopy(target, sizeof target, input);
			return Client_FindBySteamId(input);
		} else if (SimpleRegexMatch(input, "(\d{1,3}\.){3}(\d{1,3})")) {
			strcopy(target, sizeof target, input);
			return -1;
		} else {
			new client = Client_FindByName(target);
			if (client == -1)
				return -2;
			
			GetClientAuthString(client, target, sizeof target);
			return client;
		}
	}
}

/**
 * Logs an action to the standard SourceMod logs and to the HLXBans log
 * Formatted message is cropped to 512 bytes.
 */
stock hlx_Log(const String:format[], any:...)
{
    static Handle:hlx_logFile = INVALID_HANDLE;
    if (hlx_logFile == INVALID_HANDLE) {
        decl String:logFile[256];
        BuildPath(Path_SM, logFile, sizeof logFile, "logs/hlxbans.log");
        hlx_logFile = OpenFile(logFile, "a");
    }

    decl String:buffer[512];
    VFormat(buffer, sizeof buffer, format, 2);
    LogToOpenFile(hlx_logFile, buffer);
}
