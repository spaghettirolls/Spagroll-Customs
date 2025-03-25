search your project ignis folder for this (e.g. /ProjectIgnis/config/configs.JSON).

open with an lua scripter and search the line that starts with "repos": [ and insert the following code directly below it:

		{
			"url": "https://github.com/Beanbag-EDOPRO/Beanbag-s-Customs",
			"repo_name": "Beanbags",
			"repo_path": "./repositories/beans",
			"should_update": true,
			"should_read": true
		}

DO NOT REMOVE ANY OTHER REPOS
this will mess with EDOPRO's official repositories
always double check for mistakes before saving and enjoy
