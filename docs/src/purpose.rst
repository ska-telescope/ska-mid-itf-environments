=================================
Purpose and general documentation
=================================

Purpose of the Mid ITF Environments repository
=======================================
TBD

Spectrum Analyser File Access
=============================
The Ansritsu MS2090A Spectrum Analyser in the ITF hosts an FTP server. This allows users to access recordings made on the device remotely. In order to make this access more user friendly, we run `filestash <https://www.filestash.app/>`_. This provides a file browser web frontend to various backends, among them FTP. This is deployed with the ``file-browser`` helm chart.

==========
Deployment
==========

Deployment of Test Equipment
============================
Deployment of Test Equipment Tango Device Servers are mainly done using the ``test-equipment`` namespace.
We have a make target that gives URLs to the deployed software: ``make itf-links``.

Deploying Test Equipment charts for verification
------------------------------------------------
Use the umbrella chart under `charts/test-equipment-verification` to deploy charts that were publihsed to the `Test Equipment Helm Package Registry <https://gitlab.com/ska-telescope/ska-ser-test-equipment/-/packages>`_. Note that these packages are deployed in the Helm Build job and the version number is outputted in the Job logs - example of this can be seen `here <https://gitlab.com/ska-telescope/ska-ser-test-equipment/-/jobs/4768261311>`_.

If you want to change the container image version, you can do so by editing the ``$TE_VERSION`` variable in ``/resources/makefiles/test-equipment-dev.mk``.

Sky Simulator
=============
Deployment of the Sky Simulator Control Tango Device (the RPi-hosted device that switches on and off noise sources, filters and U and V signals) follows directly (but manually) from this deployment, as the SkySimCtl Tango Device needs to be registered on the same Test Equipment namespace. This is achieved by using a triggered pipeline - see `this Confluence page <https://confluence.skatelescope.org/x/0RWKDQ>`_ for details.

Deployment of File Browser
==========================
The spectrum analyser file browser is deployed with the ``file-browser-install`` Makefile target. It is deployed to the ``file-browser`` namespace in the ITF. The configuration file lives in the ``$FILEBROWSER_CONFIG_PATH`` environment variable on Gitlab. For local deployments, an example file is provided at ``charts/file-browser/secrets/example.json``. This doesn't provide access to the Spectrum Analyser FTP server, but does allow you to verify that the deployment is working as expected.
