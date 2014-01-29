'use strict'

angular.module('LibraryBoxApp')
  .controller 'optionPageCtrl',
    ['$scope','$state','$rootScope','$window','$q','$notify','storage', 'apiUrl', 
    (($scope , $state , $rootScope , $window , $q , $notify , storage, apiUrl) ->
      $rootScope.$state = $state
      $rootScope.$on "$stateChangeStart", ()-> $rootScope.isViewLoading = on
      $rootScope.$on "$stateChangeSuccess", ()-> $rootScope.isViewLoading = off
      $rootScope.$on "$stateChangeError", ()-> $rootScope.isViewLoading = off

      $rootScope.$on "loggedin" , (e,info)->
        info.userIconUrl = info.userIconUrl || ""
        $scope.loginStatus = "loggedin"
        $scope.userIconUrl = info.userIconUrl.replace(/\?sz=\d+/ ,"?sz=30")
        $scope.nickname = info.nickname
        $scope.$apply()

      $window.gapiIsLoaded = ()->
        gapi.auth.init ()->
          loadApiDefer = (api, version, base)->
            d = $q.defer()
            if base
                gapi.client.load api, version, ((e)->
                  $scope.$apply ()-> 
                    d.resolve api
                ), base
            else
                gapi.client.load api, version, (e)->
                  $scope.$apply ()->
                    d.resolve api
            d.promise

          $q.all([
            # loadApiDefer "plus", "v1"
            loadApiDefer "drive", "v2"
            # loadApiDefer "libraries", "v1", apiUrl
            # loadApiDefer "members", "v1", apiUrl
          ]).then ()-> 
            chrome.identity.getAuthToken interactive : on, (token)->
              gapi.auth.setToken "access_token" : token
              $rootScope.loginStatus = "loaded"
              # gapi.client.members.get
              #   userKey : "me"
              # .execute (result)->
              #   if result.code is 404
              #     $notify.info "Please Sign Up", "You are not registered to gas-library-box service.<br> If you want to publish your library to gas-library-box , please sign up."
              #     $scope.loginStatus = "givenRegister"
              #   else
              #     $rootScope.loginUser = result
              #     $rootScope.$emit "loggedin" , result

              #   $rootScope.loggedin = result.code isnt 404

              $rootScope.gapiLoaded = on
              $rootScope.$emit 'gapiLoaded'
              # console.log result
              $scope.$apply()

      $scope.showRegister = ()->
        $state.go "register"
    )]
