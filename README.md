# Groove Help Desk Software

## Description

Cog utilities for working with the Groove help desk system. Currently supported commands include:

* `groove:tickets` - list tickets, optionally filtered by state, assignee, or customer
* `groove:ticket` - show details of a single ticket
* `groove:trigger` - handle inbound webhook events for ticket creation from Groove

See the documentation in Cog or in the [bundle config file](https://github.com/cogcmd/groove/blob/master/config.yaml) for more information.

## Dynamic Configuration

The following dynamic configuration values must be configured:

* `GROOVE_API_TOKEN` - Private Token found under Settings -> API in Groove
