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
    name = "HLXBans Chat Logs",
    author = "HLXBans.net",
    description = "HL & HL2 Banning System",
    version = hlxbans_version,
    url = "http://www.hlxbans.net/"
};

new Handle:g_cvChatLogsEnabled,
    bool:g_bChatLogsEnabled;

public OnPluginStart()
{
    LoadTranslations("common.phrases");
    //LoadTranslations("hlxbans.phrases");
    
    g_cvChatLogsEnabled = CreateConVar("hlxbans_chatlogs_enabled", "1", "Send recent chat messages to server when a player is banned");
    
    HookConVarChange(g_cvChatLogsEnabled, OnConVarChange);
    
    g_bChatLogsEnabled = true;
    
    HookEvent("player_chat", Event_PlayerChat);
}

public OnConVarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
    if (convar == g_cvChatLogsEnabled) {
        g_bChatLogsEnabled = !!StringToInt(newValue);
    }
}

public Action:Event_PlayerChat(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (g_bChatLogsEnabled)
    {
        decl String:authid[32], String:message[256], String:query[512];
        GetClientAuthString(GetClientOfUserId(GetEventInt(event, "userid")), authid, sizeof authid);
        GetEventString(event, "text", message, sizeof message);

        decl hlx_MessageType:type = GetEventBool(event, "teamonly") ? MessageType_Team : MessageType_All;
        hlx_PushChatMessage(authid, message, type);        
    }
    
    return Plugin_Handled;
}
