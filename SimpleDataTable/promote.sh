buildVersion=$(cat sfdx-project.json | jq '.packageAliases | to_entries | length+1')
install=$(cat template/classes/InstallHandler.cls)
install1=${install/<BuildVersion>/$buildVersion}
install2=${install1/<PackageName>/Test App: $3}
echo "${install2/<PostInstallCode>/$5}" > $4/main/default/classes/InstallHandler.cls
uninstall=$(cat template/classes/UninstallHandler.cls)
uninstall1=${uninstall/<BuildVersion>/$buildVersion}
uninstall2=${uninstall1/<PackageName>/Test App: $3}
echo "${uninstall/<PostUninstallCode>/$6}" > $4/main/default/classes/UninstallHandler.cls
cp template/classes/MailUtils.cls $4/main/default/classes/MailUtils.cls
cp template/classes/MailUtils.cls-meta.xml $4/main/default/classes/MailUtils.cls-meta.xml
cp template/classes/InstallHandler.cls-meta.xml $4/main/default/classes/InstallHandler.cls-meta.xml
cp template/classes/UninstallHandler.cls-meta.xml $4/main/default/classes/UninstallHandler.cls-meta.xml

pid=$(sfdx force:package:version:create -x -v $1 -p "Test App: $3"  -w 60 --codecoverage --postinstallscript InstallHandler --uninstallscript UninstallHandler | awk '$1 ~ /Successfully/ { print $11 }')

sfdx force:package:version:promote -n -v $1 -p $pid

coverage=$(sfdx force:package:version:list --verbose -v $1 | awk '/$pid/ { print $18 }')
echo $coverage

echo "Hi client. Created and promoted a Managed Released version of installable package $3 https://login.salesforce.com/packaging/installPackage.apexp?p0=$pid
Coverage = $coverage

This version includes the following updates:" > "message$4Release$pid.txt"

hub=$(sfdx config:get defaultdevhubusername | awk '/^==|^──|^Name/ {next}{print $2}')
sfdx config:set defaultdevhubusername=$1


default=$(sfdx config:get defaultusername | awk '/^==|^──|^Name/ {next}{print $2}')
sfdx force:config:set defaultusername=$2

sfdx force:package:install -p $pid -r -w 600
sfdx force:org:open 

#sfdx force:org:create -s -d 30 -a o$(( RANDOM % 1000)) -f config/project-scratch-def.json
#sfdx force:package:install -p $pid -r -w 600
#sfdx force:org:open

sfdx config:set defaultusername=$default
sfdx config:set defaultdevhubusername=$hub
 