package features.apis;

import com.intuit.karate.junit5.Karate;

class UsersRunner {
    
    @Karate.Test
    Karate testUsers() {
//        return Karate.run("CAS_netflix_context").relativeTo(getClass());
        return Karate.run("CAS_netflix_context").relativeTo(getClass());
    }
}
