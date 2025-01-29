@cas_regression
Feature: support for netflix activation url

  Background:

    * call read('sat_creation.feature@GetSatToken')
    * def sleepTime = 10
    * def sleep =
      """
      function(seconds){
      karate.log("Sleeping for "+seconds +" seconds")
        for(i = 0; i <= seconds; i++)
        {
          java.lang.Thread.sleep(1*1000);
        }
      }
      """

    * def uuid =
      """
      function() {
      var uuid = java.util.UUID.randomUUID();
      return uuid.toString();
      }
       """

  Scenario Outline: Get the activation URL with Context Now. Verify that the status returning pending, then proceed to Revoke Entitlement by SAI

    # Get activation Link
    Given url  casbaseUrl
    Given path 'activation/url'
    Given header Authorization = 'Bearer '+satToken
    And header appId = netflixAppId
    And header xboId = xboId
    And header msoPartner = 'comcast'
    And header Content-Type = 'application/json'
    And header transactionId = uuid()
    And request { product: '<productId>', context: 'Now' }
    When method POST
    Then status 200

    * def activationUrl = response.url
    * match activationUrl == '#? _.startsWith("https://www.sandbox.netflix.com/partner/home?ptoken=")'
    * match response.method == 'GET'

    # Get PAI (Internal API)
    Given url casbaseUrl
    Given path 'netflix/pai'
    And header xboId = xboId
    Given header Authorization = 'Bearer '+satToken
    When method get
    Then status 200

    * def PAI = response.replaceAll("[^0-9]", "")

    * call sleep sleepTime

    # Get status
    Given url casbaseUrl
    Given path 'activation/status'
    And header Authorization = 'Bearer '+satToken
    And header Content-Type = 'application/json'
    And header oat = PAI
    When method Get
    Then status 200

    * def filteredResponse = karate.filter(response, function(x){ return x.productId == '<productId>'})

    * match filteredResponse[0].url == activationUrl
    * match filteredResponse[0].productId == '<productId>'

    # Revoke entitlement by SAI
    Given url casbaseUrl
    Given path 'apps/netflix/entitlement/'
    Given path '<productId>'
    And header Authorization = 'Bearer '+satToken
    And header xboId = xboId
    And header Content-Type = 'application/json'
    And header msoPartner = 'comcast'
    When method DELETE
    Then status 204

    Examples:
      | productId |
      | standard  |
#      | premium             |
#      | standardAdSupported |

