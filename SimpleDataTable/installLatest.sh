pid=$(cat sfdx-project.json | jq '.packageAliases | to_entries[-1].value ' -r)

sfdx force:package:install -p $pid -r -w 600

sfdx force:org:open
