Public Python Package Template
##############################

This repository provides a template for a pip-installable open-source Python package
deployed using CircleCI to PyPI.

This is a `cookiecutter <https://cookiecutter.readthedocs.io/en/latest/>`__ template that can
be used by `temple <https://github.com/CloverHealth/temple/>`__ to create and manage the
project.

A new open source python package can be started with::

    pip3 install temple
    temple setup git@github.com:CloverHealth/temple-python-public.git

**Note** It is recommended to create a private Python package first with temple and then
convert it to an open source package.

Template Parameters
===================

When calling ``temple setup``, the user will be prompted for template parameters. These parameters
are defined in the cookiecutter.json file and are as follows:

1. ``repo_name``: The name of the repository **and** and name of the python package. The name has to use hyphens instead of underscores for spacing because of Gemfury issues (i.e. ``pip install my-installable-package``).
2. ``module_name``: The name of the Python module that will be imported as a library. Modules must have underscores (i.e. ``import my_installable_package``)
3. ``short_description``: A short description of the project. This will be added as the Github repo description and the description in the `setup.cfg` file. It will also be the description displayed when users do ``temple ls`` to list this project.
4. ``deploy_branch`` (default=master): The branch to which deployments will happen. By default, merging into master will trigger a deploy of a new package.

What Does This Template Provide?
================================

When using this template with ``temple setup git@github.com:CloverHealth/temple-python-public.git``, the ``hooks/pre_gen_project.py``
and ``hooks/post_gen_project.py`` files will be called to bootstrap your Python project.
Once this is complete, the user can take advantage of all of the scaffolding provided by the template,
which includes:

1. Automatic deployment to PyPI when merging into the ``deploy_branch`` (see ``circle.yaml``).
2. Pylint and flake8 integration (see ``setup.cfg`` for pylint and flake8 configuration).
3. Coverage integration (see ``setup.cfg`` for coverage configuration).
4. Automatic version tagging and version bumping using `PBR <https://docs.openstack.org/developer/pbr/>`__.
5. Automatic generation of ChangeLog and AUTHORS files using `PBR <https://docs.openstack.org/developer/pbr/>`__.
6. Automatic generation of a ``__version__`` string in the ``version.py`` file (imported in ``__init__.py``).
7. A makefile for setting up the development environment locally (``make setup``), running tests (``make test``), and
   running validation (``make validate``).
8. A CircleCI file for running tests, doing deployments, and verifying any project made with this template
   remains up to date.
9. A ``.gitignore`` file with defaults for Python, Sublime, Vim, Emacs, Git, Pycharm, and Mac files.
10. Scaffolding for `Sphinx <http://www.sphinx-doc.org/en/stable/index.html>`__ documentation and
    automatic deployment of docs to `ReadTheDocs.org <https://readthedocs.org>`__.

An Important Note to Users
==========================

By using this template for your Python project, you are implicitly engaging in a contract that you will keep your
project up to date with this template whenever it changes. You will know that your project is out of date
when CircleCI runs the ``temple update --check`` command in the ``circle.yaml`` file of the project. When this happens,
you can run ``temple update`` locally in your project repo to pull in the latest updates.

**Note** If you must do a release because of emergency circumstances, comment out ``temple update --check``
in the ``circle.yaml`` file to temporarily bypass the template check.

It is important to keep any changes to the templated files of this project to a minimum, otherwise ``temple update``
will produce diffs that can be difficult to merge. Along with that, minimally editing the templated files ensures
that your Python library project behaves similarly to all of the other ones at Clover. If there is an error in the
templated files or a change that needs to be propagated to every package (e.g. updating Python), then the change should
be made in this template repository.

Please be aware that editing **any** part of this template repository (even this README file) will cause
CircleCI builds to fail for all packages built with this template.
Any changes to the template should not be taken lightly, and ideally multiple changes are merged in at once.

Technical Decisions and How To
==============================

