@RestResource(urlMapping='/whatfix/*')
global with sharing class WhatfixService {
 
    @HttpGet
    global static String fetchUserProfile( ){
        User currentUser = [SELECT Profile.Name, Id FROM User WHERE Id = :UserInfo.getUserId()];
        return json.serialize( new whatfixProfileInfo( currentUser.Id, currentUser.Profile.Name ) );
    }
    global class whatfixProfileInfo{
        global Id userId { get; private set; }
        global String profileName { get; private set; }
        public whatfixProfileInfo( Id userId, String profileName ){
            this.userId = userId;
            this.profileName = profileName;
        }
    }
}