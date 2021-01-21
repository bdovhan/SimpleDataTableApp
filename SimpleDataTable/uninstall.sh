if [ "$1" == 'Base Setup' ]
then
    sfdx force:apex:execute -f apex/deleteData.apex
    sfdx force:package:uninstall -w 500 -p $(sfdx force:package:installed:list | awk -v p="Test App: Data Table" '$0 ~ p {if ($8 ~ /04t/) {print $8} else if ($9 ~ /04t/) { print $9} else { print $7}}')
    sfdx force:package:uninstall -w 500 -p $(sfdx force:package:installed:list | awk -v p="Test App: Simple Data Table" '$0 ~ p {if ($8 ~ /04t/) {print $8} else if ($9 ~ /04t/) { print $9} else { print $7}}')
fi
if [ "$1" == 'Simple Data Table' ]
then
    sfdx force:package:uninstall -w 500 -p $(sfdx force:package:installed:list | awk -v p="Test App: Data Table" '$0 ~ p {if ($8 ~ /04t/) {print $8} else if ($9 ~ /04t/) { print $9} else { print $7}}')
fi
sfdx force:package:uninstall -w 500 -p $(sfdx force:package:installed:list | awk -v p="Test App: $1" '$0 ~ p {if ($8 ~ /04t/) {print $8} else if ($9 ~ /04t/) { print $9} else { print $7}}')

