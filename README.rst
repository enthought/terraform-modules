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
