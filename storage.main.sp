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

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
    CreateNative("hlx_Ban", Native_Ban);
    CreateNative("hlx_Unban", Native_Ban);
    CreateNative("hlx_BanIP", Native_Ban);
    CreateNative("hlx_Flag", Native_Ban);
    CreateNative("hlx_Unflag", Native_Ban);
    return APLRes_Success;
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