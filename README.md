# Entando Wildfly 11 s2i

## Description

This is a s2i project based on WildFly 11 release and Entando 4.3.2-rc1 release containing all entando dependencies to build the final artifact to be deployed on the java container.
The project has been adapted to run on OpenShift platform as a cloud-native application ready for horizontal scaling scenarios.

## Environment Variables

To be able to let OpenShift connect to the entando Data layer you have to create at least those environment variables on your OpenShift project:

- PG-USERNAME
- PG-PASSWORD
- PG-ENTANDO-PORT-DB-JNDI-NAME (the entire string defined in jbossBaseSystemConfig.xml configuration file)
- PG-ENTANDO-SERV-DB-JNDI-NAME (the entire string defined in jbossBaseSystemConfig.xml configuration file)
- PG-ENTANDO-PORT-DB-CONNECTION-STRING (host:port/dbName)
- PG-ENTANDO-SERV-DB-CONNECTION-STRING (host:port(dbName)

