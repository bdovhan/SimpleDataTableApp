pid=$(sfdx force:package:version:create -d force-app -x -v $1 -w 60 --codecoverage --postinstallscript InstallHandler --uninstallscript UninstallHandler | awk '$1 ~ /Successfully/ { print $11 }')

sfdx force:package:version:promote -n -v $1 -p $pid

coverage=$(sfdx force:package:version:list --verbose -v $1 | awk '/$pid/ { print $18 }')
echo $coverage

echo "Hi client. Created and promoted a Managed Released version of installable package for Finalize https://login.salesforce.com/packaging/installPackage.apexp?p0=$pid
Coverage = $coverage

This version includes the following updates:" > messageRelease$pid.txt

hub=$(sfdx config:get defaultdevhubusername | awk '/^==|^──|^Name/ {next}{print $2}')
sfdx config:set defaultdevhubusername=$1


default=$(sfdx config:get defaultusername | awk '/^==|^──|^Name/ {next}{print $2}')
sfdx force:config:set defaultusername=cont

sfdx force:package:install -p $pid -r -w 600
sfdx force:org:open 

sfdx force:org:create -s -d 30 -a o$(( RANDOM % 1000)) -f config/project-scratch-def.json
sfdx force:package:install -p $pid -r -w 600
sfdx force:org:open

sfdx config:set defaultusername=$default
sfdx config:set defaultdevhubusername=$hub
 