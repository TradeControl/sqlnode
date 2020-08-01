# Trade Control Node

Modelling the physical and financial workflows of a business entity in Sql Server. 

**Purpose:**

- Share with the community a free, practical alternative to conventional MIS and accountancy implementations.
- Introduce a new business framework that is resistant to fraud whilst enabling fine-grained global visibility at transaction level speeds.
- Express the commercial architecture of the business entity as a recursive node, facilitating supply-chain scheduling.
- Demonstrate the author's knowledge of Sql Server, systems design and business control systems to prospective clients.

Trade Control is not a development product or a prototype. Its functionality is materialised and tested in live environments.

## Overview

Trade Control has been created through the application of manufacturing system control techniques to the general problem of managing cash and business activity.  The result is a generic tool that provides real-time information regarding overall business performance and project management.  It is an alternative to asset-based accounting systems which have been designed by accountants to support double entry book-keeping and the legal obligation to present accounts. Trade Control is designed using the methods of Systems Engineering to satisfy the needs of production and work; money is subsequently mapped onto these processes.  Double-entry book-keeping error checks by balancing ledgers. Trade Control error checks against a cash account in the UoA of the presiding jurisdiction. It could be a bank or [crypto account](https://github.com/tradecontrol/tc-bitcoin), although there are no jurisdictions that currently support the latter.

Each instance is called a node because it is designed to be connected to other instances in a network. Inputs perfectly match outputs, so there are no native customer or supplier accounts; no sales, purchase or works orders. Instead demand and supply present a mirror interface and order types are modelled using a principle of cash polarity. Supply-chains are implemented in the [Network repository](https://github.com/tradecontrol/tc-network).

### Book

If you have any interest in technological production and manufacturing, there is a short book that explains the underlying principles and history of Trade Control. It is not necessary to read this in order to use the app, but it will give you a deeper understanding of the schema design, as well as insight into a vital aspect of human endeavour that is often ignored.

[Trade Control Functions](https://www.amazon.co.uk/dp/B0845RQDVD/ref=sr_1_2?keywords=flyleaf&qid=1579879852&s=handmade&sr=1-2) is published by [Flyleaf](https://www.flyleaf.co.uk) for £5.99.

## Installation

For the latest changes and current version, consult the [Change Log](changelog.md)

All schema and business logic dimensions of Trade Control are coded in Sql Server. However, technical knowledge of Sql Server is not required. Each instance is installed and configured by an app.

[Configuration](docs/tc_nodecore_config.md)

Whilst a configured instance contains the totality of schemas, views and business logic that service the app, it is low level, so you will need to use a client to interact with the code. The first release has only one:

[Client](https://github.com/tradecontrol/tc-office)

To connect up the nodes using Ethereum, install the service from the following repository:

[Network](https://github.com/tradecontrol/tc-network)

To use bitcoin as your commercial Unit of Account:

[Bitcoin](https://github.com/tradecontrol/tc-bitcoin)

### Visual Studio Solution

The repository can be opened in Visual Studio from [the VS solution](src/tc-nodecore.sln). 
Add the extensions:

- Visual Studio Installer Projects
- [A Markdown Editor](https://github.com/madskristensen/MarkdownEditor)

## Versioning

Each version has a creation script, identified by a [SemVer](http://semver.org/) number in the form Version.External.Internal. The first digit is the schema version; the second increments when an upgrade necessitates changes to external apps; and the third identifies an internal change to the database. Any increment in the second digit resets the third to 1. A version change resets the second digit and involves a conversion script to transpose the old schema design into the new.

The procedure is handled by a [Configurator](docs/tc_nodecore_config.md). Every release is encapsulated in an upgrade script (*.sql), applied in versioning order to the creation script. To illustrate how the upgrade procedure works, the first release applies two upgrades: one that alters the internal structure of the database, and another that affects clients. 

## T-SQL

Refer to [Coding Practice](docs/tc_coding_practice.md) for the author's approach to schema design and T-Sql.

## Donations

Trade Control is free and Open Source. If you are using the system in your business, why not consider donating? 

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=C55YGUTBJ4N36)

## Licence

The Trade Control Code licence is issued by Trade Control Ltd under a [GNU General Public Licence v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) 

Trade Control Documentation by Trade Control Ltd is licenced under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/) 

![Creative Commons](https://i.creativecommons.org/l/by-sa/4.0/88x31.png) 



