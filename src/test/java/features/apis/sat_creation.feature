Feature: Get SAT token

  Background:

    * def headersdata = { "Content-Type" : "application/json" , "Accept" : "application/json"};
    * call read('fetchfromaws.feature@FetchSecrets')
    * def env = env

  @GetSatToken
  Scenario: Get SAT token

    * def client_id = env == 'qa' ? qa_client_id : stg_client_id
    * def client_secret = env == 'qa' ? qa_client_secret : stg_client_secret

    Given url saturl
    Given path 'v2/oauth/token'
    And headers headersdata
    And header X-Client-Id = client_id
    And header X-Client-Secret = client_secret
    And request ""
    When method post
    Then status 200
    And match $ contains {access_token: '#notnull'}

    * def satToken = response.access_token

  @GetSatTokenProd
  Scenario: Get SAT token prod
    #Sat token in prod (Used it in the CAS_and_getBE.feature)
    Given url 'https://sat-prod.codebig2.net'
    Given path 'v2/oauth/token'
    And header X-Client-Id = commerce_sat_key_prod
    And header X-Client-Secret = commerce_sat_secret_prod
    And request ""
    When method post
    Then status 200

    * def satTokenProd = response.access_token

