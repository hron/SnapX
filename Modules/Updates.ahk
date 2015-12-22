class UpdateChecker
{
	__New(settings, build)
	{
		this.settings := settings
		this.build := build
		
		if (this.settings.checkForUpdates)
		{
			daysSinceLastUpdate := A_Now
			EnvSub, daysSinceLastUpdate, % this.settings.lastUpdateCheck, Days
Debug.write("Last update check: " this.settings.lastUpdateCheck "; (days:) " daysSinceLastUpdate)

			if (daysSinceLastUpdate >= this.settings.checkForUpdates_IntervalDays)
			{
				this.checkForUpdates()
			}
		}
	}
	
	checkForUpdates()
	{
		updateFound := false
		latestRelease := ""
Debug.write("Checking for updates")
		
		try
		{
			whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			whr.Open("GET", "https://raw.githubusercontent.com/benallred/SnapX/master/Build.ahk", true)
			whr.Send()
			whr.WaitForResponse(10)
			latestRelease := whr.ResponseText
Debug.write("GET succeeded")
		}
		catch
		{
Debug.write("GET failed")
		}
		
Debug.write("Latest: " latestRelease)
		
		if (InStr(latestRelease, "Build := ", true) == 1)
		{
			RegExMatch(latestRelease, "O)version\s*:\s*""(.+?)""", match)
			newVersion := match.Value(1)
Debug.write("Old version: " this.build.version)
Debug.write("New version: " newVersion)

			if (newVersion != this.build.version)
			{
				updateFound := true
				MsgBox, 0x44, % this.settings.programTitle " Update Available", % this.settings.programTitle " version " newVersion " is available.`n`nWould you like to open the download page now?" ; 0x4 = Yes/No; 0x40 = Info
				IfMsgBox Yes
				{
					Run, https://github.com/benallred/SnapX/releases/latest
				}
			}
		}
		
		this.settings.lastUpdateCheck := A_Now
		this.settings.WriteSetting("lastUpdateCheck", "Updates")
		
		return updateFound
	}
}