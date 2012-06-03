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
#include <dbi>

#include "hlxbans/common"

#include "storage/main.sp"
#include "storage/cache.sp"

/* Storage engine states:
    - IDLE: waiting for next command
    - LOAD: try to load info from DB (ie. on player connection)
    - RETRY: try to reach the main database again according to the plugin configuration.
             Future actions can cause us to leave RETRY state earlier. If we successfully
             reach the server in RETRY state, we go to the RESTORE state. 

    Note that the secondary storage does little error checking. If we fail to acquire
    a handle to a local SQLite DB, the plugin will die gracefully as there's no way to
    ensure data integrity.
*/
enum StorageState {
    IDLE
    ,LOAD
    ,RETRY
};

static StorageState:g_state = StorageState:-1;

// main is usually MySQL remote and secondary is usually local SQLite
static Handle:g_primDB = INVALID_HANDLE, Handle:g_secDB = INVALID_HANDLE;

static Handle:g_cvRetryInterval;

InitStorage()
{
    g_state = LOAD;

    g_cvRetryInterval = CreateConVar("hlx_retry_interval", "60", "Interval for retrying database access", .hasMin=true, .min=0.0);

    SQL_TConnect(ConnectCallback, "hlxbans", 1);
}

public ConnectCallback(Handle:owner, Handle:hndl, const String:error[], any:retryCount)
{
    if (hndl == INVALID_HANDLE) {
        if (retryCount > 1)
            hlx_Log("Primary database unreachable after %d attempts (%s).", retryCount, error);
        else
            hlx_Log("Primary database unreachable (%s).", error);
    } else {
        g_primDB = hndl;
    }

    if (g_secDB == INVALID_HANDLE) {
        decl String:err[255];
        g_secDB = SQLite_UseDatabase("hlxbans", err, sizeof err);
        if (g_secDB == INVALID_HANDLE) {
            new bool:fatal = (g_primDB == INVALID_HANDLE);
            hlx_Log("%sSecondary database unreachable (%s).", fatal ? "FATAL: " : "", err);
            if (fatal)
                SetFailState("Cannot reach secondary database. Data integrity cannot be guaranteed.");
        }
    }

    if (g_primDB == INVALID_HANDLE) {
        g_state = RETRY;
        CreateTimer(GetConVarFloat(g_cvRetryInterval), RetryTimer, retryCount+1);
    } else {
        g_state = IDLE;
    }
}

public Action:RetryTimer(Handle:timer, any:retryCount)
{
    SQL_TConnect(ConnectCallback, "hlxbans", retryCount);
}

static bool:StorageAvailable()
{
    return g_state == IDLE || g_state == RETRY;
}

hlx_Check(const String:target[], const String:ip[])
{
    PrintToServer("hlx_Check");
    if (!StorageAvailable())
        return -1;

    if (g_state == IDLE) {
        return Primary_Check(g_primDB, target, ip);
    } else {
        return Secondary_Check(g_secDB, target, ip);
    }
}

hlx_Ban(const String:targetId[], const String:targetNick[], const String:targetIp[], time, const String:reason[], const String:adminId[])
{
    if (!StorageAvailable())
        return -1;

    if (g_state == IDLE) {
        return Primary_Ban(g_primDB, targetId, targetNick, targetIp, time, reason, adminId);
    } else {
        return Secondary_Ban(g_secDB, targetId, targetNick, targetIp, time, reason, adminId);
    }
}

hlx_Unban(const String:target[], const String:reason[], const String:adminId[])
{
    if (!StorageAvailable())
        return -1;

    if (g_state == IDLE) {
        return Primary_Unban(g_primDB, target, reason, adminId);
    } else {
        return Secondary_Unban(g_secDB, target, reason, adminId);
    }
}

hlx_BanIP(const String:address[], const String:reason[], const String:adminId[])
{
    if (!StorageAvailable())
        return -1;

    if (g_state == IDLE) {
        return Primary_BanIP(g_primDB, address, reason, adminId);
    } else {
        return Secondary_BanIP(g_secDB, address, reason, adminId);
    }
}

hlx_Flag(const String:target[], const String:flag[], const String:adminId[])
{
    if (!StorageAvailable())
        return -1;

    decl String:target[32], String:flag[32], AdminId:admin;
    GetNativeString(1, target, sizeof target);
    GetNativeString(2, flag, sizeof flag);
    admin = GetNativeCell(3);

    if (g_state == IDLE) {
        return Primary_Flag(g_primDB, target, flag, admin);
    } else {
        return Secondary_Flag(g_secDB, target, flag, admin);
    }
}

hlx_Unflag(const String:target[], const String:flag[], const String:adminId[])
{
    if (!StorageAvailable())
        return -1;

    if (g_state == IDLE) {
        return Primary_Unflag(g_primDB, target, flag, adminId);
    } else {
        return Secondary_Unflag(g_secDB, target, flag, adminId);
    }
}

hlx_PushChatMessage(const String:target[], const String:message[], bool:teamOnly)
{
    if (!StorageAvailable())
        return -1;
    
    decl String:target[32], String:message[255], bool:teamOnly;
    GetNativeString(1, target, sizeof target);
    GetNativeString(2, message, sizeof message);
    teamOnly = bool:GetNativeCell(3);
    
    if (g_state == IDLE) {
        return Primary_PushChatMessage(g_primDB, target, message, teamOnly);
    } else {
        return Secondary_PushChatMessage(g_secDB, target, message, teamOnly);
    }
}
