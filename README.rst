########################################################################
Enthought Terraform Modules
########################################################################

This repo contains reusable terraform modules developed in-house at Enthought.


************************************************************************
Using Modules
************************************************************************

1. To use a module from this repository, add a block like the following to
   your terraform code:

   .. code-block:: hcl

        module "cool_thing" {
          source = "git::git@github.com:enthought/terraform-modules.git//cool_thing?ref=v0.1.0"
          var_one = "foo"
          var_two = "bar"
        }

#. Ensure that the ``ref`` above corresponds to an existing release tag in this
   repository.
#. Run ``terraform get`` to acquire the module.
#. Boom! You can now run ``terraform plan`` to see how it will work.


************************************************************************
Developing Modules
************************************************************************

1. Install githooks with::

      cp git_hooks/* .git/hooks

#. Be sure that you have read through Gruntwork's `awesome explainer <https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d>`_
   on terraform modules.
#. Review terraform's docs on `module structure <https://www.terraform.io/docs/modules/create.html#standard-module-structure>`_

    - All modules must have a ``README.md`` file
    - All variables and outputs must have a ``description`` key with a short
      description of their purpose
    - Consider adding an ``examples`` directory with at least one example
      of the intended usage of the module (in a markdown file is fine)

#. Review our local `naming conventions`_
#. Be sure you've read through our hard-won `tips and tricks`_
#. You can verify module functionality during development by including it in a
   terraform file in our terraform repository, using a local file source
   instead of a git source:

   .. code-block:: hcl

        module "thing_in_development" {
            source = "../../terraform-modules/thing_in_development"
            var_one = "foo"
        }


Naming Conventions
========================================================================

* For consistency, module (folder) names, variable names, and output names
  should all be in ``snake_case``

Tips and Tricks
========================================================================

Data Source vs Resource URLs
------------------------------------------------------------------------

In Terraform's documentation, when there are equivalently named resources
and data sources, the only difference between their URLs is that one has a
``/r/`` and the other a ``/d/``. For example, the following are the URLs
for the aws_lb_ resource and data source:

* Resource: https://www.terraform.io/docs/providers/aws/r/lb.html
* Data Source: https://www.terraform.io/docs/providers/aws/d/lb.html

When navigating the docs, it is often easier to just change the single
letter in the URL than to look through the giant list on the left hand
side of all of the data sources and resources for a given provider.

Validate Inputs with the Null Resource
------------------------------------------------------------------------

You can "assert" that variables were defined correctly by using the
``null_resource``. Essentially, you set the ``count`` parameter for the
null resource, so it only evaluates if your desired assertion fails.
Then, you give it a descriptive error message as a dummy parameter. When
this parameter fails to resolve, which will only happen when your assertion
fails, your error message will be displayed to the user, albeit in a bit
of a weird context.

For example, let's say I have a module to which one can either provide
an SSH key to register with AWS or an existing AWS-managed SSH key name:

**variables.tf**

.. code-block:: hcl

    variable "ssh_key_name" {
      default = "none"
    }

    variable "ssh_public_key" {
      default = "none"
    }

**main.tf**

.. code-block:: hcl

    # Validate that one of ssh_public_key or ssh_key is provided
    resource "null_resource" "ssh_key_defined" {
      count = "${var.ssh_public_key == "none" && var.ssh_key_name == "none" ? 1 : 0}"

      "ERROR: One of the ssh_public_key or ssh_key_name variables must be set" = true
    }

    # Validate that not both ssh_public_key and ssh_key were provided
    resource "null_resource" "ssh_key_no_dupes" {
      count = "${var.ssh_public_key != "none" && var.ssh_key_name != "none" ? 1 : 0}"

      "ERROR: You may only define one of the ssh_public_key and ssh_key_name variables" = true
    }



Conditional Resources
------------------------------------------------------------------------

Conditional resources are consistently some of the hardest things to
implement in Terraform modules, but they're often really worthwhile.
Maybe the module default is to set up a new S3 bucket, but you'd like the
module user to be able to specify an existing bucket if they'd like.
Maybe you only want to encrypt a resource if requested by a user.
Unfortunately, there is no silver bullet technique for implementing
resources that may or may not exist, particularly when they involve
intermediate resources are could be used in other resources down the line.
That being said, here are some general pointers that will hopefully be
of use.

Use count for data sources
^^^^^^^^^^^^^^^^^^^^^^^^^^

In addition to resources, data sources can make use of the ``count``
parameter. This can allow you to define a data source that is only
evaluated when some condition is true. However, be careful! You may use
the conditional data source in resources that are bound to the same condition,
but you cannot use it in a ternary expression in an unconditionally evaluated
resource, because both branches of the ternary expression must evaluate
successfully.

Use names rather than IDs if possible
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Certain resources and data sources can be defined and/or accessed by a
user-defined name, rather than a provider-defined ID.

When this is the case, you can define an optional variable to get a
user-specified name of an existing resource. If the variable is not provided,
you can programmatically generate the name and the resource as required
for the module. Either way, you can set a ``local`` variable to either
the user-specified name or your programmatic name, and then just use the
name in references thereafter.

Consider a simple example of a module that can either create a new bucket with
a public policy or attach a public policy to an existing bucket. We can take
an optional ``existing_s3_bucket_name`` variable and use it as follows:

**public_bucket/variables.tf**

.. code-block:: hcl

    variable "namespace" {
      description = "the namespace for the application."
    }

    variable "existing_s3_bucket_name" {
      description = "the name of an existing s3 bucket."
      default = "none"
    }

**public_bucket/main.tf**

.. code-block:: hcl

    locals {
      s3_bucket_name = "${
        var.existing_s3_bucket_name != "none"
          ? var.existing_s3_bucket_name
          : format("%s-public", var.namespace)
      }"
    }

    # Only make the bucket if we need to
    resource "aws_s3_bucket" "new_Bucket" {
      count = "${var.existing_s3_bucket_name == "none" ? 1 : 0}"
      bucket = "${local.s3_bucket_name}
    }

    # Just using the bucket name here, so if the resource is not defined,
    # we are okay.
    data "aws_iam_policy_document" "public_bucket_policy" {
      statement {
        sid = "public-${var.namespace}-policy"
        actions = ["s3:GetObject"]
        effect = "Allow"
        resources = ["arn:aws:s3:::${local.s3_bucket_name}/*"]
        principals {
          type = "*"
          identifiers = ["*"]
        }
      }
    }

    # Still just using the bucket name here, since they function as bucket IDs!
    resource "aws_s3_bucket_policy" "bucket_policy_attachment" {
      bucket = "${local.s3_bucket_name}"
      policy = "${data.aws_iam_policy_document.public_bucket_policy.json}"
    }

**example usage**

.. code-block:: hcl

    # Say we've got a bucket to which we'd like to add this policy.
    resource "aws_s3_bucket" "already_managed_bucket" {
      bucket = "already-managed-bucket"
      acl = "public"
    }

    # Creates a new bucket with the policy attached
    module "new_public_bucket" {
      source = "./public_bucket"
      namespace = "com.my_org.app_one"
    }

    # Attaches the policy to the provided bucket
    module "existing_bucket_ensure_policy" {
      source = "./public_bucket"
      namespace = "com.my_org.app_two"
      existing_s3_bucket_name = "already-managed-bucket"
    }


A non-exhaustive list for resources or data sources for which this is possible
follows:

* aws_lb_
* aws_iam_role_
* aws_kms_key_
* aws_s3_bucket_
* github_repository_
* github_user_


.. _aws_lb: https://www.terraform.io/docs/providers/aws/r/lb.html
.. _aws_iam_role: https://www.terraform.io/docs/providers/aws/r/iam_role.html
.. _aws_kms_key: https://www.terraform.io/docs/providers/aws/d/kms_key.html
.. _aws_s3_bucket: https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#
.. _github_repository: https://www.terraform.io/docs/providers/github/r/repository.html
.. _github_user: https://www.terraform.io/docs/providers/github/d/user.html