#  Scenario Outline: Get the activation URL with Context HsdVideo. Verify that the status returning pending, then proceed to Revoke Entitlement by SAI
#
#    # Get activation Link
#    Given url  casbaseUrl
#    Given path 'activation/url'
#    Given header Authorization = 'Bearer '+satToken
#    And header appId = netflixAppId
#    And header xboId = xboId
#    And header msoPartner = 'comcast'
#    And header Content-Type = 'application/json'
#    And header transactionId = uuid()
#    And request { product: '<productId>', context: 'HsdVideo' }
#    When method POST
#    Then status 200
#
#    * def activationUrl = response.url
#    * match activationUrl == '#? _.startsWith("https://www.sandbox.netflix.com/partner/home?ptoken=")'
#    * match response.method == 'GET'
#
#    # Get PAI (Internal API)
#    Given url casbaseUrl
#    Given path 'netflix/pai'
#    And header xboId = xboId
#    Given header Authorization = 'Bearer '+satToken
#    When method get
#    Then status 200
#
#    * def PAI = response.replaceAll("[^0-9]", "")
#
#    * call sleep sleepTime
#
#    # Get status
#    Given url casbaseUrl
#    Given path 'activation/status'
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header oat = PAI
#    When method Get
#    Then status 200
#
#    * def filteredResponse = karate.filter(response, function(x){ return x.productId == '<productId>'})
#
#    * match filteredResponse[0].url == activationUrl
#    * match filteredResponse[0].productId == '<productId>'
#
#    # Revoke entitlement by SAI
#    Given url casbaseUrl
#    Given path 'apps/netflix/entitlement/'
#    Given path '<productId>'
#    And header Authorization = 'Bearer '+satToken
#    And header xboId = xboId
#    And header Content-Type = 'application/json'
#    And header msoPartner = 'comcast'
#    When method DELETE
#    Then status 204
#
#    Examples:
#      | productId |
#      | standard  |
#      | premium             |
#      | standardAdSupported |
#
#  Scenario: Enroll to Netflix with invalid value for the Context
#
#    # Get activation Link
#    Given url  casbaseUrl
#    Given path 'activation/url'
#    Given header Authorization = 'Bearer '+satToken
#    And header appId = netflixAppId
#    And header xboId = xboId
#    And header msoPartner = 'comcast'
#    And header Content-Type = 'application/json'
#    And header transactionId = uuid()
#    And request { product: 'standardAdSupported', context: 'test' }
#    When method POST
#    Then status 500
#
#    # todo: the response is 500 should get 400 with appropriate error response (500 is fine for this launch)
#
#
#  Scenario: Enroll to Netflix with empty value for the Context, It should be success enroll like no context
#
#    # Get activation Link
#    Given url  casbaseUrl
#    Given path 'activation/url'
#    Given header Authorization = 'Bearer '+satToken
#    And header appId = netflixAppId
#    And header xboId = xboId
#    And header msoPartner = 'comcast'
#    And header Content-Type = 'application/json'
#    And header transactionId = uuid()
#    And request { product: 'standardAdSupported', context: '' }
#    When method POST
#    Then status 200
#
#    * def activationUrl = response.url
#    * match activationUrl == '#? _.startsWith("https://www.sandbox.netflix.com/partner/home?ptoken=")'
#    * match response.method == 'GET'
#
#    # Get PAI (Internal API)
#    Given url casbaseUrl
#    Given path 'netflix/pai'
#    And header xboId = xboId
#    Given header Authorization = 'Bearer '+satToken
#    When method get
#    Then status 200
#
#    * def PAI = response.replaceAll("[^0-9]", "")
#
#    * call sleep sleepTime
#
#   # Get status
#    Given url casbaseUrl
#    Given path 'activation/status'
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header oat = PAI
#    When method Get
#    Then status 200
#
#    * def filteredResponse = karate.filter(response, function(x){ return x.productId == 'standardAdSupported'})
#
#    * match filteredResponse[0].url == activationUrl
#    * match filteredResponse[0].productId == 'standardAdSupported'
#    * match filteredResponse[0].context == ""
#
#    # Revoke entitlement by SAI
#    Given url casbaseUrl
#    Given path 'apps/netflix/entitlement/'
#    Given path 'standardAdSupported'
#    And header Authorization = 'Bearer '+satToken
#    And header xboId = xboId
#    And header Content-Type = 'application/json'
#    And header msoPartner = 'comcast'
#    When method DELETE
#    Then status 204
#
#
#  Scenario Outline: Enroll with Context Now, Verify that the status, Switch only context to HsdVideo, Verify the status, then proceed to Revoke Entitlement by SAI
#
#    # Get activation Link
#    Given url  casbaseUrl
#    Given path 'activation/url'
#    Given header Authorization = 'Bearer '+satToken
#    And header appId = netflixAppId
#    And header xboId = xboId
#    And header msoPartner = 'comcast'
#    And header Content-Type = 'application/json'
#    And header transactionId = uuid()
#    And request { product: '<productId>', context: 'Now' }
#    When method POST
#    Then status 200
#
#    * def activationUrl = response.url
#    * match activationUrl == '#? _.startsWith("https://www.sandbox.netflix.com/partner/home?ptoken=")'
#    * match response.method == 'GET'
#
#    # Get PAI (Internal API)
#    Given url casbaseUrl
#    Given path 'netflix/pai'
#    And header xboId = xboId
#    Given header Authorization = 'Bearer '+satToken
#    When method get
#    Then status 200
#
#    * def PAI = response.replaceAll("[^0-9]", "")
#
#    * call sleep sleepTime
#
#    # Get status
#    Given url casbaseUrl
#    Given path 'activation/status'
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header oat = PAI
#    When method Get
#    Then status 200
#
#    * def filteredResponse = karate.filter(response, function(x){ return x.productId == '<productId>'})
#
#    * match filteredResponse[0].url == activationUrl
#    * match filteredResponse[0].productId == '<productId>'
#    * match filteredResponse[0].context == 'Now'
#
#    # Switch context
#    Given url casbaseUrl
#    Given path 'apps/netflix/entitlement/<productId>'
#    And param action.sku = '<productId>'
#    And param context = 'HsdVideo'
#    And header xboId = xboId
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header msoPartner = 'comcast'
#    And request ""
#    When method Post
#    Then status 200
#
#    # Get status
#    Given url casbaseUrl
#    Given path 'activation/status'
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header oat = PAI
#    When method Get
#    Then status 200
#
#    * def filteredResponse = karate.filter(response, function(x){ return x.productId == '<productId>'})
#
#    * match filteredResponse[0].url == activationUrl
#    * match filteredResponse[0].productId == '<productId>'
#    * match filteredResponse[0].context == 'HsdVideo'
#
#    # Revoke entitlement by SAI
#    Given url casbaseUrl
#    Given path 'apps/netflix/entitlement/'
#    Given path '<productId>'
#    And header Authorization = 'Bearer '+satToken
#    And header xboId = xboId
#    And header Content-Type = 'application/json'
#    And header msoPartner = 'comcast'
#    When method DELETE
#    Then status 204
#
#    Examples:
#      | productId |
#      | standard  |
#      | premium             |
#      | standardAdSupported |
#
#
#  Scenario Outline: Enroll with Context HsdVideo, Verify that the status, Switch only context to Now, Verify the status, then proceed to Revoke Entitlement by SAI
#
#    # Get activation Link
#    Given url  casbaseUrl
#    Given path 'activation/url'
#    Given header Authorization = 'Bearer '+satToken
#    And header appId = netflixAppId
#    And header xboId = xboId
#    And header msoPartner = 'comcast'
#    And header Content-Type = 'application/json'
#    And header transactionId = uuid()
#    And request { product: '<productId>', context: 'HsdVideo' }
#    When method POST
#    Then status 200
#
#    * def activationUrl = response.url
#    * match activationUrl == '#? _.startsWith("https://www.sandbox.netflix.com/partner/home?ptoken=")'
#    * match response.method == 'GET'
#
#    # Get PAI (Internal API)
#    Given url casbaseUrl
#    Given path 'netflix/pai'
#    And header xboId = xboId
#    Given header Authorization = 'Bearer '+satToken
#    When method get
#    Then status 200
#
#    * def PAI = response.replaceAll("[^0-9]", "")
#
#    * call sleep sleepTime
#
#    # Get status
#    Given url casbaseUrl
#    Given path 'activation/status'
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header oat = PAI
#    When method Get
#    Then status 200
#
#    * def filteredResponse = karate.filter(response, function(x){ return x.productId == '<productId>'})
#
#    * match filteredResponse[0].url == activationUrl
#    * match filteredResponse[0].productId == '<productId>'
#    * match filteredResponse[0].context == 'HsdVideo'
#
#    # Switch context
#    Given url casbaseUrl
#    Given path 'apps/netflix/entitlement/<productId>'
#    And param action.sku = '<productId>'
#    And param context = 'Now'
#    And header xboId = xboId
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header msoPartner = 'comcast'
#    And request ""
#    When method Post
#    Then status 200
#
#    # Get status
#    Given url casbaseUrl
#    Given path 'activation/status'
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header oat = PAI
#    When method Get
#    Then status 200
#
#    * def filteredResponse = karate.filter(response, function(x){ return x.productId == '<productId>'})
#
#    * match filteredResponse[0].url == activationUrl
#    * match filteredResponse[0].productId == '<productId>'
#    * match filteredResponse[0].context == 'Now'
#
#    # Revoke entitlement by SAI
#    Given url casbaseUrl
#    Given path 'apps/netflix/entitlement/'
#    Given path '<productId>'
#    And header Authorization = 'Bearer '+satToken
#    And header xboId = xboId
#    And header Content-Type = 'application/json'
#    And header msoPartner = 'comcast'
#    When method DELETE
#    Then status 204
#
#    Examples:
#      | productId |
#      | standard  |
#      | premium             |
#      | standardAdSupported |
#
#
#  Scenario: Enroll with standardAdSupported and Context HsdVideo, Verify that the status, Switch Entitlement to premium with context Now, Verify the status, then proceed to Revoke Entitlement by SAI
#
#    # Get activation Link
#    Given url  casbaseUrl
#    Given path 'activation/url'
#    Given header Authorization = 'Bearer '+satToken
#    And header appId = netflixAppId
#    And header xboId = xboId
#    And header msoPartner = 'comcast'
#    And header Content-Type = 'application/json'
#    And header transactionId = uuid()
#    And request { product: 'standardAdSupported', context: 'HsdVideo' }
#    When method POST
#    Then status 200
#
#    * def activationUrl = response.url
#    * match activationUrl == '#? _.startsWith("https://www.sandbox.netflix.com/partner/home?ptoken=")'
#    * match response.method == 'GET'
#
#    # Get PAI (Internal API)
#    Given url casbaseUrl
#    Given path 'netflix/pai'
#    And header xboId = xboId
#    Given header Authorization = 'Bearer '+satToken
#    When method get
#    Then status 200
#
#    * def PAI = response.replaceAll("[^0-9]", "")
#
#    * call sleep sleepTime
#
#    # Get status
#    Given url casbaseUrl
#    Given path 'activation/status'
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header oat = PAI
#    When method Get
#    Then status 200
#
#    * def filteredResponse = karate.filter(response, function(x){ return x.productId == 'standardAdSupported'})
#
#    * match filteredResponse[0].url == activationUrl
#    * match filteredResponse[0].productId == 'standardAdSupported'
#    * match filteredResponse[0].context == 'HsdVideo'
#
#    # Switch context
#    Given url casbaseUrl
#    Given path 'apps/netflix/entitlement/standardAdSupported'
#    And param action.sku = 'premium'
#    And param context = 'Now'
#    And header xboId = xboId
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header msoPartner = 'comcast'
#    And request ""
#    When method Post
#    Then status 200
#
#    # Get status
#    Given url casbaseUrl
#    Given path 'activation/status'
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header oat = PAI
#    When method Get
#    Then status 200
#
#    * def filteredResponse = karate.filter(response, function(x){ return x.productId == 'premium'})
#
#    * match filteredResponse[0].url == activationUrl
#    * match filteredResponse[0].productId == 'premium'
#    * match filteredResponse[0].context == 'Now'
#
#    # Revoke entitlement by SAI
#    Given url casbaseUrl
#    Given path 'apps/netflix/entitlement/'
#    Given path 'premium'
#    And header Authorization = 'Bearer '+satToken
#    And header xboId = xboId
#    And header Content-Type = 'application/json'
#    And header msoPartner = 'comcast'
#    When method DELETE
#    Then status 204
#
#  Scenario: Enroll with standardAdSupported and Context Now, Verify that the status, Switch Entitlement to standard with context HsdVideo, Verify the status, then proceed to Revoke Entitlement by SAI
#
#    # Get activation Link
#    Given url  casbaseUrl
#    Given path 'activation/url'
#    Given header Authorization = 'Bearer '+satToken
#    And header appId = netflixAppId
#    And header xboId = xboId
#    And header msoPartner = 'comcast'
#    And header Content-Type = 'application/json'
#    And header transactionId = uuid()
#    And request { product: 'standardAdSupported', context: 'Now' }
#    When method POST
#    Then status 200
#
#    * def activationUrl = response.url
#    * match activationUrl == '#? _.startsWith("https://www.sandbox.netflix.com/partner/home?ptoken=")'
#    * match response.method == 'GET'
#
#    # Get PAI (Internal API)
#    Given url casbaseUrl
#    Given path 'netflix/pai'
#    And header xboId = xboId
#    Given header Authorization = 'Bearer '+satToken
#    When method get
#    Then status 200
#
#    * def PAI = response.replaceAll("[^0-9]", "")
#
#    * call sleep sleepTime
#
#    # Get status
#    Given url casbaseUrl
#    Given path 'activation/status'
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header oat = PAI
#    When method Get
#    Then status 200
#
#    * def filteredResponse = karate.filter(response, function(x){ return x.productId == 'standardAdSupported'})
#
#    * match filteredResponse[0].url == activationUrl
#    * match filteredResponse[0].productId == 'standardAdSupported'
#    * match filteredResponse[0].context == 'Now'
#
#    # Switch context
#    Given url casbaseUrl
#    Given path 'apps/netflix/entitlement/standardAdSupported'
#    And param action.sku = 'standard'
#    And param context = 'HsdVideo'
#    And header xboId = xboId
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header msoPartner = 'comcast'
#    And request ""
#    When method Post
#    Then status 200
#
#    # Get status
#    Given url casbaseUrl
#    Given path 'activation/status'
#    And header Authorization = 'Bearer '+satToken
#    And header Content-Type = 'application/json'
#    And header oat = PAI
#    When method Get
#    Then status 200
#
#    * def filteredResponse = karate.filter(response, function(x){ return x.productId == 'standard'})
#
#    * match filteredResponse[0].url == activationUrl
#    * match filteredResponse[0].productId == 'standard'
#    * match filteredResponse[0].context == 'HsdVideo'
#
#    # Revoke entitlement by SAI
#    Given url casbaseUrl
#    Given path 'apps/netflix/entitlement/'
#    Given path 'standard'
#    And header Authorization = 'Bearer '+satToken
#    And header xboId = xboId
#    And header Content-Type = 'application/json'
#    And header msoPartner = 'comcast'
#    When method DELETE
#    Then status 204

