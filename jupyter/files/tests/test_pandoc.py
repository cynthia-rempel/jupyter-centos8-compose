# Copyright (c) Jupyter Development Team.
# https://github.com/jupyter/docker-stacks/blob/master/base-notebook/test/test_pandoc.py
# Distributed under the terms of the Modified BSD License.

import logging

import pytest

LOGGER = logging.getLogger(__name__)


def test_pandoc(container):
    """Pandoc shall be able to convert MD to HTML."""
    c = container.run(
        tty=True, command=["start.sh", "bash", "-c", 'echo "**BOLD**" | pandoc']
    )
    c.wait(timeout=10)
    logs = c.logs(stdout=True).decode("utf-8")
    LOGGER.debug(logs)
    assert "<p><strong>BOLD</strong></p>" in logs

