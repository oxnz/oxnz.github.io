---
title: Restful API Design
---

>
Representational state transfer (REST) or RESTful web services are one way of providing interoperability between computer systems on the internet. REST-compliant web services allow requesting systems to access and manipulate textual representations of web resources using a uniform and predefined set of stateless operations.

## Table of Contents

* TOC
{:toc}

<!--more-->

## Everything is a resource

Any interaction of a RESTful API is an interaction with a resource. In fact, the API can be considered simply as mapping and endpoint - or, resource identifier (URL) - to a resource. Resources are sources of information, typically documents or services.

Resources can have different representations.

## Design

### Protocol

HTTPS

### Domain

* https://api.example.com
* https://example.com/**api**/

### Versioning

https://api.example.com/**v1**/

### Endpoint

* https://api.example.com/v1/articles
* https://api.example.com/v1/tags

### HTTP Verbs

HTTP Method | Action
------------|-------
GET     | retrieve a representation of a resource without side-effects
HEAD    | retrieves just the resource meta-information (headers)
OPTIONS | returns the actions supported for specified the resource
POST    | used for creating resources
PUT     | (completely) replace an existing resource
PATCH   | Used for updating resources with partial JSON data. For instance, an Issue resource has title and body attributes. A PATCH request may accept one or more of the attributes to update the resource. PATCH is a relatively new and uncommon HTTP verb, so resource endpoints also accept POST requests.
DELETE  | Used for deleting resources

### Filtering

* ?limit=10
* ?offset=10
* ?page=2&size=10
* ?sortedby=name&order=asc
* ?type=article

### Status Codes

### Error Handling

```json
{
    "error": "invalid token"
}
```

### Responses

* GET /collection: list or array
* GET /collection/resource: single object
* POST /collection: return new object
* PUT /collection/resource: return whole object
* PATCH /collection/resource: return whole object
* DELETE /collection/resource: return an empty document

#### HTTP Status Code

```
Status-Code    =
            "100"  ; Section 10.1.1: Continue
          | "101"  ; Section 10.1.2: Switching Protocols
          | "200"  ; Section 10.2.1: OK
          | "201"  ; Section 10.2.2: Created
          | "202"  ; Section 10.2.3: Accepted
          | "203"  ; Section 10.2.4: Non-Authoritative Information
          | "204"  ; Section 10.2.5: No Content
          | "205"  ; Section 10.2.6: Reset Content
          | "206"  ; Section 10.2.7: Partial Content
          | "300"  ; Section 10.3.1: Multiple Choices
          | "301"  ; Section 10.3.2: Moved Permanently
          | "302"  ; Section 10.3.3: Found
          | "303"  ; Section 10.3.4: See Other
          | "304"  ; Section 10.3.5: Not Modified
          | "305"  ; Section 10.3.6: Use Proxy
          | "307"  ; Section 10.3.8: Temporary Redirect
          | "400"  ; Section 10.4.1: Bad Request
          | "401"  ; Section 10.4.2: Unauthorized
          | "402"  ; Section 10.4.3: Payment Required
          | "403"  ; Section 10.4.4: Forbidden
          | "404"  ; Section 10.4.5: Not Found
          | "405"  ; Section 10.4.6: Method Not Allowed
          | "406"  ; Section 10.4.7: Not Acceptable
          | "407"  ; Section 10.4.8: Proxy Authentication Required
          | "408"  ; Section 10.4.9: Request Time-out
          | "409"  ; Section 10.4.10: Conflict
          | "410"  ; Section 10.4.11: Gone
          | "411"  ; Section 10.4.12: Length Required
          | "412"  ; Section 10.4.13: Precondition Failed
          | "413"  ; Section 10.4.14: Request Entity Too Large
          | "414"  ; Section 10.4.15: Request-URI Too Large
          | "415"  ; Section 10.4.16: Unsupported Media Type
          | "416"  ; Section 10.4.17: Requested range not satisfiable
          | "417"  ; Section 10.4.18: Expectation Failed
          | "500"  ; Section 10.5.1: Internal Server Error
          | "501"  ; Section 10.5.2: Not Implemented
          | "502"  ; Section 10.5.3: Bad Gateway
          | "503"  ; Section 10.5.4: Service Unavailable
          | "504"  ; Section 10.5.5: Gateway Time-out
          | "505"  ; Section 10.5.6: HTTP Version not supported
          | extension-code
```