There are quite a few interacting pieces of this template that are described in the following, along with a guide on how
they work within the context of your Python package.

Sphinx Documentation and Autodocs
---------------------------------

This template includes scaffolding for creating documentation with `Sphinx <http://www.sphinx-doc.org/en/stable/index.html>`__,
a tool for creating documentation for Python code. With Sphinx, one writes their documentation as
`ReStructured Text <http://docutils.sourceforge.net/rst.html>`__. The power of Sphix comes from its ability to handle
*directives* to do special tasks with documentation, such as automatically documenting a module or running a piece of
code and showing its output.

We used Sphinx and the `Read the Docs Theme <http://docs.readthedocs.io/en/latest/theme.html>`__ for building and styling
documentation because of its ubiquity in the Python community. Along with that, we chose it because it makes documentation
beautiful and searchable, something we hoped that would make writing documentation more fun for others.

For an example of a project at Clover that makes heavy use of Sphinx, check out the documentation folder for
`pgtest-pgsql <https://github.com/CloverHealth/pytest-pgsql/tree/master/docs>`__.

Remember that one can also perform ``temple ls git@github.com:CloverHealth/temple-python-public.git`` to see a list of
all projects spun up with this template for more examples.

Building docs also comes with this template. In order to build and look at docs locally, one has to first set up the
project with ``make setup`` and then type ``make docs`` to build docs. Docs can be opened with ``make open_docs``.

**Note** Docs are also built during ``make validate`` in order to catch any documentation building errors during
continuous integration.

Library Dependencies
--------------------

In order to add dependencies to your library, add them to ``requirements.txt``. Typically python packages will include
dependencies in ``setup.py`` under the ``install_requires`` attribute. This template uses a package
called `PBR <https://docs.openstack.org/developer/pbr/>`__ that modifies the ``setup.py`` file and gets it to read
requirements from ``requirements.txt``.

While it makes sense to pin dependencies in an application, depedencies should **never** be pinned in the ``requirements.txt``
of a Python library. There are two primary reasons for this:

1. Assume you pin a library (e.g. ``sqlalchemy``) to 1.1.1 in your library. If any application uses your library, it is also
   now forced to use ``sqlalchemy==1.1.1``. Requiring any other version of ``sqlalchemy`` by that application will either
   result in a dependency conflict or in an ambiguous version of ``sqlalchemy`` being used by the library and by the
   application depending on how deployment is orchestrated.
2. Even if one pins a library under a certain version like ``sqlalchemy<1.3``, it can still cause issues. Say that a security
   patch was released and an application must now update ``sqlalchemy`` to 1.3. The problems from the first example will now
   arise, and then maintainers of the library need to edit its dependencies and deploy a new version before the application
   can be safely deployed.

The second option should only be used if you are **certain** that your library breaks under a particular version of a dependency.
Otherwise, one should also leave their dependencies unpinned or use ``>=`` when specifying dependencies.

This template includes tests as part of the released library, meaning the application has the ability to install the package
and run its tests againsts the requirements pinned by the application. This is the preffered way to catch issues with libraries
and their dependencies. 

Versioning
----------

Typically when deploying python packages, one will manually edit the version in a ``setup.py`` file and then go through a
series of steps to tag the version and push it to a package server. This template takes care of all of those steps automatically.

Version management is performed by the `PBR library <https://docs.openstack.org/developer/pbr/>`__. This is a library that is
used by ``setup.py`` and has the following capabilities:

1. Reads all ``setup.py`` settings from the ``setup.cfg`` file.
2. As detailed in the previous section, reads library requirements from a ``requirements.txt`` file.
3. Determines the package version by looking at the most recent tag and incrementing the version based on
   commit messages since the tag(more on this in a bit)
4. Automatically generates an AUTHORS and a ChangeLog file.

PBR's version management eliminates the need for anyone to ever manually bump a version string, and it conforms to
the `Semantic Versioning Spec <http://semver.org/>`__. In order to bump the version of a package, the user can make
commit messages that start with the following in order to bump the version:

