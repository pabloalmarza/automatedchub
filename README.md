# automatedchub
# Blackduck Support automation Scrips

A few scripts to automate specific deployment tasks 


# Resetting Blackduck server 

deploy_local.sh Replaces current stack with Blackduck and Alert versions of your choosing:

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `--version, -v` | Blackduck Version to install | `null` |
| `--alert-version, -a` | Blackduck Alert version to install | `null` |
| `--name, -n` | name of the new stack | `null` |

example:

deploy_local.sh -v=2021.2.1 -a=6.4.4 -n=hub


## Generating AWS machine with deployed Blackduck instance

