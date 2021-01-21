./uninstall.sh "Base Setup"

basePid=$(cat sfdx-project.json | jq '[.packageAliases | to_entries [] | select(.key | contains("Base Setup")) .value][-1]' -r)

sfdx force:package:install -p $basePid -r -w 600

simplePid=$(cat sfdx-project.json | jq '[.packageAliases | to_entries [] | select(.key | contains("Simple Data Table")) .value][-1]' -r)

sfdx force:package:install -p $simplePid -r -w 600

tablePid=$(cat sfdx-project.json | jq '[.packageAliases | to_entries [] | select(.key | contains(": Data Table")) .value][-1]' -r)

sfdx force:package:install -p $tablePid -r -w 600

namespace = $(cat sfdx-project.json | jq '.namespace' -r)

sfdx force:org:open -p $namespace/SimpleDataApp.app
sfdx force:org:open -p $namespace/DataTableTestApp.app