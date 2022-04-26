<p align="center">
    <img alt="Gorilla Logo" src="/assets/img/logo.png" width="180" />
    <h3 align="center">Gorilla</h3>
    <p align="center">A Distributed Lock Service, Set up in Minutes.</p>
    <p align="center">
        <a href="https://github.com/Clevenio/Gorilla/actions/workflows/ci.yml">
            <img src="https://github.com/Clevenio/Gorilla/actions/workflows/ci.yml/badge.svg"/>
        </a>
        <a href="https://github.com/Clevenio/Gorilla/releases">
            <img src="https://img.shields.io/badge/Version-0.1.0-1abc9c.svg">
        </a>
        <a href="https://github.com/Clevenio/Gorilla/blob/master/LICENSE">
            <img src="https://img.shields.io/badge/LICENSE-MIT-orange.svg">
        </a>
    </p>
</p>

Gorilla is a distributed lock service that allows multiple processes or nodes to coordinate and synchronize access to a shared resource or data.


### Getting Started

To install dependencies.

```zsh
$ make deps
```

To create and migrate your database.

```zsh
$ make migrate
```

To start the application.

```zsh
$ make run
```

Now you can visit [localhost:4000](http://localhost:4000) from your browser.

To run test cases:

```zsh
$ make ci
```

To list all commands:

```zsh
$ make
```

To run `postgresql` with `docker`

```zsh
$ docker run -itd \
    -e POSTGRES_USER=gorilla \
    -e POSTGRES_PASSWORD=gorilla \
    -e POSTGRES_DB=gorilla_dev \
    -p 5432:5432 \
    --name postgresql \
    postgres:15.2
```


### Service Endpoints

- **Acquire Lock**: Acquire a lock for a specific resource.

```pre
Endpoint:
    POST /api/v1/locks/{resource}

Request Body:
    {
        "owner": "<unique identifier for the requester>",
        "timeout": "<maximum time (in seconds) the lock can be held>",
        "metadata": "<any additional metadata for the lock>"
    }

Response:
    HTTP/1.1 200 OK
    {
        "id": <The lock ID>,
        "owner": "<The lock owner>",
        "resource": "<The lock resource name>",
        "token": "<A new unique token for the extended lock>",
        "timeout": <Actual time (in seconds) the lock can be held>,
        "metadata": ["list", "of", "metadata"],
        "createdAt": "2023-03-14T18:35:04",
        "updatedAt": "2023-03-14T18:35:04",
        "expireAt": "2023-03-14T19:35:04"
    }

Possible errors:
    HTTP/1.1 409 Conflict: The lock is already held by another owner.
    HTTP/1.1 400 Bad Request: The request is invalid or missing required parameters.
```

- **Release Lock**: Release a lock for a specific resource.

```
Endpoint:
    DELETE /api/v1/locks/{resource}/{token}

Response:
    HTTP/1.1 204 No Content

Possible errors:
    HTTP/1.1 404 Not Found: The token is not associated with any lock for the resource.
```

- **Check Lock Status**: Get the status of a lock for a specific resource.

```
Endpoint:
    GET /api/v1/locks/{resource}/{token}

Response:
    HTTP/1.1 200 OK
    {
        "id": <The lock ID>,
        "owner": "<The lock owner>",
        "resource": "<The lock resource name>",
        "token": "<A new unique token for the extended lock>",
        "timeout": <Actual time (in seconds) the lock can be held>,
        "metadata": ["list", "of", "metadata"],
        "createdAt": "2023-03-14T18:35:04",
        "updatedAt": "2023-03-14T18:35:04",
        "expireAt": "2023-03-14T19:35:04"
    }

Possible errors:
    HTTP/1.1 404 Not Found: The token is not associated with any lock for the resource.
```

- **Extend Lock Time**: Extend the time a lock is held for a specific resource.

```
Endpoint:
    PUT /api/v1/locks/{resource}/{token}

Request Body:
    {
        "timeout": <maximum time (in seconds) the lock can be held>
    }

Response:
    HTTP/1.1 200 OK
    {
        "id": <The lock ID>,
        "owner": "<The lock owner>",
        "resource": "<The lock resource name>",
        "token": "<A new unique token for the extended lock>",
        "timeout": <Actual time (in seconds) the lock can be held>,
        "metadata": ["list", "of", "metadata"],
        "createdAt": "2023-03-14T18:35:04",
        "updatedAt": "2023-03-14T18:35:04",
        "expireAt": "2023-03-14T19:35:04"
    }

Possible errors:
    HTTP/1.1 404 Not Found: The token is not associated with any lock for the resource.
    HTTP/1.1 409 Conflict: The lock is already held by another owner or the extended timeout is less than the remaining time of the lock.
```



### Versioning

For transparency into our release cycle and in striving to maintain backward compatibility, `Gorilla` is maintained under the [Semantic Versioning guidelines](https://semver.org/) and release process is predictable and business-friendly.

See the [Releases section of our GitHub project](https://github.com/clevenio/gorilla/releases) for changelogs for each release version of `Gorilla`. It contains summaries of the most noteworthy changes made in each release. Also see the [Milestones section](https://github.com/clevenio/gorilla/milestones) for the future roadmap.


### Bug tracker

If you have any suggestions, bug reports, or annoyances please report them to our issue tracker at https://github.com/clevenio/gorilla/issues


### Security Issues

If you discover a security vulnerability within `Gorilla`, please send an email to [hello@clivern.com](mailto:hello@clivern.com)


### Contributing

We are an open source, community-driven project so please feel free to join us. see the [contributing guidelines](CONTRIBUTING.md) for more details.


### License

© 2023, Clivern. Released under [MIT License](https://opensource.org/licenses/mit-license.php).

**Gorilla** is authored and maintained by [@clivern](http://github.com/clivern).
