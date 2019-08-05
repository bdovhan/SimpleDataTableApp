sfdx force:org:create -s -d 30 -f config/DE.json -a $1
sfdx force:source:push -f
sfdx force:apex:execute -f apex/defaultSetup.apex
sfdx force:user:create -f config/adminUser.json -a $2
sfdx force:org:open -p c/SimpleDataApp.app -u $2
