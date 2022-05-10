#!/bin/bash
python -m coverage run -m tests -v && \
python -m coverage report --fail-under ${UNITTEST_THRESHOLD}
