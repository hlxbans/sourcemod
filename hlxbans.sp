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

#include <sourcemod>

#include "hlxbans/common"
#include "hlxbans/db"

public Plugin:myinfo =
{
    name = "HLXBans",
    author = "HLXBans.net",
    description = "HL & HL2 Banning System",
    version = hlx_version,
    url = "http://www.hlxbans.net/"
};

new bool:g_bLateLoaded;

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
    g_bLateLoaded = late;
    return APLRes_Success;
}

public OnPluginStart()
{   
    LoadTranslations("common.phrases");
    //LoadTranslations("hlxbans.phrases");
    
    CreateConVar("hlxbans_version", hlx_version, _, FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
    
    RegAdminCmd("sm_ban", Cmd_Ban, ADMFLAG_BAN, "sm_ban <#userid|name> <minutes|0> [reason]");
    RegAdminCmd("sm_unban", Cmd_Unban, ADMFLAG_UNBAN, "sm_unban <steamid|ip> [reason]");
    RegAdminCmd("sm_addban", Cmd_AddBan, ADMFLAG_RCON, "sm_addban <time> <steamid> [reason]");
    RegAdminCmd("sm_banip", Cmd_BanIp, ADMFLAG_BAN, "sm_banip <ip|#userid|name> <time> [reason]");
    
    if (g_bLateLoaded) {
        decl String:authid[32];
        for (new i = 1; i <= MaxClients; ++i) {
            if (IsClientInGame(i) && !IsFakeClient(i)) {
                GetClientAuthString(i, authid, sizeof authid);
                OnClientAuthorized(i, authid);
            }
        }
    }
}

public OnAllPluginsLoaded()
{
    new Handle:basebans = FindPluginByFile("basebans.smx");
    if (basebans != INVALID_HANDLE && GetPluginStatus(basebans) == Plugin_Running) {
        ServerCommand("sm plugins unload basebans");
        HLX_Log("Unloaded basebans plugin");
    }
}

public OnMapStart()
{

}

public OnMapEnd()
{

}

public OnClientAuthorized(client, const String:auth[])
{

}

/***********************
        COMMANDS
 ***********************/

// sm_ban <#userid|name> <minutes|0> [reason]
public Action:Cmd_Ban(client, args)
{

}

// sm_unban <steamid|ip> [reason]
public Action:Cmd_Unban(client, args)
{

}

// sm_addban <time> <steamid> [reason]
public Action:Cmd_AddBan(client, args)
{

}

// sm_banip <ip|#userid|name> <time> [reason]
public Action:Cmd_BanIp(client, args)
{

}
