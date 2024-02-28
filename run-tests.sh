#!/bin/bash
python3 -m pytest --cov=. --cov-report xml:testresults/coverage.xml --junitxml=test-results/pytestreport.xml
