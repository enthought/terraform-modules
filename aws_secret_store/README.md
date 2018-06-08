# aws_secret_store

This module ensures that a bucket exists for secrets for the given
application and deploy environment (e.g. my_app/staging). It creates
KMS key unique to the given application and environment, which will
be used by the secret manager to encrypt and decrypt files.

It also generates a pre-made policy for secret access whose ID is
returned as an output, allowing it to be associated with roles or
instances as needed.

It is designed to be used in conjunction with the ``secrets.py`` module
found in the [brood repo](https://github.com/enthought/brood/blob/master/deploy/docker/stack/secrets.py)
and soon to be distributed as a standalone package.

## Variables

* **namespace:** the application namespace (generally the name of an application)
* **environment:** the deploy environment (e.g. dev, staging, prod)

