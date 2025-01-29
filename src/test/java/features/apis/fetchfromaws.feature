@FetchFromAws
Feature: Fetching values from local properties file

  Background:

    * def javaMethods = Java.type("features.javamethods.ReusableMethods");
    #* def secretpath = env == 'qa' ? "commerce/automation/secrets" : "commerce/stage/automation/secrets"
    * def secretpath = "commerce/automation/secrets"

  @FetchSecrets
  Scenario: Fetch secrets

    * def qa_client_secret = javaMethods.getAwsSecret(secretpath,"commerce.sat.secret.qa")
    * def qa_client_id = javaMethods.getAwsSecret(secretpath,"commerce.sat.key.qa")
    * def stg_client_id = javaMethods.getAwsSecret(secretpath,"commerce.sat.key.stage");
    * def stg_client_secret = javaMethods.getAwsSecret(secretpath,"commerce.sat.secret.stage")
    * def x_api_key = javaMethods.getAwsSecret(secretpath,"commerce.xapi.key")
    * def cstore_x_api_key = javaMethods.getAwsSecret(secretpath,"commerce.cstore.xapi.key")
    * def qaBoatsClient = javaMethods.getAwsSecret(secretpath,"commerce.boats.client.qa")
    * def stgBoatsClient = javaMethods.getAwsSecret (secretpath,"commerce.boats.client.stage")
    * def qaFMDSClient = javaMethods.getAwsSecret (secretpath,"commerce.fmds.data.qa")
    * def cstoreClient = javaMethods.getAwsSecret (secretpath,"commerce.cstore.key")
    * def qa_oat_authorization = javaMethods.getAwsSecret (secretpath,"commerce.qa.invalidationAPI.Authorization")
    * def commerce_sat_key_prod = javaMethods.getAwsSecret (secretpath,"commerce.sat.key.prod")
    * def commerce_sat_secret_prod = javaMethods.getAwsSecret (secretpath,"commerce.sat.secret.prod")

