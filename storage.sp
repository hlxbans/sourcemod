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

#include "common"

#include "storage/main.sp"
#include "storage/cache.sp"

/* The storage engine is a state machine:
    - IDLE: waiting for next command
    - LOAD: try to load info from DB (ie. on player connection)
    - STORE: try to store info in DB (ie. saving a ban)
        Both LOAD and STORE can end successfully, returning to IDLE, or fail
        to access the database, going then to the FAIL state.
    - FAIL: register a failure according to the plugin configuration (plugin logs,
            server logs, etc), store to cache and enter RETRY state.
    - RETRY: try to reach the main database again according to the plugin configuration.
             Future actions can cause us to leave RETRY state earlier. If we successfully
             reach the server in RETRY state, we go to the RESTORE state. 
    - RESTORE: transplant cached bans to main database. This can be an expensive operation
               depending on how long the primary db has been unreachable and the server
               activity.

    Note that the secondary storage does little error checking. If we fail to acquire
    a handle to a local SQLite DB, the plugin will die gracefully as there's no way to
    ensure data integrity.
*/
enum StorageState {
    IDLE
    ,LOAD
    ,STORE
    ,FAIL
    ,RETRY
    ,RESTORE
};

new StorageState:g_state = IDLE;

// main is usually MySQL remote and secondary is usually local SQLite
new Handle:g_primDB = INVALID_HANDLE, Handle:g_secDB = INVALID_HANDLE;

new Handle:g_cvRetryInterval;

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
    CreateNative("hlx_Ban", Native_Ban);
    CreateNative("hlx_Unban", Native_Unban);
    CreateNative("hlx_BanIP", Native_BanIP);
    CreateNative("hlx_Flag", Native_Flag);
    CreateNative("hlx_Unflag", Native_Unflag);
    CreateNative("hlx_PushChatMessage", Native_PushChatMessage);
    return APLRes_Success;
}

public OnPluginLoad()
{
    g_state = LOAD;

    g_cvRetryInterval = CreateConVar("hlx_retry_interval", "60", "Interval for retrying database access", .hasMin=true, .min=0.0);

    SQL_TConnect(ConnectCallback, "hlxbans");
}

public ConnectCallback(Handle:owner, Handle:hndl, const String:error[], any:retryCount)
{
    if (hndl == INVALID_HANDLE) {
        if (retryCount > 0)
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
        CreateTimer(GetConVarFloat(g_cvRetryInterval), RetryTimer, retryCount);
    } else {
        g_state = IDLE;
    }
}

public Action:RetryTimer(Handle:timer, any:retryCount)
{
    SQL_TConnect(ConnectCallback, "hlxbans", retryCount+1);
}

stock bool:StorageAvailable()
{
    return g_state == IDLE || g_state == RETRY;
}

// native hlx_Check(String:target[], String:ip[]);
public Native_Check(Handle:plugin, numParams)
{
    if (!StorageAvailable())
        return -1;

    decl String:target[32], String:ip[32];
    GetNativeString(1, target, sizeof target);
    GetNativeString(2, ip, sizeof ip);

    if (g_state == IDLE) {
        return Primary_Check(target, ip);
    } else {
        return Secondary_Check(target, ip);
    }
}

// native hlx_Ban(String:target[], time, String:reason[], AdminId:admin);
public Native_Ban(Handle:plugin, numParams)
{
}

// native hlx_Unban(String:target[], String:reason[], AdminId:admin);
public Native_Unban(Handle:plugin, numParams)
{
}

// native hlx_BanIP(String:address[], String:reason[], AdminId:admin);
public Native_BanIP(Handle:plugin, numParams)
{
}

// native hlx_FlagUser(String:target[], String:flag[], AdminId:admin);
public Native_Flag(Handle:plugin, numParams)
{
}

// native hlx_UnflagUser(String:target[], String:flag[], AdminId:admin);
public Native_Unflag(Handle:plugin, numParams)
{
}

