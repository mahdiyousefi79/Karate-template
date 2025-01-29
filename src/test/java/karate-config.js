function fn() {
    var env = karate.env;

    karate.log('karate.env system property was ll:', env);

    if (!env) {
        env = 'stage';
    }

    switch (env) {

 	    case 'qa':

            xclassXboId = '881954397461135298';
            xboId = '5481340105705931557';
            boatsBaseUrl = 'https://boatsqa.channelstore.comcast.net/boats';
            fmdsBaseUrl = 'https://fmdsnextcommerceqa.cubits.xidio.net/fmds/api';
            oatInvalidateUrl = "https://boatsqa.channelstore.comcast.net/boats/admin/deactivateOat";

            peacockappId = 'NbcuPeacock_qa';
            netflixAppId = "netflix_qa";

            casbaseUrl = "https://cas.dev.commerce.comcast.com"

        break;

        case 'stage':

            xclassSAI = '4450631607420274433';
            xboId = '4588616755639566735';
            boatsBaseUrl = 'https://boats-stg.codebig2.net';
            fmdsBaseUrl = 'https://stgfmds.cubits.xidio.net/fmds/api';

            peacockappId = 'NbcuPeacock';
            netflixAppId = "netflix"
            appleAppId = 'apple_inc_apple_tv';
            oatInvalidateUrl = "https://tx874no3uj.execute-api.us-east-1.amazonaws.com/test/invalidateOAT";

            casbaseUrl = "https://cas-stg.codebig2.net"

            //
            camsBaseUrl = "https://cams-next-stg.codebig2.net";
            commerceBaseUrl = "https://commerce-service-stg.codebig2.net";



            break;

    }

    var config =
        {
            env: env,
            boatsUrl: boatsBaseUrl  +"/token/forServiceAccountId",
            saturl : "https://sat-prod.codebig2.net",
            CAMSUrl: camsBaseUrl + '/cams/api',
            commerceUrl: commerceBaseUrl+'/commerce',

       retry: {
              count: 5,
              interval: 120000,
              until: function (response) {
              return response.status == 503;
              }
            }
        };

    karate.log('karate.env is:', env);
    // Temporarily set the timeout for all feature files to check whether we can fix the failing test on the pipeline or not.
    karate.configure('connectTimeout', 900000); // 10 times more than default in milliseconds
    karate.configure('readTimeout', 900000); // 10 times more than default in milliseconds


    return config;
}