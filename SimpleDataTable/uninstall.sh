sfdx force:package:uninstall -w 500 -p $(sfdx force:package:installed:list | awk '/Test/ {print $6}')
