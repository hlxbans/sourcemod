/*
 *	@package HLXBans
 *
 *	Copyright (C) 2011  HLXBans Crew
 *	
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *	
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *	
 *	You should have received a copy of the GNU General Public License
 *	along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *	@author Sleepwalker
 *	@copyright (c) 2012 HLXBans
 *	@version 0.0.0.0001
 *	@License GPLv3
 */

#include <sourcemod>

new const String:hlxbans_version[] = "0.0.0.0001";

public Plugin:myinfo =
{
	name = "HLXBans",
	author = "HLXBans Crew",
	description = "HL & HL2 Banning System",
	version = hlxbans_version,
	url = "http://www.hlxbans.net/"
};

new const String:g_szPrefix[] = "[HLXBans] ";

public OnPluginStart()
{	
	CreateConVar("hlxbans_version", hlxbans_version, _, FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
}