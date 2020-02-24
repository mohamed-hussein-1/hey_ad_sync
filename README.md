**Introduction**

Repo to solve the ruby task provided by Heyjobs

**Implementation**

In this task i was required to build a service object that calls external api
and calculate difference between local and remote state

it was implemented into a model and two services

**Campaign** represent local model
**AdSyncService** represent the main service implementation
**ExternalAdService** represent a service that calls the external api

**Assumptions :**

* project doesn't expose api , just a service that could be called and the only way to make sure it works
is through tests
* a sql database is used
* external url is static
* campaign are related to remote using external reference id
* campaign status field of value active maps to enabled of remote and value disabled maps to paused
* in case of api being down or external request could not success , it is the responsibility of the caller to decide what to do

**Requirements :**

* ruby 2.6.5
* bundler >= 2

**Run :**

rake test



**Good Luck**