# Migrate from 1GMP to 2GMP Workshop Prerequisites

Git, SFDX CLI tools and at least one Dev Hub org and at least one Org with registered namespace are required for this workshop.

Tools needed:
 - Git (Git Bash for Windows is required for Windows users)
 - SFDX CLI
 - IDE (like Visual Studio Code) which supports SFDX project code format

GitHub user needed:
 - Register a GitHub user if you don't have one
 - Setup SSH Key for your GitHub user

Salesforce organizations needed:
 - Dev Hub org. [You can signup for 30-day DX Trial Org here](https://developer.salesforce.com/promotions/orgs/dx-signup) or you can enable Dev Hub on Developer Edition Org which doesn't have namespace
 - Namespace Org [You can signup for Developer Edition Org here](https://developer.salesforce.com/signup) 
 - Some org or sandbox to install the package

## 1. Prerequisites: Tools

### 1a. Install SFDX CLI:
[Use installers for Windows, MacOS](https://developer.salesforce.com/tools/sfdxcli)
[Follow the Salesforce Guide for Linux installation](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm)

### 1b. Install Git
If you are using Windows, also [install Git Bash for Windows](https://gitforwindows.org/)

### 1c. Register Github user

You need to register a Github user if you don't have one

Go to [Github Sign up page](https://github.com/join) if you don't have an active Github user 

### 1d. Generate SSH Key

It is convenient to use SSH key while working with Github repositories. You can always fork and clone repository using https:// username and password authentication, however, it is better to use ssh key to avoid typing your password every time.

Replace `<your name>` with your credential and run the following script 
`ssh-keygen -t rsa -b 4096 -C "<your name>@softserveinc.com"`

Copy the SSH key to your clipboard. Based on your OS version, you might use either `clip` or `pbcopy` command here
`clip < ~/.ssh/id_rsa.pub` or `pbcopy < ~/.ssh/id_rsa.pub`


Go to [Github: Add New SSH Key](https://github.com/settings/ssh/new)
and paste the key from clipboard there and save

### 1e. Install VS Code

If your IDE doesn't support SFDX Project format, it is a good idea to install VS Code.

Follow [this link](https://code.visualstudio.com/download) to download VS Code for your OS

## 2. Prerequisites: Setup DevHub org

This workshop required DevHub org, so it must be set up

### 2a. Verify if you have already a Dev Hub org setup

Run the following command to determine if you have Default DevHub username set up

`sfdx force:config:get defaultdevhubusername`

If the command response has blank space under Value column, this means that you don't have one and you need setup it using the following steps

|  Name | Value | Success |
| ------------- | ------------- | ------------- |
| defaultdevhubusername | | true  |


### 2b. Choose the org where you can enable Dev Hub feature

You can enabled DevHub feature in your trial production or Developer Edition org without namespace registered. Also Partner Developer Edition org may not be used.

Go to Setup and search for `Dev Hub`.

![Searchning `Dev Hub`](https://github.com/bdovhan/SimpleDataTableApp/blob/master/SimpleDataTable/2gmp-workshop/DevHub.png?raw=true)

If you can't see it or can't find it, your org might not support Dev Hub. You need a different org or register a brand new Developer Edition org or Trailhead org.

[You can signup for 30-day DX Trial Org here](https://developer.salesforce.com/promotions/orgs/dx-signup)

[Alternatively just sign up for usual Developer Edition Org here](https://developer.salesforce.com/signup)

Once you have figured this out, click on the Dev Hub link and switch on the Enable Dev Hub toggle and Enable Unlocked Packages and Second-Generation Managed Packages

![Switching enable Dev Hub toggle input - update required](https://github.com/bdovhan/SimpleDataTableApp/blob/master/SimpleDataTable/2gmp-workshop/DevHub.gif?raw=true)

There are several documentation articles which provide extended information about DevHub setup. Refer to them if you can't figure this out and additional help or guidance is required

[Salesforce DX Developer Guide: Enable Dev Hub Features in Your Org](https://developer.salesforce.com/docs/atlas.en-us.230.0.sfdx_dev.meta/sfdx_dev/sfdx_setup_enable_devhub.htm)

[Salesforce Help: Enable Dev Hub Features in Your Org](https://help.salesforce.com/articleView?id=sfdx_setup_enable_devhub.htm&type=0)

### 2c. Authorize your Dev Hub org for SFDX

Go to CMD on Windows or Terminal in MacOS or Linux and execute the following command where you might replace DH with your own alias for your Dev Hub org

`sfdx force:auth:web:login -d -a DH` 

The browser window should open where you have to login to your Dev Hub org and Authorize SFDX CLI connected app

## 3. Prerequisites: Namespace org

This workshop required Namespace org, so it must be set up.
If you have already Developer Edition org with registered namespace, no action is needed for this step.
Otherwise please [Developer Edition Org here](https://developer.salesforce.com/signup) and register some namespace.

If you haven't connected your namespace org to sfdx, you can do that by executing the command

`sfdx force:auth:web:login -a namespaced_org` 

You can open the namespace package settings by executing sfdx command 

`sfdx force:org:open -p "0A2?setupid=Package" -u namespaced_org`

where `namespaced_org` is the alias of your namespaced org.

and then entering login credentials for your namespaced org.

When the packaging namespace tab open, you can read the namespace prefix from the screen and copy Namespace Prefix from the UI

![Package Types Allowed: Managed and Unmanaged; Managed Package: Test; Namespace Prefix: TestApplication](https://github.com/bdovhan/SimpleDataTableApp/blob/master/SimpleDataTable/2gmp-workshop/TestApplication.png?raw=true)

If you don't have any namespaced org yet, you can just register one. On the Packages tab you will see that there is no Namespace prefix is defined.

![Package Types Allowed: Unmanaged Only; Managed Package: None; Namespace Prefix: None](https://github.com/bdovhan/SimpleDataTableApp/blob/master/SimpleDataTable/2gmp-workshop/NoNamespace.png?raw=true)

If you click Edit button, you can select and define your own namespace here. You don't have to create any first-generation package though

## 4. Prerequisites: Sandbox org

Select some sandbox or developer edition org for package installation test.

This org might coincide with a dev hub or namespace org, but in general case it is better to have some dedicated org.

If you use some production or DX Trial as DX, consider creating a sandbox from it and use it as your sandbox org for package installation test

Execute this command 

`sfdx force:auth:web:login -a sand -r https://test.salesforce.com/` 

where `sand` is the alias for you sandbox org and then entering login credentials for your sandbox.

# Thanks

Now you should be ready for a 1GMP to 2GMP migration workshop.