1. Commits that start with ``Sem-Ver: bugfix,`` will bump the ``PATCH`` number
   (see the `Semantic Versioning Spec <http://semver.org/>`__ for info on this number and others that follow).
2. Commits that start with ``Sem-Ver: feature,`` or ``Sem-Ver: deprecation,`` will bump the ``MINOR`` number.
3. Commits that start with ``Sem-Ver: api-break,` will bump the ``MAJOR`` number.

If one doesn't include any of these in their commit messages, the ``PATCH`` number will be bumped. If one includes
multiple messages with ``Sem-Ver`` tags, the one that bumps the version by the most will be used.

**Note** When using squash and merge with the Github API, your ``Sem-Ver`` tags on your message should be placed in the
title of your commit message if you want versions to be bumped a certain way.

Deployment
----------

Deployment is performed with the ``deploy.py`` script that is included in the template. The deploy script is executed
by CircleCI whenever the ``deploy_branch`` is merged (master by default). The script does the following:

1. Ensures proper environment variables are set and checks that we are on CircleCI
2. Tags the repository with the new version
3. Creates a standard distribution and a wheel
4. Updates version.py to have the proper version
5. Commits the ChangeLog, AUTHORS, and version.py file
6. Pushes to PyPI
7. Pushes the tags and newly committed files to Github
8. ReadTheDocs will detect the change to the repo and build the latest docs

Pausing Deployment
^^^^^^^^^^^^^^^^^^

In order to pause deployment, either pause the CircleCI project or cancel the build after the deploy branch is merged.

Manually Deploying
^^^^^^^^^^^^^^^^^^

Before doing any manual deployment commands, first type ``pip install -r deploy_requirements.txt`` in your
project folder.

Manually deploying a package is not recommended. In the cases where it must happen, one can do the following
locally in a shell::

    PBR_VERSION=version.to.use python setup.py sdist bdist_wheel

The built packages under the ``dist`` folder can then be manually uploaded to PyPI. If the manually-uploaded
package is an official release that is not temporary, the user should also tag their repo at the version of
the package.

Testing and Validation
======================

Python libraries are set up to use `pytest <http://pytest-django.readthedocs.io/en/latest/>`__ as the test runner and framework.
`coverage <https://coverage.readthedocs.io>`__ is also used to ensure that code meets a minimum testing coverage
requirement. Testing is executed in the ``circle.yaml`` file and can be executed locally with ``make test``.

By default, the template configures that every branch of code is covered by tests in the ``setup.cfg`` file. It
is recommended to not turn off this setting and instead opt for placing ``# pragma: no cover`` comments on
functions or lines of code that do not have any value in being covered by tests. By keeping this setting on,
it helps ensure that any new additions to the library have been tested or have at least been documented to say
that it isn't valuable to test.

For validation, `flake8 <http://flake8.pycqa.org/en/latest/>`__ and `pylint <https://www.pylint.org/>`__
are used to do static analysis of code and perform style linting. These checks are executed in the ``circle.yaml``
file and can be executed locally with ``make validate``.

FAQ
===

Why Use This Template?
----------------------

Using this template ensures that your Python package behaves like all of the other Python packages at Clover,
all the way from local development to documentation to production deployment. Having all of our Python
packages set up, documented, and deployed in similar ways decreases the cognitive load for others using, fixing,
and maintaining your tool.

Using this template also ensures your package is kept up to date with changes at Clover, such as when we
upgrade Python to newer versions or potentially switch our deployment process.

Why Squash and Merge by Default?
--------------------------------

Projects created with this template have Github configured to use squash and merge as the merging strategy.
The main reason for this is because we maintain an automated ChangeLog file of all of the changes for a particular
version. Squash and merge helps keep this file informative and keeps on random commits like ``lint`` from
being displayed. The ChangeLog is automatically included in the documentation for a package. Go check out the
documentation for other packages to see this in action.
