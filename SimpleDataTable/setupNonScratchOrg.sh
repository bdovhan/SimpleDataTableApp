sfdx force:source:deploy -p force-app/main/default -u $1
sfdx force:apex:execute -f apex/defaultSetup.apex -u $1
sfdx force:org:open -p c/SimpleDataApp.app -u $1