### Hypermedia API

```json
{
  "login": "octocat",
  "id": 1,
  "url": "https://api.github.com/users/octocat",
  "html_url": "https://github.com/octocat",
  "followers_url": "https://api.github.com/users/octocat/followers",
  "following_url": "https://api.github.com/users/octocat/following{/other_user}",
  "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
  "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
  "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
  "organizations_url": "https://api.github.com/users/octocat/orgs",
  "repos_url": "https://api.github.com/users/octocat/repos",
  "events_url": "https://api.github.com/users/octocat/events{/privacy}",
  "received_events_url": "https://api.github.com/users/octocat/received_events",
  "type": "User",
  "public_repos": 2,
  "public_gists": 1,
  "created_at": "2008-01-14T04:33:35Z",
  "updated_at": "2008-01-14T04:33:35Z"
}
```

### Others

#### Authentication

OAuth 2.0

JSON

## Applied to web services

Web service APIs that adhere to the REST architectural constraints are called RESTful APIs.
HTTP-based RESTful APIs are defined with the following aspects:

* Base URL
	* `http://api.example.com/resources/`
* An *internet media type* that defines state transition data elements (e.g. Atom, microformats, application/vnd.collection+json, etc.)
* Standard HTTP methods (e.g. OPTIONS, GET, PUT, POST and DELETE)

### Relationship between URL and HTTP methods

HTTP Method | **Collection** `http://api.example.com/resources/` | **Element** `http://api.example.com/resources/item17/`
GET    | **List** the URIs and perhaps other details of the collection's members. | **Retrieve** a representation of the addressed member of the collection, expressed in an appropriate Internet media type.
PUT    | **Replace** the entire collection with another collection | **Replace** the addressed member of the collection, or if it does not exist, **create** it.
POST   | **Create** a new entry in the collection. The new entry's URI is assigned automatically and is usually returned by the operation. | Not generally used. Treat the addressed member as a collection in its own right and **create** a new entry within it.
DELETE | **Delete** the entire collection. | **Delete** the addressed member of the collection.

## Examples

### Elasticsearch API

[ELK (Elasticsearch Logstash Kibana) Stack](/2016/04/27/elk-elastic-search-logstash-kibana/#operations)

### Github Users API

* get a single user
	* GET /users/:username
* get the authenticated user
	* GET /user
* update the authenticated user
	* PATCH /user
* get all users
	* GET /users

### Github Repositories API

* List your repositories
	* GET /user/repos
* List user repositories
	* GET /users/:username/repos
* List organization repositories
	* GET /orgs/:org/repos
* List all public repositories
	* GET /repositories
* Create
	* POST /user/repos
	* POST /orgs/:org/repos

### Tumblr API

Reblog a post: api.tumblr.com/v2/blog/{blog-identifier}/post/reblog

#### URI Structure

* api.tumblr.com/v2/blog/{blog-identifier}/...
	* api.tumblr.com/v2/blog/{blog-identifier}/posts
	* api.tumblr.com/v2/blog/{blog-identifier}/posts[/type]
* api.tumblr.com/v2/user/

OAuth

URL               | Description
------------------|--------------------------------------------
Request-token URL | https://www.tumblr.com/oauth/request_token
Authorize URL     | https://www.tumblr.com/oauth/authorize
Access-token URL  | https://www.tumblr.com/oauth/access_token

## References

* [Status Code and Reason Phrase](https://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html#sec6.1.1)
