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
#include "hlxbans/storage.sp"

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
    InitStorage();

    LoadTranslations("common.phrases");
    //LoadTranslations("hlxbans.phrases");

    CreateConVar("hlxbans_version", hlx_version, _, FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

    RegAdminCmd("sm_ban", Cmd_Ban, ADMFLAG_BAN, "sm_ban <#userid|steamid|name> <minutes|0> [reason]");
    RegAdminCmd("sm_unban", Cmd_Unban, ADMFLAG_UNBAN, "sm_unban <steamid> [reason]");
    RegAdminCmd("sm_addban", Cmd_AddBan, ADMFLAG_RCON, "sm_addban <time> <steamid> [reason]");
    RegAdminCmd("sm_banip", Cmd_BanIp, ADMFLAG_BAN, "sm_banip <ip|#userid|steamid|name> <time> [reason]");

    RegAdminCmd("hlx_check", Cmd_Check, ADMFLAG_GENERIC, "hlx_check <steamid|#userid|name>");

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
        hlx_Log("Unloaded basebans plugin");
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

// sm_ban <#userid|steamid|name> <minutes|0> [reason]
public Action:Cmd_Ban(client, args)
{
    if (args < 2) {
        ReplyToCommand(client, "Usage: sm_ban <#userid|steamid|name> <minutes|0> [reason]");
        return Plugin_Handled;
    }

    decl String:target[32], String:argTime[10];
    GetCmdArg(1, target, sizeof target);
    GetCmdArg(2, argTime, sizeof argTime);

    new time = StringToInt(argTime);

  new String:reason[255];
    if (args > 2) {
        GetCmdArg(3, reason, sizeof reason);
    }

    decl String:adminId[32];
    GetClientAuthString(client, adminId, sizeof adminId);

    new String:finalTarget[32];
    new targetClient = hlx_ParseTarget(target, finalTarget);

    if (targetClient == -1) { // offline ban, no nick or IP
        hlx_Ban(finalTarget, "", "", time, reason, adminId);
    } else {
        decl String:targetNick[32], String:targetIp[32];
        GetClientName(targetClient, targetNick, sizeof targetNick);
        GetClientIP(targetClient, targetIp, sizeof targetIp);

        hlx_Ban(finalTarget, targetNick, targetIp, time, reason, adminId);
    }

    return Plugin_Handled;
}

// sm_unban <steamid|ip> [reason]
public Action:Cmd_Unban(client, args)
{
    if (args < 1) {
        ReplyToCommand(client, "Usage: sm_unban <#userid|steamid|name> [reason]");
        return Plugin_Handled;
    }

    decl String:target[32];
    GetCmdArg(1, target, sizeof target);

    new String:reason[255];
    if (args > 1) {
        GetCmdArg(2, reason, sizeof reason);
    }

    decl String:adminId[32];
    GetClientAuthString(client, adminId, sizeof adminId);

    new String:finalTarget[32];
    hlx_ParseTarget(target, finalTarget);
    hlx_Unban(finalTarget, reason, adminId);

    return Plugin_Handled;
}

// sm_addban <steamid> <minutes|0> [reason]
public Action:Cmd_AddBan(client, args)
{
    if (args < 2) {
        ReplyToCommand(client, "Usage: sm_addban <steamid> <minutes|0> [reason]");
        return Plugin_Handled;
    }

    return Cmd_Ban(client, args);
}

// sm_banip <ip|#userid|name> <time> [reason]
public Action:Cmd_BanIp(client, args)
{
    if (args < 2) {
        ReplyToCommand(client, "Usage: sm_banip <ip|#userid|name> <time> [reason]");
        return Plugin_Handled;
    }

    decl String:target[32], String:argTime[10];
    GetCmdArg(1, target, sizeof target);
    GetCmdArg(2, argTime, sizeof argTime);

    new time = StringToInt(argTime);

    new String:reason[255];
    if (args > 2) {
        GetCmdArg(3, reason, sizeof reason);
    }

    decl String:adminId[32];
    GetClientAuthString(client, adminId, sizeof adminId);

    new String:finalTarget[32];
    new targetClient = hlx_ParseTarget(target, finalTarget);
    if (targetClient == -1) { // offline ban, assume IP
        hlx_Ban("", "", finalTarget, time, reason, adminId);
    } else {
        decl String:targetNick[32], String:targetIp[32];
        GetClientName(targetClient, targetNick, sizeof targetNick);
        GetClientIP(targetClient, targetIp, sizeof targetIp);

        hlx_Ban(finalTarget, targetNick, targetIp, time, reason, adminId);
    }

    return Plugin_Handled;
}

// hlx_check <steamid|#userid|name>
public Action:Cmd_Check(client, args)
{
    if (args < 1) {
        ReplyToCommand(client, "Usage: hlx_check <steamid|#userid|name>");
        return Plugin_Handled;
    }

    decl String:target[32];
    GetCmdArg(1, target, sizeof target);

    new String:finalTarget[32];
    new targetClient = hlx_ParseTarget(target, finalTarget);
    if (targetClient == -1) { // IP
        hlx_Check("", finalTarget);
    } else {
        decl String:targetIp[32];
        GetClientIP(targetClient, targetIp, sizeof targetIp);

        hlx_Check(finalTarget, targetIp);
    }

    return Plugin_Handled;
}
