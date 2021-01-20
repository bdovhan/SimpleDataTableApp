hub=$(sfdx config:get defaultdevhubusername | awk '/^==|^──|^Name/ {next}{print $2}')
sfdx config:set defaultdevhubusername=$1
default=$(sfdx config:get defaultusername | awk '/^==|^──|^Name/ {next}{print $2}')
sfdx force:org:create -s -d 30 -a o$(( RANDOM % 1000)) -f config/project-scratch-def.json
sfdx force:source:push
sfdx force:org:open

sfdx config:set defaultusername=$default
sfdx config:set defaultdevhubusername=$hub