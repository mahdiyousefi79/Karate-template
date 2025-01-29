@Authentication @ignore
Feature: Get the Authentication APIs

  Background:
    * callonce read('classpath:karate-config.js')
    * call read('sat_creation.feature@GetSatToken')
    * def javaMethods = Java.type("features.javamethods.ReusableMethods");
    * def timezoneInMinutes = javaMethods.getOffsetTimezone()

  @boats @P0 @P1 @ccoat
  Scenario: (1) oat creation
    #get OAT by SAI
    Given url boatsUrl
    Given param tenant = tenant
    And param create = true
    And param app = app
    And header service-account-id = SAI
    And header Authorization = 'Bearer '+satToken
    And retry until responseStatus == 200
    When method get
    Then status 200

    * def OAT = response.accountToken

  @invalidateOAT
  Scenario: Invalidate OAT

    * def paramName = env == 'qa' ? 'accountToken' : 'oat'
    * def httpMethod = env == 'qa' ? 'put' : 'get'
    * def qa_headers = { "Authorization":  '#(qa_oat_authorization)' }
    * def stage_headers = { "x-api-key":  '#(x_api_key)' }
    * def req_headers = env == 'qa' ? qa_headers : stage_headers

    Given url oatInvalidateUrl + "?" + paramName + "=" + accountToken
    And headers req_headers
    And request ""
    And retry until responseStatus == 200
    When method httpMethod

  @invalidateOSAI

  Scenario: Invalidate OSAI
    Given url "https://qhpfghxmqi.execute-api.us-east-1.amazonaws.com"
    Given path "test/invalidatecstore"
    Given param SAI = SAI
    And header x-api-key = cstore_x_api_key
    And retry until responseStatus == 200
    When method get
    Then status 200

  @fabric
  Scenario: Fabric Authenticate and Auto Login

#    * def boats_client_id = env == 'qa' ? qaFMDSClient : stgBoatsClient

    Given url fmdsBaseUrl
    And path 'tenants'
    #ottsf or cstore
    And path tenant
    And path 'partners'
    #comcast or xglobal
    And path partner
    And path 'platforms/stb/admin/login'
    And path OAT
    And header Content-Type = 'text/plain'
    And request  qaFMDSClient
    When method post
    Then status 200

    * def authorizationToken = responseHeaders.token_authorization[0]


  @fabricclassic
  Scenario: Fabric Authenticate and Auto Login Stg

    * def client_id = env == 'qa' ? qaFMDSClient : stgBoatsClient

   #Authenticate
    Given url authUrl
    And header Content-Type = 'text/plain'
    And request client_id
    When method post
    Then status 204

    * def sessionToken =  responseHeaders["SessionToken"]

    #AutoLogin
    Given url autoLoginUrl
    Given path OAT
    And header Accept = 'text/plain'
    And header Content-Type = 'text/plain'
    And header SessionToken = sessionToken
    And request ""
    And retry until responseStatus == 200
    When method post

    * def authorizationToken =  responseHeaders.Authorization[0]

  @fetchBillingAccountId
  Scenario: Fetch Billing Account id from ServiceAccountId

  # fetch X1 BAI
    Given url boatsbaseUrl + "/account/forServiceAccountId"
    And param app = app
    And param tenant = tenant
    And header Accept = "application/json"
    And header Content-Type = "application/json"
    And header service-account-id = SAI
    And header Authorization = 'Bearer ' + satToken
    When method get
    Then status 200
    * def billingAccountId = $response.billingAccountId

  @fetchoats
  Scenario: Fetch oats associated with account

    Given url boatsBaseUrl + "/accounts/forServiceAccountId"
    And param tenant = tenant
    And header Accept = "application/json"
    And header Content-Type = "application/json"
    And header service-account-id = xboId
    And header Authorization = 'Bearer ' + satToken
    When method get
    Then status 200

    * def response = response.results

  @cstore @ignore
  Scenario: Cstore subscription

    Given url fmdscstoreurl
    And path partner
    And path 'platforms/stb/admin/login'
    Given path OAT
    And header Accept = 'text/plain'
    And header Content-Type = 'text/plain'
    And request qaFMDSClient
    When method post
    Then status 200

    * def authorizationToken =  responseHeaders.Authorization[0]

  #subscription
    Given url fmdscstoreurl
    And path partner
    And path 'platforms/stb/users/channels'
    And path channelId
    And path 'subscription'
    Given param timeZoneMinutes = timezoneInMinutes
    And header Accept = 'application/json'
    And header Content-Type = 'text/plain'
    And header Authorization = authorizationToken
    And request ""
    And retry until responseStatus == 200
    When method POST
    Then status 200

  @expire_cstore_sub @ignore
  Scenario: Cstore Subscription immediate expiry

    Given url fmdscstoreurl
    And path partner
    And path 'platforms/stb/users/products'
    And path dailyburnSKU
    And path 'subscription'
    Given param timeZoneMinutes = timezoneInMinutes
    And param immediate = true
    And header Accept = 'application/json'
    And header Content-Type = 'text/plain'
    And header Authorization = authorizationToken
    And retry until responseStatus == 200
    When method DELETE
    Then status 200




