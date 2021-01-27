hub=$(sfdx config:get defaultdevhubusername | awk '/^==|^──|^Name/ {next}{print $2}')
sfdx config:set defaultdevhubusername=$1
default=$(sfdx config:get defaultusername | awk '/^==|^──|^Name/ {next}{print $2}')
sfdx force:config:set defaultusername=$2

./promote.sh $1 $2 "Base Setup" baseSetup "Setup.default();" "" $3
./promote.sh $1 $2 "Simple Data Table" simpleDataTable "" "" $3
./promote.sh $1 $2 "Data Table" dataTable "" "" $3

namespace=$(cat sfdx-project.json | jq '.namespace' -r)
sfdx force:org:open -p "$namespace/SimpleDataApp.app"
sfdx force:org:open -p "$namespace/DataTableTestApp.app"

sfdx config:set defaultusername=$default
sfdx config:set defaultdevhubusername=$hub