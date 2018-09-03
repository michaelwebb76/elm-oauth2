module OAuth.ClientCredentials exposing (Authentication, Credentials, AuthenticationSuccess, AuthenticationError, RequestParts, makeTokenRequest, authenticationErrorDecoder)

{-| The client can request an access token using only its client
credentials (or other supported means of authentication) when the client is requesting access to
the protected resources under its control, or those of another resource owner that have been
previously arranged with the authorization server (the method of which is beyond the scope of
this specification).

There's only one step in this process:

  - The client authenticates itself directly using credentials it owns.

After this step, the client owns an `access_token` that can be used to authorize any subsequent
request.


## Authenticate

@docs Authentication, Credentials, AuthenticationSuccess, AuthenticationError, RequestParts, makeTokenRequest, authenticationErrorDecoder

-}

import Internal as Internal exposing (..)
import Json.Decode as Json
import OAuth exposing (ErrorCode(..), errorCodeFromString)
import Url exposing (Url)
import Url.Builder as Builder


{-| Request configuration for a ClientCredentials authentication

    let authentication =
          { credentials =
          -- Token endpoint of the resource provider
          , url = "<token-endpoint>"
          -- Scopes requested, can be empty
          , scope = ["read:whatever"]
          }

-}
type alias Authentication =
    { credentials : Credentials
    , scope : List String
    , url : Url
    }


{-| Describes a couple of client credentials used for Basic authentication

      { clientId = "<my-client-id>"
      , secret = "<my-client-secret>"
      }

-}
type alias Credentials =
    { clientId : String, secret : String }


type alias AuthenticationSuccess =
    Internal.AuthenticationSuccess


type alias AuthenticationError =
    Internal.AuthenticationError ErrorCode


type alias RequestParts a =
    Internal.RequestParts a


authenticationErrorDecoder : Json.Decoder AuthenticationError
authenticationErrorDecoder =
    Internal.authenticationErrorDecoder (errorDecoder errorCodeFromString)


{-| Builds a the request components required to get a token from client credentials

    let req : Http.Request TokenResponse
        req = makeTokenRequest authentication |> Http.request

-}
makeTokenRequest : Authentication -> RequestParts AuthenticationSuccess
makeTokenRequest { credentials, scope, url } =
    let
        body =
            [ Builder.string "grant_type" "client_credentials" ]
                |> urlAddList "scope" scope
                |> Builder.toQuery
                |> String.dropLeft 1

        headers =
            makeHeaders <|
                Just
                    { clientId = credentials.clientId
                    , secret = credentials.secret
                    }
    in
    makeRequest url headers body
