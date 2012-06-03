Secondary_Check(Handle:db, const String:target[], const String:ip[])
{
	PrintToServer("Secondary_Check");
	return 0;
}

Secondary_Ban(Handle:db, const String:targetId[], const String:targetNick[], const String:targetIp[], time, const String:reason[], const String:adminId[])
{
	PrintToServer("Secondary_Ban: %s | ID: %s | IP: %s | Time: %d | Reason: %s", targetNick, targetId, targetIp, time, reason);
	return 0;
}

Secondary_Unban(Handle:db, String:target[], String:reason[], const String:adminId[])
{
	return 0;
}

Secondary_BanIP(Handle:db, String:address[], String:reason[], const String:adminId[])
{
	return 0;
}

Secondary_Flag(Handle:db, String:target[], String:flag[], const String:adminId[])
{
	return 0;
}

Secondary_Unflag(Handle:db, String:target[], String:flag[], const String:adminId[])
{
	return 0;
}

Secondary_PushChatMessage(Handle:db, String:target[], String:message[], bool:teamOnly)
{
	return 0;
}
