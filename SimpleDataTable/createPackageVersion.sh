buildVersion=$(cat sfdx-project.json | jq '.packageAliases | to_entries | length+1')
install=$(cat template/classes/InstallHandler.cls)
uninstall=$(cat template/classes/UninstallHandler.cls)
echo "${install/<BuildVersion>/$buildVersion}" > force-app/main/default/classes/InstallHandler.cls
echo "${uninstall/<BuildVersion>/$buildVersion}" > force-app/main/default/classes/UninstallHandler.cls

pid=$(sfdx force:package:version:create -d force-app -v $1 -x -w 60 --skipvalidation --postinstallscript InstallHandler --uninstallscript UninstallHandler | awk '$1 ~ /Successfully/ { print $11 }')
echo "Hi client. Created a new Beta test version of installable package https://login.salesforce.com/packaging/installPackage.apexp?p0=$pid

This version includes the following updates:" > message$pid.txt

hub=$(sfdx config:get defaultdevhubusername | awk '/^==|^──|^Name/ {next}{print $2}')
sfdx config:set defaultdevhubusername=$1 

default=$(sfdx config:get defaultusername | awk '/^==|^──|^Name/ {next}{print $2}')
sfdx force:config:set defaultusername=$2

./uninstall.sh
sfdx force:package:install -p $pid -r -w 600
sfdx force:org:open

sfdx config:set defaultusername=$default
sfdx config:set defaultdevhubusername=$hub