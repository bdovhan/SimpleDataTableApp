# Migrate from 1GMP to 2GMP Workshop Guide

Read [the Prerequisites section from Readme file here](../README.md)
Git, SFDX CLI tools and at least one Dev Hub org and at least one Org with registered namespace are required for this workshop.

## Agenda

For this workshop, the following steps will be performed.
The code will be split into two subdirectories to divide it into the base 2GMP package and the dependent 2GMP package.
`SimpleDataTableController` class and related entities should be placed into the base 2GMP package
`DataTableController` class and related entities should be placed into the dependent 2GMP package
Then both packages will be installed into some test environment (Dev Hub org) might be reused for this purpose
@NamespaceAccessible annotation should be used in the base package to expose the code for the dependent package.
Both packages will share the same registered namespace.