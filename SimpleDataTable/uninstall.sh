sfdx force:apex:execute -f apex/deleteData.apex
sfdx force:package:uninstall -w 500 -p $(sfdx force:package:installed:list | awk '/Test App:/ {if ($8 ~ /04t/) {print $8} else {print $7}}')
